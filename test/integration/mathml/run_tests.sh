#!/bin/bash
# MathML Integration Test Runner
# Runs both Dart export and Python validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "========================================"
echo "MathML Integration Test"
echo "========================================"
echo ""

# Step 1: Run Dart test to export test cases
echo "Step 1: Running Dart export..."
cd "$PROJECT_ROOT"
dart test test/integration/mathml/mathml_export_integration_test.dart
echo ""

# Step 2: Run Python validation
echo "Step 2: Running Python/XML validation..."
source "$SCRIPT_DIR/.venv/bin/activate"
python "$SCRIPT_DIR/verify_mathml_export.py"
deactivate

echo ""
echo "Integration test complete!"
