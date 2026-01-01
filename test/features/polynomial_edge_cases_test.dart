import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Edge case tests for polynomial expansion and factorization - v0.2.0 milestone verification
void main() {
  late SymbolicEngine engine;
  late Evaluator evaluator;

  setUp(() {
    engine = SymbolicEngine();
    evaluator = Evaluator();
  });

  group('High-Degree Polynomial Expansion', () {
    test('(x+1)^4 expands correctly', () {
      final xPlus1 =
          BinaryOp(Variable('x'), BinaryOperator.add, const NumberLiteral(1));
      final expr =
          BinaryOp(xPlus1, BinaryOperator.power, const NumberLiteral(4));
      final expanded = engine.expand(expr);

      for (var x in [0, 1, 2, 3, -1]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(expanded, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('(x+1)^5 expands correctly', () {
      final xPlus1 =
          BinaryOp(Variable('x'), BinaryOperator.add, const NumberLiteral(1));
      final expr =
          BinaryOp(xPlus1, BinaryOperator.power, const NumberLiteral(5));
      final expanded = engine.expand(expr);

      for (var x in [0, 1, 2, -1]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(expanded, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('(x-1)^4 expands correctly', () {
      final xMinus1 = BinaryOp(
          Variable('x'), BinaryOperator.subtract, const NumberLiteral(1));
      final expr =
          BinaryOp(xMinus1, BinaryOperator.power, const NumberLiteral(4));
      final expanded = engine.expand(expr);

      for (var x in [0, 1, 2, 3]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(expanded, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('(2x+3)^3 expands correctly', () {
      final twoX = BinaryOp(
          const NumberLiteral(2), BinaryOperator.multiply, Variable('x'));
      final twoXPlus3 =
          BinaryOp(twoX, BinaryOperator.add, const NumberLiteral(3));
      final expr =
          BinaryOp(twoXPlus3, BinaryOperator.power, const NumberLiteral(3));
      final expanded = engine.expand(expr);

      for (var x in [0, 1, 2, -1]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(expanded, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });
  });

  group('Multinomial Expressions', () {
    test('(x+y)^2 = x^2 + 2xy + y^2', () {
      final xPlusY = BinaryOp(Variable('x'), BinaryOperator.add, Variable('y'));
      final expr =
          BinaryOp(xPlusY, BinaryOperator.power, const NumberLiteral(2));
      final expanded = engine.expand(expr);

      for (var x in [1.0, 2.0, 3.0]) {
        for (var y in [1.0, 2.0, 4.0]) {
          final original =
              evaluator.evaluate(expr, {'x': x, 'y': y}).asNumeric();
          final result =
              evaluator.evaluate(expanded, {'x': x, 'y': y}).asNumeric();
          expect(result, closeTo(original, 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });

    test('(x-y)^2 = x^2 - 2xy + y^2', () {
      final xMinusY =
          BinaryOp(Variable('x'), BinaryOperator.subtract, Variable('y'));
      final expr =
          BinaryOp(xMinusY, BinaryOperator.power, const NumberLiteral(2));
      final expanded = engine.expand(expr);

      for (var x in [3.0, 5.0]) {
        for (var y in [1.0, 2.0]) {
          final original =
              evaluator.evaluate(expr, {'x': x, 'y': y}).asNumeric();
          final result =
              evaluator.evaluate(expanded, {'x': x, 'y': y}).asNumeric();
          expect(result, closeTo(original, 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });

    test('(x+y)^3 expands correctly', () {
      final xPlusY = BinaryOp(Variable('x'), BinaryOperator.add, Variable('y'));
      final expr =
          BinaryOp(xPlusY, BinaryOperator.power, const NumberLiteral(3));
      final expanded = engine.expand(expr);

      for (var x in [1.0, 2.0]) {
        for (var y in [1.0, 3.0]) {
          final original =
              evaluator.evaluate(expr, {'x': x, 'y': y}).asNumeric();
          final result =
              evaluator.evaluate(expanded, {'x': x, 'y': y}).asNumeric();
          expect(result, closeTo(original, 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });

    test('(x+y)(x-y) = x^2 - y^2', () {
      final xPlusY = BinaryOp(Variable('x'), BinaryOperator.add, Variable('y'));
      final xMinusY =
          BinaryOp(Variable('x'), BinaryOperator.subtract, Variable('y'));
      final expr = BinaryOp(xPlusY, BinaryOperator.multiply, xMinusY);
      final expanded = engine.expand(expr);

      for (var x in [3.0, 5.0, 7.0]) {
        for (var y in [1.0, 2.0, 4.0]) {
          final original =
              evaluator.evaluate(expr, {'x': x, 'y': y}).asNumeric();
          final result =
              evaluator.evaluate(expanded, {'x': x, 'y': y}).asNumeric();
          expect(result, closeTo(original, 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });
  });

  group('Edge Case Expansions', () {
    test('(x-x)^2 = 0', () {
      final xMinusX =
          BinaryOp(Variable('x'), BinaryOperator.subtract, Variable('x'));
      final expr =
          BinaryOp(xMinusX, BinaryOperator.power, const NumberLiteral(2));
      final simplified = engine.simplify(expr);

      for (var x in [1.0, 5.0, 10.0]) {
        final result = evaluator.evaluate(simplified, {'x': x}).asNumeric();
        expect(result, closeTo(0, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('(0+x)^3 = x^3', () {
      final zeroPlusX =
          BinaryOp(const NumberLiteral(0), BinaryOperator.add, Variable('x'));
      final expr =
          BinaryOp(zeroPlusX, BinaryOperator.power, const NumberLiteral(3));
      final simplified = engine.simplify(expr);

      for (var x in [2.0, 3.0, 4.0]) {
        final original = evaluator.evaluate(expr, {'x': x}).asNumeric();
        final result = evaluator.evaluate(simplified, {'x': x}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('(1*x)^2 = x^2', () {
      final oneTimesX = BinaryOp(
          const NumberLiteral(1), BinaryOperator.multiply, Variable('x'));
      final expr =
          BinaryOp(oneTimesX, BinaryOperator.power, const NumberLiteral(2));
      final simplified = engine.simplify(expr);

      for (var x in [2.0, 3.0, 5.0]) {
        final original = evaluator.evaluate(expr, {'x': x}).asNumeric();
        final result = evaluator.evaluate(simplified, {'x': x}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });
  });

  group('Difference of Squares Factorization', () {
    test('x^2 - 16 = (x-4)(x+4)', () {
      final xSquared =
          BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
      final expr =
          BinaryOp(xSquared, BinaryOperator.subtract, const NumberLiteral(16));
      final factored = engine.factor(expr);

      for (var x in [0, 4, -4, 5, 10]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(factored, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('x^2 - 25 = (x-5)(x+5)', () {
      final xSquared =
          BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
      final expr =
          BinaryOp(xSquared, BinaryOperator.subtract, const NumberLiteral(25));
      final factored = engine.factor(expr);

      for (var x in [0, 5, -5, 3, 7]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(factored, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('4x^2 - 9 difference of squares', () {
      // 4x^2 = (2x)^2
      final fourXSquared = BinaryOp(
          const NumberLiteral(4),
          BinaryOperator.multiply,
          BinaryOp(
              Variable('x'), BinaryOperator.power, const NumberLiteral(2)));
      final expr = BinaryOp(
          fourXSquared, BinaryOperator.subtract, const NumberLiteral(9));
      final factored = engine.factor(expr);

      for (var x in [0.0, 1.5, -1.5, 2.0]) {
        final original = evaluator.evaluate(expr, {'x': x}).asNumeric();
        final result = evaluator.evaluate(factored, {'x': x}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });
  });

  group('Non-Factorable Expressions', () {
    test('x^2 + 1 remains as is (no real factors)', () {
      final xSquared =
          BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
      final expr =
          BinaryOp(xSquared, BinaryOperator.add, const NumberLiteral(1));
      final factored = engine.factor(expr);

      // Should evaluate the same (may or may not change structure)
      for (var x in [0.0, 1.0, 2.0, -1.0]) {
        final original = evaluator.evaluate(expr, {'x': x}).asNumeric();
        final result = evaluator.evaluate(factored, {'x': x}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('x^2 + x + 1 has no real factors (discriminant < 0)', () {
      // x^2 + x + 1, discriminant = 1 - 4 = -3 < 0
      final xSquared =
          BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
      final xSquaredPlusX =
          BinaryOp(xSquared, BinaryOperator.add, Variable('x'));
      final expr =
          BinaryOp(xSquaredPlusX, BinaryOperator.add, const NumberLiteral(1));
      final factored = engine.factor(expr);

      for (var x in [0.0, 1.0, -1.0, 2.0]) {
        final original = evaluator.evaluate(expr, {'x': x}).asNumeric();
        final result = evaluator.evaluate(factored, {'x': x}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });
  });

  group('Perfect Square Trinomials', () {
    test('x^2 + 2x + 1 = (x+1)^2', () {
      final xSquared =
          BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
      final twoX = BinaryOp(
          const NumberLiteral(2), BinaryOperator.multiply, Variable('x'));
      final xSquaredPlus2x = BinaryOp(xSquared, BinaryOperator.add, twoX);
      final expr =
          BinaryOp(xSquaredPlus2x, BinaryOperator.add, const NumberLiteral(1));
      final factored = engine.factor(expr);

      for (var x in [0, 1, 2, -1, -2]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(factored, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('x^2 - 2x + 1 = (x-1)^2', () {
      final xSquared =
          BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
      final twoX = BinaryOp(
          const NumberLiteral(2), BinaryOperator.multiply, Variable('x'));
      final xSquaredMinus2x = BinaryOp(xSquared, BinaryOperator.subtract, twoX);
      final expr =
          BinaryOp(xSquaredMinus2x, BinaryOperator.add, const NumberLiteral(1));
      final factored = engine.factor(expr);

      for (var x in [0, 1, 2, -1]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(factored, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('x^2 + 4x + 4 = (x+2)^2', () {
      final xSquared =
          BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
      final fourX = BinaryOp(
          const NumberLiteral(4), BinaryOperator.multiply, Variable('x'));
      final xSquaredPlus4x = BinaryOp(xSquared, BinaryOperator.add, fourX);
      final expr =
          BinaryOp(xSquaredPlus4x, BinaryOperator.add, const NumberLiteral(4));
      final factored = engine.factor(expr);

      for (var x in [0, 1, -2, 3]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(factored, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });
  });

  group('Coefficient Polynomial Operations', () {
    test('3x^2 + 6x + 3 = 3(x^2 + 2x + 1) = 3(x+1)^2', () {
      // 3x^2
      final threeXSquared = BinaryOp(
          const NumberLiteral(3),
          BinaryOperator.multiply,
          BinaryOp(
              Variable('x'), BinaryOperator.power, const NumberLiteral(2)));
      // 6x
      final sixX = BinaryOp(
          const NumberLiteral(6), BinaryOperator.multiply, Variable('x'));
      // 3x^2 + 6x
      final sum1 = BinaryOp(threeXSquared, BinaryOperator.add, sixX);
      // 3x^2 + 6x + 3
      final expr = BinaryOp(sum1, BinaryOperator.add, const NumberLiteral(3));
      final factored = engine.factor(expr);

      for (var x in [0, 1, -1, 2]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(factored, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('2x^2 - 8 = 2(x^2 - 4) = 2(x-2)(x+2)', () {
      // 2x^2
      final twoXSquared = BinaryOp(
          const NumberLiteral(2),
          BinaryOperator.multiply,
          BinaryOp(
              Variable('x'), BinaryOperator.power, const NumberLiteral(2)));
      final expr = BinaryOp(
          twoXSquared, BinaryOperator.subtract, const NumberLiteral(8));
      final factored = engine.factor(expr);

      for (var x in [0, 2, -2, 3, 1]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(factored, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });
  });

  group('Expansion and Factorization Round-trip', () {
    test('expand then factor (x+1)^2', () {
      final xPlus1 =
          BinaryOp(Variable('x'), BinaryOperator.add, const NumberLiteral(1));
      final original =
          BinaryOp(xPlus1, BinaryOperator.power, const NumberLiteral(2));

      final expanded = engine.expand(original);
      final refactored = engine.factor(expanded);

      for (var x in [0, 1, 2, -1, -2]) {
        final origVal =
            evaluator.evaluate(original, {'x': x.toDouble()}).asNumeric();
        final resultVal =
            evaluator.evaluate(refactored, {'x': x.toDouble()}).asNumeric();
        expect(resultVal, closeTo(origVal, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('factor then expand x^2 - 4', () {
      final xSquared =
          BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(2));
      final original =
          BinaryOp(xSquared, BinaryOperator.subtract, const NumberLiteral(4));

      final factored = engine.factor(original);
      final reexpanded = engine.expand(factored);

      for (var x in [0, 2, -2, 3]) {
        final origVal =
            evaluator.evaluate(original, {'x': x.toDouble()}).asNumeric();
        final resultVal =
            evaluator.evaluate(reexpanded, {'x': x.toDouble()}).asNumeric();
        expect(resultVal, closeTo(origVal, 1e-10), reason: 'Failed for x=$x');
      }
    });
  });
}
