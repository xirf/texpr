import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Cases Environment Parser Tests', () {
    late LatexMathEvaluator evaluator;

    setUp(() {
      evaluator = LatexMathEvaluator();
    });

    group('Basic Parsing', () {
      test('parses simple two-case piecewise function', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x^2 & x < 0 \\
            2x & x \geq 0
          \end{cases}
        ''');

        expect(expr, isA<PiecewiseExpr>());
        final piecewise = expr as PiecewiseExpr;
        expect(piecewise.cases.length, 2);

        // First case: x^2 when x < 0
        expect(piecewise.cases[0].expression, isA<BinaryOp>());
        expect(piecewise.cases[0].condition, isA<Comparison>());

        // Second case: 2x when x >= 0
        expect(piecewise.cases[1].expression, isA<BinaryOp>());
        expect(piecewise.cases[1].condition, isA<Comparison>());
      });

      test('parses three-case piecewise function', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            0 & x < 0 \\
            x^2 & 0 \leq x \leq 1 \\
            1 & x > 1
          \end{cases}
        ''');

        expect(expr, isA<PiecewiseExpr>());
        final piecewise = expr as PiecewiseExpr;
        expect(piecewise.cases.length, 3);
      });

      test('parses single-case piecewise function', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x + 1 & x > 0
          \end{cases}
        ''');

        expect(expr, isA<PiecewiseExpr>());
        final piecewise = expr as PiecewiseExpr;
        expect(piecewise.cases.length, 1);
      });

      test('parses piecewise with otherwise case', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x^2 & x < 0 \\
            0 & \text{otherwise}
          \end{cases}
        ''');

        expect(expr, isA<PiecewiseExpr>());
        final piecewise = expr as PiecewiseExpr;
        expect(piecewise.cases.length, 2);
        expect(piecewise.cases[1].condition, isNull); // otherwise case
      });

      test('parses ReLU function correctly', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            0 & x < 0 \\
            x & x \geq 0
          \end{cases}
        ''');

        expect(expr, isA<PiecewiseExpr>());
        final piecewise = expr as PiecewiseExpr;
        expect(piecewise.cases.length, 2);

        // First case: 0 when x < 0
        expect(piecewise.cases[0].expression, isA<NumberLiteral>());

        // Second case: x when x >= 0
        expect(piecewise.cases[1].expression, isA<Variable>());
      });
    });

    group('Complex Expressions', () {
      test('parses piecewise with fractions', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            \frac{1}{2}x^2 & x < 0 \\
            \frac{x}{x+1} & x \geq 0
          \end{cases}
        ''');

        expect(expr, isA<PiecewiseExpr>());
        final piecewise = expr as PiecewiseExpr;
        expect(piecewise.cases.length, 2);
      });

      test('parses piecewise with trigonometric functions', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            \sin(x) & x < \pi \\
            \cos(x) & x \geq \pi
          \end{cases}
        ''');

        expect(expr, isA<PiecewiseExpr>());
        final piecewise = expr as PiecewiseExpr;
        expect(piecewise.cases.length, 2);
      });

      test('parses piecewise with absolute value in expression', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            |x| & x < 1 \\
            x^2 & x \geq 1
          \end{cases}
        ''');

        expect(expr, isA<PiecewiseExpr>());
        final piecewise = expr as PiecewiseExpr;
        expect(piecewise.cases.length, 2);
        expect(piecewise.cases[0].expression, isA<AbsoluteValue>());
      });
    });

    group('LaTeX Roundtrip', () {
      test('toLatex generates valid cases environment', () {
        final expr = evaluator.parse(r'''
          \begin{cases}
            x^{2} & x < 0 \\
            x & x \geq 0
          \end{cases}
        ''');

        final latex = expr.toLatex();
        expect(latex, contains(r'\begin{cases}'));
        expect(latex, contains(r'\end{cases}'));
        expect(latex, contains('&'));
      });

      test('roundtrip parsing preserves structure', () {
        final expr1 = evaluator.parse(r'''
          \begin{cases}
            x^{2} & x < 0 \\
            2x & x \geq 0
          \end{cases}
        ''');

        final latex = expr1.toLatex();
        final expr2 = evaluator.parse(latex);

        expect(expr2, isA<PiecewiseExpr>());
        final piecewise = expr2 as PiecewiseExpr;
        expect(piecewise.cases.length, 2);
      });
    });

    group('Error Handling', () {
      test('throws on environment mismatch', () {
        expect(
          () => evaluator.parse(r'\begin{cases} x & x > 0 \end{matrix}'),
          throwsA(isA<ParserException>()),
        );
      });
    });
  });
}
