import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Parse and Reuse', () {
    final evaluator = Texpr();

    test('parse returns an Expression', () {
      final ast = evaluator.parse('2 + 3');
      expect(ast, isA<Expression>());
    });

    test('evaluateParsed works with pre-parsed expression', () {
      final ast = evaluator.parse('x + 1');
      expect(evaluator.evaluateParsed(ast, {'x': 2}).asNumeric(), 3.0);
      expect(evaluator.evaluateParsed(ast, {'x': 5}).asNumeric(), 6.0);
      expect(evaluator.evaluateParsed(ast, {'x': 10}).asNumeric(), 11.0);
    });

    test('reuse quadratic expression multiple times', () {
      final ast = evaluator.parse(r'x^{2} + 2x + 1');

      expect(evaluator.evaluateParsed(ast, {'x': 0}).asNumeric(), 1.0);
      expect(evaluator.evaluateParsed(ast, {'x': 1}).asNumeric(), 4.0);
      expect(evaluator.evaluateParsed(ast, {'x': 2}).asNumeric(), 9.0);
      expect(evaluator.evaluateParsed(ast, {'x': -1}).asNumeric(), 0.0);
    });

    test('reuse multi-variable expression', () {
      final ast = evaluator.parse('a + b * c');

      expect(
          evaluator.evaluateParsed(ast, {'a': 1, 'b': 2, 'c': 3}).asNumeric(),
          7.0);
      expect(
          evaluator.evaluateParsed(ast, {'a': 10, 'b': 5, 'c': 2}).asNumeric(),
          20.0);
      expect(
          evaluator.evaluateParsed(ast, {'a': 0, 'b': 0, 'c': 0}).asNumeric(),
          0.0);
    });

    test('reuse trigonometric expression', () {
      final ast = evaluator.parse(r'\sin{x}');

      expect(evaluator.evaluateParsed(ast, {'x': 0}).asNumeric(), 0.0);
      expect(evaluator.evaluateParsed(ast, {'x': 1.5708}).asNumeric(),
          closeTo(1.0, 0.001));
    });

    test('reuse with different variable sets', () {
      final ast = evaluator.parse('x + y');

      expect(evaluator.evaluateParsed(ast, {'x': 1, 'y': 2}).asNumeric(), 3.0);
      expect(
          evaluator.evaluateParsed(ast, {'x': 10, 'y': 20}).asNumeric(), 30.0);
      expect(evaluator.evaluateParsed(ast, {'x': -5, 'y': 5}).asNumeric(), 0.0);
    });

    test('parse once is equivalent to parse+evaluate each time', () {
      const expr = r'x^{3} - 2x^{2} + x - 5';
      final ast = evaluator.parse(expr);

      for (int i = 0; i < 10; i++) {
        final direct =
            evaluator.evaluate(expr, {'x': i.toDouble()}).asNumeric();
        final reused =
            evaluator.evaluateParsed(ast, {'x': i.toDouble()}).asNumeric();
        expect(reused, direct);
      }
    });

    test('reuse with fractions', () {
      final ast = evaluator.parse(r'\frac{a}{b}');

      expect(evaluator.evaluateParsed(ast, {'a': 1, 'b': 2}).asNumeric(), 0.5);
      expect(evaluator.evaluateParsed(ast, {'a': 3, 'b': 4}).asNumeric(), 0.75);
      expect(evaluator.evaluateParsed(ast, {'a': 10, 'b': 5}).asNumeric(), 2.0);
    });

    test('reuse with complex expression', () {
      final ast = evaluator.parse(r'2x^{2} + 3y - \sqrt{z}');

      expect(
          evaluator.evaluateParsed(ast, {'x': 2, 'y': 3, 'z': 4}).asNumeric(),
          closeTo(15.0, 0.001));
      expect(
          evaluator.evaluateParsed(ast, {'x': 1, 'y': 1, 'z': 9}).asNumeric(),
          closeTo(2.0, 0.001));
    });

    test('parse with implicit multiplication', () {
      final ast = evaluator.parse('2x');

      expect(evaluator.evaluateParsed(ast, {'x': 3}).asNumeric(), 6.0);
      expect(evaluator.evaluateParsed(ast, {'x': 10}).asNumeric(), 20.0);
    });

    test('evaluateParsed without variables uses constants', () {
      final ast = evaluator.parse(r'\pi');
      final result = evaluator.evaluateParsed(ast).asNumeric();

      expect(result, closeTo(3.14159, 0.00001));
    });
  });
}
