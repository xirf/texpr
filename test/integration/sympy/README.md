# SymPy Integration Test

This directory contains integration tests that verify the SymPy export
functionality by comparing results between the Dart library and Python/SymPy.

## How It Works

1. **Dart test** (`sympy_export_integration_test.dart`):

   - Parses LaTeX expressions
   - Evaluates them with the Dart evaluator
   - Exports to SymPy code
   - Saves test data to `test_cases.json`

2. **Python script** (`verify_sympy_export.py`):
   - Reads `test_cases.json`
   - Evaluates SymPy code with Python
   - Compares results with Dart
   - Reports pass/fail for each test

## Running the Tests

### Quick Start

```bash
# From project root
./test/integration/sympy/run_tests.sh
```

### Manual Steps

```bash
# 1. Run Dart test to generate JSON
dart test test/integration/sympy/sympy_export_integration_test.dart

# 2. Activate Python venv and run verification
source test/integration/sympy/.venv/bin/activate
python test/integration/sympy/verify_sympy_export.py
```

## Setup (First Time)

The venv should already be set up. If not:

```bash
cd test/integration/sympy
python3 -m venv .venv
source .venv/bin/activate
pip install sympy
```

## Files

- `sympy_export_integration_test.dart` - Dart test that exports test cases
- `verify_sympy_export.py` - Python script that verifies with SymPy
- `test_cases.json` - Generated test data (created by Dart test)
- `verification_results.json` - Results from Python verification
- `.venv/` - Python virtual environment with SymPy

## Test Cases Covered

- Basic arithmetic: +, -, *, ÷, ^
- Trigonometry: sin, cos
- Functions: sqrt, cube root, ln, abs
- Variable expressions
- Symbolic calculus: integrals, derivatives
- Combinatorics: binomial, factorial
- Constants: e, π
- Complex expressions: Normal distribution PDF
