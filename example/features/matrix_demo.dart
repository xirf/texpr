import 'package:texpr/texpr.dart';

void main() {
  final evaluator = LatexMathEvaluator();

  print('--- Matrix Evaluation Demo ---\n');

  // 1. Basic Matrix Creation
  print('1. Basic Matrix:');
  final matrixExpr = r'''
    \begin{pmatrix}
      1 & 2 & 3 \\
      4 & 5 & 6
    \end{pmatrix}
  ''';
  final matrix = evaluator.evaluate(matrixExpr);
  print('Expression: $matrixExpr');
  print('Result:\n$matrix\n');

  // 2. Matrix Addition
  print('2. Matrix Addition:');
  final addExpr = r'''
    \begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix} + \begin{matrix} 10 & 20 \\ 30 & 40 \end{matrix}
  ''';
  final addResult = evaluator.evaluate(addExpr);
  print('Expression: $addExpr');
  print('Result:\n$addResult\n');

  // 3. Matrix Multiplication
  print('3. Matrix Multiplication:');
  final multExpr = r'''
    \begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix} * \begin{pmatrix} 2 & 0 \\ 1 & 2 \end{pmatrix}
  ''';
  final multResult = evaluator.evaluate(multExpr);
  print('Expression: $multExpr');
  print('Result:\n$multResult\n');

  // 4. Scalar Multiplication
  print('4. Scalar Multiplication:');
  final scalarExpr = r'''
    5 * \begin{bmatrix} 1 & 0 \\ 0 & 1 \end{bmatrix}
  ''';
  final scalarResult = evaluator.evaluate(scalarExpr);
  print('Expression: $scalarExpr');
  print('Result:\n$scalarResult\n');

  // 5. Matrices with Variables
  print('5. Matrices with Variables:');
  final varExpr = r'''
    \begin{pmatrix} x & 0 \\ 0 & y \end{pmatrix} * \begin{pmatrix} 2 \\ 3 \end{pmatrix}
  ''';
  final varResult = evaluator.evaluate(varExpr, {'x': 5, 'y': 10});
  print('Expression: $varExpr');
  print('Variables: {x: 5, y: 10}');
  print('Result:\n$varResult\n');
}
