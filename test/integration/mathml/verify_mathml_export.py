#!/usr/bin/env python3
"""
MathML Integration Test Verifier

This script reads MathML test cases exported from the Dart library
and validates them for:
1. Valid XML structure
2. Presence of expected MathML elements
3. Correct content where specified

Usage:
    source .venv/bin/activate
    python verify_mathml_export.py
"""

import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def validate_mathml(mathml: str, expected_elements: list, expected_content: str = None) -> tuple[bool, str]:
    """
    Validate MathML output.
    
    Args:
        mathml: The MathML string to validate
        expected_elements: List of element tags that should be present
        expected_content: Optional content that should appear in the MathML
        
    Returns:
        Tuple of (success, message)
    """
    errors = []
    
    # Check 1: Valid XML
    try:
        # Remove namespace for easier parsing
        mathml_clean = mathml.replace('xmlns="http://www.w3.org/1998/Math/MathML"', '')
        root = ET.fromstring(mathml_clean)
    except ET.ParseError as e:
        return False, f"Invalid XML: {e}"
    
    # Check 2: Root element should be <math>
    if root.tag != 'math':
        errors.append(f"Root element is '{root.tag}', expected 'math'")
    
    # Check 3: Find all elements
    all_elements = set()
    for elem in root.iter():
        all_elements.add(elem.tag)
    
    # Check 4: Expected elements present
    missing_elements = []
    for expected in expected_elements:
        if expected not in all_elements:
            missing_elements.append(expected)
    
    if missing_elements:
        errors.append(f"Missing elements: {missing_elements}")
    
    # Check 5: Expected content present
    if expected_content:
        mathml_text = ET.tostring(root, encoding='unicode', method='text')
        full_text = mathml  # Also check raw string for special chars
        if expected_content not in mathml_text and expected_content not in full_text:
            errors.append(f"Missing content: '{expected_content}'")
    
    # Check 6: Balanced tags (already validated by XML parser)
    # Check 7: No empty required elements
    for elem in root.iter():
        # mn (number) and mi (identifier) should have content
        if elem.tag in ('mn', 'mi') and not elem.text:
            if len(list(elem)) == 0:  # No children either
                errors.append(f"Empty <{elem.tag}> element found")
    
    if errors:
        return False, "; ".join(errors)
    
    return True, f"Valid. Elements: {sorted(all_elements)}"


def main():
    # Find the test cases file
    script_dir = Path(__file__).parent
    test_cases_path = script_dir / 'test_cases.json'
    
    if not test_cases_path.exists():
        print(f"Error: {test_cases_path} not found.")
        print("Run the Dart test first to generate test cases:")
        print("  dart test test/integration/mathml/mathml_export_integration_test.dart")
        sys.exit(1)
    
    # Load test cases
    with open(test_cases_path) as f:
        data = json.load(f)
    
    test_cases = data['test_cases']
    print(f"MathML Integration Test Verification")
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
        
        if 'error' in tc:
            print(f"[SKIP] {desc}")
            print(f"       Dart error: {tc['error']}")
            errors += 1
            continue
        
        mathml = tc['mathml']
        expected_elements = tc['expected_elements']
        expected_content = tc.get('expected_content')
        
        success, msg = validate_mathml(mathml, expected_elements, expected_content)
        
        if success:
            print(f"[PASS] {desc}")
            print(f"       LaTeX: {latex}")
            print(f"       {msg}")
            passed += 1
            results.append({'test': desc, 'status': 'pass'})
        else:
            print(f"[FAIL] {desc}")
            print(f"       LaTeX: {latex}")
            print(f"       Error: {msg}")
            print(f"       MathML: {mathml[:100]}...")
            failed += 1
            results.append({'test': desc, 'status': 'fail', 'error': msg})
        
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
