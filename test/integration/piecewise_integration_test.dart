import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Piecewise Integration Tests', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    group('Symbolic Integration', () {
      test('integrates each case independently', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x & x < 0 \\
            x^{2} & x \geq 0
          \end{cases}
        ''');

        final integral = evaluator.integrate(expr, 'x');

        expect(integral, isA<PiecewiseExpr>());
        final piecewise = integral as PiecewiseExpr;
        expect(piecewise.cases.length, 2);

        // Both cases should have been integrated
        // x -> x^2/2
        // x^2 -> x^3/3
      });

      test('integrates ReLU function', () {
        // ReLU: f(x) = 0 for x < 0, x for x >= 0
        final expr = evaluator.parse(r'''
          \begin{cases}
            0 & x < 0 \\
            x & x \geq 0
          \end{cases}
        ''');

        final integral = evaluator.integrate(expr, 'x');

        expect(integral, isA<PiecewiseExpr>());
        final piecewise = integral as PiecewiseExpr;
        expect(piecewise.cases.length, 2);
      });

      test('integrates piecewise with trigonometric functions', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            \sin(x) & x < 0 \\
            \cos(x) & x \geq 0
          \end{cases}
        ''');

        final integral = evaluator.integrate(expr, 'x');

        expect(integral, isA<PiecewiseExpr>());
        // sin(x) -> -cos(x)
        // cos(x) -> sin(x)
      });

      test('integrates piecewise linear function', () {
        // Simple linear piecewise
        final expr = evaluator.parse(r'''
          \begin{cases}
            2 & x < 0 \\
            3 & x \geq 0
          \end{cases}
        ''');

        final integral = evaluator.integrate(expr, 'x');

        expect(integral, isA<PiecewiseExpr>());
        // 2 -> 2x
        // 3 -> 3x
      });

      test('preserves conditions after integration', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x^{2} & x < 0 \\
            x^{3} & x \geq 0
          \end{cases}
        ''');

        final integral = evaluator.integrate(expr, 'x');
        final piecewise = integral as PiecewiseExpr;

        // Conditions should be preserved
        expect(piecewise.cases[0].condition, isNotNull);
        expect(piecewise.cases[1].condition, isNotNull);
      });
    });

    group('Huber Loss Function (Optimization)', () {
      // Huber loss: f(r) = (1/2)r^2 for |r| <= delta, delta(|r| - (1/2)delta) for |r| > delta
      test('can express Huber-like piecewise function', () {
        // Simplified Huber loss with delta=1
        final expr = evaluator.parse(r'''
          \begin{cases}
            \frac{1}{2}r^{2} & r \leq 1 \\
            r - \frac{1}{2} & r > 1
          \end{cases}
        ''');

        expect(expr, isA<PiecewiseExpr>());

        // Evaluate at r=0.5 (within quadratic region)
        final result1 = evaluator.evaluateParsed(expr, {'r': 0.5});
        expect(
            result1.asNumeric(), closeTo(0.125, 0.0001)); // 0.5 * 0.5^2 = 0.125

        // Evaluate at r=2 (linear region)
        final result2 = evaluator.evaluateParsed(expr, {'r': 2.0});
        expect(result2.asNumeric(), closeTo(1.5, 0.0001)); // 2 - 0.5 = 1.5
      });
    });

    group('Real-World Examples', () {
      test('integrates step function', () {
        // Heaviside step function H(x)
        final expr = evaluator.parse(r'''
          \begin{cases}
            0 & x < 0 \\
            1 & x \geq 0
          \end{cases}
        ''');

        final integral = evaluator.integrate(expr, 'x');
        expect(integral, isA<PiecewiseExpr>());

        // Integral of step function is ramp function:
        // 0 -> 0
        // 1 -> x
      });

      test('integrates absolute value via piecewise', () {
        // |x| as piecewise: -x for x < 0, x for x >= 0
        final expr = evaluator.parse(r'''
          \begin{cases}
            -x & x < 0 \\
            x & x \geq 0
          \end{cases}
        ''');

        final integral = evaluator.integrate(expr, 'x');
        expect(integral, isA<PiecewiseExpr>());
        // -x -> -x^2/2
        // x -> x^2/2
      });
    });
  });

  group('Piecewise Differentiation Tests', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    group('Symbolic Differentiation', () {
      test('differentiates each case independently', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x^{2} & x < 0 \\
            x^{3} & x \geq 0
          \end{cases}
        ''');

        final derivative = evaluator.differentiate(expr, 'x');

        expect(derivative, isA<PiecewiseExpr>());
        final piecewise = derivative as PiecewiseExpr;
        expect(piecewise.cases.length, 2);
      });

      test('differentiates ReLU function', () {
        // ReLU: f(x) = 0 for x < 0, x for x >= 0
        // ReLU derivative: 0 for x < 0, 1 for x >= 0
        final expr = evaluator.parse(r'''
          \begin{cases}
            0 & x < 0 \\
            x & x \geq 0
          \end{cases}
        ''');

        final derivative = evaluator.differentiate(expr, 'x');
        expect(derivative, isA<PiecewiseExpr>());

        // Evaluate derivative
        final result1 = evaluator.evaluateParsed(derivative, {'x': -5.0});
        expect(result1.asNumeric(), closeTo(0, 0.0001)); // d/dx(0) = 0

        final result2 = evaluator.evaluateParsed(derivative, {'x': 5.0});
        expect(result2.asNumeric(), closeTo(1, 0.0001)); // d/dx(x) = 1
      });

      test('differentiates quadratic piecewise function', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x^{2} & x < 0 \\
            2x & x \geq 0
          \end{cases}
        ''');

        final derivative = evaluator.differentiate(expr, 'x');

        // Evaluate derivative at x = -2
        final result1 = evaluator.evaluateParsed(derivative, {'x': -2.0});
        expect(result1.asNumeric(), closeTo(-4, 0.0001)); // d/dx(x^2) = 2x = -4

        // Evaluate derivative at x = 3
        final result2 = evaluator.evaluateParsed(derivative, {'x': 3.0});
        expect(result2.asNumeric(), closeTo(2, 0.0001)); // d/dx(2x) = 2
      });

      test('second derivative of piecewise function', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x^{3} & x < 0 \\
            x^{4} & x \geq 0
          \end{cases}
        ''');

        final derivative = evaluator.differentiate(expr, 'x', order: 2);
        expect(derivative, isA<PiecewiseExpr>());

        // d²/dx²(x^3) = 6x
        // d²/dx²(x^4) = 12x^2
        final result1 = evaluator.evaluateParsed(derivative, {'x': -1.0});
        expect(result1.asNumeric(), closeTo(-6, 0.0001));

        final result2 = evaluator.evaluateParsed(derivative, {'x': 2.0});
        expect(result2.asNumeric(), closeTo(48, 0.0001)); // 12 * 4 = 48
      });
    });
  });

  group('Evaluation Tests', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    group('Basic Evaluation', () {
      test('evaluates first matching case', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x^{2} & x < 0 \\
            2x & x \geq 0
          \end{cases}
        ''');

        // x = -2, should use x^2 = 4
        final result1 = evaluator.evaluateParsed(expr, {'x': -2.0});
        expect(result1.asNumeric(), closeTo(4, 0.0001));

        // x = 3, should use 2x = 6
        final result2 = evaluator.evaluateParsed(expr, {'x': 3.0});
        expect(result2.asNumeric(), closeTo(6, 0.0001));

        // x = 0, should use 2x = 0 (second case matches)
        final result3 = evaluator.evaluateParsed(expr, {'x': 0.0});
        expect(result3.asNumeric(), closeTo(0, 0.0001));
      });

      test('evaluates ReLU function correctly', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            0 & x < 0 \\
            x & x \geq 0
          \end{cases}
        ''');

        expect(evaluator.evaluateParsed(expr, {'x': -5.0}).asNumeric(), 0.0);
        expect(evaluator.evaluateParsed(expr, {'x': -0.001}).asNumeric(), 0.0);
        expect(evaluator.evaluateParsed(expr, {'x': 0.0}).asNumeric(), 0.0);
        expect(evaluator.evaluateParsed(expr, {'x': 0.001}).asNumeric(),
            closeTo(0.001, 0.0001));
        expect(evaluator.evaluateParsed(expr, {'x': 5.0}).asNumeric(), 5.0);
      });

      test('evaluates otherwise case when no condition matches', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x^{2} & x < -10 \\
            x^{3} & x > 10 \\
            0 & \text{otherwise}
          \end{cases}
        ''');

        // x = 0, matches otherwise
        final result = evaluator.evaluateParsed(expr, {'x': 0.0});
        expect(result.asNumeric(), closeTo(0, 0.0001));

        // x = 5, still otherwise (not < -10 and not > 10)
        final result2 = evaluator.evaluateParsed(expr, {'x': 5.0});
        expect(result2.asNumeric(), closeTo(0, 0.0001));

        // x = -15, matches first case
        final result3 = evaluator.evaluateParsed(expr, {'x': -15.0});
        expect(result3.asNumeric(), closeTo(225, 0.0001));

        // x = 15, matches second case
        final result4 = evaluator.evaluateParsed(expr, {'x': 15.0});
        expect(result4.asNumeric(), closeTo(3375, 0.0001));
      });

      test('returns NaN when no case matches and no otherwise', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x^{2} & x < -10 \\
            x^{3} & x > 10
          \end{cases}
        ''');

        // x = 0, no case matches
        final result = evaluator.evaluateParsed(expr, {'x': 0.0});
        expect(result.asNumeric().isNaN, isTrue);
      });
    });

    group('Chained Comparisons', () {
      test('evaluates with chained comparison condition', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            0 & x < 0 \\
            x^{2} & 0 \leq x \leq 1 \\
            1 & x > 1
          \end{cases}
        ''');

        expect(evaluator.evaluateParsed(expr, {'x': -1.0}).asNumeric(), 0.0);
        expect(evaluator.evaluateParsed(expr, {'x': 0.5}).asNumeric(),
            closeTo(0.25, 0.0001));
        expect(evaluator.evaluateParsed(expr, {'x': 2.0}).asNumeric(), 1.0);
      });
    });

    group('Edge Cases', () {
      test('evaluates at boundary conditions', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x^{2} & x < 0 \\
            x^{3} & x \geq 0
          \end{cases}
        ''');

        // At boundary x = 0
        final result = evaluator.evaluateParsed(expr, {'x': 0.0});
        expect(result.asNumeric(), closeTo(0, 0.0001)); // x^3 at x=0

        // Just before boundary
        final resultBefore = evaluator.evaluateParsed(expr, {'x': -0.0001});
        expect(resultBefore.asNumeric(), closeTo(0.00000001, 0.0001)); // x^2

        // Just after boundary
        final resultAfter = evaluator.evaluateParsed(expr, {'x': 0.0001});
        expect(resultAfter.asNumeric(), closeTo(0.000000000001, 1e-10)); // x^3
      });
    });
  });
}
