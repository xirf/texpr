// TeXpr - Typed Evaluations Demo
//
// This example demonstrates the simplified DX-friendly API
// using evaluateNumeric() and evaluateMatrix() convenience methods.
//
// Run with: dart run example/basics/typed_evaluations.dart

import 'package:texpr/texpr.dart';

void main() {
  final evaluator = Texpr();

  print('=== Numeric Evaluation ===');

  // Simple numeric evaluation - no need for .asNumeric()
  print('Basic: 2 + 3 * 4');
  final result1 = evaluator.evaluateNumeric(r'2 + 3 \times 4');
  print('Result: $result1\n');

  // With variables
  print('Variables: x² + 1 where x = 3');
  final result2 = evaluator.evaluateNumeric(r'x^{2} + 1', {'x': 3});
  print('Result: $result2\n');

  // Functions
  print('Functions: sin(π/2)');
  final result3 = evaluator.evaluateNumeric(r'\sin{\frac{\pi}{2}}');
  print('Result: $result3\n');

  // Logarithms
  print('Logarithms: log₂(8)');
  final result4 = evaluator.evaluateNumeric(r'\log_{2}{8}');
  print('Result: $result4\n');

  // Complex expressions
  print('Complex: √(x² + y²) where x = 3, y = 4');
  final result5 = evaluator.evaluateNumeric(
    r'\sqrt{x^{2} + y^{2}}',
    {'x': 3, 'y': 4},
  );
  print('Result: $result5\n');

  print('=== Matrix Evaluation ===');

  // Matrix evaluation - no need for .asMatrix()
  print('Matrix: 2*2 Identity-like matrix');
  final matrix1 = evaluator.evaluateMatrix(
    r'\begin{matrix} 1 & 0 \\ 0 & 1 \end{matrix}',
  );
  print('Result: $matrix1\n');

  print('Matrix: 2*3 Matrix');
  final matrix2 = evaluator.evaluateMatrix(
    r'\begin{matrix} 1 & 2 & 3 \\ 4 & 5 & 6 \end{matrix}',
  );
  print('Result: $matrix2\n');
}
