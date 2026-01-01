import 'package:test/test.dart';
import 'package:texpr/src/ast.dart';
import 'package:texpr/src/symbolic/equivalence_checker.dart';

void main() {
  group('EquivalenceChecker', () {
    late EquivalenceChecker checker;

    setUp(() {
      checker = EquivalenceChecker();
    });

    // Structural: a == b
    test('Structural: x + y == x + y', () {
      final a = BinaryOp(Variable('x'), BinaryOperator.add, Variable('y'));
      final b = BinaryOp(Variable('x'), BinaryOperator.add, Variable('y'));
      expect(checker.areEquivalent(a, b, level: EquivalenceLevel.structural),
          isTrue);
    });

    test('Structural: x + y != y + x', () {
      final a = BinaryOp(Variable('x'), BinaryOperator.add, Variable('y'));
      final b = BinaryOp(Variable('y'), BinaryOperator.add, Variable('x'));
      expect(checker.areEquivalent(a, b, level: EquivalenceLevel.structural),
          isFalse);
    });

    // Algebraic: normalize(a) == normalize(b)
    test('Algebraic: x + y == y + x', () {
      final a = BinaryOp(Variable('x'), BinaryOperator.add, Variable('y'));
      final b = BinaryOp(Variable('y'), BinaryOperator.add, Variable('x'));
      expect(checker.areEquivalent(a, b, level: EquivalenceLevel.algebraic),
          isTrue);
    });

    test('Algebraic: (x + y) + z == x + (y + z)', () {
      final a = BinaryOp(
          BinaryOp(Variable('x'), BinaryOperator.add, Variable('y')),
          BinaryOperator.add,
          Variable('z'));
      final b = BinaryOp(Variable('x'), BinaryOperator.add,
          BinaryOp(Variable('y'), BinaryOperator.add, Variable('z')));
      expect(checker.areEquivalent(a, b, level: EquivalenceLevel.algebraic),
          isTrue);
    });

    // Numeric: evaluate(a) == evaluate(b)
    test('Numeric: sin^2(x) + cos^2(x) == 1', () {
      // sin(x)^2 + cos(x)^2
      final sin2 = BinaryOp(FunctionCall('sin', Variable('x')),
          BinaryOperator.power, NumberLiteral(2));
      final cos2 = BinaryOp(FunctionCall('cos', Variable('x')),
          BinaryOperator.power, NumberLiteral(2));
      final sum = BinaryOp(sin2, BinaryOperator.add, cos2);
      final one = NumberLiteral(1);

      // Algebraic fails (requires PythRule)
      // Numeric should pass
      expect(checker.areEquivalent(sum, one, level: EquivalenceLevel.numeric),
          isTrue);
    });

    test('Numeric: x != x + 1', () {
      final a = Variable('x');
      final b = BinaryOp(Variable('x'), BinaryOperator.add, NumberLiteral(1));
      expect(checker.areEquivalent(a, b, level: EquivalenceLevel.numeric),
          isFalse);
    });
  });
}
