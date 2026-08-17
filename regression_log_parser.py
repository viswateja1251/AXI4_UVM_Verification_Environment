#!/usr/bin/env python3
"""
AXI4 UVM Regression Log Parser
--------------------------------
Parses Cadence Xcelium / UVM regression logs and generates a
pass/fail + coverage summary report (console table + CSV).

Usage:
    python3 regression_log_parser.py <log_file_or_directory> [--pattern '*.log'] [--csv report.csv]
"""

import argparse
import csv
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional, List


@dataclass
class TestResult:
    test_name: str
    log_file: str
    status: str = "UNKNOWN"      # PASS / FAIL / UNKNOWN
    uvm_info: int = 0
    uvm_warning: int = 0
    uvm_error: int = 0
    uvm_fatal: int = 0
    coverage: Optional[float] = None


# ---------------------------------------------------------------------------
# Regex patterns
# ---------------------------------------------------------------------------
# UVM message prefixes are emitted by the UVM report server as the first
# token on the line (by convention), so anchoring with ^\s* is safe and
# avoids accidentally matching "UVM_ERROR" if it appears inside a printed
# string elsewhere in the log.
RE_UVM_INFO    = re.compile(r'^\s*UVM_INFO')
RE_UVM_WARNING = re.compile(r'^\s*UVM_WARNING')
RE_UVM_ERROR   = re.compile(r'^\s*UVM_ERROR')
RE_UVM_FATAL   = re.compile(r'^\s*UVM_FATAL')

# Common explicit pass/fail banners. This is the part most likely to need
# tuning once we see your actual log — extend this list to match whatever
# your scoreboard's report_phase() actually prints.
RE_PASS = re.compile(r'(TEST\s*PASSED|\*\s*TEST\s*PASSED\s*\*|UVM_TEST_DONE.*PASS)', re.IGNORECASE)
RE_FAIL = re.compile(r'(TEST\s*FAILED|\*\s*TEST\s*FAILED\s*\*|UVM_TEST_DONE.*FAIL)', re.IGNORECASE)

# Coverage line — matches things like:
#   "Total Coverage By Instance (filtered view): 91.67%"
#   "Functional Coverage = 91.67%"
#   "Coverage: 91.67%"
RE_COVERAGE = re.compile(r'Coverage[^:=%\n]*[:=]\s*([\d.]+)\s*%', re.IGNORECASE)


def parse_log(log_path: Path) -> TestResult:
    """Parse a single regression log file into a TestResult."""
    result = TestResult(test_name=log_path.stem, log_file=str(log_path))

    with open(log_path, 'r', errors='ignore') as f:
        for line in f:
            # Xcelium (and other simulators) print a summary footer like:
            #   --- UVM Report Summary ---
            #   UVM_INFO :    8
            #   UVM_WARNING :    1
            # These lines start with the same UVM_INFO/WARNING/ERROR/FATAL
            # prefix as real report lines, so without this guard they'd be
            # double-counted on top of the messages we already tallied.
            if 'UVM Report Summary' in line:
                break

            if RE_UVM_INFO.match(line):
                result.uvm_info += 1
            elif RE_UVM_WARNING.match(line):
                result.uvm_warning += 1
            elif RE_UVM_ERROR.match(line):
                result.uvm_error += 1
            elif RE_UVM_FATAL.match(line):
                result.uvm_fatal += 1

            if RE_PASS.search(line):
                result.status = "PASS"
            elif RE_FAIL.search(line):
                result.status = "FAIL"

            cov_match = RE_COVERAGE.search(line)
            if cov_match:
                result.coverage = float(cov_match.group(1))

    # Fallback: if no explicit PASS/FAIL banner was found, infer status
    # from error/fatal counts. This matters because not every testbench
    # prints a clean banner, and UVM_ERROR == 0 is the de facto pass
    # criterion most regressions actually use.
    if result.status == "UNKNOWN":
        if result.uvm_error == 0 and result.uvm_fatal == 0:
            result.status = "PASS (inferred)"
        else:
            result.status = "FAIL (inferred)"

    return result


def find_logs(path: Path, pattern: str) -> List[Path]:
    """Return a list of log files: a single file, or everything matching
    `pattern` inside a directory (e.g. '*.log')."""
    if path.is_file():
        return [path]
    if path.is_dir():
        return sorted(path.glob(pattern))
    return []


def print_summary(results: List[TestResult]) -> None:
    header = f'{"TEST":<30} {"STATUS":<16} {"ERR":>4} {"WARN":>5} {"COV%":>8}'
    print(header)
    print('-' * len(header))

    for r in results:
        cov_str = f"{r.coverage:.2f}" if r.coverage is not None else "N/A"
        print(f'{r.test_name:<30} {r.status:<16} {r.uvm_error:>4} '
              f'{r.uvm_warning:>5} {cov_str:>8}')

    print('-' * len(header))
    total = len(results)
    passed = sum(1 for r in results if r.status.startswith("PASS"))
    print(f'TOTAL: {total}   PASSED: {passed}   FAILED: {total - passed}')


def write_csv(results: List[TestResult], out_path: str) -> None:
    with open(out_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['test_name', 'status', 'uvm_info', 'uvm_warning',
                          'uvm_error', 'uvm_fatal', 'coverage_pct', 'log_file'])
        for r in results:
            writer.writerow([r.test_name, r.status, r.uvm_info, r.uvm_warning,
                              r.uvm_error, r.uvm_fatal, r.coverage, r.log_file])


def main():
    parser = argparse.ArgumentParser(
        description="Parse UVM/Xcelium regression logs into a pass/fail + coverage summary.")
    parser.add_argument('path', help="A single log file, or a directory of logs")
    parser.add_argument('--pattern', default='*.log',
                         help="Glob pattern when 'path' is a directory (default: *.log)")
    parser.add_argument('--csv', help="Write the summary to this CSV file")
    args = parser.parse_args()

    path = Path(args.path)
    logs = find_logs(path, args.pattern)

    if not logs:
        print(f"No log files found at: {path}", file=sys.stderr)
        sys.exit(2)

    results = [parse_log(log) for log in logs]
    print_summary(results)

    if args.csv:
        write_csv(results, args.csv)
        print(f"\nCSV report written to: {args.csv}")

    # Non-zero exit if anything failed -> lets this plug into a CI pipeline
    failed = sum(1 for r in results if not r.status.startswith("PASS"))
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()
