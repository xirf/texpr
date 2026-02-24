import 'package:texpr/texpr.dart';

/// Demonstrates the validation API for checking expression syntax.
void main() {
  print('=== LaTeX Math Validation Demo ===\n');

  final evaluator = Texpr();

  // Example 1: Basic parse() + try/catch usage
  print('1. Basic Validation with parse()');
  print('   --------------------------------');
  _checkValid(evaluator, '2 + 3');
  _checkValid(evaluator, r'\sin{0}');
  _checkValid(evaluator, r'x^{2} + 1');
  _checkValid(evaluator, r'\sin{'); // Invalid: unclosed brace
  _checkValid(evaluator, r'\unknown{5}'); // Invalid: unknown command
  print('');

  // Example 2: Detailed validation with parse() errors
  print('2. Detailed Validation with parse() errors');
  print('   -----------------------------------------');
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
    try {
      evaluator.parse(input);
      print('   ✓ "$input" - Valid');
    } on TexprException catch (e) {
      print('   ✗ "$input"');
      print('     Error: ${e.message}');
      if (e.suggestion != null) {
        print('     Suggestion: ${e.suggestion}');
      }
    }
  }
  print('');

  // Example 6: Validation with implicit multiplication
  print('6. Validation with Implicit Multiplication');
  print('   ----------------------------------------');
  final evalWithImplicit = Texpr(allowImplicitMultiplication: true);
  final evalNoImplicit = Texpr(allowImplicitMultiplication: false);

  print('   With implicit multiplication enabled:');
  print('     2x is valid: ${_isParseValid(evalWithImplicit, '2x')}');
  print('     3xy is valid: ${_isParseValid(evalWithImplicit, '3xy')}');

  print('   With implicit multiplication disabled:');
  print('     2x is valid: ${_isParseValid(evalNoImplicit, '2x')}');
  final timesXValid = _isParseValid(evalNoImplicit, r'2 \times x');
  print('     2 \\times x is valid: $timesXValid');
  print('');

  // Example 7: TexprException properties
  print('7. TexprException Properties');
  print('   -------------------------');
  print('   Expression: r\'\\sin{\'');
  try {
    evaluator.parse(r'\sin{');
    print('   isValid: true');
  } on TexprException catch (e) {
    print('   isValid: false');
    print('   errorMessage: ${e.message}');
    print('   position: ${e.position}');
    print('   suggestion: ${e.suggestion}');
    print('   exceptionType: ${e.runtimeType}');
  }
  print('');

  print('=== Demo Complete ===');
}

bool _isParseValid(Texpr evaluator, String expression) {
  try {
    evaluator.parse(expression);
    return true;
  } on TexprException {
    return false;
  }
}

/// Helper function to demonstrate parse() validation
void _checkValid(Texpr evaluator, String expression) {
  final isValid = _isParseValid(evaluator, expression);
  final status = isValid ? '✓' : '✗';
  print('   $status "$expression" - ${isValid ? 'Valid' : 'Invalid'}');
}

/// Helper function to demonstrate parse() error reporting
void _detailedValidation(Texpr evaluator, String expression) {
  try {
    evaluator.parse(expression);
    print('   ✓ "$expression"');
    print('     Status: Valid');
  } on TexprException catch (e) {
    print('   ✗ "$expression"');
    print('     Status: Invalid');
    print('     Error: ${e.message}');
    if (e.position != null) {
      print('     Position: ${e.position}');
    }
    if (e.suggestion != null) {
      print('     Suggestion: ${e.suggestion}');
    }
  }
  print('');
}
