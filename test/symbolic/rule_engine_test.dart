import 'package:test/test.dart';
import 'package:texpr/src/ast.dart';
import 'package:texpr/src/symbolic/rewrite_rule.dart';
import 'package:texpr/src/symbolic/rule_engine.dart';
import 'package:texpr/src/symbolic/rules/arithmetic_rules.dart';
import 'package:texpr/src/symbolic/rules/trig_rules.dart';

void main() {
  group('RuleEngine', () {
    late RuleEngine engine;

    setUp(() {
      engine = RuleEngine(
        rules: [SubtractSelfRule()],
        enabledCategories: {RuleCategory.simplification},
      );
    });

    test('applies SubtractSelfRule: x - x -> 0', () {
      final expr = BinaryOp(
        Variable('x'),
        BinaryOperator.subtract,
        Variable('x'),
      );

      final result = engine.applyRules(expr);

      expect(result, isA<NumberLiteral>());
      expect((result as NumberLiteral).value, 0);
    });

    test('applies nested rules: (x - x) + y -> 0 + y', () {
      // (x - x) + y
      final expr = BinaryOp(
        BinaryOp(Variable('x'), BinaryOperator.subtract, Variable('x')),
        BinaryOperator.add,
        Variable('y'),
      );

      final result = engine.applyRules(expr);

      // Expected: 0 + y (since normalizer isn't running here to remove 0)
      expect(result, isA<BinaryOp>());
      final op = result as BinaryOp;
      expect(op.left, isA<NumberLiteral>());
      expect((op.left as NumberLiteral).value, 0);
      expect(op.right, isA<Variable>());
      expect((op.right as Variable).name, 'y');
    });

    test('ignores non-matching expressions', () {
      final expr = BinaryOp(
        Variable('x'),
        BinaryOperator.subtract,
        Variable('y'),
      );

      final result = engine.applyRules(expr);

      expect(result, equals(expr));
    });

    test('applies PythagoreanRule: sin^2(x) + cos^2(x) -> 1', () {
      // sin^2(x)
      final sin2 = BinaryOp(FunctionCall('sin', Variable('x')),
          BinaryOperator.power, NumberLiteral(2));
      // cos^2(x)
      final cos2 = BinaryOp(FunctionCall('cos', Variable('x')),
          BinaryOperator.power, NumberLiteral(2));

      final expr = BinaryOp(sin2, BinaryOperator.add, cos2);

      // Need to add PythRule to engine
      final trigEngine = RuleEngine(
          rules: [PythagoreanRule()],
          enabledCategories: {RuleCategory.simplification});
      final result = trigEngine.applyRules(expr);

      expect(result, isA<NumberLiteral>());
      expect((result as NumberLiteral).value, 1);
    });

    test(
        'applies PythagoreanRule with equivalent args: sin^2(x+0) + cos^2(x) -> 1',
        () {
      // sin^2(x+0)
      final sin2 = BinaryOp(
          FunctionCall('sin',
              BinaryOp(Variable('x'), BinaryOperator.add, NumberLiteral(0))),
          BinaryOperator.power,
          NumberLiteral(2));
      // cos^2(x)
      final cos2 = BinaryOp(FunctionCall('cos', Variable('x')),
          BinaryOperator.power, NumberLiteral(2));

      final expr = BinaryOp(sin2, BinaryOperator.add, cos2);

      final trigEngine = RuleEngine(
          rules: [PythagoreanRule()],
          enabledCategories: {RuleCategory.simplification});

      final result = trigEngine.applyRules(expr);

      expect(result, isA<NumberLiteral>());
      expect((result as NumberLiteral).value, 1);
    });
  });
}
