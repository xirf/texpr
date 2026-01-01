import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Extended LaTeX Support', () {
    Expression parse(String input) {
      final tokens = Tokenizer(input).tokenize();
      return Parser(tokens).parse();
    }

    group('Multiple Integrals', () {
      test('parses double integral with variables', () {
        final result = parse(r'\iint{x^2} dx dy');
        expect(result, isA<MultiIntegralExpr>());
        final expr = result as MultiIntegralExpr;
        expect(expr.order, 2);
        expect(expr.variables, containsAll(['x', 'y']));
      });

      test('parses triple integral', () {
        final result = parse(r'\iiint{x} dx dy dz');
        expect(result, isA<MultiIntegralExpr>());
        final expr = result as MultiIntegralExpr;
        expect(expr.order, 3);
        expect(expr.variables, containsAll(['x', 'y', 'z']));
      });

      test('parses double integral with bounds', () {
        final result = parse(r'\iint_{0}^{1}{x y} dx dy');
        expect(result, isA<MultiIntegralExpr>());
        final expr = result as MultiIntegralExpr;
        expect(expr.lower, isA<NumberLiteral>());
        expect((expr.lower as NumberLiteral).value, 0.0);
        expect(expr.upper, isA<NumberLiteral>());
        expect((expr.upper as NumberLiteral).value, 1.0);
      });
    });

    group('Partial Derivatives', () {
      test('parses partial derivative notation', () {
        final result = parse(r'\frac{\partial}{\partial x}(x^2)');
        expect(result, isA<PartialDerivativeExpr>());
      });

      test('parses standalone partial as variable', () {
        final result = parse(r'\partial f');
        expect(result, isA<BinaryOp>()); // partial * f
        final op = result as BinaryOp;
        expect(op.left, isA<Variable>());
        expect((op.left as Variable).name, 'partial');
      });

      test('parses nabla as variable', () {
        final result = parse(r'\nabla f');
        expect(result, isA<BinaryOp>()); // nabla * f
        final op = result as BinaryOp;
        expect(op.left, isA<Variable>());
        expect((op.left as Variable).name, 'nabla');
      });
    });

    group('Binomial Coefficients', () {
      test('parses binom', () {
        final result = parse(r'\binom{n}{k}');
        expect(result, isA<BinomExpr>());
        final expr = result as BinomExpr;
        expect(expr.n, isA<Variable>());
        expect(expr.k, isA<Variable>());
      });

      test('evaluates binom', () {
        final evaluator = LatexMathEvaluator();
        expect(evaluator.evaluate(r'\binom{5}{2}').asNumeric(), 10.0);
      });
    });

    group('Greek Letters as Variables', () {
      test('parses alpha, beta, gamma as variables', () {
        final result = parse(r'\alpha + \beta');
        expect(result, isA<BinaryOp>());
        final op = result as BinaryOp;
        expect((op.left as Variable).name, 'alpha');
        expect((op.right as Variable).name, 'beta');
      });

      test('evaluates expressions with Greek variables', () {
        final evaluator = LatexMathEvaluator();
        final result = evaluator.evaluate(r'\alpha \times 2', {'alpha': 5.0});
        expect(result.asNumeric(), 10.0);
      });
    });

    group('Spacing Commands', () {
      test('ignores spacing in expressions', () {
        final result = parse(r'x \, + \; y \quad z');
        expect(result, isA<BinaryOp>());
        final op = result as BinaryOp;
        expect(op.operator, BinaryOperator.add);
      });

      test('handles escaped spaces', () {
        final result = parse(r'x \  y');
        expect(result, isA<BinaryOp>()); // x * y
      });
    });

    group('Multi-line Environments', () {
      test('parses align environment', () {
        final result = parse(r'\begin{align} x & 1 \\ y & 2 \end{align}');
        expect(result, isA<MatrixExpr>());
        final matrix = result as MatrixExpr;
        expect(matrix.rows.length, 2);
      });
    });

    group('toLatex()', () {
      test('MultiIntegralExpr toLatex', () {
        final expr =
            MultiIntegralExpr(2, null, null, const Variable('f'), ['x', 'y']);
        expect(expr.toLatex(), contains(r'\iint'));
        expect(expr.toLatex(), contains('dx dy'));
      });

      test('PartialDerivativeExpr toLatex', () {
        final expr =
            PartialDerivativeExpr(const NumberLiteral(1.0), 'x', order: 2);
        expect(expr.toLatex(), contains(r'\partial^{2}'));
      });

      test('BinomExpr toLatex', () {
        final expr = BinomExpr(const Variable('n'), const Variable('k'));
        expect(expr.toLatex(), r'\binom{n}{k}');
      });
    });

    group('Exhaustive Parser Tests', () {
      final greekLetters = [
        'alpha',
        'beta',
        'gamma',
        'delta',
        'epsilon',
        'zeta',
        'eta',
        'theta',
        'kappa',
        'lambda',
        'mu',
        'rho',
        'sigma',
        'tau',
        'phi',
        'chi',
        'psi',
        'omega'
      ];

      for (final letter in greekLetters) {
        test('parses \\$letter as variable', () {
          final result = parse('\\$letter');
          expect(result, isA<Variable>());
          expect((result as Variable).name, letter);
        });
      }

      final spacingCommands = [
        r'\,',
        r'\;',
        r'\:',
        r'\!',
        r'\ ',
        r'\quad',
        r'\qquad',
        r'\thinspace',
        r'\negspace'
      ];
      for (final cmd in spacingCommands) {
        test('ignores $cmd spacing', () {
          final result = parse('x $cmd + $cmd y');
          expect(result, isA<BinaryOp>());
          expect((result as BinaryOp).operator, BinaryOperator.add);
        });
      }

      test('parses variety of binomials', () {
        for (int n = 0; n < 20; n++) {
          for (int k = 0; k <= n; k++) {
            final result = parse('\\binom{$n}{$k}');
            expect(result, isA<BinomExpr>());
          }
        }
      });

      test('complex combinations', () {
        final complexExprs = [
          r'\iint_{0}^{\pi} \sin(\alpha) d\alpha d\beta',
          r'\frac{\partial^2}{\partial x^2} (x^2 + \binom{n}{k})',
          r'\iiint \nabla \phi \, dV',
          r'\alpha + \beta \times \gamma - \delta / \epsilon',
          r'\sum_{i=1}^{n} \binom{n}{i} x^i',
          r'\lim_{x \to 0} \frac{\sin x}{x} + \text{spacing} \quad \text{test}',
          r'\iint \iint f \, dA \, dB',
          r'\partial f / \partial x + \partial g / \partial y',
          r'x \qquad y \quad z \; a \: b \, c \! d',
        ];
        for (final expr in complexExprs) {
          final result = parse(expr);
          expect(result, isNotNull);
          expect(result.toLatex(), isNotEmpty);
        }
      });
    });

    group('Edge Cases', () {
      test('escaped braces', () {
        final result = parse(r'\{ 42 \}');
        expect(result, isA<NumberLiteral>());
        expect((result as NumberLiteral).value, 42.0);
      });
    });
  });
}
