import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Semantic invariant tests verify mathematical correctness beyond surface-level
/// functionality. These tests ensure that evaluated results match mathematical
/// expectations and that algebraic identities hold.
void main() {
  group('Semantic Invariant Tests', () {
    late Texpr texpr;

    setUp(() {
      texpr = Texpr();
    });

    group('Derivative Correctness (Finite Difference Validation)', () {
      /// Verifies that symbolic derivatives match numerical finite differences.
      /// For f'(x), we check: f'(x) ≈ (f(x+h) - f(x-h)) / 2h within tolerance.
      const double h = 1e-7;
      const double tolerance = 1e-5;

      void testDerivativeAt(String expr, String variable, double x) {
        final derivative = texpr.differentiate(expr, variable);
        final derivativeValue =
            texpr.evaluateParsed(derivative, {variable: x}).asNumeric();

        // Central difference: (f(x+h) - f(x-h)) / 2h
        final fPlus = texpr.evaluate(expr, {variable: x + h}).asNumeric();
        final fMinus = texpr.evaluate(expr, {variable: x - h}).asNumeric();
        final finiteDiff = (fPlus - fMinus) / (2 * h);

        expect(
          derivativeValue,
          closeTo(finiteDiff, tolerance),
          reason: 'd/d$variable($expr) at $variable=$x: '
              'symbolic=$derivativeValue, finite_diff=$finiteDiff',
        );
      }

      test('d/dx(x^2) matches finite difference', () {
        testDerivativeAt('x^2', 'x', 2.0);
        testDerivativeAt('x^2', 'x', -1.5);
        testDerivativeAt('x^2', 'x', 0.5);
      });

      test('d/dx(x^3) matches finite difference', () {
        testDerivativeAt('x^3', 'x', 2.0);
        testDerivativeAt('x^3', 'x', -1.0);
      });

      test('d/dx(sin(x)) matches finite difference', () {
        testDerivativeAt(r'\sin(x)', 'x', 0.0);
        testDerivativeAt(r'\sin(x)', 'x', math.pi / 4);
        testDerivativeAt(r'\sin(x)', 'x', math.pi / 2);
      });

      test('d/dx(cos(x)) matches finite difference', () {
        testDerivativeAt(r'\cos(x)', 'x', 0.0);
        testDerivativeAt(r'\cos(x)', 'x', math.pi / 4);
      });

      test('d/dx(e^x) matches finite difference', () {
        testDerivativeAt('e^x', 'x', 0.0);
        testDerivativeAt('e^x', 'x', 1.0);
        testDerivativeAt('e^x', 'x', -1.0);
      });

      test('d/dx(ln(x)) matches finite difference', () {
        testDerivativeAt(r'\ln(x)', 'x', 1.0);
        testDerivativeAt(r'\ln(x)', 'x', 2.0);
        testDerivativeAt(r'\ln(x)', 'x', 0.5);
      });

      test('d/dx(sqrt(x)) matches finite difference', () {
        testDerivativeAt(r'\sqrt{x}', 'x', 1.0);
        testDerivativeAt(r'\sqrt{x}', 'x', 4.0);
      });

      test('d/dx(1/x) matches finite difference', () {
        testDerivativeAt(r'\frac{1}{x}', 'x', 1.0);
        testDerivativeAt(r'\frac{1}{x}', 'x', 2.0);
      });

      test('d/dx(x*sin(x)) product rule', () {
        testDerivativeAt(r'x \cdot \sin(x)', 'x', 1.0);
        testDerivativeAt(r'x \cdot \sin(x)', 'x', 2.0);
      });

      test('d/dx(sin(x^2)) chain rule', () {
        testDerivativeAt(r'\sin(x^2)', 'x', 0.5);
        testDerivativeAt(r'\sin(x^2)', 'x', 1.0);
      });
    });

    group('Round-Trip Parsing (parse → toLatex → parse)', () {
      /// Verifies that parsing an expression, converting to LaTeX, and
      /// parsing again produces semantically equivalent results.

      void testRoundTrip(String original, double x) {
        final ast1 = texpr.parse(original);
        final latex = ast1.toLatex();
        final ast2 = texpr.parse(latex);

        final result1 = texpr.evaluateParsed(ast1, {'x': x}).asNumeric();
        final result2 = texpr.evaluateParsed(ast2, {'x': x}).asNumeric();

        expect(
          result1,
          closeTo(result2, 1e-10),
          reason: 'Round-trip failed for "$original" → "$latex" at x=$x',
        );
      }

      test('simple expressions round-trip correctly', () {
        testRoundTrip('x + 1', 5.0);
        testRoundTrip('x - 2', 3.0);
        testRoundTrip('x * 3', 2.0);
        testRoundTrip('x / 2', 4.0);
      });

      test('power expressions round-trip correctly', () {
        testRoundTrip('x^2', 3.0);
        testRoundTrip('x^3', 2.0);
        testRoundTrip('2^x', 3.0);
      });

      test('function expressions round-trip correctly', () {
        testRoundTrip(r'\sin(x)', 1.0);
        testRoundTrip(r'\cos(x)', 1.0);
        testRoundTrip(r'\ln(x)', 2.0);
        testRoundTrip(r'\sqrt{x}', 4.0);
      });

      test('fraction expressions round-trip correctly', () {
        testRoundTrip(r'\frac{x}{2}', 4.0);
        testRoundTrip(r'\frac{1}{x}', 2.0);
        testRoundTrip(r'\frac{x+1}{x-1}', 3.0);
      });

      test('complex expressions round-trip correctly', () {
        testRoundTrip(r'x^2 + 2x + 1', 2.0);
        testRoundTrip(r'\sin(x) + \cos(x)', 0.5);
        testRoundTrip(r'\frac{\sin(x)}{x}', 1.0);
      });
    });

    group('Known Mathematical Constants', () {
      /// Verifies that famous mathematical identities evaluate correctly.

      test("Euler's identity: e^{iπ} + 1 ≈ 0", () {
        final result = texpr.evaluate(r'e^{i \pi} + 1');
        // Result is complex, magnitude should be ~0
        final complex = result.asComplex();
        expect(complex.real, closeTo(0, 1e-10));
        expect(complex.imaginary, closeTo(0, 1e-10));
      });

      test('e^{iπ/2} = i', () {
        final result = texpr.evaluate(r'e^{i \frac{\pi}{2}}');
        final complex = result.asComplex();
        expect(complex.real, closeTo(0, 1e-10));
        expect(complex.imaginary, closeTo(1, 1e-10));
      });

      test('ln(e) = 1', () {
        final result = texpr.evaluate(r'\ln(e)');
        expect(result.asNumeric(), closeTo(1.0, 1e-10));
      });

      test('e^{ln(2)} = 2', () {
        final result = texpr.evaluate(r'e^{\ln(2)}');
        expect(result.asNumeric(), closeTo(2.0, 1e-10));
      });

      test('sin(π) = 0', () {
        final result = texpr.evaluate(r'\sin(\pi)');
        expect(result.asNumeric(), closeTo(0.0, 1e-10));
      });

      test('cos(π) = -1', () {
        final result = texpr.evaluate(r'\cos(\pi)');
        expect(result.asNumeric(), closeTo(-1.0, 1e-10));
      });

      test('sin(π/2) = 1', () {
        final result = texpr.evaluate(r'\sin(\frac{\pi}{2})');
        expect(result.asNumeric(), closeTo(1.0, 1e-10));
      });

      test('cos(π/2) = 0', () {
        final result = texpr.evaluate(r'\cos(\frac{\pi}{2})');
        expect(result.asNumeric(), closeTo(0.0, 1e-10));
      });

      test('tan(π/4) = 1', () {
        final result = texpr.evaluate(r'\tan(\frac{\pi}{4})');
        expect(result.asNumeric(), closeTo(1.0, 1e-10));
      });

      test('√2 × √2 = 2', () {
        final result = texpr.evaluate(r'\sqrt{2} \times \sqrt{2}');
        expect(result.asNumeric(), closeTo(2.0, 1e-10));
      });

      test('golden ratio: φ² = φ + 1', () {
        final phi = texpr.evaluate(r'\phi').asNumeric();
        final phiSquared = texpr.evaluate(r'\phi^2').asNumeric();
        expect(phiSquared, closeTo(phi + 1, 1e-10));
      });
    });

    group('Algebraic Identities', () {
      /// Verifies that algebraic identities hold numerically.

      void testIdentity(String lhs, String rhs, Map<String, double> vars) {
        final leftResult = texpr.evaluate(lhs, vars).asNumeric();
        final rightResult = texpr.evaluate(rhs, vars).asNumeric();
        expect(
          leftResult,
          closeTo(rightResult, 1e-10),
          reason: '"$lhs" ≠ "$rhs" at $vars: $leftResult vs $rightResult',
        );
      }

      test('sin²(x) + cos²(x) = 1', () {
        for (final x in [0.0, 0.5, 1.0, math.pi / 4, math.pi / 2]) {
          testIdentity(
            r'\sin(x)^2 + \cos(x)^2',
            '1',
            {'x': x},
          );
        }
      });

      test('sin(2x) = 2sin(x)cos(x)', () {
        for (final x in [0.5, 1.0, math.pi / 6]) {
          testIdentity(
            r'\sin(2x)',
            r'2 \sin(x) \cos(x)',
            {'x': x},
          );
        }
      });

      test('cos(2x) = cos²(x) - sin²(x)', () {
        for (final x in [0.5, 1.0, math.pi / 6]) {
          testIdentity(
            r'\cos(2x)',
            r'\cos(x)^2 - \sin(x)^2',
            {'x': x},
          );
        }
      });

      test('(a + b)² = a² + 2ab + b²', () {
        for (final (a, b) in [(2.0, 3.0), (1.5, 2.5), (-1.0, 4.0)]) {
          testIdentity(
            '(a + b)^2',
            'a^2 + 2 a b + b^2',
            {'a': a, 'b': b},
          );
        }
      });

      test('(a - b)(a + b) = a² - b²', () {
        for (final (a, b) in [(5.0, 3.0), (4.0, 2.0)]) {
          testIdentity(
            '(a - b)(a + b)',
            'a^2 - b^2',
            {'a': a, 'b': b},
          );
        }
      });

      test('ln(ab) = ln(a) + ln(b)', () {
        for (final (a, b) in [(2.0, 3.0), (4.0, 5.0)]) {
          testIdentity(
            r'\ln(a \cdot b)',
            r'\ln(a) + \ln(b)',
            {'a': a, 'b': b},
          );
        }
      });

      test('ln(a^n) = n ln(a)', () {
        for (final (a, n) in [(2.0, 3.0), (3.0, 2.0)]) {
          testIdentity(
            r'\ln(a^n)',
            r'n \cdot \ln(a)',
            {'a': a, 'n': n},
          );
        }
      });

      test('e^{a+b} = e^a × e^b', () {
        for (final (a, b) in [(1.0, 2.0), (0.5, 1.5)]) {
          testIdentity(
            'e^{a + b}',
            'e^a e^b',
            {'a': a, 'b': b},
          );
        }
      });

      test('sinh²(x) = (cosh(2x) - 1) / 2', () {
        for (final x in [0.5, 1.0, 1.5]) {
          testIdentity(
            r'\sinh(x)^2',
            r'\frac{\cosh(2x) - 1}{2}',
            {'x': x},
          );
        }
      });

      test('cosh²(x) - sinh²(x) = 1', () {
        for (final x in [0.5, 1.0, 1.5]) {
          testIdentity(
            r'\cosh(x)^2 - \sinh(x)^2',
            '1',
            {'x': x},
          );
        }
      });
    });

    group('Limit Consistency', () {
      /// Verifies that limits match direct evaluation where applicable.

      test('lim_{x→a} f(x) = f(a) for continuous functions', () {
        // For continuous functions, the limit equals the function value
        final directEval = texpr.evaluate('x^2 + 1', {'x': 2.0}).asNumeric();
        final limitEval =
            texpr.evaluate(r'\lim_{x \to 2} (x^2 + 1)').asNumeric();
        expect(limitEval, closeTo(directEval, 1e-10));
      });

      test('lim_{x→0} sin(x)/x = 1', () {
        final result = texpr.evaluate(r'\lim_{x \to 0} \frac{\sin(x)}{x}');
        expect(result.asNumeric(), closeTo(1.0, 1e-10));
      });

      test('lim_{x→∞} 1/x = 0', () {
        final result = texpr.evaluate(r'\lim_{x \to \infty} \frac{1}{x}');
        // Numerical limit approximation may not reach exactly 0
        expect(result.asNumeric(), closeTo(0.0, 1e-6));
      });
    });

    group('Summation Identities', () {
      /// Verifies known summation formulas.

      test('sum_{k=1}^{n} k = n(n+1)/2', () {
        for (final n in [5, 10, 20]) {
          final sumResult =
              texpr.evaluate(r'\sum_{k=1}^{n} k', {'n': n}).asNumeric();
          final formulaResult = n * (n + 1) / 2;
          expect(sumResult, closeTo(formulaResult, 1e-10));
        }
      });

      test('sum_{k=1}^{n} k² = n(n+1)(2n+1)/6', () {
        for (final n in [5, 10]) {
          final sumResult =
              texpr.evaluate(r'\sum_{k=1}^{n} k^2', {'n': n}).asNumeric();
          final formulaResult = n * (n + 1) * (2 * n + 1) / 6;
          expect(sumResult, closeTo(formulaResult, 1e-10));
        }
      });

      test('sum_{k=0}^{n} x^k = (1 - x^{n+1}) / (1 - x) for x ≠ 1', () {
        for (final (n, x) in [(5, 0.5), (10, 0.8)]) {
          final sumResult = texpr
              .evaluate(r'\sum_{k=0}^{n} x^k', {'n': n, 'x': x}).asNumeric();
          final formulaResult = (1 - math.pow(x, n + 1)) / (1 - x);
          expect(sumResult, closeTo(formulaResult, 1e-10));
        }
      });
    });
  });
}
