import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  group('Conditions Complex Scenarios', () {
    late LatexMathEvaluator evaluator;

    setUp(() {
      evaluator = LatexMathEvaluator();
    });

    test('Condition with function calls', () {
      final result = evaluator.evaluate(
          "x, \\sin{x} > 0", {'x': 1}).asNumeric(); // sin(1) is approx 0.84 > 0
      expect(result, 1.0);
    });

    test('Condition with function calls (false)', () {
      final result = evaluator.evaluate("x, \\sin{x} > 0",
          {'x': 4}).asNumeric(); // sin(4) is approx -0.75 < 0
      expect(result.isNaN, isTrue);
    });

    test('Condition with arithmetic expression', () {
      final result = evaluator
          .evaluate("x, x^2 - 4 > 0", {'x': 3}).asNumeric(); // 9 - 4 = 5 > 0
      expect(result, 3.0);
    });

    test('Chained comparison with variables', () {
      final result = evaluator
          .evaluate("x, y < x < z", {'x': 5, 'y': 0, 'z': 10}).asNumeric();
      expect(result, 5.0);
    });

    test('Chained comparison with variables (fail)', () {
      final result = evaluator
          .evaluate("x, y < x < z", {'x': 15, 'y': 0, 'z': 10}).asNumeric();
      expect(result.isNaN, isTrue);
    });

    test('Nested functions in condition', () {
      final result = evaluator.evaluate(
          "x, \\sqrt{x+1} > 2", {'x': 4}).asNumeric(); // sqrt(5) > 2.23 > 2
      expect(result, 4.0);
    });

    test('Multiple conditions', () {
      final result = evaluator.evaluate("x, x > 0", {'x': 1}).asNumeric();
      expect(result, 1.0);
    });

    test('Condition using result of another calculation', () {
      // x > y + z
      final result = evaluator
          .evaluate("x, x > y + z", {'x': 10, 'y': 2, 'z': 3}).asNumeric();
      expect(result, 10.0);
    });
  });
}
