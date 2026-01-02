import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Delimiter Sizing Commands', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    group('\\left and \\right', () {
      test('works with absolute value', () {
        final result1 =
            evaluator.evaluate(r'\sqrt{\left|x+1\right|}', {'x': -2});
        expect(result1.asNumeric(), closeTo(1.0, 1e-10));

        final result2 =
            evaluator.evaluate(r'\sqrt{\left|x+1\right|}', {'x': 0});
        expect(result2.asNumeric(), closeTo(1.0, 1e-10));

        final result3 =
            evaluator.evaluate(r'\sqrt{\left|x+1\right|}', {'x': 3});
        expect(result3.asNumeric(), closeTo(2.0, 1e-10));
      });

      test('works with parentheses', () {
        final result = evaluator.evaluate(r'\left(2+3\right) * 4');
        expect(result.asNumeric(), closeTo(20.0, 1e-10));
      });

      test('works with curly braces notation', () {
        final result = evaluator.evaluate(r'\left\{2+3\right\} * 5');
        expect(result.asNumeric(), closeTo(25.0, 1e-10));
      });

      test('works with nested delimiters', () {
        final result =
            evaluator.evaluate(r'\left(\left(2+3\right) * 4\right) + 1');
        expect(result.asNumeric(), closeTo(21.0, 1e-10));
      });

      test('works in complex expressions', () {
        final result = evaluator.evaluate(
          r'\frac{\left|x-2\right|}{\left(x+1\right)}',
          {'x': 5},
        );
        expect(result.asNumeric(), closeTo(0.5, 1e-10));
      });
    });

    group('\\big, \\Big, \\bigg, \\Bigg', () {
      test('\\big is ignored', () {
        final result = evaluator.evaluate(r'\big(2+3\big) * 4');
        expect(result.asNumeric(), closeTo(20.0, 1e-10));
      });

      test('\\Big is ignored', () {
        final result = evaluator.evaluate(r'\Big(3+4\Big)');
        expect(result.asNumeric(), closeTo(7.0, 1e-10));
      });

      test('\\bigg is ignored', () {
        final result = evaluator.evaluate(r'\bigg(2+3\bigg) * 4');
        expect(result.asNumeric(), closeTo(20.0, 1e-10));
      });

      test('\\Bigg is ignored', () {
        final result = evaluator.evaluate(r'\Bigg(3+4\Bigg)');
        expect(result.asNumeric(), closeTo(7.0, 1e-10));
      });
    });

    group('Academic LaTeX examples', () {
      test('calculus notation with \\left and \\right', () {
        final result = evaluator.evaluate(
          r'\left(\frac{1}{x}\right)^2',
          {'x': 2},
        );
        expect(result.asNumeric(), closeTo(0.25, 1e-10));
      });

      test('trigonometric expression', () {
        final result = evaluator.evaluate(
          r'\left|\sin{\left(x\right)}\right|',
          {'x': 0},
        );
        expect(result.asNumeric(), closeTo(0.0, 1e-10));
      });

      test('complex fraction with delimiters', () {
        final result = evaluator.evaluate(
          r'\left(\frac{a+b}{c}\right)',
          {'a': 1, 'b': 2, 'c': 3},
        );
        expect(result.asNumeric(), closeTo(1.0, 1e-10));
      });

      test('multi-level nesting from academic notes', () {
        final result = evaluator.evaluate(
          r'\left(\left(\frac{x}{2}\right)^2 + 1\right)',
          {'x': 4},
        );
        expect(result.asNumeric(), closeTo(5.0, 1e-10));
      });
    });

    group('Edge cases', () {
      test('only \\left without \\right', () {
        final result = evaluator.evaluate(r'\left(2+3) * 4');
        expect(result.asNumeric(), closeTo(20.0, 1e-10));
      });

      test('only \\right without \\left', () {
        final result = evaluator.evaluate(r'(2+3\right) * 4');
        expect(result.asNumeric(), closeTo(20.0, 1e-10));
      });

      test('multiple \\left in a row', () {
        final result = evaluator.evaluate(r'\left\left(2+3) * 4');
        expect(result.asNumeric(), closeTo(20.0, 1e-10));
      });
    });
  });
}
