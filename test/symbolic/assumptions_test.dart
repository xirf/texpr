import 'package:test/test.dart';
import 'package:texpr/src/ast.dart';
import 'package:texpr/src/symbolic/symbolic_engine.dart';
import 'package:texpr/src/symbolic/assumptions.dart';

void main() {
  group('Assumptions System', () {
    test('Propagation of properties', () {
      final assumptions = Assumptions();
      assumptions.assume('x', Assumption.positive);

      expect(assumptions.check('x', Assumption.positive), isTrue);
      expect(
          assumptions.check('x', Assumption.nonNegative), isTrue); // Propagated
      expect(assumptions.check('x', Assumption.real), isTrue); // Propagated
      expect(assumptions.check('x', Assumption.negative), isFalse);
    });

    test('Engine integration with PowerPowerRule', () {
      final engine = SymbolicEngine();
      final x = Variable('x');

      // (x^2)^0.5
      // Without assumption, this should NOT simplify to x (because x could be negative, result would be |x|)
      // Simple rule requires x >= 0 to simplify at all.
      final expr = BinaryOp(BinaryOp(x, BinaryOperator.power, NumberLiteral(2)),
          BinaryOperator.power, NumberLiteral(0.5));

      final simplified1 = engine.simplify(expr);
      // Without assumption, (x^2)^0.5 -> |x|
      expect(simplified1, equals(AbsoluteValue(x)));
      // Note: Normalizer might re-format it but structure should implicitly ensure equality logic holds

      // Add assumption x >= 0
      engine.assume('x', Assumption.nonNegative);

      final simplified2 = engine.simplify(expr);
      final expected = x;
      expect(simplified2, equals(expected));

      // Test sqrt(x^2)
      final sqrtExpr = FunctionCall(
          'sqrt', BinaryOp(x, BinaryOperator.power, NumberLiteral(2)));
      final simplifiedSqrt = engine.simplify(sqrtExpr);
      expect(simplifiedSqrt, equals(x));

      // Test log(x^2)
      final logExpr = FunctionCall(
          'ln', BinaryOp(x, BinaryOperator.power, NumberLiteral(2)));

      // With x >= 0 assume
      final simplifiedLog = engine.simplify(logExpr);
      // Expect 2*ln(x)
      expect(
          simplifiedLog,
          equals(BinaryOp(NumberLiteral(2), BinaryOperator.multiply,
              FunctionCall('ln', x))));

      // Test log(y^2) without assumption
      // Should become 2*ln(|y|)
      final y = Variable('y');
      final logExprY = FunctionCall(
          'ln', BinaryOp(y, BinaryOperator.power, NumberLiteral(2)));
      final simplifiedLogY = engine.simplify(logExprY);
      expect(
          simplifiedLogY,
          equals(BinaryOp(NumberLiteral(2), BinaryOperator.multiply,
              FunctionCall('ln', AbsoluteValue(y)))));
    });
  });
}
