import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// LaTeX round-trip tests to verify that AST generation
/// properly supports toLatex() round-trip conversion.
void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  /// Helper to test round-trip: parse, toLatex, parse again, compare by evaluation
  void testRoundTrip(String latex, Map<String, double> vars) {
    final expr1 = evaluator.parse(latex);
    final regenerated = expr1.toLatex();
    final expr2 = evaluator.parse(regenerated);

    final result1 = evaluator.evaluate(latex, vars).asNumeric();
    final result2 = evaluator.evaluateParsed(expr2, vars).asNumeric();

    expect(result2, closeTo(result1, 1e-10),
        reason: 'Round-trip failed for: $latex -> $regenerated');
  }

  group('Basic Arithmetic', () {
    test('addition round-trip', () {
      testRoundTrip('2 + 3', {});
    });

    test('subtraction round-trip', () {
      testRoundTrip('5 - 2', {});
    });

    test('multiplication round-trip', () {
      testRoundTrip(r'3 \times 4', {});
    });

    test('division round-trip', () {
      testRoundTrip(r'\frac{10}{2}', {});
    });
  });

  group('Trigonometric Functions', () {
    test('sin round-trip', () {
      testRoundTrip(r'\sin{0.5}', {});
    });

    test('cos round-trip', () {
      testRoundTrip(r'\cos{0.5}', {});
    });

    test('tan round-trip', () {
      testRoundTrip(r'\tan{0.3}', {});
    });

    test('sec round-trip', () {
      testRoundTrip(r'\sec{0.5}', {});
    });

    test('csc round-trip', () {
      testRoundTrip(r'\csc{0.5}', {});
    });

    test('cot round-trip', () {
      testRoundTrip(r'\cot{0.5}', {});
    });

    test('arcsin round-trip', () {
      testRoundTrip(r'\arcsin{0.5}', {});
    });

    test('arccos round-trip', () {
      testRoundTrip(r'\arccos{0.5}', {});
    });

    test('arctan round-trip', () {
      testRoundTrip(r'\arctan{0.5}', {});
    });
  });

  group('Hyperbolic Functions', () {
    test('sinh round-trip', () {
      testRoundTrip(r'\sinh{1}', {});
    });

    test('cosh round-trip', () {
      testRoundTrip(r'\cosh{1}', {});
    });

    test('tanh round-trip', () {
      testRoundTrip(r'\tanh{0.5}', {});
    });

    test('sech round-trip', () {
      testRoundTrip(r'\sech{1}', {});
    });

    test('csch round-trip', () {
      testRoundTrip(r'\csch{1}', {});
    });

    test('coth round-trip', () {
      testRoundTrip(r'\coth{1}', {});
    });

    test('asinh round-trip', () {
      testRoundTrip(r'\asinh{1}', {});
    });

    test('acosh round-trip', () {
      testRoundTrip(r'\acosh{2}', {});
    });

    test('atanh round-trip', () {
      testRoundTrip(r'\atanh{0.5}', {});
    });
  });

  group('Logarithmic Functions', () {
    test('ln round-trip', () {
      testRoundTrip(r'\ln{e}', {});
    });

    test('log base 10 round-trip', () {
      testRoundTrip(r'\log{100}', {});
    });

    test('log with custom base round-trip', () {
      testRoundTrip(r'\log_{2}{8}', {});
    });
  });

  group('Power and Root Functions', () {
    test('power round-trip', () {
      testRoundTrip('2^{3}', {});
    });

    test('square root round-trip', () {
      testRoundTrip(r'\sqrt{16}', {});
    });

    test('cube root round-trip', () {
      testRoundTrip(r'\sqrt[3]{8}', {});
    });

    test('nth root variable index round-trip', () {
      final expr = evaluator.parse(r'\sqrt[n]{x}');
      final latex = expr.toLatex();
      expect(latex, contains(r'\sqrt'));
      expect(latex, contains('n'));
    });
  });

  group('Math Functions', () {
    test('factorial round-trip', () {
      final expr = evaluator.parse(r'\factorial{5}');
      final latex = expr.toLatex();
      expect(latex, anyOf(contains('!'), contains('factorial')));
      final result = evaluator.evaluate(r'\factorial{5}').asNumeric();
      expect(result, closeTo(120, 1e-10));
    });

    test('abs function round-trip', () {
      testRoundTrip(r'\abs{-5}', {});
    });

    test('floor round-trip', () {
      testRoundTrip(r'\floor{3.7}', {});
    });

    test('ceil round-trip', () {
      testRoundTrip(r'\ceil{3.2}', {});
    });

    test('round round-trip', () {
      testRoundTrip(r'\round{3.5}', {});
    });

    test('min round-trip', () {
      final expr = evaluator.parse(r'\min_{3}{5}');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('min'));
    });

    test('max round-trip', () {
      final expr = evaluator.parse(r'\max_{3}{5}');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('max'));
    });

    test('sign/sgn round-trip', () {
      testRoundTrip(r'\sgn{5}', {});
    });
  });

  group('Combinatorics & Number Theory', () {
    test('binomial coefficient round-trip', () {
      testRoundTrip(r'\binom{5}{2}', {});
    });

    test('gcd round-trip', () {
      testRoundTrip(r'\gcd(12, 8)', {});
    });

    test('lcm round-trip', () {
      testRoundTrip(r'\lcm(4, 6)', {});
    });
  });

  group('Calculus', () {
    test('definite integral round-trip', () {
      final expr = evaluator.parse(r'\int_{0}^{1} x dx');
      final latex = expr.toLatex();
      expect(latex, contains(r'\int'));
      expect(latex, contains('dx'));
    });

    test('limit round-trip', () {
      final expr = evaluator.parse(r'\lim_{x \to 0} x');
      final latex = expr.toLatex();
      expect(latex, contains('lim'));
      expect(latex, contains('to'));
    });

    test('derivative round-trip', () {
      final expr = evaluator.parse(r'\frac{d}{dx}(x^2)');
      final latex = expr.toLatex();
      expect(latex, contains(r'\frac{d}{dx}'));
    });
  });

  group('Matrix Operations', () {
    test('matrix determinant round-trip', () {
      final expr =
          evaluator.parse(r'\det(\begin{matrix}1 & 2\\3 & 4\end{matrix})');
      final latex = expr.toLatex();
      expect(latex, contains(r'\det'));
    });

    test('matrix trace round-trip', () {
      final expr =
          evaluator.parse(r'\trace{\begin{matrix}1 & 0\\0 & 1\end{matrix}}');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('tr'));
    });

    test('matrix inverse round-trip', () {
      final expr = evaluator.parse(r'M^{-1}');
      final latex = expr.toLatex();
      expect(latex, contains('-1'));
    });
  });

  group('Constants & Variables', () {
    test('pi round-trip', () {
      final expr = evaluator.parse(r'\pi');
      final latex = expr.toLatex();
      expect(latex, contains('pi'));
    });

    test('hbar round-trip', () {
      final expr = evaluator.parse(r'\hbar');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('hbar'));
    });

    test('variables round-trip', () {
      testRoundTrip('x + y', {'x': 3.0, 'y': 4.0});
    });
  });

  group('Complex Numbers', () {
    test('Re function round-trip', () {
      final expr = evaluator.parse(r'\text{Re}(z)');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('re'));
    });

    test('Im function round-trip', () {
      final expr = evaluator.parse(r'\text{Im}(z)');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('im'));
    });
  });

  group('Extended Notation', () {
    test('Greek Letters round-trip', () {
      final expr = evaluator.parse(r'\Alpha + \beta + \Gamma');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('alpha'));
      expect(latex.toLowerCase(), contains('beta'));
      expect(latex.toLowerCase(), contains('gamma'));
    });

    test('Font Commands round-trip', () {
      final expr = evaluator.parse(r'\mathbf{E}');
      final latex = expr.toLatex();
      expect(latex, contains('mathbf'));
    });

    test('Academic Delimiters round-trip', () {
      testRoundTrip(r'\left(x + 1\right)', {'x': 2.0});
    });
  });

  group('Piecewise Functions', () {
    test('piecewise round-trip', () {
      final expr = evaluator.parse(r'x^2, x > 0');
      final latex = expr.toLatex();
      expect(latex, contains('x'));
      expect(latex, contains('>'));
    });
  });
  group('Unary Operations', () {
    test('negation', () {
      final expr = evaluator.parse('-x');
      final latex = expr.toLatex();
      final result = evaluator.evaluate(latex, {'x': 5.0});
      expect(result.asNumeric(), closeTo(-5, 1e-10));
    });

    test('double negation', () {
      final expr = evaluator.parse('--x');
      final latex = expr.toLatex();
      final result = evaluator.evaluate(latex, {'x': 5.0});
      expect(result.asNumeric(), closeTo(5, 1e-10));
    });

    test('negation of expression', () {
      final expr = evaluator.parse('-(x + y)');
      final latex = expr.toLatex();
      final result = evaluator.evaluate(latex, {'x': 3.0, 'y': 2.0});
      expect(result.asNumeric(), closeTo(-5, 1e-10));
    });
  });

  group('Extended Integrals & Derivatives', () {
    test('double integral', () {
      final expr = evaluator.parse(r'\iint x dx dy');
      final latex = expr.toLatex();
      expect(latex, contains(r'\iint'));
    });

    test('triple integral', () {
      final expr = evaluator.parse(r'\iiint x dx dy dz');
      final latex = expr.toLatex();
      expect(latex, contains(r'\iiint'));
    });

    test('partial derivative', () {
      final expr = evaluator.parse(r'\frac{\partial}{\partial x}(x^{2})');
      final latex = expr.toLatex();
      expect(latex, contains('partial'));
    });
  });

  group('Complex Expressions', () {
    test('quadratic formula style', () {
      testRoundTrip(r'\frac{-b + \sqrt{b^{2} - 4*a*c}}{2*a}',
          {'a': 1.0, 'b': 5.0, 'c': 6.0});
    });

    test('trigonometric identity', () {
      testRoundTrip(r'\sin(x)^{2} + \cos(x)^{2}', {'x': 0.7});
    });

    test('nested expression with multiple operations', () {
      testRoundTrip(
          r'\frac{\sin(x) + \cos(y)}{x^{2} + y^{2}}', {'x': 1.0, 'y': 2.0});
    });

    test('logarithm with nested arguments', () {
      testRoundTrip(r'\ln(\exp(x) + 1)', {'x': 2.0});
    });

    test('power tower', () {
      testRoundTrip('2^{3^{2}}', {});
    });
  });

  group('Edge Cases', () {
    test('negative number', () {
      final expr = evaluator.parse('-5');
      final latex = expr.toLatex();
      final result = evaluator.evaluate(latex);
      expect(result.asNumeric(), closeTo(-5, 1e-10));
    });

    test('decimal number', () {
      final expr = evaluator.parse('3.14159');
      final latex = expr.toLatex();
      final result = evaluator.evaluate(latex);
      expect(result.asNumeric(), closeTo(3.14159, 1e-5));
    });

    test('very small number', () {
      final expr = evaluator.parse('0.000001');
      final latex = expr.toLatex();
      final result = evaluator.evaluate(latex);
      expect(result.asNumeric(), closeTo(0.000001, 1e-10));
    });

    test('expression with many parentheses', () {
      testRoundTrip('((x + 1) * (y - 2))', {'x': 3.0, 'y': 5.0});
    });
  });

  group('All Function Types Preserve', () {
    final functions = [
      (r'\sin(x)', {'x': 0.5}),
      (r'\cos(x)', {'x': 0.5}),
      (r'\tan(x)', {'x': 0.3}),
      (r'\arcsin(0.5)', <String, double>{}),
      (r'\arccos(0.5)', <String, double>{}),
      (r'\arctan(1)', <String, double>{}),
      (r'\sinh(1)', <String, double>{}),
      (r'\cosh(1)', <String, double>{}),
      (r'\tanh(1)', <String, double>{}),
      (r'\ln(x)', {'x': 5.0}),
      (r'\log(x)', {'x': 100.0}),
      (r'\exp(x)', {'x': 2.0}),
      (r'\sqrt{x}', {'x': 16.0}),
      (r'\floor(3.7)', <String, double>{}),
      (r'\ceil(3.2)', <String, double>{}),
      (r'\sec(0.5)', <String, double>{}),
      (r'\csc(0.5)', <String, double>{}),
      (r'\cot(0.5)', <String, double>{}),
    ];

    for (final (latex, vars) in functions) {
      test('function preserves: $latex', () {
        final expr = evaluator.parse(latex);
        final regenerated = expr.toLatex();
        final result1 = evaluator.evaluate(latex, vars).asNumeric();
        final result2 = evaluator.evaluate(regenerated, vars).asNumeric();
        expect(result2, closeTo(result1, 1e-9),
            reason: 'Failed: $latex -> $regenerated');
      });
    }
  });
}
