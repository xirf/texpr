# MathML Integration Test

This directory contains integration tests that verify the MathML export
functionality by validating the generated XML with Python.

## How It Works

1. **Dart test** (`mathml_export_integration_test.dart`):

   - Parses LaTeX expressions
   - Exports to MathML
   - Saves test data to `test_cases.json`

2. **Python script** (`verify_mathml_export.py`):
   - Reads `test_cases.json`
   - Validates XML well-formedness
   - Checks for expected MathML elements
   - Verifies content presence
   - Reports pass/fail for each test

## Running the Tests

### Quick Start

```bash
# From project root
./test/integration/mathml/run_tests.sh
```

### Manual Steps

```bash
# 1. Run Dart test to generate JSON
dart test test/integration/mathml/mathml_export_integration_test.dart

# 2. Activate Python venv and run validation
source test/integration/mathml/.venv/bin/activate
python test/integration/mathml/verify_mathml_export.py
```

## Setup (First Time)

The venv should already be set up. If not:

```bash
cd test/integration/mathml
python3 -m venv .venv
# No additional packages needed - uses stdlib xml.etree
```

## Files

- `mathml_export_integration_test.dart` - Dart test that exports test cases
- `verify_mathml_export.py` - Python script that validates MathML
- `test_cases.json` - Generated test data (created by Dart test)
- `verification_results.json` - Results from Python validation
- `.venv/` - Python virtual environment

## Validation Checks

1. **XML Well-formedness**: Parseable by Python's XML parser
2. **Root Element**: Must be `<math>`
3. **Element Presence**: Expected MathML elements found
4. **Content Verification**: Specific content present (symbols, operators)
5. **Non-empty Elements**: `<mn>` and `<mi>` have content

## MathML Elements Tested

| Element        | Description           |
| -------------- | --------------------- |
| `<mn>`         | Numbers               |
| `<mi>`         | Identifiers/variables |
| `<mo>`         | Operators             |
| `<mrow>`       | Row grouping          |
| `<mfrac>`      | Fractions             |
| `<msup>`       | Superscripts          |
| `<msub>`       | Subscripts            |
| `<msqrt>`      | Square roots          |
| `<mroot>`      | N-th roots            |
| `<munder>`     | Under-scripts         |
| `<munderover>` | Under/over scripts    |
| `<mtable>`     | Tables/matrices       |
| `<mtr>`        | Table rows            |
| `<mtd>`        | Table cells           |
