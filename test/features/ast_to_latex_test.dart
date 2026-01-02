import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('AST to LaTeX Round-Trip Tests', () {
    group('Basic Expressions', () {
      test('number literals', () {
        expect(evaluator.parse('42').toLatex(), '42');
        expect(evaluator.parse('3.14159').toLatex(), '3.14159');
        expect(evaluator.parse('0').toLatex(), '0');
        expect(evaluator.parse('-5').toLatex(), '-5');
      });

      test('variables', () {
        expect(evaluator.parse('x').toLatex(), 'x');
        expect(evaluator.parse('y').toLatex(), 'y');
        expect(evaluator.parse('a').toLatex(), 'a');
      });
    });

    group('Binary Operations', () {
      test('addition', () {
        expect(evaluator.parse(r'2+3').toLatex(), '2+3');
        expect(evaluator.parse(r'x+y').toLatex(), 'x+y');
        expect(evaluator.parse(r'1+2+3').toLatex(), '1+2+3');
      });

      test('subtraction', () {
        expect(evaluator.parse(r'5-3').toLatex(), '5-3');
        expect(evaluator.parse(r'x-y').toLatex(), 'x-y');
      });

      test('multiplication', () {
        final latex = evaluator.parse(r'2 \times 3').toLatex();
        expect(latex, contains('2'));
        expect(latex, contains('3'));

        // Implicit multiplication
        expect(evaluator.parse(r'2x').toLatex(), contains('x'));
      });

      test('division as fractions', () {
        expect(evaluator.parse(r'\frac{2}{3}').toLatex(), r'\frac{2}{3}');
        expect(
            evaluator.parse(r'\frac{x+1}{y-2}').toLatex(), r'\frac{x+1}{y-2}');
      });

      test('exponentiation', () {
        expect(evaluator.parse(r'x^2').toLatex(), r'x^{2}');
        expect(evaluator.parse(r'2^{10}').toLatex(), r'2^{10}');
        expect(evaluator.parse(r'e^{-x}').toLatex(), r'e^{-x}');
      });

      test('complex expressions with operator precedence', () {
        // Parentheses should be added where needed
        final expr1 = evaluator.parse(r'2+3 \times 4');
        expect(expr1.toLatex(), contains('2+3'));

        final expr2 = evaluator.parse(r'(2+3) \times 4');
        final latex = expr2.toLatex();
        expect(latex, contains('2+3'));
      });
    });

    group('Functions', () {
      test('trigonometric functions', () {
        expect(evaluator.parse(r'\sin{x}').toLatex(), r'\sin{x}');
        expect(evaluator.parse(r'\cos{2x}').toLatex(), contains(r'\cos'));
        expect(evaluator.parse(r'\tan{x}').toLatex(), contains(r'\tan'));
      });

      test('logarithmic functions', () {
        expect(evaluator.parse(r'\ln{x}').toLatex(), r'\ln{x}');
        expect(evaluator.parse(r'\log{x}').toLatex(), r'\log{x}');
        expect(evaluator.parse(r'\log_{2}{8}').toLatex(), r'\log_{2}{8}');
      });

      test('square root', () {
        expect(evaluator.parse(r'\sqrt{4}').toLatex(), r'\sqrt{4}');
        expect(evaluator.parse(r'\sqrt{x^2+1}').toLatex(), contains(r'\sqrt'));
        expect(evaluator.parse(r'\sqrt[3]{27}').toLatex(), r'\sqrt[3]{27}');
      });

      test('absolute value', () {
        expect(evaluator.parse(r'|x|').toLatex(), r'\left|x\right|');
        expect(evaluator.parse(r'|-5|').toLatex(), r'\left|-5\right|');
      });
    });

    group('Calculus', () {
      test('limits', () {
        final latex = evaluator.parse(r'\lim_{x \to 0}{\frac{x}{2}}').toLatex();
        expect(latex, contains(r'\lim'));
        expect(latex, contains(r'\to'));
        expect(latex, contains(r'\frac'));
      });

      test('derivatives', () {
        final latex1 = evaluator.parse(r'\frac{d}{dx}{x^2}').toLatex();
        expect(latex1, contains(r'\frac{d}{dx}'));

        final latex2 = evaluator.parse(r'\frac{d^2}{dx^2}{x^3}').toLatex();
        expect(latex2, contains(r'\frac{d^{2}}{dx^{2}}'));
      });

      test('integrals', () {
        final latex = evaluator.parse(r'\int_{0}^{1}{x^2} dx').toLatex();
        expect(latex, contains(r'\int'));
        expect(latex, contains(r'dx'));
      });

      test('summation', () {
        final latex = evaluator.parse(r'\sum_{i=1}^{10}{i}').toLatex();
        expect(latex, contains(r'\sum'));
      });

      test('product', () {
        final latex = evaluator.parse(r'\prod_{i=1}^{5}{i}').toLatex();
        expect(latex, contains(r'\prod'));
      });
    });

    group('Matrices and Vectors', () {
      test('matrix', () {
        final latex = evaluator
            .parse(r'\begin{bmatrix}1 & 2\\3 & 4\end{bmatrix}')
            .toLatex();
        expect(latex, contains(r'\begin{bmatrix}'));
        expect(latex, contains(r'\end{bmatrix}'));
        expect(latex, contains('&'));
      });

      test('vector', () {
        final latex = evaluator.parse(r'\vec{1,2,3}').toLatex();
        expect(latex, contains(r'\vec'));
      });
    });

    group('Comparisons', () {
      test('simple comparisons', () {
        expect(evaluator.parse(r'x < 5').toLatex(), r'x < 5');
        expect(evaluator.parse(r'x > 0').toLatex(), r'x > 0');
      });

      test('chained comparisons', () {
        final latex = evaluator.parse(r'-1 < x < 1').toLatex();
        expect(latex, contains('-1'));
        expect(latex, contains('<'));
        expect(latex, contains('x'));
      });
    });

    group('Round-Trip Verification', () {
      void testRoundTrip(String latex) {
        final expr1 = evaluator.parse(latex);
        final regenerated = expr1.toLatex();
        final expr2 = evaluator.parse(regenerated);

        // The ASTs should be structurally equivalent
        expect(expr1, equals(expr2),
            reason: 'Round-trip failed: $latex -> $regenerated');
      }

      test('basic arithmetic', () {
        testRoundTrip(r'2+3');
        testRoundTrip(r'x-y');
        testRoundTrip(r'\frac{1}{2}');
        testRoundTrip(r'x^{2}');
      });

      test('nested expressions', () {
        testRoundTrip(r'\frac{x^{2}+1}{x-1}');
        testRoundTrip(r'x^{y^{z}}');
      });

      test('functions', () {
        testRoundTrip(r'\sin{x}');
        testRoundTrip(r'\sqrt{16}');
        testRoundTrip(r'\log_{10}{100}');
      });

      test('calculus', () {
        testRoundTrip(r'\sum_{i=1}^{10}{i}');
        testRoundTrip(r'\int_{0}^{1}{x} dx');
      });
    });

    group('Complex Real-World Examples', () {
      test('quadratic formula', () {
        final latex =
            evaluator.parse(r'\frac{-b+\sqrt{b^{2}-4ac}}{2a}').toLatex();
        expect(latex, contains(r'\frac'));
        expect(latex, contains(r'\sqrt'));
      });

      test('simplified series', () {
        final latex =
            evaluator.parse(r'\sum_{n=0}^{10}{\frac{x^{n}}{n}}').toLatex();
        expect(latex, contains(r'\sum'));
        expect(latex, contains(r'\frac'));
      });

      test('definite integral with trig', () {
        final latex = evaluator.parse(r'\int_{0}^{\pi}{\sin{x}} dx').toLatex();
        expect(latex, contains(r'\int'));
        expect(latex, contains(r'\sin'));
      });
    });

    group('Edge Cases', () {
      test('negative numbers', () {
        expect(evaluator.parse('-5').toLatex(), '-5');
        expect(evaluator.parse(r'-x').toLatex(), '-x');
      });

      test('decimal numbers', () {
        expect(evaluator.parse('3.14159').toLatex(), '3.14159');
      });

      test('deeply nested expressions', () {
        final expr = evaluator.parse(r'((((x))))');
        final latex = expr.toLatex();
        expect(latex, contains('x'));
      });
    });
  });

  group('AST Manipulation and Regeneration', () {
    test('programmatically build AST and generate LaTeX', () {
      // Build: x^2 + 2x + 1
      const x = Variable('x');
      const one = NumberLiteral(1);
      const two = NumberLiteral(2);

      final xSquared = BinaryOp(x, BinaryOperator.power, two);
      final twoX = BinaryOp(two, BinaryOperator.multiply, x);
      final xSquaredPlus2x = BinaryOp(xSquared, BinaryOperator.add, twoX);
      final result = BinaryOp(xSquaredPlus2x, BinaryOperator.add, one);

      final latex = result.toLatex();
      expect(latex, contains('x^{2}'));
      expect(latex, contains('+'));

      // Should be parseable
      final parsed = evaluator.parse(latex);
      expect(parsed, isNotNull);
    });

    test('modify AST and regenerate', () {
      // Parse original expression
      final original = evaluator.parse(r'x^2');

      // Create modified version: (x^2) + 1
      final modified = BinaryOp(
        original,
        BinaryOperator.add,
        const NumberLiteral(1),
      );

      final latex = modified.toLatex();
      expect(latex, contains('x^{2}'));
      expect(latex, contains('+1'));
    });
  });
}
