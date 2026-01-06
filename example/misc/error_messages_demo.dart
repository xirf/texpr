/* Demonstrates the error messages with position markers and suggestions.

This example shows how the error messages help debug LaTeX expressions. */

import 'package:texpr/texpr.dart';

void main() {
  final evaluator = Texpr();

  print('=== Error Messages with Position Markers Demo ===\n');

  // Example 1: Unclosed brace
  print('Example 1: Unclosed brace');
  print('Expression: \\frac{1{2}\n');
  try {
    evaluator.evaluate(r'\frac{1{2}');
  } on TexprException catch (e) {
    print(e);
  }
  print("\n${'-' * 60}\n");

  // Example 2: Unknown LaTeX command
  print('Example 2: Unknown LaTeX command');
  print('Expression: \\unknowncommand{x}\n');
  try {
    evaluator.evaluate(r'\unknowncommand{x}');
  } on TexprException catch (e) {
    print(e);
  }
  print("\n${'-' * 60}\n");

  // Example 3: Undefined variable
  print('Example 3: Undefined variable');
  print('Expression: x + y + z\n');
  try {
    evaluator.evaluate(r'x + y + z', {'x': 1, 'y': 2});
  } on TexprException catch (e) {
    print(e);
  }
  print("\n${'-' * 60}\n");

  // Example 4: Division by zero
  print('Example 4: Division by zero');
  print('Expression: 5 / 0\n');
  try {
    evaluator.evaluate(r'5 / 0');
  } on TexprException catch (e) {
    print(e);
  }
  print("\n${'-' * 60}\n");

  // Example 5: Unexpected character
  print('Example 5: Unexpected character');
  print('Expression: 2 + 3 @ 4\n');
  try {
    evaluator.evaluate(r'2 + 3 @ 4');
  } on TexprException catch (e) {
    print(e);
  }
  print("\n${'-' * 60}\n");

  // Example 6: Missing closing parenthesis
  print('Example 6: Missing closing parenthesis');
  print('Expression: (2 + 3 \\times 4\n');
  try {
    evaluator.evaluate(r'(2 + 3 \times 4');
  } on TexprException catch (e) {
    print(e);
  }
  print("\n${'-' * 60}\n");

  // Example 7: Matrix environment mismatch
  print('Example 7: Matrix environment mismatch');
  print('Expression: \\begin{pmatrix}1 & 2\\\\3 & 4\\end{bmatrix}\n');
  try {
    evaluator.evaluate(r'\begin{pmatrix}1 & 2\\3 & 4\end{bmatrix}');
  } on TexprException catch (e) {
    print(e);
  }
  print("\n${'-' * 60}\n");

  // Example 8: Validation API with error details
  print('Example 8: Using Validation API');
  print('Expression: \\sin{x\n');
  final result = evaluator.validate(r'\sin{x');
  if (!result.isValid) {
    print('Valid: ${result.isValid}');
    print('Error: ${result.errorMessage}');
    print('Position: ${result.position}');
    print('Suggestion: ${result.suggestion}');
    print('Exception Type: ${result.exceptionType}');
  }
  print("\n${'-' * 60}\n");

  // Example 9: Long expression with error in the middle
  print('Example 9: Error in long expression');
  print('Expression: \\sin{\\pi/2} + \\cos{\\pi} + \\tan{\\unknown}\n');
  try {
    evaluator.evaluate(r'\sin{\pi/2} + \cos{\pi} + \tan{\unknown}');
  } on TexprException catch (e) {
    print(e);
  }
  print("\n${'-' * 60}\n");

  print('=== Demo Complete ===');
}
