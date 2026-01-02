import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Tests for MathML export functionality.
void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('MathML Export', () {
    group('Basic Expressions', () {
      test('NumberLiteral', () {
        final expr = evaluator.parse('42');
        final mathml = expr.toMathML();

        expect(mathml, contains('<math'));
        expect(mathml, contains('xmlns'));
        expect(mathml, contains('<mn>42</mn>'));
      });

      test('Variable', () {
        final expr = evaluator.parse('x');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mi>x</mi>'));
      });

      test('Greek variable', () {
        final expr = evaluator.parse(r'\alpha');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mi>α</mi>'));
      });

      test('negative number', () {
        final expr = evaluator.parse('-5');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>-</mo>'));
        expect(mathml, contains('<mn>5</mn>'));
      });

      test('without wrapper', () {
        final expr = evaluator.parse('x');
        final mathml = expr.toMathML(includeWrapper: false);

        expect(mathml, isNot(contains('<math')));
        expect(mathml, contains('<mi>x</mi>'));
      });
    });

    group('Binary Operations', () {
      test('addition', () {
        final expr = evaluator.parse('2 + 3');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mn>2</mn>'));
        expect(mathml, contains('<mo>+</mo>'));
        expect(mathml, contains('<mn>3</mn>'));
      });

      test('subtraction uses minus sign', () {
        final expr = evaluator.parse('5 - 2');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>−</mo>')); // Unicode minus
      });

      test('multiplication uses dot', () {
        final expr = evaluator.parse(r'3 \times 4');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>⋅</mo>')); // Unicode dot
      });

      test('division as mfrac', () {
        final expr = evaluator.parse(r'\frac{10}{2}');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mfrac>'));
        expect(mathml, contains('<mn>10</mn>'));
        expect(mathml, contains('<mn>2</mn>'));
        expect(mathml, contains('</mfrac>'));
      });

      test('power as msup', () {
        final expr = evaluator.parse('x^{2}');
        final mathml = expr.toMathML();

        expect(mathml, contains('<msup>'));
        expect(mathml, contains('<mi>x</mi>'));
        expect(mathml, contains('<mn>2</mn>'));
        expect(mathml, contains('</msup>'));
      });
    });

    group('Functions', () {
      test('sin function', () {
        final expr = evaluator.parse(r'\sin{x}');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mi>sin</mi>'));
        expect(mathml, contains('<mi>x</mi>'));
      });

      test('sqrt as msqrt', () {
        final expr = evaluator.parse(r'\sqrt{x}');
        final mathml = expr.toMathML();

        expect(mathml, contains('<msqrt>'));
        expect(mathml, contains('</msqrt>'));
      });

      test('nth root as mroot', () {
        final expr = evaluator.parse(r'\sqrt[3]{27}');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mroot>'));
        expect(mathml, contains('</mroot>'));
      });

      test('log with base as msub', () {
        final expr = evaluator.parse(r'\log_{2}{8}');
        final mathml = expr.toMathML();

        expect(mathml, contains('<msub>'));
        expect(mathml, contains('<mi>log</mi>'));
      });

      test('absolute value', () {
        final expr = evaluator.parse(r'|x|');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>|</mo>'));
      });
    });

    group('Calculus', () {
      test('summation uses Σ', () {
        final expr = evaluator.parse(r'\sum_{i=1}^{10} i');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>∑</mo>'));
        expect(mathml, contains('<munderover>'));
      });

      test('product uses Π', () {
        final expr = evaluator.parse(r'\prod_{i=1}^{5} i');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>∏</mo>'));
      });

      test('limit uses lim with arrow', () {
        final expr = evaluator.parse(r'\lim_{x \to 0} x');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>lim</mo>'));
        expect(mathml, contains('<mo>→</mo>'));
        expect(mathml, contains('<munder>'));
      });

      test('definite integral', () {
        final expr = evaluator.parse(r'\int_{0}^{1} x dx');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>∫</mo>'));
        expect(mathml, contains('<msubsup>'));
      });

      test('indefinite integral', () {
        final expr = evaluator.parse(r'\int x dx');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>∫</mo>'));
        expect(mathml, contains('<mi>d</mi>'));
      });

      test('binomial coefficient', () {
        final expr = evaluator.parse(r'\binom{5}{2}');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mfrac'));
        expect(mathml, contains('linethickness="0"'));
      });
    });

    group('Comparisons', () {
      test('less than', () {
        final expr = evaluator.parse('x < 5');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>&lt;</mo>')); // XML-escaped
      });

      test('less equal uses ≤', () {
        final expr = evaluator.parse(r'x \leq 5');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>≤</mo>'));
      });

      test('greater equal uses ≥', () {
        final expr = evaluator.parse(r'x \geq 5');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mo>≥</mo>'));
      });
    });

    group('Matrix and Vector', () {
      test('matrix uses mtable', () {
        final expr =
            evaluator.parse(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mtable>'));
        expect(mathml, contains('<mtr>'));
        expect(mathml, contains('<mtd>'));
      });

      test('vector has arrow', () {
        final expr = evaluator.parse(r'\vec{1, 2, 3}');
        final mathml = expr.toMathML();

        expect(mathml, contains('<mover>'));
        expect(mathml, contains('<mo>→</mo>'));
      });
    });

    group('Valid XML', () {
      test('output is well-formed', () {
        final expr = evaluator.parse(r'\frac{-b + \sqrt{b^{2} - 4ac}}{2a}');
        final mathml = expr.toMathML();

        // Should contain opening and closing math tags
        expect(mathml, contains('<math'));
        expect(mathml, contains('</math>'));

        // Count opening and closing tags match for key elements
        expect(
          '<mfrac>'.allMatches(mathml).length,
          '</mfrac>'.allMatches(mathml).length,
        );
        expect(
          '<mrow>'.allMatches(mathml).length,
          '</mrow>'.allMatches(mathml).length,
        );
        expect(
          '<msup>'.allMatches(mathml).length,
          '</msup>'.allMatches(mathml).length,
        );
      });
    });
  });
}
