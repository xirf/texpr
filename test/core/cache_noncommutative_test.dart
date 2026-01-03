import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  group('Cache Non-Commutative Operations', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    test('cache distinguishes subtraction operand order', () {
      final result1 = evaluator.evaluate('5 - 3').asNumeric();
      final result2 = evaluator.evaluate('3 - 5').asNumeric();

      expect(result1, equals(2.0));
      expect(result2, equals(-2.0));
    });

    test('cache distinguishes division operand order', () {
      final result1 = evaluator.evaluate('6 / 3').asNumeric();
      final result2 = evaluator.evaluate('3 / 6').asNumeric();

      expect(result1, equals(2.0));
      expect(result2, equals(0.5));
    });

    test('cache distinguishes power operand order', () {
      final result1 = evaluator.evaluate('2^3').asNumeric();
      final result2 = evaluator.evaluate('3^2').asNumeric();

      expect(result1, equals(8.0));
      expect(result2, equals(9.0));
    });

    test('cache distinguishes vector cross product operand order', () {
      final result1 = evaluator.evaluate(r'\vec{1, 2, 3} \times \vec{4, 5, 6}');
      final result2 = evaluator.evaluate(r'\vec{4, 5, 6} \times \vec{1, 2, 3}');

      final vec1 = result1.asVector();
      final vec2 = result2.asVector();

      // vec1 * vec2 = [-3, 6, -3]
      expect(vec1[0], equals(-3.0));
      expect(vec1[1], equals(6.0));
      expect(vec1[2], equals(-3.0));

      // vec2 * vec1 = [3, -6, 3] (opposite of vec1 * vec2)
      expect(vec2[0], equals(3.0));
      expect(vec2[1], equals(-6.0));
      expect(vec2[2], equals(3.0));

      // Verify anti-commutativity
      expect(vec1[0], equals(-vec2[0]));
      expect(vec1[1], equals(-vec2[1]));
      expect(vec1[2], equals(-vec2[2]));
    });

    test('cache correctly handles repeated evaluations with swapped operands',
        () {
      // Evaluate multiple times to ensure cache is being used
      for (int i = 0; i < 3; i++) {
        final sub1 = evaluator.evaluate('10 - 4').asNumeric();
        final sub2 = evaluator.evaluate('4 - 10').asNumeric();

        expect(sub1, equals(6.0), reason: 'Iteration $i: 10 - 4');
        expect(sub2, equals(-6.0), reason: 'Iteration $i: 4 - 10');
      }
    });

    test('cache statistics track different expressions correctly', () {
      final config = CacheConfig(
        collectStatistics: true,
        parsedExpressionCacheSize: 100,
        evaluationResultCacheSize: 100,
      );
      final evaluatorWithStats = Texpr(cacheConfig: config);

      // First evaluations - cache misses
      evaluatorWithStats.evaluate('5 - 3');
      evaluatorWithStats.evaluate('3 - 5');

      final stats = evaluatorWithStats.cacheStatistics;
      expect(stats.parsedExpressions.totalAccesses, greaterThan(0));

      // Second evaluations - should be cache hits
      evaluatorWithStats.evaluate('5 - 3');
      evaluatorWithStats.evaluate('3 - 5');

      expect(stats.parsedExpressions.hits, greaterThan(0),
          reason: 'Should have cache hits for repeated expressions');
    });

    test('commutative operations (addition, multiplication) work correctly',
        () {
      // These should give the same result regardless of order
      final add1 = evaluator.evaluate('3 + 5').asNumeric();
      final add2 = evaluator.evaluate('5 + 3').asNumeric();
      expect(add1, equals(add2));

      final mul1 = evaluator.evaluate('4 * 7').asNumeric();
      final mul2 = evaluator.evaluate('7 * 4').asNumeric();
      expect(mul1, equals(mul2));
    });
  });
}
