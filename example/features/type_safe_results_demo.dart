import 'package:texpr/texpr.dart';

void main() {
  print('=== Type-Safe Result API Demo ===\n');

  final evaluator = Texpr();

  // Example 1: Using .asNumeric() for numeric results
  print('Example 1: Numeric Results');
  final numericResult = evaluator.evaluate('2 + 3 \\times 4');
  print('Expression: 2 + 3 * 4');
  print('Result type: ${numericResult.runtimeType}');
  print('Value: ${numericResult.asNumeric()}');
  print('Is numeric: ${numericResult.isNumeric}');
  print('Is matrix: ${numericResult.isMatrix}\n');

  // Example 2: Using .asMatrix() for matrix results
  print('Example 2: Matrix Results');
  final matrixResult =
      evaluator.evaluate(r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}');
  print('Expression: Matrix [[1, 2], [3, 4]]');
  print('Result type: ${matrixResult.runtimeType}');
  print('Value: ${matrixResult.asMatrix()}');
  print('Is numeric: ${matrixResult.isNumeric}');
  print('Is matrix: ${matrixResult.isMatrix}\n');

  // Example 3: Pattern matching with switch expression
  print('Example 3: Pattern Matching');
  void analyzeResult(EvaluationResult result, String expr) {
    print('Expression: $expr');
    switch (result) {
      case NumericResult(:final value):
        print('  -> Got a number: $value');
        if (value.isNaN) {
          print('  -> Warning: Result is NaN');
        } else if (value.isInfinite) {
          print('  -> Warning: Result is infinite');
        } else if (value < 0) {
          print('  -> Note: Result is negative');
        }
      case ComplexResult(:final value):
        print('  -> Got a complex number: $value');
        print('  -> Real part: ${value.real}');
        print('  -> Imaginary part: ${value.imaginary}');
      case MatrixResult(:final matrix):
        print('  -> Got a matrix: ${matrix.rows}*${matrix.cols}');
        print('  -> Matrix data: $matrix');
      case VectorResult(:final vector):
        print('  -> Got a vector: ${vector.dimension}');
        print('  -> Vector data: $vector');
    }
    print('');
  }

  analyzeResult(evaluator.evaluate('5^{2}'), '5^2');
  analyzeResult(evaluator.evaluate('-10 + 3'), '-10 + 3');
  analyzeResult(
      evaluator.evaluate(r'\begin{pmatrix} 1 & 0 \\ 0 & 1 \end{pmatrix}'),
      'Identity matrix');

  // Example 4: Type-safe operations
  print('Example 4: Type-Safe Operations');
  final expr1 = evaluator.evaluate('x^{2} + 1', {'x': 3});
  final expr2 = evaluator.evaluate('2 \\times y', {'y': 5});

  // Both are numeric, so we can safely add them
  if (expr1.isNumeric && expr2.isNumeric) {
    final sum = expr1.asNumeric() + expr2.asNumeric();
    print('(x² + 1) + (2y) where x=3, y=5');
    print('= ${expr1.asNumeric()} + ${expr2.asNumeric()}');
    print('= $sum\n');
  }

  // Example 5: Error handling with type checking
  print('Example 5: Safe Type Conversion');
  final result = evaluator.evaluate('\\pi');
  try {
    // This is safe because we know π evaluates to a number
    print('π = ${result.asNumeric()}');
  } catch (e) {
    print('Error accessing numeric value: $e');
  }

  // Try to access as matrix (will throw)
  try {
    print('Trying to access π as matrix...');
    result.asMatrix();
  } on StateError catch (e) {
    print('Caught expected error: $e\n');
  }

  // Example 6: Parse once, evaluate many times
  print('Example 6: Reusing Parsed Expressions');
  final equation = evaluator.parse('x^{2} + 2x + 1');

  for (var x in [1, 2, 3, 4, 5]) {
    final result = evaluator.evaluateParsed(equation, {'x': x.toDouble()});
    print('f($x) = ${result.asNumeric()}');
  }
  print('');

  // Example 7: Working with matrices
  print('Example 7: Matrix Operations');
  final m1 =
      evaluator.evaluate(r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}');
  final m2 =
      evaluator.evaluate(r'\begin{pmatrix} 5 & 6 \\ 7 & 8 \end{pmatrix}');

  if (m1.isMatrix && m2.isMatrix) {
    print('Matrix 1: ${m1.asMatrix()}');
    print('Matrix 2: ${m2.asMatrix()}');

    // Matrix addition
    final sum = evaluator.evaluate(
        r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix} + \begin{pmatrix} 5 & 6 \\ 7 & 8 \end{pmatrix}');
    print('Sum: ${sum.asMatrix()}');

    // Matrix transpose
    final transpose =
        evaluator.evaluate(r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}^T');
    print('Transpose of Matrix 1: ${transpose.asMatrix()}');
  }
}
