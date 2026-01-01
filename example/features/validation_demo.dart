import 'package:texpr/texpr.dart';

/// Demonstrates the validation API for checking expression syntax.
void main() {
  print('=== LaTeX Math Validation Demo ===\n');

  final evaluator = LatexMathEvaluator();

  // Example 1: Basic isValid() usage
  print('1. Basic Validation with isValid()');
  print('   ---------------------------------');
  _checkValid(evaluator, '2 + 3');
  _checkValid(evaluator, r'\sin{0}');
  _checkValid(evaluator, r'x^{2} + 1');
  _checkValid(evaluator, r'\sin{'); // Invalid: unclosed brace
  _checkValid(evaluator, r'\unknown{5}'); // Invalid: unknown command
  print('');

  // Example 2: Detailed validation with validate()
  print('2. Detailed Validation with validate()');
  print('   ------------------------------------');
  _detailedValidation(evaluator, r'\frac{1}{2}'); // Valid
  _detailedValidation(evaluator, r'\log_{2}{8}'); // Valid
  _detailedValidation(evaluator, r'\sin{'); // Invalid
  _detailedValidation(evaluator, r'(2 + 3'); // Invalid: unclosed parenthesis
  _detailedValidation(evaluator, r'\notreal{x}'); // Invalid: unknown command
  print('');

  // Example 3: Variables are valid in syntax check
  print('3. Variables in Validation');
  print('   -----------------------');
  print('   Note: Variables do NOT cause validation to fail');
  _checkValid(evaluator, 'x');
  _checkValid(evaluator, 'x + y');
  _checkValid(evaluator, r'\sin{x} + \cos{y}');
  print('');

  // Example 4: Complex expressions
  print('4. Complex Expression Validation');
  print('   -----------------------------');
  _detailedValidation(evaluator, r'\sum_{i=1}^{10} i^{2}');
  _detailedValidation(evaluator, r'\int_{0}^{1} x^{2} dx');
  _detailedValidation(evaluator, r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}');
  _detailedValidation(evaluator, r'\lim_{x \to 0} \frac{\sin{x}}{x}');
  print('');

  // Example 5: Form validation example
  print('5. Form Validation Example');
  print('   ----------------------');
  final userInputs = [
    r'\sqrt{16}',
    r'\log{10}',
    r'\sin{',
    r'2x + 3y',
    r'\frac{1}{0}', // Valid syntax, but will fail at evaluation
    r'\unknown{5}',
  ];

  for (final input in userInputs) {
    final result = evaluator.validate(input);
    if (result.isValid) {
      print('   ✓ "$input" - Valid');
    } else {
      print('   ✗ "$input"');
      print('     Error: ${result.errorMessage}');
      if (result.suggestion != null) {
        print('     Suggestion: ${result.suggestion}');
      }
    }
  }
  print('');

  // Example 6: Validation with implicit multiplication
  print('6. Validation with Implicit Multiplication');
  print('   ----------------------------------------');
  final evalWithImplicit =
      LatexMathEvaluator(allowImplicitMultiplication: true);
  final evalNoImplicit = LatexMathEvaluator(allowImplicitMultiplication: false);

  print('   With implicit multiplication enabled:');
  print('     2x is valid: ${evalWithImplicit.isValid('2x')}');
  print('     3xy is valid: ${evalWithImplicit.isValid('3xy')}');

  print('   With implicit multiplication disabled:');
  print('     2x is valid: ${evalNoImplicit.isValid('2x')}');
  final timesXValid = evalNoImplicit.isValid(r'2 \times x');
  print('     2 \\times x is valid: $timesXValid');
  print('');

  // Example 7: Using ValidationResult properties
  print('7. ValidationResult Properties');
  print('   ---------------------------');
  final invalidResult = evaluator.validate(r'\sin{');
  print('   Expression: r\'\\sin{\'');
  print('   isValid: ${invalidResult.isValid}');
  print('   errorMessage: ${invalidResult.errorMessage}');
  print('   position: ${invalidResult.position}');
  print('   suggestion: ${invalidResult.suggestion}');
  print('   exceptionType: ${invalidResult.exceptionType}');
  print('');

  print('=== Demo Complete ===');
}

/// Helper function to demonstrate isValid()
void _checkValid(LatexMathEvaluator evaluator, String expression) {
  final isValid = evaluator.isValid(expression);
  final status = isValid ? '✓' : '✗';
  print('   $status "$expression" - ${isValid ? 'Valid' : 'Invalid'}');
}

/// Helper function to demonstrate validate()
void _detailedValidation(LatexMathEvaluator evaluator, String expression) {
  final result = evaluator.validate(expression);

  if (result.isValid) {
    print('   ✓ "$expression"');
    print('     Status: Valid');
  } else {
    print('   ✗ "$expression"');
    print('     Status: Invalid');
    print('     Error: ${result.errorMessage}');
    if (result.position != null) {
      print('     Position: ${result.position}');
    }
    if (result.suggestion != null) {
      print('     Suggestion: ${result.suggestion}');
    }
  }
  print('');
}
