import 'package:texpr/texpr.dart';

void main() {
  final engine = SymbolicEngine();

  print('=== Equation Solving Demo ===\n');

  // Example 1: Simple Linear Equations
  print('1. Linear Equations:');

  // 2x + 4 = 0
  var twoX =
      BinaryOp(const NumberLiteral(2), BinaryOperator.multiply, Variable('x'));
  var equation = BinaryOp(twoX, BinaryOperator.add, const NumberLiteral(4));
  var solution = engine.solveLinear(equation, 'x');
  print('   2x + 4 = 0');
  print('   Solution: x = ${solution?.toLatex()}\n');

  // x + 5 = 0
  equation =
      BinaryOp(Variable('x'), BinaryOperator.add, const NumberLiteral(5));
  solution = engine.solveLinear(equation, 'x');
  print('   x + 5 = 0');
  print('   Solution: x = ${solution?.toLatex()}\n');

  // 3x - 6 = 0
  final threeX =
      BinaryOp(const NumberLiteral(3), BinaryOperator.multiply, Variable('x'));
  equation = BinaryOp(threeX, BinaryOperator.subtract, const NumberLiteral(6));
  solution = engine.solveLinear(equation, 'x');
  print('   3x - 6 = 0');
  print('   Solution: x = ${solution?.toLatex()}\n');

  // Example 2: Quadratic Equations
  print('2. Quadratic Equations:');

  // x² - 4 = 0 (difference of squares)
  var xSquared =
      BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
  equation =
      BinaryOp(xSquared, BinaryOperator.subtract, const NumberLiteral(4));
  var solutions = engine.solveQuadratic(equation, 'x');
  print('   x² - 4 = 0');
  print('   Solutions:');
  for (var i = 0; i < solutions.length; i++) {
    print('     x${i + 1} = ${solutions[i].toLatex()}');
  }
  print('');

  // x² + 2x + 1 = 0 (perfect square)
  xSquared =
      BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
  twoX =
      BinaryOp(const NumberLiteral(2), BinaryOperator.multiply, Variable('x'));
  final xSquaredPlus2x = BinaryOp(xSquared, BinaryOperator.add, twoX);
  equation =
      BinaryOp(xSquaredPlus2x, BinaryOperator.add, const NumberLiteral(1));
  solutions = engine.solveQuadratic(equation, 'x');
  print('   x² + 2x + 1 = 0');
  print('   Solutions (double root):');
  for (var i = 0; i < solutions.length; i++) {
    print('     x${i + 1} = ${solutions[i].toLatex()}');
  }
  print('');

  // x² - 5x + 6 = 0
  xSquared =
      BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
  final fiveX =
      BinaryOp(const NumberLiteral(5), BinaryOperator.multiply, Variable('x'));
  final xSquaredMinus5x = BinaryOp(xSquared, BinaryOperator.subtract, fiveX);
  equation =
      BinaryOp(xSquaredMinus5x, BinaryOperator.add, const NumberLiteral(6));
  solutions = engine.solveQuadratic(equation, 'x');
  print('   x² - 5x + 6 = 0');
  print('   Solutions:');
  for (var i = 0; i < solutions.length; i++) {
    print('     x${i + 1} = ${solutions[i].toLatex()}');
  }
  print('');

  // Example 3: Symbolic Solutions
  print('3. Symbolic Quadratic Solutions:');

  // x² + bx + c = 0 (general form with symbolic coefficients)
  xSquared =
      BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
  final bX = BinaryOp(Variable('b'), BinaryOperator.multiply, Variable('x'));
  equation = BinaryOp(
    BinaryOp(xSquared, BinaryOperator.add, bX),
    BinaryOperator.add,
    Variable('c'),
  );
  solutions = engine.solveQuadratic(equation, 'x');
  print('   x² + bx + c = 0');
  print('   Quadratic formula solutions:');
  for (var i = 0; i < solutions.length; i++) {
    print('     x${i + 1} = ${solutions[i].toLatex()}');
  }
  print('');

  // Example 4: Verification
  print('4. Solution Verification:');

  // Solve x² - 9 = 0
  xSquared =
      BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
  equation =
      BinaryOp(xSquared, BinaryOperator.subtract, const NumberLiteral(9));
  solutions = engine.solveQuadratic(equation, 'x');

  print('   x² - 9 = 0');
  print(
      '   Solutions: x = ${solutions[0].toLatex()}, x = ${solutions[1].toLatex()}');
  print('   Verification:');

  final eval = Evaluator();
  for (var sol in solutions) {
    final xValue = eval.evaluate(sol, {}).asNumeric();
    final result = eval.evaluate(equation, {'x': xValue}).asNumeric();
    print('     For x = $xValue: x² - 9 = $result ≈ 0 ✓');
  }

  print('\n=== Demo Complete ===');
}
