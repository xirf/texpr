import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('LatexMathEvaluator Integration', () {
    final evaluator = LatexMathEvaluator();

    group('basic arithmetic', () {
      test('addition', () {
        expect(evaluator.evaluate('2 + 3').asNumeric(), 5.0);
      });

      test('subtraction', () {
        expect(evaluator.evaluate('5 - 2').asNumeric(), 3.0);
      });

      test('multiplication with times', () {
        expect(evaluator.evaluate(r'2 \times 3').asNumeric(), 6.0);
      });

      test('multiplication with cdot', () {
        expect(evaluator.evaluate(r'2 \cdot 3').asNumeric(), 6.0);
      });

      test('division', () {
        expect(evaluator.evaluate(r'6 \div 2').asNumeric(), 3.0);
      });

      test('power', () {
        expect(evaluator.evaluate('2^{3}').asNumeric(), 8.0);
      });
    });

    group('operator precedence', () {
      test('PEMDAS: add and multiply', () {
        expect(evaluator.evaluate(r'2 + 3 \times 4').asNumeric(), 14.0);
      });

      test('PEMDAS: multiply and power', () {
        expect(evaluator.evaluate(r'2 \times 3^{2}').asNumeric(), 18.0);
      });

      test('parentheses override precedence', () {
        expect(evaluator.evaluate(r'(2 + 3) \times 4').asNumeric(), 20.0);
      });

      test('braces work like parentheses', () {
        expect(evaluator.evaluate(r'{2 + 3} \times 4').asNumeric(), 20.0);
      });
    });

    group('variables', () {
      test('simple variable', () {
        expect(evaluator.evaluate('x', {'x': 5}).asNumeric(), 5.0);
      });

      test('expression with variable', () {
        expect(evaluator.evaluate('x + 1', {'x': 2}).asNumeric(), 3.0);
      });

      test('multiple variables', () {
        expect(evaluator.evaluate('x + y', {'x': 2, 'y': 3}).asNumeric(), 5.0);
      });

      test('variable in power', () {
        expect(evaluator.evaluate('x^{2}', {'x': 3}).asNumeric(), 9.0);
      });

      test('variable base and exponent', () {
        expect(evaluator.evaluate('x^{y}', {'x': 2, 'y': 3}).asNumeric(), 8.0);
      });
    });

    group('complex expressions', () {
      test('quadratic: x^2 + 2x + 1 at x=3', () {
        expect(
          evaluator.evaluate(r'x^{2} + 2 \times x + 1', {'x': 3}).asNumeric(),
          16.0,
        );
      });

      test('nested parentheses', () {
        expect(
          evaluator.evaluate('((1 + 2) + 3)').asNumeric(),
          6.0,
        );
      });

      test('unary minus', () {
        expect(evaluator.evaluate('-x', {'x': 5}).asNumeric(), -5.0);
      });

      test('double negative', () {
        expect(evaluator.evaluate('--5').asNumeric(), 5.0);
      });

      test('negative in expression', () {
        expect(evaluator.evaluate('2 + -3').asNumeric(), -1.0);
      });
    });

    group('decimal numbers', () {
      test('decimal addition', () {
        expect(evaluator.evaluate('1.5 + 2.5').asNumeric(), 4.0);
      });

      test('decimal variable', () {
        expect(evaluator.evaluate('x + 0.5', {'x': 1.5}).asNumeric(), 2.0);
      });
    });

    group('fractions', () {
      test('simple fraction', () {
        expect(evaluator.evaluate(r'\frac{1}{2}').asNumeric(), 0.5);
      });

      test('fraction with expressions', () {
        expect(evaluator.evaluate(r'\frac{4 + 2}{3}').asNumeric(), 2.0);
      });

      test('nested fractions', () {
        expect(evaluator.evaluate(r'\frac{\frac{1}{2}}{2}').asNumeric(), 0.25);
      });

      test('fraction with variables', () {
        expect(evaluator.evaluate(r'\frac{x}{y}', {'x': 6, 'y': 3}).asNumeric(),
            2.0);
      });
    });

    group('LaTeX constants', () {
      test('pi constant', () {
        expect(evaluator.evaluate(r'\pi').asNumeric(), closeTo(3.14159, 0.001));
      });

      test('tau constant', () {
        expect(
            evaluator.evaluate(r'\tau').asNumeric(), closeTo(6.28318, 0.001));
      });

      test('phi (golden ratio)', () {
        expect(
            evaluator.evaluate(r'\phi').asNumeric(), closeTo(1.61803, 0.001));
      });

      test('pi in expression', () {
        expect(evaluator.evaluate(r'2 * \pi').asNumeric(),
            closeTo(6.28318, 0.001));
      });

      test('pi^2', () {
        expect(
            evaluator.evaluate(r'\pi^{2}').asNumeric(), closeTo(9.8696, 0.001));
      });
    });

    group('complex real-world expressions', () {
      test('sin(pi^3 * x) with fraction and absolute value', () {
        final expr =
            r'\sin(\pi^3 x) \cdot \sqrt{\frac{e^2 - x^2}{2}} + \sqrt{|x|}';
        final result = evaluator.evaluate(expr, {'x': 1}).asNumeric();
        expect(result, isA<double>());
        expect(result.isFinite, isTrue);
      });

      test('fraction with constants', () {
        expect(
          evaluator.evaluate(r'\frac{\pi}{2}').asNumeric(),
          closeTo(1.5708, 0.001),
        );
      });
    });
  });
}
