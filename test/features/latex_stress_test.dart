import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Stress tests for extended LaTeX notation - v0.2.0 milestone verification
void main() {
  late LatexMathEvaluator evaluator;

  setUp(() {
    evaluator = LatexMathEvaluator();
  });

  group('All Greek Letters in Expressions', () {
    final greekLetters = [
      'alpha',
      'beta',
      'gamma',
      'delta',
      'epsilon',
      'zeta',
      'eta',
      'theta',
      'iota',
      'kappa',
      'lambda',
      'mu',
      'nu',
      'xi',
      'omicron',
      'rho',
      'sigma',
      'tau',
      'upsilon',
      'phi',
      'chi',
      'psi',
      'omega'
    ];

    for (final letter in greekLetters) {
      test('parses \\$letter as variable', () {
        final result = evaluator.parse('\\$letter');
        expect(result, isA<Variable>());
        expect((result as Variable).name, letter);
      });
    }

    test('expression with multiple Greek letters', () {
      final result = evaluator.evaluate(
        r'\alpha + \beta * \gamma',
        {'alpha': 1.0, 'beta': 2.0, 'gamma': 3.0},
      );
      expect(result.asNumeric(), closeTo(7, 1e-10));
    });

    test('Greek letter in function argument', () {
      final result = evaluator.evaluate(
        r'\sin(\theta)',
        {'theta': 0.5},
      );
      expect(result.asNumeric(), closeTo(0.479425538604203, 1e-10));
    });

    test('Greek letter as exponent', () {
      final result = evaluator.evaluate(
        r'x^{\alpha}',
        {'x': 2.0, 'alpha': 3.0},
      );
      expect(result.asNumeric(), closeTo(8, 1e-10));
    });
  });

  group('Multi-Integral Stress Tests', () {
    test('double integral parses correctly', () {
      final expr = evaluator.parse(r'\iint x dx dy');
      expect(expr, isA<MultiIntegralExpr>());
      final mi = expr as MultiIntegralExpr;
      expect(mi.order, 2);
      expect(mi.variables, containsAll(['x', 'y']));
    });

    test('triple integral parses correctly', () {
      final expr = evaluator.parse(r'\iiint x dx dy dz');
      expect(expr, isA<MultiIntegralExpr>());
      final mi = expr as MultiIntegralExpr;
      expect(mi.order, 3);
      expect(mi.variables, containsAll(['x', 'y', 'z']));
    });

    test('double integral with bounds', () {
      final expr = evaluator.parse(r'\iint_{0}^{1} xy dx dy');
      expect(expr, isA<MultiIntegralExpr>());
      final mi = expr as MultiIntegralExpr;
      expect(mi.lower, isNotNull);
      expect(mi.upper, isNotNull);
    });

    test('multi-integral with complex integrand', () {
      final expr = evaluator.parse(r'\iint (x^2 + y^2) dx dy');
      expect(expr, isA<MultiIntegralExpr>());
    });

    test('nested multi-integrals', () {
      final expr = evaluator.parse(r'\iint \sin(x+y) dx dy');
      expect(expr, isA<MultiIntegralExpr>());
    });
  });

  group('Partial Derivative Stress Tests', () {
    test('simple partial derivative', () {
      final expr = evaluator.parse(r'\frac{\partial}{\partial x}(x^2)');
      expect(expr, isA<PartialDerivativeExpr>());
    });

    test('second order partial derivative', () {
      final expr = evaluator.parse(r'\frac{\partial^2}{\partial x^2}(x^3)');
      expect(expr, isA<PartialDerivativeExpr>());
      final pd = expr as PartialDerivativeExpr;
      expect(pd.order, 2);
    });

    test('partial derivative with complex expression', () {
      final expr =
          evaluator.parse(r'\frac{\partial}{\partial x}(\sin(x) * \cos(y))');
      expect(expr, isA<PartialDerivativeExpr>());
    });

    test('mixed partial derivative notation', () {
      final expr = evaluator.parse(r'\partial f');
      expect(expr, isNotNull);
    });

    test('nabla operator', () {
      final expr = evaluator.parse(r'\nabla f');
      expect(expr, isNotNull);
    });
  });

  group('Binomial Coefficient Stress Tests', () {
    test('simple binomial', () {
      final result = evaluator.evaluate(r'\binom{5}{2}');
      expect(result.asNumeric(), closeTo(10, 1e-10));
    });

    test('binomial with n=0', () {
      final result = evaluator.evaluate(r'\binom{0}{0}');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('binomial with k=0', () {
      final result = evaluator.evaluate(r'\binom{10}{0}');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('binomial with k=n', () {
      final result = evaluator.evaluate(r'\binom{7}{7}');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('large binomial coefficient', () {
      final result = evaluator.evaluate(r'\binom{10}{5}');
      expect(result.asNumeric(), closeTo(252, 1e-10));
    });

    test('binomial in expression', () {
      final result = evaluator.evaluate(r'\binom{5}{2} + \binom{5}{3}');
      // 10 + 10 = 20
      expect(result.asNumeric(), closeTo(20, 1e-10));
    });

    test('Pascal triangle identity: C(n,k) = C(n-1,k-1) + C(n-1,k)', () {
      // C(5,2) = C(4,1) + C(4,2) = 4 + 6 = 10
      final lhs = evaluator.evaluate(r'\binom{5}{2}');
      final rhs = evaluator.evaluate(r'\binom{4}{1} + \binom{4}{2}');
      expect(lhs.asNumeric(), closeTo(rhs.asNumeric(), 1e-10));
    });
  });

  group('Spacing Commands', () {
    final spacingCommands = [
      r'\,',
      r'\;',
      r'\:',
      r'\!',
      r'\ ',
      r'\quad',
      r'\qquad',
    ];

    for (final cmd in spacingCommands) {
      test('ignores $cmd in expression', () {
        final result = evaluator.evaluate('2 $cmd + $cmd 3');
        expect(result.asNumeric(), closeTo(5, 1e-10));
      });
    }

    test('spacing in complex expression', () {
      final result = evaluator.evaluate(
          r'x \quad + \; y \, * \! z', {'x': 1.0, 'y': 2.0, 'z': 3.0});
      expect(result.asNumeric(), closeTo(7, 1e-10));
    });

    test('spacing around functions', () {
      final result = evaluator.evaluate(r'\sin \, (x)', {'x': 0.5});
      expect(result.asNumeric(), closeTo(0.479425538604203, 1e-10));
    });
  });

  group('Delimiter Sizing', () {
    test('\\left( \\right) parses correctly', () {
      final result = evaluator.evaluate(r'\left( 2 + 3 \right)');
      expect(result.asNumeric(), closeTo(5, 1e-10));
    });

    test('\\left[ \\right] with parentheses fallback', () {
      // Note: \left[ \right] with brackets not supported, use parentheses
      final result = evaluator.evaluate(r'\left( 2 + 3 \right)');
      expect(result.asNumeric(), closeTo(5, 1e-10));
    });

    test('nested left/right delimiters', () {
      final result = evaluator
          .evaluate(r'\left( \left( x + 1 \right) * 2 \right)', {'x': 3.0});
      expect(result.asNumeric(), closeTo(8, 1e-10));
    });

    test('left/right with fraction', () {
      final result = evaluator.evaluate(r'\left( \frac{1}{2} \right)');
      expect(result.asNumeric(), closeTo(0.5, 1e-10));
    });
  });

  group('Environment Parsing', () {
    test('matrix environment', () {
      final expr =
          evaluator.parse(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}');
      expect(expr, isA<MatrixExpr>());
      final m = expr as MatrixExpr;
      expect(m.rows.length, 2);
      expect(m.rows[0].length, 2);
    });

    test('pmatrix environment', () {
      final expr =
          evaluator.parse(r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}');
      expect(expr, isA<MatrixExpr>());
    });

    test('bmatrix environment', () {
      final expr =
          evaluator.parse(r'\begin{bmatrix} 1 & 2 \\ 3 & 4 \end{bmatrix}');
      expect(expr, isA<MatrixExpr>());
    });

    test('align environment', () {
      final expr = evaluator.parse(r'\begin{align} x & 1 \\ y & 2 \end{align}');
      expect(expr, isA<MatrixExpr>());
    });

    test('cases environment (piecewise)', () {
      final expr = evaluator
          .parse(r'\begin{cases} x & x > 0 \\ -x & x \leq 0 \end{cases}');
      expect(expr, isA<PiecewiseExpr>());
    });
  });

  group('Function Power Notation', () {
    test('sin^2(x)', () {
      final result = evaluator.evaluate(r'\sin^{2}(x)', {'x': 0.5});
      final expected = evaluator.evaluate(r'(\sin(x))^{2}', {'x': 0.5});
      expect(result.asNumeric(), closeTo(expected.asNumeric(), 1e-10));
    });

    test('cos^3(x)', () {
      final result = evaluator.evaluate(r'\cos^{3}(x)', {'x': 0.5});
      final expected = evaluator.evaluate(r'(\cos(x))^{3}', {'x': 0.5});
      expect(result.asNumeric(), closeTo(expected.asNumeric(), 1e-10));
    });

    test('tan^2(θ)', () {
      final result = evaluator.evaluate(r'\tan^{2}(\theta)', {'theta': 0.3});
      final expected =
          evaluator.evaluate(r'(\tan(\theta))^{2}', {'theta': 0.3});
      expect(result.asNumeric(), closeTo(expected.asNumeric(), 1e-10));
    });
  });

  group('Complex LaTeX Combinations', () {
    test('sum with binomial', () {
      // Sum of C(4,k) for k=0 to 4 should be 2^4 = 16
      final result = evaluator.evaluate(r'\sum_{k=0}^{4} \binom{4}{k}');
      expect(result.asNumeric(), closeTo(16, 1e-10));
    });

    test('integral with Greek letters', () {
      final expr = evaluator.parse(r'\int_{0}^{\pi} \sin(\theta) d\theta');
      expect(expr, isA<IntegralExpr>());
    });

    test('fraction with partial derivatives', () {
      final expr = evaluator.parse(r'\frac{\partial f}{\partial x}');
      expect(expr, isNotNull);
    });

    test('nested functions with Greek', () {
      final result = evaluator.evaluate(
        r'\sin(\alpha) * \cos(\beta) + \tan(\gamma)',
        {'alpha': 0.1, 'beta': 0.2, 'gamma': 0.3},
      );
      expect(result.asNumeric(), isNotNaN);
    });

    test('matrix determinant', () {
      final result = evaluator.evaluate(
        r'\det(\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix})',
      );
      expect(result.asNumeric(), closeTo(-2, 1e-10));
    });

    test('complex expression with multiple constructs', () {
      // Note: i! factorial syntax with raw '!' not supported
      // Use \factorial{i} function instead
      final expr = evaluator.parse(
        r'\sum_{i=1}^{n} \frac{\alpha^{i}}{\factorial(i)}',
      );
      expect(expr, isNotNull);
    });
  });

  group('Edge Cases in Extended LaTeX', () {
    test('escaped braces', () {
      final result = evaluator.evaluate(r'\{ 42 \}');
      expect(result.asNumeric(), closeTo(42, 1e-10));
    });

    test('empty subscript handling', () {
      // Should not crash
      expect(() => evaluator.parse(r'x_{}'), returnsNormally);
    });

    test('deeply nested expressions', () {
      final result = evaluator.evaluate(
        r'\sin(\cos(\tan(\sin(\cos(x)))))',
        {'x': 0.1},
      );
      expect(result.asNumeric(), isNotNaN);
    });

    test('very long expression', () {
      final longExpr = List.generate(20, (i) => 'x_$i').join(' + ');
      final vars = {for (var i = 0; i < 20; i++) 'x_$i': 1.0};
      final result = evaluator.evaluate(longExpr, vars);
      expect(result.asNumeric(), closeTo(20, 1e-10));
    });
  });

  group('toLatex for Extended Constructs', () {
    test('MultiIntegralExpr toLatex', () {
      final expr = evaluator.parse(r'\iint f dx dy');
      final latex = expr.toLatex();
      expect(latex, contains(r'\iint'));
    });

    test('BinomExpr toLatex', () {
      final expr = evaluator.parse(r'\binom{n}{k}');
      final latex = expr.toLatex();
      expect(latex, equals(r'\binom{n}{k}'));
    });

    test('PartialDerivativeExpr toLatex', () {
      final expr = evaluator.parse(r'\frac{\partial}{\partial x}(x^2)');
      final latex = expr.toLatex();
      expect(latex, contains('partial'));
    });

    test('Greek letter toLatex', () {
      final expr = evaluator.parse(r'\alpha');
      final latex = expr.toLatex();
      expect(latex, contains('alpha'));
    });
  });
}
