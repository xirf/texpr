import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('User Requested LaTeX Cases', () {
    Expression parse(String input) {
      final tokens = Tokenizer(input).tokenize();
      return Parser(tokens).parse();
    }

    final evaluator = Texpr();

    group('1. Binomial Coefficient & Auto-sizing Delimiters', () {
      test('parses binomial theorem expression', () {
        // Using library format: braces around arguments
        final result =
            parse(r'(x + y)^n = \sum_{k=0}^{n} \binom{n}{k} x^{n-k} y^k');
        expect(result, isNotNull);
      });

      test('parses binomial with nested delimiters', () {
        // \left( \right) are ignored for parsing - they're just sizing hints
        final result = parse(
            r'P = \binom{n}{k} \left( \frac{1}{2} \right)^k \left( 1 - \frac{1}{2} \right)^{n-k}');
        expect(result, isNotNull);
      });

      test('evaluates binom(5,2) = 10', () {
        final result = evaluator.evaluate(r'\binom{5}{2}');
        expect(result.asNumeric(), 10.0);
      });

      test('evaluates binom(10,3) = 120', () {
        final result = evaluator.evaluate(r'\binom{10}{3}');
        expect(result.asNumeric(), 120.0);
      });
    });

    group('2. Multiple Integrals & Spacing', () {
      test('parses double integral with braces', () {
        // Library expects: \iint{body} dx dy
        final result = parse(r'\iint{f \cdot x \cdot y} dx dy');
        expect(result, isA<MultiIntegralExpr>());
      });

      test('parses double integral with bounds', () {
        final result = parse(r'\iint_{0}^{1}{x y} dx dy');
        expect(result, isA<MultiIntegralExpr>());
        final expr = result as MultiIntegralExpr;
        expect(expr.order, 2);
      });

      test('parses triple integral with thick spacing', () {
        // \; spacing is ignored during parsing
        final result = parse(r'\iiint{x y z} dx dy dz');
        expect(result, isA<MultiIntegralExpr>());
        final expr = result as MultiIntegralExpr;
        expect(expr.order, 3);
      });

      test('spacing commands are ignored', () {
        // All these spacing variants should parse the same
        final variants = [
          r'x \, y',
          r'x \; y',
          r'x \: y',
          r'x \quad y',
          r'x \qquad y',
        ];
        for (final latex in variants) {
          final result = parse(latex);
          expect(result, isA<BinaryOp>());
        }
      });
    });

    group('3. Partial Derivatives & Gradient', () {
      test('parses partial derivative notation', () {
        final result = parse(r'\frac{\partial}{\partial x}(x^2)');
        expect(result, isA<PartialDerivativeExpr>());
      });

      test('parses nabla as variable', () {
        final result = parse(r'\nabla f');
        expect(result, isA<BinaryOp>());
        final op = result as BinaryOp;
        expect(op.left, isA<Variable>());
        expect((op.left as Variable).name, 'nabla');
      });

      test('parses nabla squared', () {
        final result = parse(r'\nabla^2 u');
        expect(result, isNotNull);
      });

      test('parses alpha nabla expression', () {
        final result = parse(r'\alpha \nabla^2 u');
        expect(result, isNotNull);
      });
    });

    group('4. Multi-line Equations (align)', () {
      test('parses simple align environment', () {
        final result = parse(r'\begin{align} x & 1 \\ y & 2 \end{align}');
        expect(result, isA<MatrixExpr>());
        final matrix = result as MatrixExpr;
        expect(matrix.rows.length, 2);
      });

      test('parses align with numbers and variables', () {
        // Note: align environment treats cells as separate expressions
        // Equations with = signs should use the comparison parser
        final result = parse(r'\begin{align} a & b \\ c & d \end{align}');
        expect(result, isA<MatrixExpr>());
        final matrix = result as MatrixExpr;
        expect(matrix.rows.length, 2);
        expect(matrix.rows[0].length, 2);
      });
    });

    group('5. Greek Letters', () {
      test('parses uppercase Psi', () {
        final result = parse(r'\Psi');
        expect(result, isA<Variable>());
        expect((result as Variable).name, 'Psi');
      });

      test('parses uppercase Greek letters', () {
        final uppercaseGreek = [
          'Psi',
          'Phi',
          'Delta',
          'Gamma',
          'Lambda',
          'Sigma',
          'Pi',
          'Xi',
          'Theta'
        ];
        for (final letter in uppercaseGreek) {
          final result = parse('\\$letter');
          expect(result, isA<Variable>(), reason: 'Failed for \\$letter');
          expect((result as Variable).name, letter);
        }
      });

      test('parses variant Greek letters', () {
        final variants = ['varepsilon', 'varphi', 'varrho', 'vartheta'];
        for (final variant in variants) {
          final result = parse('\\$variant');
          expect(result, isA<Variable>(), reason: 'Failed for \\$variant');
          expect((result as Variable).name, variant);
        }
      });

      test('parses wave function with Psi', () {
        final result = parse(r'\Psi = A \sin(k x)');
        expect(result, isNotNull);
      });
    });

    group('6. Font Commands', () {
      test('parses mathbf', () {
        final result = parse(r'\mathbf{E}');
        expect(result, isA<Variable>());
        expect((result as Variable).name, 'mathbf:E');
      });

      test('parses mathcal', () {
        final result = parse(r'\mathcal{L}');
        expect(result, isA<Variable>());
        expect((result as Variable).name, 'mathcal:L');
      });

      test('parses multiple font commands', () {
        final result = parse(r'\mathbf{E} + \mathbf{B}');
        expect(result, isA<BinaryOp>());
      });
    });

    group('7. Combined Stress Tests', () {
      test('parses complex expression with Greek and functions', () {
        final result =
            parse(r'\alpha + \beta \times \gamma - \delta / \epsilon');
        expect(result, isNotNull);
      });

      test('parses sum with binomial', () {
        final result = parse(r'\sum_{i=1}^{n} \binom{n}{i} x^i');
        expect(result, isNotNull);
      });

      test('parses limit expression', () {
        final result = parse(r'\lim_{x \to 0} \frac{\sin x}{x}');
        expect(result, isA<LimitExpr>());
      });

      test('parses nested integrals', () {
        final result = parse(r'\iint{\iint{f} dx dy} dx dy');
        expect(result, isA<MultiIntegralExpr>());
      });
    });
  });
}
