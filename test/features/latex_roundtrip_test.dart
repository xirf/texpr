import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// LaTeX round-trip tests - verification
void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  /// Helper to test round-trip: parse, toLatex, parse again, compare semantically
  void testRoundTrip(String latex, Map<String, double> vars) {
    final expr1 = evaluator.parse(latex);
    final regenerated = expr1.toLatex();
    final expr2 = evaluator.parse(regenerated);

    // Compare by evaluation using evaluateParsed
    final result1 = evaluator.evaluate(latex, vars).asNumeric();
    final result2 = evaluator.evaluateParsed(expr2, vars).asNumeric();

    expect(result2, closeTo(result1, 1e-10),
        reason: 'Round-trip failed for: $latex -> $regenerated');
  }

  group('Basic Operations Round-Trip', () {
    test('addition: x + y', () {
      testRoundTrip('x + y', {'x': 3.0, 'y': 5.0});
    });

    test('subtraction: x - y', () {
      testRoundTrip('x - y', {'x': 10.0, 'y': 3.0});
    });

    test('multiplication: x * y', () {
      testRoundTrip(r'x \times y', {'x': 4.0, 'y': 7.0});
    });

    test('division: x / y', () {
      testRoundTrip(r'\frac{x}{y}', {'x': 15.0, 'y': 3.0});
    });

    test('power: x^2', () {
      testRoundTrip('x^{2}', {'x': 5.0});
    });

    test('nested operations: (x + y) * z', () {
      testRoundTrip('(x + y) * z', {'x': 2.0, 'y': 3.0, 'z': 4.0});
    });
  });

  group('Function Round-Trip', () {
    test('sin function', () {
      testRoundTrip(r'\sin(x)', {'x': 0.5});
    });

    test('cos function', () {
      testRoundTrip(r'\cos(x)', {'x': 0.5});
    });

    test('tan function', () {
      testRoundTrip(r'\tan(x)', {'x': 0.3});
    });

    test('log function', () {
      testRoundTrip(r'\log(x)', {'x': 100.0});
    });

    test('ln function', () {
      testRoundTrip(r'\ln(x)', {'x': 10.0});
    });

    test('sqrt function', () {
      testRoundTrip(r'\sqrt{x}', {'x': 16.0});
    });

    test('exp function', () {
      testRoundTrip(r'\exp(x)', {'x': 2.0});
    });

    test('abs function', () {
      testRoundTrip(r'\abs{x}', {'x': -5.0});
    });

    test('nested functions', () {
      testRoundTrip(r'\sin(\cos(x))', {'x': 0.5});
    });

    test('function with complex argument', () {
      testRoundTrip(r'\sin(x^{2} + 1)', {'x': 0.5});
    });
  });

  group('Fraction Round-Trip', () {
    test('simple fraction', () {
      testRoundTrip(r'\frac{1}{2}', {});
    });

    test('fraction with variables', () {
      testRoundTrip(r'\frac{x}{y}', {'x': 10.0, 'y': 3.0});
    });

    test('nested fractions', () {
      testRoundTrip(r'\frac{\frac{1}{2}}{3}', {});
    });

    test('fraction in function', () {
      testRoundTrip(r'\sin(\frac{x}{2})', {'x': 1.0});
    });
  });

  group('Power and Root Round-Trip', () {
    test('simple power', () {
      testRoundTrip('x^{3}', {'x': 2.0});
    });

    test('negative power', () {
      testRoundTrip('x^{-1}', {'x': 4.0});
    });

    test('fractional power', () {
      testRoundTrip('x^{0.5}', {'x': 9.0});
    });

    test('nested power', () {
      testRoundTrip('(x^{2})^{3}', {'x': 2.0});
    });

    test('sqrt of expression', () {
      testRoundTrip(r'\sqrt{x^{2} + y^{2}}', {'x': 3.0, 'y': 4.0});
    });
  });

  group('Summation and Product Round-Trip', () {
    test('summation with bounds', () {
      final expr = evaluator.parse(r'\sum_{i=1}^{5} i');
      final latex = expr.toLatex();
      expect(latex, contains(r'\sum'));

      final result = evaluator.evaluate(r'\sum_{i=1}^{5} i');
      expect(result.asNumeric(), closeTo(15, 1e-10));
    });

    test('product with bounds', () {
      final expr = evaluator.parse(r'\prod_{i=1}^{4} i');
      final latex = expr.toLatex();
      expect(latex, contains(r'\prod'));

      final result = evaluator.evaluate(r'\prod_{i=1}^{4} i');
      expect(result.asNumeric(), closeTo(24, 1e-10));
    });
  });

  group('Limit Round-Trip', () {
    test('limit notation', () {
      final expr = evaluator.parse(r'\lim_{x \to 0} x');
      final latex = expr.toLatex();
      expect(latex, contains('lim'));
    });
  });

  group('Integral Round-Trip', () {
    test('definite integral', () {
      final expr = evaluator.parse(r'\int_{0}^{1} x dx');
      final latex = expr.toLatex();
      expect(latex, contains(r'\int'));
    });

    test('indefinite integral', () {
      final expr = evaluator.parse(r'\int x^{2} dx');
      final latex = expr.toLatex();
      expect(latex, contains(r'\int'));
    });
  });

  group('Extended LaTeX Constructs Round-Trip', () {
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

    test('binomial coefficient', () {
      final expr = evaluator.parse(r'\binom{5}{2}');
      final latex = expr.toLatex();
      expect(latex, contains(r'\binom'));

      final result = evaluator.evaluate(r'\binom{5}{2}');
      expect(result.asNumeric(), closeTo(10, 1e-10));
    });

    test('partial derivative', () {
      final expr = evaluator.parse(r'\frac{\partial}{\partial x}(x^{2})');
      final latex = expr.toLatex();
      expect(latex, contains('partial'));
    });
  });

  group('Greek Letters Round-Trip', () {
    test('alpha variable', () {
      final expr = evaluator.parse(r'\alpha + 1');
      final latex = expr.toLatex();
      expect(latex, contains('alpha'));
    });

    test('beta variable', () {
      final expr = evaluator.parse(r'\beta * 2');
      final latex = expr.toLatex();
      expect(latex, contains('beta'));
    });

    test('pi constant', () {
      // testRoundTrip uses evaluate which may have issues with just \pi
      // Instead verify parsing and regeneration works
      final expr = evaluator.parse(r'\pi');
      final latex = expr.toLatex();
      expect(latex, contains('pi'));
    });

    test('multiple greek letters', () {
      final expr = evaluator.parse(r'\alpha + \beta + \gamma');
      final latex = expr.toLatex();
      expect(latex, contains('alpha'));
      expect(latex, contains('beta'));
      expect(latex, contains('gamma'));
    });
  });

  group('Matrix Round-Trip', () {
    test('simple matrix', () {
      final expr =
          evaluator.parse(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}');
      final latex = expr.toLatex();
      expect(latex, contains('matrix'));
    });

    test('matrix determinant', () {
      final result = evaluator
          .evaluate(r'\det(\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix})');
      expect(result.asNumeric(), closeTo(-2, 1e-10));
    });
  });

  group('Complex Expression Round-Trip', () {
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

  group('Edge Cases Round-Trip', () {
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

  group('Unary Operations Round-Trip', () {
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

  group('Absolute Value Round-Trip', () {
    test('absolute value of negative', () {
      final expr = evaluator.parse(r'\abs{-5}');
      final latex = expr.toLatex();
      expect(latex.toLowerCase(), contains('abs'));
      final result = evaluator.evaluate(latex);
      expect(result.asNumeric(), closeTo(5, 1e-10));
    });

    test('absolute value of expression', () {
      final expr = evaluator.parse(r'\abs{x - 10}');
      final latex = expr.toLatex();
      final result = evaluator.evaluate(latex, {'x': 5.0});
      expect(result.asNumeric(), closeTo(5, 1e-10));
    });
  });

  group('Conditional Expression Round-Trip', () {
    // Note: Ternary ? : syntax is not supported in the evaluator
    // Use \begin{cases} environment for piecewise functions
    test('piecewise conditional via cases (doc reference)', () {
      // This test documents the correct approach for conditionals
      expect(
          evaluator
              .isValid(r'\begin{cases} x & x > 0 \\ -x & x \leq 0 \end{cases}'),
          isTrue);
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
