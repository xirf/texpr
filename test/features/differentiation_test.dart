import 'dart:math' as dart_math;

import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  late LatexMathEvaluator evaluator;

  setUp(() {
    evaluator = LatexMathEvaluator();
  });

  group('Basic Derivatives', () {
    test('constant rule: d/dx(5) = 0', () {
      final expr = r'\frac{d}{dx}(5)';
      final result = evaluator.evaluate(expr);
      expect(result.asNumeric(), closeTo(0, 0.0001));
    });

    test('variable rule: d/dx(x) = 1', () {
      final expr = r'\frac{d}{dx}(x)';
      final result = evaluator.evaluate(expr, {'x': 5});
      expect(result.asNumeric(), closeTo(1, 0.0001));
    });

    test('constant multiple: d/dx(5x) = 5', () {
      final expr = r'\frac{d}{dx}(5x)';
      final result = evaluator.evaluate(expr, {'x': 3});
      expect(result.asNumeric(), closeTo(5, 0.0001));
    });

    test('power rule: d/dx(x^2) = 2x', () {
      final expr = r'\frac{d}{dx}(x^{2})';
      final result = evaluator.evaluate(expr, {'x': 3});
      expect(result.asNumeric(), closeTo(6, 0.0001));
    });

    test('power rule: d/dx(x^3) = 3x^2', () {
      final expr = r'\frac{d}{dx}(x^{3})';
      final result = evaluator.evaluate(expr, {'x': 2});
      expect(result.asNumeric(), closeTo(12, 0.0001));
    });

    test('power rule: d/dx(x^{-1}) = -x^{-2}', () {
      final expr = r'\frac{d}{dx}(x^{-1})';
      final result = evaluator.evaluate(expr, {'x': 2});
      expect(result.asNumeric(), closeTo(-0.25, 0.0001));
    });

    test('power rule: d/dx(x^{0.5}) = 0.5x^{-0.5}', () {
      final expr = r'\frac{d}{dx}(x^{0.5})';
      final result = evaluator.evaluate(expr, {'x': 4});
      expect(result.asNumeric(), closeTo(0.25, 0.0001));
    });
  });

  group('Sum and Difference Rules', () {
    test('sum rule: d/dx(x^2 + x) = 2x + 1', () {
      final expr = r'\frac{d}{dx}(x^{2} + x)';
      final result = evaluator.evaluate(expr, {'x': 3});
      expect(result.asNumeric(), closeTo(7, 0.0001));
    });

    test('difference rule: d/dx(x^3 - x) = 3x^2 - 1', () {
      final expr = r'\frac{d}{dx}(x^{3} - x)';
      final result = evaluator.evaluate(expr, {'x': 2});
      expect(result.asNumeric(), closeTo(11, 0.0001));
    });

    test('multiple terms: d/dx(x^3 + 2x^2 - 5x + 7) = 3x^2 + 4x - 5', () {
      final expr = r'\frac{d}{dx}(x^{3} + 2x^{2} - 5x + 7)';
      final result = evaluator.evaluate(expr, {'x': 1});
      expect(result.asNumeric(), closeTo(2, 0.0001));
    });
  });

  group('Product Rule', () {
    test('product rule: d/dx(x * x^2) = x^2 + x*2x = 3x^2', () {
      final expr = r'\frac{d}{dx}(x \cdot x^{2})';
      final result = evaluator.evaluate(expr, {'x': 2});
      expect(result.asNumeric(), closeTo(12, 0.0001));
    });

    test('product rule: d/dx((x+1)(x-1)) = (x-1) + (x+1)', () {
      final expr = r'\frac{d}{dx}((x+1)(x-1))';
      final result = evaluator.evaluate(expr, {'x': 3});
      expect(result.asNumeric(), closeTo(6, 0.0001));
    });

    test('product rule with constants: d/dx(5x * 3x) = 30x', () {
      final expr = r'\frac{d}{dx}(5x \cdot 3x)';
      final result = evaluator.evaluate(expr, {'x': 2});
      expect(result.asNumeric(), closeTo(60, 0.0001));
    });
  });

  group('Quotient Rule', () {
    test('quotient rule: d/dx(x^2 / x) = d/dx(x) = 1', () {
      final expr = r'\frac{d}{dx}(\frac{x^{2}}{x})';
      final result = evaluator.evaluate(expr, {'x': 5});
      expect(result.asNumeric(), closeTo(1, 0.0001));
    });

    test('quotient rule: d/dx(1/x) = -1/x^2', () {
      final expr = r'\frac{d}{dx}(\frac{1}{x})';
      final result = evaluator.evaluate(expr, {'x': 2});
      expect(result.asNumeric(), closeTo(-0.25, 0.0001));
    });

    test('quotient rule: d/dx(x/(x+1))', () {
      final expr = r'\frac{d}{dx}(\frac{x}{x+1})';
      final result = evaluator.evaluate(expr, {'x': 2});
      // derivative is (x+1 - x)/(x+1)^2 = 1/(x+1)^2 = 1/9
      expect(result.asNumeric(), closeTo(1 / 9, 0.0001));
    });
  });

  group('Chain Rule', () {
    test('chain rule: d/dx((x^2)^3) = 6x^5', () {
      final expr = r'\frac{d}{dx}((x^{2})^{3})';
      final result = evaluator.evaluate(expr, {'x': 2});
      expect(result.asNumeric(), closeTo(192, 0.1)); // 6 * 2^5 = 192
    });

    test('chain rule: d/dx(sin(x^2)) = 2x*cos(x^2)', () {
      final expr = r'\frac{d}{dx}(\sin{x^{2}})';
      final result = evaluator.evaluate(expr, {'x': 1});
      final expected = 2 * 1 * cos(1); // cos(1) ≈ 0.540
      expect(result.asNumeric(), closeTo(expected, 0.01));
    });

    test('chain rule: d/dx(e^(x^2)) = 2x*e^(x^2)', () {
      final expr = r'\frac{d}{dx}(\exp{x^{2}})';
      final result = evaluator.evaluate(expr, {'x': 1});
      final expected = 2 * 1 * exp(1); // 2 * e
      expect(result.asNumeric(), closeTo(expected, 0.01));
    });
  });

  group('Trigonometric Functions', () {
    test('d/dx(sin(x)) = cos(x)', () {
      final expr = r'\frac{d}{dx}(\sin{x})';
      final result = evaluator.evaluate(expr, {'x': 0});
      expect(result.asNumeric(), closeTo(1, 0.0001)); // cos(0) = 1
    });

    test('d/dx(cos(x)) = -sin(x)', () {
      final expr = r'\frac{d}{dx}(\cos{x})';
      final result = evaluator.evaluate(expr, {'x': 0});
      expect(result.asNumeric(), closeTo(0, 0.0001)); // -sin(0) = 0
    });

    test('d/dx(tan(x)) = sec^2(x)', () {
      final expr = r'\frac{d}{dx}(\tan{x})';
      final result = evaluator.evaluate(expr, {'x': 0});
      expect(result.asNumeric(), closeTo(1, 0.0001)); // sec^2(0) = 1
    });

    test('d/dx(sin(2x)) = 2cos(2x)', () {
      final expr = r'\frac{d}{dx}(\sin{2x})';
      final result = evaluator.evaluate(expr, {'x': 0});
      expect(result.asNumeric(), closeTo(2, 0.0001)); // 2*cos(0) = 2
    });
  });

  group('Inverse Trigonometric Functions', () {
    test('d/dx(arcsin(x)) = 1/sqrt(1-x^2)', () {
      final expr = r'\frac{d}{dx}(\arcsin{x})';
      final result = evaluator.evaluate(expr, {'x': 0});
      expect(result.asNumeric(), closeTo(1, 0.0001)); // 1/sqrt(1) = 1
    });

    test('d/dx(arccos(x)) = -1/sqrt(1-x^2)', () {
      final expr = r'\frac{d}{dx}(\arccos{x})';
      final result = evaluator.evaluate(expr, {'x': 0});
      expect(result.asNumeric(), closeTo(-1, 0.0001)); // -1/sqrt(1) = -1
    });

    test('d/dx(arctan(x)) = 1/(1+x^2)', () {
      final expr = r'\frac{d}{dx}(\arctan{x})';
      final result = evaluator.evaluate(expr, {'x': 0});
      expect(result.asNumeric(), closeTo(1, 0.0001)); // 1/(1+0) = 1
    });
  });

  group('Exponential and Logarithmic Functions', () {
    test('d/dx(e^x) = e^x', () {
      final expr = r'\frac{d}{dx}(\exp{x})';
      final result = evaluator.evaluate(expr, {'x': 1});
      expect(result.asNumeric(), closeTo(exp(1), 0.01));
    });

    test('d/dx(ln(x)) = 1/x', () {
      final expr = r'\frac{d}{dx}(\ln{x})';
      final result = evaluator.evaluate(expr, {'x': 2});
      expect(result.asNumeric(), closeTo(0.5, 0.0001));
    });

    test('d/dx(log(x)) = 1/(x*ln(10))', () {
      final expr = r'\frac{d}{dx}(\log{x})';
      final result = evaluator.evaluate(expr, {'x': 10});
      final expected = 1 / (10 * log(10));
      expect(result.asNumeric(), closeTo(expected, 0.0001));
    });

    test('d/dx(2^x) = 2^x * ln(2)', () {
      final expr = r'\frac{d}{dx}(2^{x})';
      final result = evaluator.evaluate(expr, {'x': 0});
      final expected = pow(2, 0) * log(2); // 1 * ln(2)
      expect(result.asNumeric(), closeTo(expected, 0.001));
    });
  });

  group('Square Root', () {
    test('d/dx(sqrt(x)) = 1/(2*sqrt(x))', () {
      final expr = r'\frac{d}{dx}(\sqrt{x})';
      final result = evaluator.evaluate(expr, {'x': 4});
      expect(result.asNumeric(), closeTo(0.25, 0.0001)); // 1/(2*2) = 0.25
    });

    test('d/dx(sqrt(x^2)) = x/sqrt(x^2)', () {
      final expr = r'\frac{d}{dx}(\sqrt{x^{2}})';
      final result = evaluator.evaluate(expr, {'x': 3});
      // derivative is 2x/(2*sqrt(x^2)) = x/|x|
      expect(result.asNumeric(), closeTo(1, 0.01));
    });
  });

  group('Higher Order Derivatives', () {
    test('second derivative: d²/dx²(x^3) = 6x', () {
      final expr = r'\frac{d^{2}}{dx^{2}}(x^{3})';
      final result = evaluator.evaluate(expr, {'x': 2});
      expect(result.asNumeric(), closeTo(12, 0.0001));
    });

    test('second derivative: d²/dx²(sin(x)) = -sin(x)', () {
      final expr = r'\frac{d^{2}}{dx^{2}}(\sin{x})';
      final result = evaluator.evaluate(expr, {'x': 0});
      expect(result.asNumeric(), closeTo(0, 0.0001)); // -sin(0) = 0
    });

    test('third derivative: d³/dx³(x^4) = 24x', () {
      final expr = r'\frac{d^{3}}{dx^{3}}(x^{4})';
      final result = evaluator.evaluate(expr, {'x': 1});
      expect(result.asNumeric(), closeTo(24, 0.0001));
    });

    test('fourth derivative: d⁴/dx⁴(x^4) = 24', () {
      final expr = r'\frac{d^{4}}{dx^{4}}(x^{4})';
      final result = evaluator.evaluate(expr, {'x': 5});
      expect(result.asNumeric(), closeTo(24, 0.0001));
    });
  });

  group('API Method - differentiate()', () {
    test('symbolic differentiation returns expression', () {
      final expr = evaluator.parse('x^{2}');
      final derivative = evaluator.differentiate(expr, 'x');
      expect(derivative, isA<Expression>());

      // Evaluate at x = 3
      final result = evaluator.evaluateParsed(derivative, {'x': 3});
      expect(result.asNumeric(), closeTo(6, 0.0001));
    });

    test('second order derivative via API', () {
      final expr = evaluator.parse('x^{3}');
      final secondDerivative = evaluator.differentiate(expr, 'x', order: 2);

      // d²/dx²(x^3) = 6x at x = 2
      final result = evaluator.evaluateParsed(secondDerivative, {'x': 2});
      expect(result.asNumeric(), closeTo(12, 0.0001));
    });

    test('derivative of complex expression', () {
      final expr = evaluator.parse(r'\sin{x} + x^{2}');
      final derivative = evaluator.differentiate(expr, 'x');

      // d/dx(sin(x) + x^2) = cos(x) + 2x at x = 0
      final result = evaluator.evaluateParsed(derivative, {'x': 0});
      expect(result.asNumeric(), closeTo(1, 0.0001)); // cos(0) + 0 = 1
    });
  });

  group('Edge Cases', () {
    test('derivative of constant with respect to different variable', () {
      final expr = r'\frac{d}{dy}(x)';
      final result = evaluator.evaluate(expr, {'x': 5, 'y': 3});
      expect(result.asNumeric(), closeTo(0, 0.0001));
    });

    test('derivative of polynomial at negative x', () {
      final expr = r'\frac{d}{dx}(x^{2})';
      final result = evaluator.evaluate(expr, {'x': -3});
      expect(result.asNumeric(), closeTo(-6, 0.0001));
    });

    test('derivative order validation - positive order required', () {
      final expr = evaluator.parse('x');
      expect(
        () => evaluator.differentiate(expr, 'x', order: 0),
        throwsA(isA<EvaluatorException>()),
      );
    });

    test('derivative order validation - max order limit', () {
      final expr = evaluator.parse('x');
      expect(
        () => evaluator.differentiate(expr, 'x', order: 11),
        throwsA(isA<EvaluatorException>()),
      );
    });
  });

  group('Complex Expressions', () {
    test('derivative of (x^2 + 1)/(x - 1)', () {
      final expr = r'\frac{d}{dx}(\frac{x^{2}+1}{x-1})';
      final result = evaluator.evaluate(expr, {'x': 2});
      // Using quotient rule: ((2x)(x-1) - (x^2+1)(1))/(x-1)^2
      // At x=2: (4*1 - 5*1)/1 = -1
      expect(result.asNumeric(), closeTo(-1, 0.0001));
    });

    test('derivative of x^x', () {
      final expr = r'\frac{d}{dx}(x^{x})';
      final result = evaluator.evaluate(expr, {'x': 2});
      // d/dx(x^x) = x^x * (ln(x) + 1)
      // At x=2: 2^2 * (ln(2) + 1) ≈ 4 * 1.693 ≈ 6.77
      final expected = pow(2, 2) * (log(2) + 1);
      expect(result.asNumeric(), closeTo(expected, 0.01));
    });
  });
}

double sin(double x) => _math.sin(x);
double cos(double x) => _math.cos(x);
double exp(double x) => _math.exp(x);
double log(double x) => _math.log(x);
num pow(num x, num exp) => _math.pow(x, exp);

final _math = _Math();

class _Math {
  double sin(double x) => dart_math.sin(x);
  double cos(double x) => dart_math.cos(x);
  double exp(double x) => dart_math.exp(x);
  double log(double x) => dart_math.log(x);
  num pow(num x, num exp) => dart_math.pow(x, exp);
}
