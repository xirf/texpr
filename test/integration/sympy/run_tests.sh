#!/bin/bash
# SymPy Integration Test Runner
# Runs both Dart export and Python verification

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

echo "========================================"
echo "SymPy Integration Test"
echo "========================================"
echo ""

# Step 1: Run Dart test to export test cases
echo "Step 1: Running Dart export..."
cd "$PROJECT_ROOT"
dart test test/integration/sympy/sympy_export_integration_test.dart
echo ""

# Step 2: Run Python verification
echo "Step 2: Running Python/SymPy verification..."
source "$SCRIPT_DIR/.venv/bin/activate"
python "$SCRIPT_DIR/verify_sympy_export.py"
deactivate

echo ""
echo "Integration test complete!"
