import 'package:test/test.dart';
import 'package:texpr/texpr.dart';
import 'dart:math' as math;

void main() {
  group('Extended Evaluator Tests', () {
    final evaluator = Evaluator();

    Expression parse(String input) {
      final tokens = Tokenizer(input).tokenize();
      return Parser(tokens).parse();
    }

    double eval(String input, [Map<String, double> vars = const {}]) {
      return evaluator.evaluate(parse(input), vars).asNumeric();
    }

    group('Trigonometry', () {
      test('evaluates sin', () {
        expect(eval(r'\sin{0}'), 0.0);
        expect(eval(r'\sin{\pi}'), closeTo(0.0, 1e-10));
        expect(eval(r'\sin{\frac{\pi}{2}}'), closeTo(1.0, 1e-10));
      });

      test('evaluates cos', () {
        expect(eval(r'\cos{0}'), 1.0);
        expect(eval(r'\cos{\pi}'), closeTo(-1.0, 1e-10));
        expect(eval(r'\cos{\frac{\pi}{2}}'), closeTo(0.0, 1e-10));
      });

      test('evaluates tan', () {
        expect(eval(r'\tan{0}'), 0.0);
        expect(eval(r'\tan{\frac{\pi}{4}}'), closeTo(1.0, 1e-10));
      });

      test('evaluates asin', () {
        expect(eval(r'\asin{0}'), 0.0);
        expect(eval(r'\asin{1}'), closeTo(math.pi / 2, 1e-10));
      });

      test('evaluates acos', () {
        expect(eval(r'\acos{1}'), 0.0);
        expect(eval(r'\acos{0}'), closeTo(math.pi / 2, 1e-10));
      });

      test('evaluates atan', () {
        expect(eval(r'\atan{0}'), 0.0);
        expect(eval(r'\atan{1}'), closeTo(math.pi / 4, 1e-10));
      });

      test('throws on asin domain error', () {
        expect(() => eval(r'\asin{2}'), throwsA(isA<EvaluatorException>()));
        expect(() => eval(r'\asin{-2}'), throwsA(isA<EvaluatorException>()));
      });

      test('throws on acos domain error', () {
        expect(() => eval(r'\acos{2}'), throwsA(isA<EvaluatorException>()));
        expect(() => eval(r'\acos{-2}'), throwsA(isA<EvaluatorException>()));
      });
    });

    group('Logarithms', () {
      test('evaluates ln', () {
        expect(eval(r'\ln{e}'), closeTo(1.0, 1e-10));
        expect(eval(r'\ln{1}'), 0.0);
      });

      test('evaluates log base 10', () {
        expect(eval(r'\log{100}'), closeTo(2.0, 1e-10));
        expect(eval(r'\log{10}'), closeTo(1.0, 1e-10));
      });

      test('evaluates log with custom base', () {
        expect(eval(r'\log_{2}{8}'), closeTo(3.0, 1e-10));
        expect(eval(r'\log_{3}{9}'), closeTo(2.0, 1e-10));
      });

      test('ln of zero returns negative infinity complex', () {
        final result = evaluator.evaluate(parse(r'\ln{0}'), {});
        expect(result.isComplex, isTrue);
        final c = (result as ComplexResult).value;
        expect(c.real.isInfinite && c.real < 0, isTrue);
      });

      test('ln of negative returns complex', () {
        final result = evaluator.evaluate(parse(r'\ln{-1}'), {});
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.imaginary, closeTo(math.pi, 1e-10));
      });

      test('log of zero/negative returns complex', () {
        // log(0) returns -infinity
        final result0 = evaluator.evaluate(parse(r'\log{0}'), {});
        expect(result0.isComplex, isTrue);
        // log(-1) returns complex
        final result1 = evaluator.evaluate(parse(r'\log{-1}'), {});
        expect(result1, isA<ComplexResult>());
      });

      test('throws on invalid log base', () {
        expect(() => eval(r'\log_{1}{10}'), throwsA(isA<EvaluatorException>()));
        expect(() => eval(r'\log_{0}{10}'), throwsA(isA<EvaluatorException>()));
        expect(
            () => eval(r'\log_{-1}{10}'), throwsA(isA<EvaluatorException>()));
      });
    });

    group('Roots', () {
      test('evaluates sqrt', () {
        expect(eval(r'\sqrt{4}'), 2.0);
        expect(eval(r'\sqrt{9}'), 3.0);
        expect(eval(r'\sqrt{2}'), closeTo(math.sqrt(2), 1e-10));
      });

      test('sqrt of negative returns complex', () {
        final result = evaluator.evaluate(parse(r'\sqrt{-1}'), {});
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.imaginary, closeTo(1.0, 1e-10));
      });
    });

    group('Fractions', () {
      test('evaluates simple fraction', () {
        expect(eval(r'\frac{1}{2}'), 0.5);
        expect(eval(r'\frac{3}{4}'), 0.75);
      });

      test('evaluates nested fractions', () {
        expect(eval(r'\frac{1}{\frac{1}{2}}'), 2.0);
        expect(eval(r'\frac{\frac{1}{2}}{2}'), 0.25);
      });

      test('throws on division by zero in fraction', () {
        expect(() => eval(r'\frac{1}{0}'), throwsA(isA<EvaluatorException>()));
      });
    });

    group('Implicit Multiplication', () {
      test('evaluates number and variable', () {
        expect(eval('2x', {'x': 3}), 6.0);
      });

      test('evaluates variable and variable', () {
        // Assuming implicit multiplication is supported for variables
        // Note: This might depend on tokenizer/parser implementation
        // If 'xy' is tokenized as a single variable, this test might fail or need adjustment
        // Based on tokenizer, letters are read as variables. 'xy' might be a variable name.
        // Let's check if 'x y' works (with space)
        expect(eval('x y', {'x': 2, 'y': 3}), 6.0);
      });

      test('evaluates number and parenthesis', () {
        expect(eval('2(3+1)'), 8.0);
      });

      test('evaluates variable and parenthesis', () {
        expect(eval('x(x+1)', {'x': 2}), 6.0);
      });

      test('evaluates parenthesis and parenthesis', () {
        expect(eval('(x+1)(x-1)', {'x': 3}), 8.0);
      });
    });

    group('Constants', () {
      test('evaluates pi', () {
        expect(eval(r'\pi'), closeTo(math.pi, 1e-10));
      });

      test('evaluates e', () {
        expect(eval('e'), closeTo(math.e, 1e-10));
      });

      test('evaluates phi', () {
        expect(eval(r'\phi'), closeTo((1 + math.sqrt(5)) / 2, 1e-10));
      });
    });

    group('Complex Expressions', () {
      test('evaluates combination of operations', () {
        // sin(pi/2) + log(100) * sqrt(4) = 1 + 2 * 2 = 5
        expect(eval(r'\sin{\frac{\pi}{2}} + \log{100} \times \sqrt{4}'),
            closeTo(5.0, 1e-10));
      });

      test('evaluates nested functions', () {
        // sqrt(3^2 + 4^2) = 5
        expect(eval(r'\sqrt{3^{2} + 4^{2}}'), 5.0);
      });

      test('evaluates expression with negative numbers', () {
        expect(eval(r'-2 + 5'), 3.0);
        expect(eval(r'5 + -2'), 3.0);
        expect(eval(r'5 - -2'), 7.0);
      });
    });

    group('More Implicit Multiplication', () {
      test('evaluates implicit multiplication with constant', () {
        expect(eval(r'2\pi'), closeTo(2 * math.pi, 1e-10));
      });

      test('evaluates implicit multiplication with variable no space', () {
        // 'xy' is tokenized as 'x' and 'y', so it becomes 'x * y'
        expect(eval('xy', {'x': 2, 'y': 3}), 6.0);

        // This should fail because it looks for 'x' and 'y', not 'xy'
        expect(
            () => eval('xy', {'xy': 10}), throwsA(isA<EvaluatorException>()));
      });
    });

    group('Matrix Operations', () {
      test('evaluates matrix determinant', () {
        // det([[1, 2], [3, 4]]) = 1*4 - 2*3 = 4 - 6 = -2
        final matrix = r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}';
        expect(eval('\\det{$matrix}'), -2.0);
      });

      test('evaluates matrix addition', () {
        final m1 = r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}';
        final m2 = r'\begin{matrix} 5 & 6 \\ 7 & 8 \end{matrix}';
        // Result: [[6, 8], [10, 12]]
        // Since eval returns dynamic (double or Matrix), we need to cast or check properties.
        // But eval defined in this file returns double.
        // I need to change eval signature or use evaluator.evaluate directly.

        final result = evaluator.evaluate(parse('$m1 + $m2')).asMatrix();
        expect(result, isA<Matrix>());
        final m = result;
        expect(m.data[0][0], 6.0);
        expect(m.data[1][1], 12.0);
      });

      test('evaluates matrix subtraction', () {
        final m1 = r'\begin{matrix} 5 & 6 \\ 7 & 8 \end{matrix}';
        final m2 = r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}';
        // Result: [[4, 4], [4, 4]]
        final result = evaluator.evaluate(parse('$m1 - $m2')).asMatrix();
        expect(result, isA<Matrix>());
        final m = result;
        expect(m.data[0][0], 4.0);
        expect(m.data[1][1], 4.0);
      });

      test('throws on matrix dimension mismatch', () {
        final m1 = r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}';
        final m2 = r'\begin{matrix} 1 & 2 \end{matrix}';
        expect(() => evaluator.evaluate(parse('$m1 + $m2')),
            throwsA(isA<EvaluatorException>()));
      });
    });

    group('Calculus', () {
      test('evaluates limit', () {
        // lim_{x \to 0} (sin(x)/x) = 1
        expect(eval(r'\lim_{x \to 0} \frac{\sin{x}}{x}'), closeTo(1.0, 1e-4));
      });

      test('evaluates limit at infinity', () {
        // lim_{x \to \infty} (1/x) = 0
        expect(eval(r'\lim_{x \to \infty} \frac{1}{x}'), closeTo(0.0, 1e-4));
      });

      test('evaluates sum', () {
        // \sum_{i=1}^{3} i = 1 + 2 + 3 = 6
        expect(eval(r'\sum_{i=1}^{3} i'), 6.0);
      });

      test('evaluates product', () {
        // \prod_{i=1}^{3} i = 1 * 2 * 3 = 6
        expect(eval(r'\prod_{i=1}^{3} i'), 6.0);
      });

      test('evaluates integral', () {
        // \int_{0}^{1} x dx = [x^2/2]_0^1 = 0.5
        // The parser expects a differential like 'dx' at the end.
        // 'x dx' is parsed as 'x * d * x'
        expect(eval(r'\int_{0}^{1} x dx'), closeTo(0.5, 1e-2));
      });

      test('throws on integral without differential', () {
        expect(() => eval(r'\int_{0}^{1} x'), throwsA(isA<ParserException>()));
      });
    });

    group('Implicit Multiplication Options', () {
      test('treats xy as x*y when implicit multiplication is enabled (default)',
          () {
        final evaluator = Texpr();
        expect(evaluator.evaluate('xy', {'x': 2, 'y': 3}).asNumeric(), 6.0);
      });

      test('treats xy as variable xy when implicit multiplication is disabled',
          () {
        final evaluator = Texpr(allowImplicitMultiplication: false);
        expect(evaluator.evaluate('xy', {'xy': 10}).asNumeric(), 10.0);

        // Should fail if we try to use x and y
        expect(() => evaluator.evaluate('xy', {'x': 2, 'y': 3}),
            throwsA(isA<EvaluatorException>()));
      });
    });

    group('New Features v0.1.1', () {
      test('evaluates inverse hyperbolic functions', () {
        expect(eval(r'\asinh{0}'), 0.0);
        expect(eval(r'\acosh{1}'), 0.0);
        expect(eval(r'\atanh{0}'), 0.0);
      });

      test('evaluates combinatorics', () {
        expect(eval(r'\binom{5}{2}'), 10.0);
        expect(eval(r'\binom{4}{4}'), 1.0);
        expect(eval(r'\binom{4}{0}'), 1.0);
      });

      test('evaluates number theory', () {
        expect(eval(r'\gcd(12, 18)'), 6.0);
        expect(eval(r'\lcm(12, 18)'), 36.0);
      });

      test('evaluates matrix trace', () {
        final expr = r'\trace{\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}}';
        expect(eval(expr), 5.0);

        final expr2 = r'\tr{\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}}';
        expect(eval(expr2), 5.0);
      });
    });
  });
}
