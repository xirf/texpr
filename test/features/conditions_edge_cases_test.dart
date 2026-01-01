import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  group('Conditions Edge Cases', () {
    late LatexMathEvaluator evaluator;

    setUp(() {
      evaluator = LatexMathEvaluator();
    });

    test('Big numbers in condition', () {
      final result =
          evaluator.evaluate("x, x > 1000000000000", {'x': 1e15}).asNumeric();
      expect(result, 1e15);
    });

    test('Big numbers in condition (false)', () {
      final result =
          evaluator.evaluate("x, x > 1000000000000", {'x': 1e10}).asNumeric();
      expect(result.isNaN, isTrue);
    });

    test('Small numbers in condition', () {
      final result =
          evaluator.evaluate("x, x < 0.0000000001", {'x': 1e-15}).asNumeric();
      expect(result, 1e-15);
    });

    test('Precision equality', () {
      // 1.0000000001 should be roughly equal to 1 for loose comparison if we had it,
      // but here we test strict inequality or epsilon if implemented.
      // The evaluator uses epsilon 1e-9 for equality.
      final result =
          evaluator.evaluate("1, x = 1", {'x': 1.00000000001}).asNumeric();
      expect(result, 1.0);
    });

    test('Precision inequality close to boundary', () {
      final result =
          evaluator.evaluate("1, x > 1", {'x': 1.00000000001}).asNumeric();
      // 1 + 1e-11 is technically > 1, but might be swallowed by epsilon if not careful.
      // Dart doubles have enough precision.
      expect(result, 1.0);
    });

    test('Infinity in condition', () {
      final result = evaluator
          .evaluate("x, x < 10", {'x': double.negativeInfinity}).asNumeric();
      expect(result, double.negativeInfinity);
    });

    test('Infinity comparison', () {
      // x > 100 with infinity
      final result =
          evaluator.evaluate("x, x > 100", {'x': double.infinity}).asNumeric();
      expect(result, double.infinity);
    });

    test('NaN in condition', () {
      // Comparisons with NaN usually return false
      final result =
          evaluator.evaluate("x, x > 0", {'x': double.nan}).asNumeric();
      expect(result.isNaN, isTrue);
    });

    test('Zero boundary positive', () {
      final result = evaluator.evaluate("1, x > 0", {'x': 0}).asNumeric();
      expect(result.isNaN, isTrue);
    });

    test('Zero boundary negative', () {
      final result = evaluator.evaluate("1, x >= 0", {'x': 0}).asNumeric();
      expect(result, 1.0);
    });
  });
}
