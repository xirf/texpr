import 'dart:math' as dart_math;

import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('Piecewise Function Differentiation', () {
    test('differentiate piecewise function with condition', () {
      final derivative = evaluator.differentiate(r'x^{2}, -3 < x < 3', 'x');
      expect(derivative, isA<ConditionalExpr>());

      // Evaluate inside range
      final result1 = evaluator.evaluateParsed(derivative, {'x': 2});
      expect(result1.asNumeric(), closeTo(4, 0.0001)); // 2x at x=2 = 4

      // Evaluate outside range (should be NaN)
      final result2 = evaluator.evaluateParsed(derivative, {'x': 5});
      expect(result2.asNumeric().isNaN, isTrue);
    });

    test('differentiate absolute value with piecewise condition', () {
      final derivative = evaluator.differentiate(r'|\sin{x}|, -3 < x < 3', 'x');

      // Inside range at x = 2.5 (sin(2.5) > 0, so derivative is cos(2.5))
      final result1 = evaluator.evaluateParsed(derivative, {'x': 2.5});
      final expected1 = dart_math.cos(2.5);
      expect(result1.asNumeric(), closeTo(expected1, 0.0001));

      // Inside range at x = 2.99
      final result2 = evaluator.evaluateParsed(derivative, {'x': 2.99});
      final expected2 = dart_math.cos(2.99);
      expect(result2.asNumeric(), closeTo(expected2, 0.0001));

      // At boundary (should be NaN)
      final result3 = evaluator.evaluateParsed(derivative, {'x': 3.0});
      expect(result3.asNumeric().isNaN, isTrue);

      // Outside range (should be NaN)
      final result4 = evaluator.evaluateParsed(derivative, {'x': 3.5});
      expect(result4.asNumeric().isNaN, isTrue);
    });

    test('differentiate complex piecewise expression', () {
      final derivative = evaluator.differentiate(
        r'x^{3} + 2x, -10 < x < 10',
        'x',
      );

      // d/dx(x^3 + 2x) = 3x^2 + 2
      final result = evaluator.evaluateParsed(derivative, {'x': 2});
      expect(result.asNumeric(), closeTo(14, 0.0001)); // 3*4 + 2 = 14
    });

    test('differentiate piecewise with chained comparison', () {
      final derivative = evaluator.differentiate(r'x^{2}, 0 < x < 5', 'x');

      // Inside range
      final result1 = evaluator.evaluateParsed(derivative, {'x': 3});
      expect(result1.asNumeric(), closeTo(6, 0.0001));

      // At lower boundary (exclusive)
      final result2 = evaluator.evaluateParsed(derivative, {'x': 0});
      expect(result2.asNumeric().isNaN, isTrue);

      // At upper boundary (exclusive)
      final result3 = evaluator.evaluateParsed(derivative, {'x': 5});
      expect(result3.asNumeric().isNaN, isTrue);
    });

    test('higher order derivative of piecewise function', () {
      final secondDerivative = evaluator.differentiate(
        r'x^{3}, -5 < x < 5',
        'x',
        order: 2,
      );

      // d²/dx²(x^3) = 6x
      final result = evaluator.evaluateParsed(secondDerivative, {'x': 2});
      expect(result.asNumeric(), closeTo(12, 0.0001));
    });
  });

  group('Sign Function', () {
    test('sign function evaluates correctly for positive values', () {
      final result = evaluator.evaluateNumeric(r'\sign{5}');
      expect(result, equals(1.0));
    });

    test('sign function evaluates correctly for negative values', () {
      final result = evaluator.evaluateNumeric(r'\sign{-5}');
      expect(result, equals(-1.0));
    });

    test('sign function evaluates correctly for zero', () {
      final result = evaluator.evaluateNumeric(r'\sign{0}');
      expect(result, equals(0.0));
    });

    test('sign function in derivative of absolute value', () {
      final derivative = evaluator.differentiate(r'|x|', 'x');

      // d/dx(|x|) = sign(x) * 1 = sign(x)
      // At x = 5 (positive)
      final result1 = evaluator.evaluateParsed(derivative, {'x': 5});
      expect(result1.asNumeric(), equals(1.0));

      // At x = -5 (negative)
      final result2 = evaluator.evaluateParsed(derivative, {'x': -5});
      expect(result2.asNumeric(), equals(-1.0));
    });

    test('sign function in derivative of |sin(x)|', () {
      final derivative = evaluator.differentiate(r'|\sin{x}|', 'x');

      // d/dx(|sin(x)|) = cos(x) * sign(sin(x))
      // At x = π/4 (sin is positive)
      final x1 = dart_math.pi / 4;
      final result1 = evaluator.evaluateParsed(derivative, {'x': x1});
      final expected1 = dart_math.cos(x1); // sign(sin(π/4)) = 1
      expect(result1.asNumeric(), closeTo(expected1, 0.0001));

      // At x = 5π/4 (sin is negative)
      final x2 = 5 * dart_math.pi / 4;
      final result2 = evaluator.evaluateParsed(derivative, {'x': x2});
      final expected2 = -dart_math.cos(x2); // sign(sin(5π/4)) = -1
      expect(result2.asNumeric(), closeTo(expected2, 0.0001));
    });

    test('sgn function still works (backward compatibility)', () {
      final result1 = evaluator.evaluateNumeric(r'\sgn{5}');
      expect(result1, equals(1.0));

      final result2 = evaluator.evaluateNumeric(r'\sgn{-3}');
      expect(result2, equals(-1.0));
    });
  });

  group('String-Based API', () {
    test('differentiate with string expression', () {
      // New API: pass string directly
      final derivative = evaluator.differentiate('x^{2}', 'x');

      final result = evaluator.evaluateParsed(derivative, {'x': 3});
      expect(result.asNumeric(), closeTo(6, 0.0001));
    });

    test('differentiate string vs parsed expression produces same result', () {
      // Old way
      final expr = evaluator.parse('x^{3} + 2x');
      final deriv1 = evaluator.differentiate(expr, 'x');

      // New way
      final deriv2 = evaluator.differentiate('x^{3} + 2x', 'x');

      // Both should produce same result
      final result1 = evaluator.evaluateParsed(deriv1, {'x': 2});
      final result2 = evaluator.evaluateParsed(deriv2, {'x': 2});

      expect(result1.asNumeric(), equals(result2.asNumeric()));
    });

    test('integrate with string expression', () {
      // New API: pass string directly
      final integral = evaluator.integrate('x^{2}', 'x');

      // Should produce x^3/3
      expect(integral, isA<Expression>());
    });

    test('integrate string vs parsed expression produces same result', () {
      // Old way
      final expr = evaluator.parse('x^{2}');
      final int1 = evaluator.integrate(expr, 'x');

      // New way
      final int2 = evaluator.integrate('x^{2}', 'x');

      // Both should produce same LaTeX
      expect(int1.toLatex(), equals(int2.toLatex()));
    });

    test('higher order derivative with string', () {
      final derivative = evaluator.differentiate('x^{4}', 'x', order: 2);

      // d²/dx²(x^4) = 12x^2
      final result = evaluator.evaluateParsed(derivative, {'x': 2});
      expect(result.asNumeric(), closeTo(48, 0.0001));
    });

    test('piecewise differentiation with string API', () {
      final derivative = evaluator.differentiate(
        r'|\sin{x}|, -3 < x < 3',
        'x',
      );

      final result = evaluator.evaluateParsed(derivative, {'x': 1});
      final expected = dart_math.cos(1); // sin(1) > 0, so sign = 1
      expect(result.asNumeric(), closeTo(expected, 0.0001));
    });
  });

  group('Absolute Value Derivatives', () {
    test('derivative of |x| at positive x', () {
      final derivative = evaluator.differentiate(r'|x|', 'x');
      final result = evaluator.evaluateParsed(derivative, {'x': 5});
      expect(result.asNumeric(), equals(1.0));
    });

    test('derivative of |x| at negative x', () {
      final derivative = evaluator.differentiate(r'|x|', 'x');
      final result = evaluator.evaluateParsed(derivative, {'x': -5});
      expect(result.asNumeric(), equals(-1.0));
    });

    test('derivative of |x^2 - 4|', () {
      final derivative = evaluator.differentiate(r'|x^{2} - 4|', 'x');

      // At x = 3: x^2 - 4 = 5 > 0, so d/dx = 2x = 6
      final result1 = evaluator.evaluateParsed(derivative, {'x': 3});
      expect(result1.asNumeric(), closeTo(6, 0.0001));

      // At x = 1: x^2 - 4 = -3 < 0, so d/dx = -2x = -2
      final result2 = evaluator.evaluateParsed(derivative, {'x': 1});
      expect(result2.asNumeric(), closeTo(-2, 0.0001));
    });

    test('derivative of |cos(x)|', () {
      final derivative = evaluator.differentiate(r'|\cos{x}|', 'x');

      // At x = 0: cos(0) = 1 > 0, so d/dx = -sin(0) = 0
      final result1 = evaluator.evaluateParsed(derivative, {'x': 0});
      expect(result1.asNumeric(), closeTo(0, 0.0001));

      // At x = π: cos(π) = -1 < 0, so d/dx = -(-sin(π)) = sin(π) ≈ 0
      final result2 = evaluator.evaluateParsed(derivative, {'x': dart_math.pi});
      expect(result2.asNumeric(), closeTo(0, 0.0001));
    });
  });

  group('Edge Cases with Piecewise and Sign', () {
    test('derivative at boundary returns NaN', () {
      final derivative = evaluator.differentiate(r'x^{2}, -5 < x < 5', 'x');

      final result1 = evaluator.evaluateParsed(derivative, {'x': -5});
      expect(result1.asNumeric().isNaN, isTrue);

      final result2 = evaluator.evaluateParsed(derivative, {'x': 5});
      expect(result2.asNumeric().isNaN, isTrue);
    });

    test('derivative very close to boundary is finite', () {
      final derivative = evaluator.differentiate(r'x^{2}, -5 < x < 5', 'x');

      final result1 = evaluator.evaluateParsed(derivative, {'x': 4.9999});
      expect(result1.asNumeric().isFinite, isTrue);
      expect(result1.asNumeric(), closeTo(9.9998, 0.001));

      final result2 = evaluator.evaluateParsed(derivative, {'x': -4.9999});
      expect(result2.asNumeric().isFinite, isTrue);
      expect(result2.asNumeric(), closeTo(-9.9998, 0.001));
    });

    test('sign function derivative is zero', () {
      final derivative = evaluator.differentiate(r'\sign{x}', 'x');

      // d/dx(sign(x)) = 0 (except at x=0 where it's undefined)
      final result = evaluator.evaluateParsed(derivative, {'x': 5});
      expect(result.asNumeric(), equals(0.0));
    });

    test('nested absolute values', () {
      final derivative = evaluator.differentiate(r'||x||', 'x');

      // ||x|| = |x|, so d/dx = sign(x)
      final result1 = evaluator.evaluateParsed(derivative, {'x': 3});
      expect(result1.asNumeric(), equals(1.0));

      final result2 = evaluator.evaluateParsed(derivative, {'x': -3});
      expect(result2.asNumeric(), equals(-1.0));
    });
  });
}
