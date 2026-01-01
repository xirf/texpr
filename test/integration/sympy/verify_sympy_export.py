#!/usr/bin/env python3
"""
SymPy Integration Test Verifier

This script reads test cases exported from the Dart library
and verifies them using SymPy.

Usage:
    source .venv/bin/activate
    python verify_sympy_export.py
"""

import json
import sys
from pathlib import Path

# Import SymPy
try:
    from sympy import *
except ImportError:
    print("Error: SymPy not installed. Run: pip install sympy")
    sys.exit(1)


def evaluate_sympy(code: str, variables: dict) -> float:
    """Evaluate a SymPy expression with given variables."""
    # Create symbol bindings
    local_vars = {'pi': pi, 'E': E, 'I': I, 'oo': oo}
    
    # Create symbols for all variables
    for var_name in variables.keys():
        local_vars[var_name] = symbols(var_name)
    
    # Also add common symbols that might be used
    for name in ['x', 'y', 'z', 't', 'n', 'k', 'i', 'j']:
        if name not in local_vars:
            local_vars[name] = symbols(name)
    
    # Import all SymPy functions
    local_vars.update({
        'sin': sin, 'cos': cos, 'tan': tan,
        'sinh': sinh, 'cosh': cosh, 'tanh': tanh,
        'asin': asin, 'acos': acos, 'atan': atan,
        'sqrt': sqrt, 'root': root, 'log': log, 'exp': exp,
        'Abs': Abs, 'factorial': factorial,
        'binomial': binomial, 'floor': floor, 'ceiling': ceiling,
        'integrate': integrate, 'diff': diff, 'limit': limit,
        'Sum': Sum, 'Product': Product,
        'simplify': simplify,
    })
    
    # Evaluate the SymPy code
    try:
        result = eval(code, {"__builtins__": {}}, local_vars)
    except Exception as e:
        raise ValueError(f"Failed to evaluate '{code}': {e}")
    
    # If we have variables to substitute, do it
    if variables:
        for var_name, var_value in variables.items():
            if hasattr(result, 'subs'):
                result = result.subs(local_vars[var_name], var_value)
    
    # Try to get numeric result
    if hasattr(result, 'evalf'):
        result = result.evalf()
    
    return float(result)


def verify_symbolic(code: str, expected: str) -> tuple[bool, str]:
    """Verify a symbolic expression matches expected output."""
    # Create common symbols
    local_vars = {'pi': pi, 'E': E, 'I': I}
    for name in ['x', 'y', 'z', 't', 'n', 'k']:
        local_vars[name] = symbols(name)
    
    local_vars.update({
        'integrate': integrate, 'diff': diff,
        'simplify': simplify, 'sqrt': sqrt,
    })
    
    try:
        result = eval(code, {"__builtins__": {}}, local_vars)
        if hasattr(result, 'doit'):
            result = result.doit()
        result = simplify(result)
        
        expected_result = eval(expected, {"__builtins__": {}}, local_vars)
        expected_result = simplify(expected_result)
        
        # Check if they're equivalent
        diff_result = simplify(result - expected_result)
        if diff_result == 0:
            return True, str(result)
        else:
            return False, f"Got {result}, expected {expected_result}"
    except Exception as e:
        return False, str(e)


def main():
    # Find the test cases file
    script_dir = Path(__file__).parent
    test_cases_path = script_dir / 'test_cases.json'
    
    if not test_cases_path.exists():
        print(f"Error: {test_cases_path} not found.")
        print("Run the Dart test first to generate test cases:")
        print("  dart test test/integration/sympy/sympy_export_integration_test.dart")
        sys.exit(1)
    
    # Load test cases
    with open(test_cases_path) as f:
        data = json.load(f)
    
    test_cases = data['test_cases']
    print(f"SymPy Integration Test Verification")
    print(f"Generated at: {data['generated_at']}")
    print(f"Total test cases: {len(test_cases)}")
    print("=" * 60)
    print()
    
    passed = 0
    failed = 0
    errors = 0
    results = []
    
    for i, tc in enumerate(test_cases):
        desc = tc['description']
        latex = tc['latex']
        tc_type = tc['type']
        
        if tc_type == 'error':
            print(f"[SKIP] {desc}")
            print(f"       Dart error: {tc['error']}")
            errors += 1
            continue
        
        sympy_code = tc['sympy_code']
        
        if tc_type == 'numeric':
            dart_result = tc['dart_result']
            tolerance = tc.get('tolerance', 1e-10)
            variables = tc.get('variables', {})
            
            try:
                sympy_result = evaluate_sympy(sympy_code, variables)
                diff = abs(sympy_result - dart_result)
                
                if diff <= tolerance:
                    print(f"[PASS] {desc}")
                    print(f"       LaTeX: {latex}")
                    print(f"       Dart: {dart_result}, SymPy: {sympy_result}")
                    passed += 1
                    results.append({'test': desc, 'status': 'pass'})
                else:
                    print(f"[FAIL] {desc}")
                    print(f"       LaTeX: {latex}")
                    print(f"       SymPy code: {sympy_code}")
                    print(f"       Dart: {dart_result}, SymPy: {sympy_result}")
                    print(f"       Diff: {diff} > tolerance {tolerance}")
                    failed += 1
                    results.append({'test': desc, 'status': 'fail', 
                                  'dart': dart_result, 'sympy': sympy_result})
            except Exception as e:
                print(f"[ERROR] {desc}")
                print(f"        LaTeX: {latex}")
                print(f"        SymPy code: {sympy_code}")
                print(f"        Error: {e}")
                errors += 1
                results.append({'test': desc, 'status': 'error', 'error': str(e)})
        
        elif tc_type == 'symbolic':
            expected = tc['expected_sympy_result']
            success, msg = verify_symbolic(sympy_code, expected)
            
            if success:
                print(f"[PASS] {desc}")
                print(f"       LaTeX: {latex}")
                print(f"       Result: {msg}")
                passed += 1
            else:
                print(f"[FAIL] {desc}")
                print(f"       LaTeX: {latex}")
                print(f"       SymPy code: {sympy_code}")
                print(f"       {msg}")
                failed += 1
        
        print()
    
    # Summary
    print("=" * 60)
    print(f"SUMMARY: {passed} passed, {failed} failed, {errors} errors")
    print("=" * 60)
    
    # Write results
    results_path = script_dir / 'verification_results.json'
    with open(results_path, 'w') as f:
        json.dump({
            'passed': passed,
            'failed': failed,
            'errors': errors,
            'results': results,
        }, f, indent=2)
    
    print(f"Results written to: {results_path}")
    
    # Exit with error code if any failures
    sys.exit(0 if failed == 0 else 1)


if __name__ == '__main__':
    main()
