import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Edge case tests for symbolic simplification - v0.2.0 milestone verification
void main() {
  late SymbolicEngine engine;
  late Evaluator evaluator;

  setUp(() {
    engine = SymbolicEngine();
    evaluator = Evaluator();
  });

  group('Deeply Nested Expressions', () {
    test('((((x+1)+1)+1)+1) simplifies correctly', () {
      // Build ((((x+1)+1)+1)+1)
      Expression expr = Variable('x');
      for (int i = 0; i < 4; i++) {
        expr = BinaryOp(expr, BinaryOperator.add, const NumberLiteral(1));
      }
      final simplified = engine.simplify(expr);

      // Verify by evaluation
      for (var x in [0, 1, 5, -3]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(simplified, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('deeply nested multiplications simplify', () {
      // (((x*2)*2)*2) = 8x
      Expression expr = Variable('x');
      for (int i = 0; i < 3; i++) {
        expr = BinaryOp(expr, BinaryOperator.multiply, const NumberLiteral(2));
      }
      final simplified = engine.simplify(expr);

      for (var x in [1, 2, 5, -2]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(simplified, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });

    test('nested parentheses with mixed operators', () {
      // ((x + 1) * 2) - x = x + 2
      final xPlus1 =
          BinaryOp(Variable('x'), BinaryOperator.add, const NumberLiteral(1));
      final times2 =
          BinaryOp(xPlus1, BinaryOperator.multiply, const NumberLiteral(2));
      final expr = BinaryOp(times2, BinaryOperator.subtract, Variable('x'));
      final simplified = engine.simplify(expr);

      for (var x in [0, 1, 5, -3]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(simplified, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });
  });

  group('Large Coefficient Handling', () {
    test('1e10 * x simplifies correctly', () {
      final expr = BinaryOp(
          const NumberLiteral(1e10), BinaryOperator.multiply, Variable('x'));
      final simplified = engine.simplify(expr);

      for (var x in [1, 2, 0.5]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(simplified, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-5), reason: 'Failed for x=$x');
      }
    });

    test('very small coefficient handling', () {
      final expr = BinaryOp(
          const NumberLiteral(1e-10), BinaryOperator.multiply, Variable('x'));
      final simplified = engine.simplify(expr);

      for (var x in [1e10, 1e5, 1]) {
        final original =
            evaluator.evaluate(expr, {'x': x.toDouble()}).asNumeric();
        final result =
            evaluator.evaluate(simplified, {'x': x.toDouble()}).asNumeric();
        expect(result, closeTo(original, 1e-15), reason: 'Failed for x=$x');
      }
    });

    test('large number addition', () {
      final expr = BinaryOp(const NumberLiteral(1e15), BinaryOperator.add,
          const NumberLiteral(1e15));
      final simplified = engine.simplify(expr);
      expect(simplified, isA<NumberLiteral>());
      expect((simplified as NumberLiteral).value, closeTo(2e15, 1e5));
    });
  });

  group('Mixed Operations Cancellation', () {
    test('x + y - x = y', () {
      final xPlusy = BinaryOp(Variable('x'), BinaryOperator.add, Variable('y'));
      final expr = BinaryOp(xPlusy, BinaryOperator.subtract, Variable('x'));
      final simplified = engine.simplify(expr);

      for (var x in [1, 5, -3]) {
        for (var y in [2, 7, -1]) {
          final original = evaluator.evaluate(
              expr, {'x': x.toDouble(), 'y': y.toDouble()}).asNumeric();
          final result = evaluator.evaluate(
              simplified, {'x': x.toDouble(), 'y': y.toDouble()}).asNumeric();
          expect(result, closeTo(original, 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });

    test('x * y / x = y (when x != 0)', () {
      final xTimesY =
          BinaryOp(Variable('x'), BinaryOperator.multiply, Variable('y'));
      final expr = BinaryOp(xTimesY, BinaryOperator.divide, Variable('x'));
      final simplified = engine.simplify(expr);

      for (var x in [1, 5, -3, 0.5]) {
        for (var y in [2, 7, -1]) {
          final original = evaluator.evaluate(
              expr, {'x': x.toDouble(), 'y': y.toDouble()}).asNumeric();
          final result = evaluator.evaluate(
              simplified, {'x': x.toDouble(), 'y': y.toDouble()}).asNumeric();
          expect(result, closeTo(original, 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });

    test('(x + y) - (y + x) = 0', () {
      final xPlusy = BinaryOp(Variable('x'), BinaryOperator.add, Variable('y'));
      final yPlusx = BinaryOp(Variable('y'), BinaryOperator.add, Variable('x'));
      final expr = BinaryOp(xPlusy, BinaryOperator.subtract, yPlusx);
      final simplified = engine.simplify(expr);

      for (var x in [1, 5]) {
        for (var y in [2, 7]) {
          final result = evaluator.evaluate(
              simplified, {'x': x.toDouble(), 'y': y.toDouble()}).asNumeric();
          expect(result, closeTo(0, 1e-10), reason: 'Failed for x=$x, y=$y');
        }
      }
    });
  });

  group('Multi-Variable Expressions', () {
    test('a + b + c + d + e simplifies correctly', () {
      Expression expr = Variable('a');
      for (var v in ['b', 'c', 'd', 'e']) {
        expr = BinaryOp(expr, BinaryOperator.add, Variable(v));
      }
      final simplified = engine.simplify(expr);

      final vars = {'a': 1.0, 'b': 2.0, 'c': 3.0, 'd': 4.0, 'e': 5.0};
      final original = evaluator.evaluate(expr, vars).asNumeric();
      final result = evaluator.evaluate(simplified, vars).asNumeric();
      expect(result, closeTo(original, 1e-10));
    });

    test('a * b * c * d simplifies correctly', () {
      Expression expr = Variable('a');
      for (var v in ['b', 'c', 'd']) {
        expr = BinaryOp(expr, BinaryOperator.multiply, Variable(v));
      }
      final simplified = engine.simplify(expr);

      final vars = {'a': 2.0, 'b': 3.0, 'c': 4.0, 'd': 5.0};
      final original = evaluator.evaluate(expr, vars).asNumeric();
      final result = evaluator.evaluate(simplified, vars).asNumeric();
      expect(result, closeTo(original, 1e-10));
    });

    test('mixed multi-variable expression', () {
      // (a + b) * (c + d)
      final aPlusB = BinaryOp(Variable('a'), BinaryOperator.add, Variable('b'));
      final cPlusD = BinaryOp(Variable('c'), BinaryOperator.add, Variable('d'));
      final expr = BinaryOp(aPlusB, BinaryOperator.multiply, cPlusD);
      final expanded = engine.expand(expr);

      final vars = {'a': 1.0, 'b': 2.0, 'c': 3.0, 'd': 4.0};
      final original = evaluator.evaluate(expr, vars).asNumeric();
      final result = evaluator.evaluate(expanded, vars).asNumeric();
      expect(result, closeTo(original, 1e-10));
    });
  });

  group('Associativity Edge Cases', () {
    test('(a + b) + c produces same result as a + (b + c)', () {
      final expr1 = BinaryOp(
          BinaryOp(Variable('a'), BinaryOperator.add, Variable('b')),
          BinaryOperator.add,
          Variable('c'));
      final expr2 = BinaryOp(Variable('a'), BinaryOperator.add,
          BinaryOp(Variable('b'), BinaryOperator.add, Variable('c')));

      final simplified1 = engine.simplify(expr1);
      final simplified2 = engine.simplify(expr2);

      final vars = {'a': 1.5, 'b': 2.5, 'c': 3.5};
      final result1 = evaluator.evaluate(simplified1, vars).asNumeric();
      final result2 = evaluator.evaluate(simplified2, vars).asNumeric();
      expect(result1, closeTo(result2, 1e-10));
    });

    test('(a * b) * c produces same result as a * (b * c)', () {
      final expr1 = BinaryOp(
          BinaryOp(Variable('a'), BinaryOperator.multiply, Variable('b')),
          BinaryOperator.multiply,
          Variable('c'));
      final expr2 = BinaryOp(Variable('a'), BinaryOperator.multiply,
          BinaryOp(Variable('b'), BinaryOperator.multiply, Variable('c')));

      final simplified1 = engine.simplify(expr1);
      final simplified2 = engine.simplify(expr2);

      final vars = {'a': 2.0, 'b': 3.0, 'c': 4.0};
      final result1 = evaluator.evaluate(simplified1, vars).asNumeric();
      final result2 = evaluator.evaluate(simplified2, vars).asNumeric();
      expect(result1, closeTo(result2, 1e-10));
    });

    test('subtraction non-associativity: (a - b) - c != a - (b - c)', () {
      final expr1 = BinaryOp(
          BinaryOp(Variable('a'), BinaryOperator.subtract, Variable('b')),
          BinaryOperator.subtract,
          Variable('c'));
      final expr2 = BinaryOp(Variable('a'), BinaryOperator.subtract,
          BinaryOp(Variable('b'), BinaryOperator.subtract, Variable('c')));

      final vars = {'a': 10.0, 'b': 4.0, 'c': 2.0};
      final result1 = evaluator.evaluate(expr1, vars).asNumeric();
      final result2 = evaluator.evaluate(expr2, vars).asNumeric();
      // (10-4)-2 = 4, 10-(4-2) = 8, different!
      expect(result1, isNot(closeTo(result2, 1e-10)));
    });
  });

  group('Zero and One Edge Cases', () {
    test('0 + 0 = 0', () {
      final expr = BinaryOp(
          const NumberLiteral(0), BinaryOperator.add, const NumberLiteral(0));
      final simplified = engine.simplify(expr);
      expect(simplified, equals(const NumberLiteral(0)));
    });

    test('1 * 1 = 1', () {
      final expr = BinaryOp(const NumberLiteral(1), BinaryOperator.multiply,
          const NumberLiteral(1));
      final simplified = engine.simplify(expr);
      expect(simplified, equals(const NumberLiteral(1)));
    });

    test('0 * 0 = 0', () {
      final expr = BinaryOp(const NumberLiteral(0), BinaryOperator.multiply,
          const NumberLiteral(0));
      final simplified = engine.simplify(expr);
      expect(simplified, equals(const NumberLiteral(0)));
    });

    test('x + 0 + 0 + 0 = x', () {
      Expression expr = Variable('x');
      for (int i = 0; i < 3; i++) {
        expr = BinaryOp(expr, BinaryOperator.add, const NumberLiteral(0));
      }
      final simplified = engine.simplify(expr);
      expect(simplified, equals(Variable('x')));
    });

    test('x * 1 * 1 * 1 = x', () {
      Expression expr = Variable('x');
      for (int i = 0; i < 3; i++) {
        expr = BinaryOp(expr, BinaryOperator.multiply, const NumberLiteral(1));
      }
      final simplified = engine.simplify(expr);
      expect(simplified, equals(Variable('x')));
    });
  });

  group('Power Edge Cases', () {
    test('x^0 = 1 for any x', () {
      final expr =
          BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(0));
      final simplified = engine.simplify(expr);
      expect(simplified, equals(const NumberLiteral(1)));
    });

    test('0^0 returns 1 (by convention)', () {
      final expr = BinaryOp(
          const NumberLiteral(0), BinaryOperator.power, const NumberLiteral(0));
      final simplified = engine.simplify(expr);
      // 0^0 is often defined as 1 in combinatorics
      expect(simplified, equals(const NumberLiteral(1)));
    });

    test('(x^a)^b = x^(a*b)', () {
      final xToA = BinaryOp(Variable('x'), BinaryOperator.power, Variable('a'));
      final expr = BinaryOp(xToA, BinaryOperator.power, Variable('b'));
      final simplified = engine.simplify(expr);

      // Verify by evaluation
      for (var x in [2.0]) {
        for (var a in [2.0, 3.0]) {
          for (var b in [2.0]) {
            final original =
                evaluator.evaluate(expr, {'x': x, 'a': a, 'b': b}).asNumeric();
            final result = evaluator
                .evaluate(simplified, {'x': x, 'a': a, 'b': b}).asNumeric();
            expect(result, closeTo(original, 1e-10),
                reason: 'Failed for x=$x, a=$a, b=$b');
          }
        }
      }
    });

    test('x^1 * x^1 = x^2', () {
      final x1 =
          BinaryOp(Variable('x'), BinaryOperator.power, const NumberLiteral(1));
      final expr = BinaryOp(x1, BinaryOperator.multiply, x1);
      final simplified = engine.simplify(expr);

      for (var x in [2.0, 3.0, 5.0]) {
        final original = evaluator.evaluate(expr, {'x': x}).asNumeric();
        final result = evaluator.evaluate(simplified, {'x': x}).asNumeric();
        expect(result, closeTo(original, 1e-10), reason: 'Failed for x=$x');
      }
    });
  });

  group('Negative Number Handling', () {
    test('(-x) + (-y) = -(x + y)', () {
      final negX = UnaryOp(UnaryOperator.negate, Variable('x'));
      final negY = UnaryOp(UnaryOperator.negate, Variable('y'));
      final expr = BinaryOp(negX, BinaryOperator.add, negY);
      final simplified = engine.simplify(expr);

      for (var x in [1.0, 5.0]) {
        for (var y in [2.0, 7.0]) {
          final original =
              evaluator.evaluate(expr, {'x': x, 'y': y}).asNumeric();
          final result =
              evaluator.evaluate(simplified, {'x': x, 'y': y}).asNumeric();
          expect(result, closeTo(original, 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });

    test('(-x) * (-y) = x * y', () {
      final negX = UnaryOp(UnaryOperator.negate, Variable('x'));
      final negY = UnaryOp(UnaryOperator.negate, Variable('y'));
      final expr = BinaryOp(negX, BinaryOperator.multiply, negY);
      final simplified = engine.simplify(expr);

      for (var x in [2.0, 3.0]) {
        for (var y in [4.0, 5.0]) {
          final original =
              evaluator.evaluate(expr, {'x': x, 'y': y}).asNumeric();
          final result =
              evaluator.evaluate(simplified, {'x': x, 'y': y}).asNumeric();
          expect(result, closeTo(original, 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });

    test('x - (-y) = x + y', () {
      final negY = UnaryOp(UnaryOperator.negate, Variable('y'));
      final expr = BinaryOp(Variable('x'), BinaryOperator.subtract, negY);
      final simplified = engine.simplify(expr);

      for (var x in [3.0, 7.0]) {
        for (var y in [2.0, 5.0]) {
          final original =
              evaluator.evaluate(expr, {'x': x, 'y': y}).asNumeric();
          final result =
              evaluator.evaluate(simplified, {'x': x, 'y': y}).asNumeric();
          expect(result, closeTo(original, 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });
  });
}
