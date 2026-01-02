import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  group('Equations with Constraints', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    group('Curly brace notation: f(x)=expr{condition}', () {
      test('f(x)=x^{2}-2{-1<x<2} with x=0 (valid)', () {
        final result =
            evaluator.evaluate("f(x)=x^{2}-2{-1<x<2}", {'x': 0}).asNumeric();
        expect(result, -2.0);
      });

      test('f(x)=x^{2}-2{-1<x<2} with x=1 (valid)', () {
        final result =
            evaluator.evaluate("f(x)=x^{2}-2{-1<x<2}", {'x': 1}).asNumeric();
        expect(result, -1.0);
      });

      test('f(x)=x^{2}-2{-1<x<2} with x=3 (invalid)', () {
        final result =
            evaluator.evaluate("f(x)=x^{2}-2{-1<x<2}", {'x': 3}).asNumeric();
        expect(result.isNaN, isTrue);
      });

      test('f(x)=x^{2}-2{-1<x<2} with x=-1 (boundary, invalid)', () {
        final result =
            evaluator.evaluate("f(x)=x^{2}-2{-1<x<2}", {'x': -1}).asNumeric();
        expect(result.isNaN, isTrue);
      });

      test('f(x)=x^{2}-2{-1<x<2} with x=2 (boundary, invalid)', () {
        final result =
            evaluator.evaluate("f(x)=x^{2}-2{-1<x<2}", {'x': 2}).asNumeric();
        expect(result.isNaN, isTrue);
      });

      test('Simple condition with curly braces: x^2{x>0} with x=2', () {
        final result = evaluator.evaluate("x^2{x>0}", {'x': 2}).asNumeric();
        expect(result, 4.0);
      });

      test('Simple condition with curly braces: x^2{x>0} with x=-2', () {
        final result = evaluator.evaluate("x^2{x>0}", {'x': -2}).asNumeric();
        expect(result.isNaN, isTrue);
      });
    });

    group('Comma notation: expr, condition', () {
      test('x^2-2, -1 < x < 2 with x=0 (valid)', () {
        final result =
            evaluator.evaluate("x^2-2, -1 < x < 2", {'x': 0}).asNumeric();
        expect(result, -2.0);
      });

      test('x^2-2, -1 < x < 2 with x=1.5 (valid)', () {
        final result =
            evaluator.evaluate("x^2-2, -1 < x < 2", {'x': 1.5}).asNumeric();
        expect(result, 0.25);
      });

      test('x^2-2, -1 < x < 2 with x=3 (invalid)', () {
        final result =
            evaluator.evaluate("x^2-2, -1 < x < 2", {'x': 3}).asNumeric();
        expect(result.isNaN, isTrue);
      });

      test('x^2-2, -1 < x < 2 with x=-2 (invalid)', () {
        final result =
            evaluator.evaluate("x^2-2, -1 < x < 2", {'x': -2}).asNumeric();
        expect(result.isNaN, isTrue);
      });

      test('Simple condition with comma: x+5, x>=0 with x=10', () {
        final result = evaluator.evaluate("x+5, x>=0", {'x': 10}).asNumeric();
        expect(result, 15.0);
      });

      test('Simple condition with comma: x+5, x>=0 with x=-1', () {
        final result = evaluator.evaluate("x+5, x>=0", {'x': -1}).asNumeric();
        expect(result.isNaN, isTrue);
      });
    });

    group('Chained comparisons', () {
      test('Standalone chained comparison: -1 < x < 2 with x=0', () {
        final result = evaluator.evaluate("-1 < x < 2", {'x': 0}).asNumeric();
        expect(result, 1.0);
      });

      test('Standalone chained comparison: -1 < x < 2 with x=-2', () {
        final result = evaluator.evaluate("-1 < x < 2", {'x': -2}).asNumeric();
        expect(result.isNaN, isTrue);
      });

      test('Standalone chained comparison: 0 <= x <= 10 with x=5', () {
        final result = evaluator.evaluate("0 <= x <= 10", {'x': 5}).asNumeric();
        expect(result, 1.0);
      });

      test('Standalone chained comparison: 0 <= x <= 10 with x=0', () {
        final result = evaluator.evaluate("0 <= x <= 10", {'x': 0}).asNumeric();
        expect(result, 1.0);
      });

      test('Standalone chained comparison: 0 <= x <= 10 with x=11', () {
        final result =
            evaluator.evaluate("0 <= x <= 10", {'x': 11}).asNumeric();
        expect(result.isNaN, isTrue);
      });
    });

    group('Edge cases', () {
      test('Multiple variables in condition', () {
        final result =
            evaluator.evaluate("x+y, x>0", {'x': 2, 'y': 3}).asNumeric();
        expect(result, 5.0);
      });

      test('Complex expression with condition', () {
        final result = evaluator
            .evaluate("2*x^2 + 3*x - 1, -5 < x < 5", {'x': 2}).asNumeric();
        expect(result, 13.0);
      });

      test('Condition with equality', () {
        final result = evaluator.evaluate("x^2, x=2", {'x': 2}).asNumeric();
        expect(result, 4.0);
      });
    });
  });
}
