import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Edge case tests for trigonometric identities - v0.2.0 milestone verification
void main() {
  late SymbolicEngine engine;
  late LatexMathEvaluator latexEvaluator;

  setUp(() {
    engine = SymbolicEngine();
    latexEvaluator = LatexMathEvaluator();
  });

  group('Composite Pythagorean Identities', () {
    test('sin^2(2x) + cos^2(2x) = 1', () {
      // sin(2x)^2 + cos(2x)^2
      final twoX = BinaryOp(
          const NumberLiteral(2), BinaryOperator.multiply, Variable('x'));
      final sin2x = FunctionCall('sin', twoX);
      final cos2x = FunctionCall('cos', twoX);
      final sin2xSquared =
          BinaryOp(sin2x, BinaryOperator.power, const NumberLiteral(2));
      final cos2xSquared =
          BinaryOp(cos2x, BinaryOperator.power, const NumberLiteral(2));
      final expr = BinaryOp(sin2xSquared, BinaryOperator.add, cos2xSquared);
      final simplified = engine.simplify(expr);

      expect(simplified, equals(const NumberLiteral(1)));
    });

    test('sin^2(3x) + cos^2(3x) = 1', () {
      final threeX = BinaryOp(
          const NumberLiteral(3), BinaryOperator.multiply, Variable('x'));
      final sin3x = FunctionCall('sin', threeX);
      final cos3x = FunctionCall('cos', threeX);
      final sin3xSquared =
          BinaryOp(sin3x, BinaryOperator.power, const NumberLiteral(2));
      final cos3xSquared =
          BinaryOp(cos3x, BinaryOperator.power, const NumberLiteral(2));
      final expr = BinaryOp(sin3xSquared, BinaryOperator.add, cos3xSquared);
      final simplified = engine.simplify(expr);

      expect(simplified, equals(const NumberLiteral(1)));
    });

    test('sin^2(x+y) + cos^2(x+y) = 1', () {
      final xPlusY = BinaryOp(Variable('x'), BinaryOperator.add, Variable('y'));
      final sinXY = FunctionCall('sin', xPlusY);
      final cosXY = FunctionCall('cos', xPlusY);
      final sinXYSquared =
          BinaryOp(sinXY, BinaryOperator.power, const NumberLiteral(2));
      final cosXYSquared =
          BinaryOp(cosXY, BinaryOperator.power, const NumberLiteral(2));
      final expr = BinaryOp(sinXYSquared, BinaryOperator.add, cosXYSquared);
      final simplified = engine.simplify(expr);

      expect(simplified, equals(const NumberLiteral(1)));
    });
  });

  group('Large Angle Values', () {
    test('sin(1000π) ≈ 0', () {
      final result = latexEvaluator.evaluate(r'\sin(1000 * \pi)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('cos(1000π) ≈ 1', () {
      final result = latexEvaluator.evaluate(r'\cos(1000 * \pi)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('sin(999π/2) ≈ -1', () {
      // 999/2 = 499.5, so sin(499.5π) = sin(0.5π) * (-1)^499 = -1
      final result = latexEvaluator.evaluate(r'\sin(999 * \pi / 2)');
      expect(result.asNumeric().abs(), closeTo(1, 1e-10));
    });

    test('cos(500π) = 1', () {
      final result = latexEvaluator.evaluate(r'\cos(500 * \pi)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('tan(250π) = 0', () {
      final result = latexEvaluator.evaluate(r'\tan(250 * \pi)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });
  });

  group('Boundary Angle Identity Verification', () {
    test('sin(π) = 0', () {
      final result = latexEvaluator.evaluate(r'\sin(\pi)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('cos(π) = -1', () {
      final result = latexEvaluator.evaluate(r'\cos(\pi)');
      expect(result.asNumeric(), closeTo(-1, 1e-10));
    });

    test('sin(3π/2) = -1', () {
      final result = latexEvaluator.evaluate(r'\sin(3 * \pi / 2)');
      expect(result.asNumeric(), closeTo(-1, 1e-10));
    });

    test('cos(3π/2) = 0', () {
      final result = latexEvaluator.evaluate(r'\cos(3 * \pi / 2)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('tan(π/4) = 1', () {
      final result = latexEvaluator.evaluate(r'\tan(\pi / 4)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('tan(3π/4) = -1', () {
      final result = latexEvaluator.evaluate(r'\tan(3 * \pi / 4)');
      expect(result.asNumeric(), closeTo(-1, 1e-10));
    });
  });

  group('Nested Trigonometric Functions', () {
    test('sin(cos(0)) = sin(1)', () {
      final result1 = latexEvaluator.evaluate(r'\sin(\cos(0))');
      final result2 = latexEvaluator.evaluate(r'\sin(1)');
      expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-10));
    });

    test('cos(sin(0)) = cos(0) = 1', () {
      final result = latexEvaluator.evaluate(r'\cos(\sin(0))');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('sin(sin(π/2)) = sin(1)', () {
      final result1 = latexEvaluator.evaluate(r'\sin(\sin(\pi / 2))');
      final result2 = latexEvaluator.evaluate(r'\sin(1)');
      expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-10));
    });

    test('tan(arctan(1)) = 1', () {
      final result = latexEvaluator.evaluate(r'\tan(\arctan(1))');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('sin(arcsin(0.5)) = 0.5', () {
      final result = latexEvaluator.evaluate(r'\sin(\arcsin(0.5))');
      expect(result.asNumeric(), closeTo(0.5, 1e-10));
    });

    test('cos(arccos(0.5)) = 0.5', () {
      final result = latexEvaluator.evaluate(r'\cos(\arccos(0.5))');
      expect(result.asNumeric(), closeTo(0.5, 1e-10));
    });
  });

  group('Triple Angle Formulas Verification', () {
    test('sin(3x) identity numerical verification', () {
      // sin(3x) = 3sin(x) - 4sin³(x)
      for (var x in [0.1, 0.5, 1.0, 1.5]) {
        final sin3x = latexEvaluator.evaluate(r'\sin(3 * x)', {'x': x});
        final identity =
            latexEvaluator.evaluate(r'3 * \sin(x) - 4 * (\sin(x))^3', {'x': x});
        expect(sin3x.asNumeric(), closeTo(identity.asNumeric(), 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('cos(3x) identity numerical verification', () {
      // cos(3x) = 4cos³(x) - 3cos(x)
      for (var x in [0.1, 0.5, 1.0, 1.5]) {
        final cos3x = latexEvaluator.evaluate(r'\cos(3 * x)', {'x': x});
        final identity =
            latexEvaluator.evaluate(r'4 * (\cos(x))^3 - 3 * \cos(x)', {'x': x});
        expect(cos3x.asNumeric(), closeTo(identity.asNumeric(), 1e-10),
            reason: 'Failed for x=$x');
      }
    });
  });

  group('Compound Angle Formulas', () {
    test('sin(x+y) = sin(x)cos(y) + cos(x)sin(y)', () {
      for (var x in [0.3, 0.7]) {
        for (var y in [0.4, 0.8]) {
          final lhs = latexEvaluator.evaluate(r'\sin(x + y)', {'x': x, 'y': y});
          final rhs = latexEvaluator.evaluate(
              r'\sin(x) * \cos(y) + \cos(x) * \sin(y)', {'x': x, 'y': y});
          expect(lhs.asNumeric(), closeTo(rhs.asNumeric(), 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });

    test('cos(x+y) = cos(x)cos(y) - sin(x)sin(y)', () {
      for (var x in [0.3, 0.7]) {
        for (var y in [0.4, 0.8]) {
          final lhs = latexEvaluator.evaluate(r'\cos(x + y)', {'x': x, 'y': y});
          final rhs = latexEvaluator.evaluate(
              r'\cos(x) * \cos(y) - \sin(x) * \sin(y)', {'x': x, 'y': y});
          expect(lhs.asNumeric(), closeTo(rhs.asNumeric(), 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });

    test('sin(x-y) = sin(x)cos(y) - cos(x)sin(y)', () {
      for (var x in [0.8, 1.2]) {
        for (var y in [0.3, 0.5]) {
          final lhs = latexEvaluator.evaluate(r'\sin(x - y)', {'x': x, 'y': y});
          final rhs = latexEvaluator.evaluate(
              r'\sin(x) * \cos(y) - \cos(x) * \sin(y)', {'x': x, 'y': y});
          expect(lhs.asNumeric(), closeTo(rhs.asNumeric(), 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });

    test('cos(x-y) = cos(x)cos(y) + sin(x)sin(y)', () {
      for (var x in [0.8, 1.2]) {
        for (var y in [0.3, 0.5]) {
          final lhs = latexEvaluator.evaluate(r'\cos(x - y)', {'x': x, 'y': y});
          final rhs = latexEvaluator.evaluate(
              r'\cos(x) * \cos(y) + \sin(x) * \sin(y)', {'x': x, 'y': y});
          expect(lhs.asNumeric(), closeTo(rhs.asNumeric(), 1e-10),
              reason: 'Failed for x=$x, y=$y');
        }
      }
    });
  });

  group('Secant, Cosecant, Cotangent', () {
    test('sec(x) = 1/cos(x)', () {
      for (var x in [0.3, 0.7, 1.0]) {
        final sec = latexEvaluator.evaluate(r'\sec(x)', {'x': x});
        final reciprocal = latexEvaluator.evaluate(r'1 / \cos(x)', {'x': x});
        expect(sec.asNumeric(), closeTo(reciprocal.asNumeric(), 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('csc(x) = 1/sin(x)', () {
      for (var x in [0.3, 0.7, 1.0]) {
        final csc = latexEvaluator.evaluate(r'\csc(x)', {'x': x});
        final reciprocal = latexEvaluator.evaluate(r'1 / \sin(x)', {'x': x});
        expect(csc.asNumeric(), closeTo(reciprocal.asNumeric(), 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('cot(x) = cos(x)/sin(x)', () {
      for (var x in [0.3, 0.7, 1.0]) {
        final cot = latexEvaluator.evaluate(r'\cot(x)', {'x': x});
        final ratio = latexEvaluator.evaluate(r'\cos(x) / \sin(x)', {'x': x});
        expect(cot.asNumeric(), closeTo(ratio.asNumeric(), 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('sec^2(x) - tan^2(x) = 1', () {
      for (var x in [0.3, 0.7, 1.0]) {
        final result =
            latexEvaluator.evaluate(r'(\sec(x))^2 - (\tan(x))^2', {'x': x});
        expect(result.asNumeric(), closeTo(1.0, 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('csc^2(x) - cot^2(x) = 1', () {
      for (var x in [0.3, 0.7, 1.0]) {
        final result =
            latexEvaluator.evaluate(r'(\csc(x))^2 - (\cot(x))^2', {'x': x});
        expect(result.asNumeric(), closeTo(1.0, 1e-10),
            reason: 'Failed for x=$x');
      }
    });
  });

  group('Hyperbolic Identity Verification', () {
    test('cosh^2(x) - sinh^2(x) = 1', () {
      for (var x in [0.0, 0.5, 1.0, 2.0]) {
        final result =
            latexEvaluator.evaluate(r'(\cosh(x))^2 - (\sinh(x))^2', {'x': x});
        expect(result.asNumeric(), closeTo(1.0, 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('tanh(x) = sinh(x)/cosh(x)', () {
      for (var x in [0.5, 1.0, 2.0]) {
        final tanh = latexEvaluator.evaluate(r'\tanh(x)', {'x': x});
        final ratio = latexEvaluator.evaluate(r'\sinh(x) / \cosh(x)', {'x': x});
        expect(tanh.asNumeric(), closeTo(ratio.asNumeric(), 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('sinh(2x) = 2*sinh(x)*cosh(x)', () {
      for (var x in [0.5, 1.0]) {
        final lhs = latexEvaluator.evaluate(r'\sinh(2 * x)', {'x': x});
        final rhs =
            latexEvaluator.evaluate(r'2 * \sinh(x) * \cosh(x)', {'x': x});
        expect(lhs.asNumeric(), closeTo(rhs.asNumeric(), 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('cosh(2x) = cosh^2(x) + sinh^2(x)', () {
      for (var x in [0.5, 1.0]) {
        final lhs = latexEvaluator.evaluate(r'\cosh(2 * x)', {'x': x});
        final rhs =
            latexEvaluator.evaluate(r'(\cosh(x))^2 + (\sinh(x))^2', {'x': x});
        expect(lhs.asNumeric(), closeTo(rhs.asNumeric(), 1e-10),
            reason: 'Failed for x=$x');
      }
    });
  });

  group('Symbolic Double-Angle Expansion', () {
    test('sin(2*x) expands to 2*sin(x)*cos(x)', () {
      final twoX = BinaryOp(
          const NumberLiteral(2), BinaryOperator.multiply, Variable('x'));
      final expr = FunctionCall('sin', twoX);
      final expanded = engine.expandTrig(expr);

      // Expected: 2*sin(x)*cos(x)
      final sinX = FunctionCall('sin', Variable('x'));
      final cosX = FunctionCall('cos', Variable('x'));
      final sinCos = BinaryOp(sinX, BinaryOperator.multiply, cosX);
      final expected =
          BinaryOp(const NumberLiteral(2), BinaryOperator.multiply, sinCos);

      expect(expanded, equals(expected));
    });

    test('cos(2*x) expands to cos^2(x) - sin^2(x)', () {
      final twoX = BinaryOp(
          const NumberLiteral(2), BinaryOperator.multiply, Variable('x'));
      final expr = FunctionCall('cos', twoX);
      final expanded = engine.expandTrig(expr);

      // Expected: cos^2(x) - sin^2(x)
      final cosX = FunctionCall('cos', Variable('x'));
      final cos2X =
          BinaryOp(cosX, BinaryOperator.power, const NumberLiteral(2));
      final sinX = FunctionCall('sin', Variable('x'));
      final sin2X =
          BinaryOp(sinX, BinaryOperator.power, const NumberLiteral(2));
      final expected = BinaryOp(cos2X, BinaryOperator.subtract, sin2X);

      expect(expanded, equals(expected));
    });
  });

  group('Even/Odd Function Properties', () {
    test('sin(-x) = -sin(x) symbolic', () {
      final negX = UnaryOp(UnaryOperator.negate, Variable('x'));
      final expr = FunctionCall('sin', negX);
      final simplified = engine.simplify(expr);
      final expected = UnaryOp(
        UnaryOperator.negate,
        FunctionCall('sin', Variable('x')),
      );
      expect(simplified, equals(expected));
    });

    test('cos(-x) = cos(x) symbolic', () {
      final negX = UnaryOp(UnaryOperator.negate, Variable('x'));
      final expr = FunctionCall('cos', negX);
      final simplified = engine.simplify(expr);
      final expected = FunctionCall('cos', Variable('x'));
      expect(simplified, equals(expected));
    });

    test('tan(-x) = -tan(x) numerical', () {
      for (var x in [0.3, 0.7, 1.0]) {
        final tanNegX = latexEvaluator.evaluate(r'\tan(-x)', {'x': x});
        final negTanX = latexEvaluator.evaluate(r'-\tan(x)', {'x': x});
        expect(tanNegX.asNumeric(), closeTo(negTanX.asNumeric(), 1e-10),
            reason: 'Failed for x=$x');
      }
    });
  });
}
