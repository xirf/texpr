import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Evaluator', () {
    final evaluator = Evaluator();

    Expression parse(String input) {
      final tokens = Tokenizer(input).tokenize();
      return Parser(tokens).parse();
    }

    double eval(String input, [Map<String, double> vars = const {}]) {
      return evaluator.evaluate(parse(input), vars).asNumeric();
    }

    group('arithmetic', () {
      test('evaluates addition', () {
        expect(eval('2 + 3'), 5.0);
      });

      test('evaluates subtraction', () {
        expect(eval('5 - 2'), 3.0);
      });

      test('evaluates multiplication', () {
        expect(eval(r'2 \times 3'), 6.0);
      });

      test('evaluates division', () {
        expect(eval(r'6 \div 2'), 3.0);
      });

      test('evaluates power', () {
        expect(eval('2^{3}'), 8.0);
      });

      test('evaluates unary minus', () {
        expect(eval('-5'), -5.0);
      });
    });

    group('precedence', () {
      test('multiply before add', () {
        expect(eval(r'2 + 3 \times 4'), 14.0);
      });

      test('power before multiply', () {
        expect(eval(r'2 \times 3^{2}'), 18.0);
      });

      test('parentheses override precedence', () {
        expect(eval(r'(2 + 3) \times 4'), 20.0);
      });
    });

    group('variables', () {
      test('evaluates single variable', () {
        expect(eval('x', {'x': 5}), 5.0);
      });

      test('evaluates expression with variable', () {
        expect(eval('x + 1', {'x': 2}), 3.0);
      });

      test('evaluates multiple variables', () {
        expect(eval('x + y', {'x': 2, 'y': 3}), 5.0);
      });

      test('evaluates power with variable', () {
        expect(eval('x^{2}', {'x': 3}), 9.0);
      });

      test('throws on undefined variable', () {
        expect(
          () => eval('x'),
          throwsA(isA<EvaluatorException>()),
        );
      });
    });

    group('errors', () {
      test('throws on division by zero', () {
        expect(
          () => eval(r'1 \div 0'),
          throwsA(isA<EvaluatorException>()),
        );
      });
    });

    group('complex expressions', () {
      test('evaluates complex expression', () {
        // 2 + x * 3 with x = 4 => 2 + 12 = 14
        expect(eval(r'2 + x \times 3', {'x': 4}), 14.0);
      });

      test('evaluates quadratic', () {
        // x^2 + 2x + 1 with x = 3 => 9 + 6 + 1 = 16
        expect(eval(r'x^{2} + 2 \times x + 1', {'x': 3}), 16.0);
      });
    });

    group('logarithms', () {
      test('evaluates natural log ln(e) = 1', () {
        expect(eval(r'\ln{2.718281828}'), closeTo(1.0, 0.001));
      });

      test('evaluates ln with variable', () {
        expect(eval(r'\ln{x}', {'x': 1.0}), 0.0);
      });

      test('evaluates log base 10', () {
        expect(eval(r'\log{10}'), closeTo(1.0, 0.001));
      });

      test('evaluates log base 10 of 100', () {
        expect(eval(r'\log{100}'), closeTo(2.0, 0.001));
      });

      test('evaluates log with custom base', () {
        expect(eval(r'\log_{2}{8}'), closeTo(3.0, 0.001));
      });

      test('evaluates log base 2 of 16', () {
        expect(eval(r'\log_{2}{16}'), closeTo(4.0, 0.001));
      });

      test('log of zero returns negative infinity', () {
        final result = evaluator.evaluate(parse(r'\log{0}'), {});
        expect(result.isComplex, isTrue);
        final c = (result as ComplexResult).value;
        expect(c.real.isInfinite && c.real < 0, isTrue);
      });

      test('ln of negative returns complex', () {
        final result = evaluator.evaluate(parse(r'\ln{-1}'), {});
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.imaginary, closeTo(3.14159, 0.001));
      });
    });

    group('limits', () {
      test('evaluates simple limit', () {
        // lim_{x -> 0} x = 0
        expect(eval(r'\lim_{x \to 0} x'), closeTo(0.0, 0.001));
      });

      test('evaluates limit of polynomial', () {
        // lim_{x -> 1} x^2 = 1
        expect(eval(r'\lim_{x \to 1} x^{2}', {'x': 1.0}), closeTo(1.0, 0.001));
      });

      test('evaluates limit of linear function', () {
        // lim_{x -> 2} (x + 3) = 5
        expect(
            eval(r'\lim_{x \to 2} (x + 3)', {'x': 2.0}), closeTo(5.0, 0.001));
      });

      test('evaluates limit with constant', () {
        // lim_{x -> 5} 10 = 10
        expect(eval(r'\lim_{x \to 5} 10', {'x': 5.0}), closeTo(10.0, 0.001));
      });
    });

    group('trigonometric functions', () {
      test('evaluates sin(0) = 0', () {
        expect(eval(r'\sin{0}'), closeTo(0.0, 0.001));
      });

      test('evaluates sin(pi/2) = 1', () {
        expect(eval(r'\sin{1.5707963}'), closeTo(1.0, 0.001));
      });

      test('evaluates cos(0) = 1', () {
        expect(eval(r'\cos{0}'), closeTo(1.0, 0.001));
      });

      test('evaluates cos(pi) = -1', () {
        expect(eval(r'\cos{3.1415926}'), closeTo(-1.0, 0.001));
      });

      test('evaluates tan(0) = 0', () {
        expect(eval(r'\tan{0}'), closeTo(0.0, 0.001));
      });

      test('evaluates asin(0) = 0', () {
        expect(eval(r'\asin{0}'), closeTo(0.0, 0.001));
      });

      test('evaluates asin(1) = pi/2', () {
        expect(eval(r'\asin{1}'), closeTo(1.5707963, 0.001));
      });

      test('evaluates acos(1) = 0', () {
        expect(eval(r'\acos{1}'), closeTo(0.0, 0.001));
      });

      test('evaluates atan(0) = 0', () {
        expect(eval(r'\atan{0}'), closeTo(0.0, 0.001));
      });

      test('evaluates atan(1) = pi/4', () {
        expect(eval(r'\atan{1}'), closeTo(0.7853981, 0.001));
      });

      test('throws on asin out of range', () {
        expect(
          () => eval(r'\asin{2}'),
          throwsA(isA<EvaluatorException>()),
        );
      });

      test('throws on acos out of range', () {
        expect(
          () => eval(r'\acos{-2}'),
          throwsA(isA<EvaluatorException>()),
        );
      });
    });

    group('other functions', () {
      test('evaluates sqrt(4) = 2', () {
        expect(eval(r'\sqrt{4}'), closeTo(2.0, 0.001));
      });

      test('evaluates sqrt(2)', () {
        expect(eval(r'\sqrt{2}'), closeTo(1.4142135, 0.001));
      });

      test('evaluates abs(-5) = 5', () {
        expect(eval(r'\abs{-5}'), closeTo(5.0, 0.001));
      });

      test('evaluates |-5| = 5 (pipe notation)', () {
        expect(eval(r'|-5|'), closeTo(5.0, 0.001));
      });

      test('evaluates |3.7| = 3.7', () {
        expect(eval(r'|3.7|'), closeTo(3.7, 0.001));
      });

      test('evaluates |-x| with x=4', () {
        expect(eval(r'|-x|', {'x': 4}), closeTo(4.0, 0.001));
      });

      test('evaluates |x^2 - 4| with x=1', () {
        expect(eval(r'|x^2 - 4|', {'x': 1}), closeTo(3.0, 0.001));
      });

      test('evaluates nested absolute values ||x|| with x=-5', () {
        expect(eval(r'||x||', {'x': -5}), closeTo(5.0, 0.001));
      });

      test('sqrt of negative returns complex', () {
        final result = evaluator.evaluate(parse(r'\sqrt{-1}'), {});
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.imaginary, closeTo(1.0, 0.001));
      });
    });

    group('rounding functions', () {
      test('evaluates ceil(1.2) = 2', () {
        expect(eval(r'\ceil{1.2}'), 2.0);
      });

      test('evaluates floor(1.8) = 1', () {
        expect(eval(r'\floor{1.8}'), 1.0);
      });

      test('evaluates round(1.5) = 2', () {
        expect(eval(r'\round{1.5}'), 2.0);
      });

      test('evaluates round(1.4) = 1', () {
        expect(eval(r'\round{1.4}'), 1.0);
      });

      test('evaluates exp(0) = 1', () {
        expect(eval(r'\exp{0}'), 1.0);
      });

      test('evaluates exp(1) = e', () {
        expect(eval(r'\exp{1}'), closeTo(2.718281828, 0.001));
      });
    });

    group('sum and product', () {
      test('evaluates simple sum', () {
        // sum_{i=1}^{3} i = 1 + 2 + 3 = 6
        expect(eval(r'\sum_{i=1}^{3} i'), 6.0);
      });

      test('evaluates sum of squares', () {
        // sum_{i=1}^{3} i^2 = 1 + 4 + 9 = 14
        expect(eval(r'\sum_{i=1}^{3} i^{2}'), 14.0);
      });

      test('evaluates sum with constant', () {
        // sum_{i=1}^{5} 2 = 2 * 5 = 10
        expect(eval(r'\sum_{i=1}^{5} 2'), 10.0);
      });

      test('evaluates factorial via product', () {
        // prod_{i=1}^{5} i = 5! = 120
        expect(eval(r'\prod_{i=1}^{5} i'), 120.0);
      });

      test('evaluates product of constants', () {
        // prod_{i=1}^{3} 2 = 2^3 = 8
        expect(eval(r'\prod_{i=1}^{3} 2'), 8.0);
      });

      test('evaluates product with expression', () {
        // prod_{i=1}^{3} (i + 1) = 2 * 3 * 4 = 24
        expect(eval(r'\prod_{i=1}^{3} (i + 1)'), 24.0);
      });
    });

    group('constants', () {
      test('evaluates sin(pi) = 0', () {
        // Using variable 'p' which can be bound to pi value
        expect(eval(r'\sin{p}', {'p': 3.14159265358979}), closeTo(0.0, 0.001));
      });

      test('evaluates e constant via ln', () {
        // ln(e) = 1, using variable bound to e
        expect(eval(r'\ln{x}', {'x': 2.71828182845905}), closeTo(1.0, 0.001));
      });

      test('constant fallback works', () {
        // Single letter 'e' should resolve to Euler's number from constants
        expect(eval('e'), closeTo(2.71828182845905, 0.0001));
      });

      test('user variable overrides constant', () {
        // User can override built-in constants
        expect(eval('e', {'e': 3.0}), 3.0);
      });
    });

    group('hyperbolic functions', () {
      test('evaluates sinh(0) = 0', () {
        expect(eval(r'\sinh{0}'), closeTo(0.0, 0.001));
      });

      test('evaluates cosh(0) = 1', () {
        expect(eval(r'\cosh{0}'), closeTo(1.0, 0.001));
      });

      test('evaluates tanh(0) = 0', () {
        expect(eval(r'\tanh{0}'), closeTo(0.0, 0.001));
      });
    });

    group('factorial and sign', () {
      test('evaluates factorial 5! = 120', () {
        expect(eval(r'\factorial{5}'), 120.0);
      });

      test('evaluates factorial 0! = 1', () {
        expect(eval(r'\factorial{0}'), 1.0);
      });

      test('evaluates sgn(5) = 1', () {
        expect(eval(r'\sgn{5}'), 1.0);
      });

      test('evaluates sgn(-3) = -1', () {
        expect(eval(r'\sgn{-3}'), -1.0);
      });

      test('evaluates sgn(0) = 0', () {
        expect(eval(r'\sgn{0}'), 0.0);
      });
    });
  });
}
