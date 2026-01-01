import 'package:texpr/texpr.dart';
import 'package:test/test.dart';
import 'dart:math' as math;

void main() {
  late LatexMathEvaluator evaluator;

  setUp(() {
    evaluator = LatexMathEvaluator();
  });

  group('Trigonometric Functions at Special Angles', () {
    test('sin(0) = 0', () {
      final result = evaluator.evaluate(r'\sin(0)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('sin(π/6) = 1/2', () {
      final result = evaluator.evaluate(r'\sin(\pi / 6)');
      expect(result.asNumeric(), closeTo(0.5, 1e-10));
    });

    test('sin(π/4) = √2/2', () {
      final result = evaluator.evaluate(r'\sin(\pi / 4)');
      expect(result.asNumeric(), closeTo(math.sqrt(2) / 2, 1e-10));
    });

    test('sin(π/3) = √3/2', () {
      final result = evaluator.evaluate(r'\sin(\pi / 3)');
      expect(result.asNumeric(), closeTo(math.sqrt(3) / 2, 1e-10));
    });

    test('sin(π/2) = 1', () {
      final result = evaluator.evaluate(r'\sin(\pi / 2)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('sin(π) = 0', () {
      final result = evaluator.evaluate(r'\sin(\pi)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('sin(2π) = 0', () {
      final result = evaluator.evaluate(r'\sin(2 * \pi)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('cos(0) = 1', () {
      final result = evaluator.evaluate(r'\cos(0)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('cos(π/6) = √3/2', () {
      final result = evaluator.evaluate(r'\cos(\pi / 6)');
      expect(result.asNumeric(), closeTo(math.sqrt(3) / 2, 1e-10));
    });

    test('cos(π/4) = √2/2', () {
      final result = evaluator.evaluate(r'\cos(\pi / 4)');
      expect(result.asNumeric(), closeTo(math.sqrt(2) / 2, 1e-10));
    });

    test('cos(π/3) = 1/2', () {
      final result = evaluator.evaluate(r'\cos(\pi / 3)');
      expect(result.asNumeric(), closeTo(0.5, 1e-10));
    });

    test('cos(π/2) = 0', () {
      final result = evaluator.evaluate(r'\cos(\pi / 2)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('cos(π) = -1', () {
      final result = evaluator.evaluate(r'\cos(\pi)');
      expect(result.asNumeric(), closeTo(-1, 1e-10));
    });

    test('tan(0) = 0', () {
      final result = evaluator.evaluate(r'\tan(0)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('tan(π/4) = 1', () {
      final result = evaluator.evaluate(r'\tan(\pi / 4)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('tan(π/6) = √3/3', () {
      final result = evaluator.evaluate(r'\tan(\pi / 6)');
      expect(result.asNumeric(), closeTo(math.sqrt(3) / 3, 1e-10));
    });
  });

  group('Negative Angles', () {
    test('sin(-π/6) = -1/2', () {
      final result = evaluator.evaluate(r'\sin(-\pi / 6)');
      expect(result.asNumeric(), closeTo(-0.5, 1e-10));
    });

    test('cos(-π/6) = √3/2', () {
      final result = evaluator.evaluate(r'\cos(-\pi / 6)');
      expect(result.asNumeric(), closeTo(math.sqrt(3) / 2, 1e-10));
    });

    test('tan(-π/4) = -1', () {
      final result = evaluator.evaluate(r'\tan(-\pi / 4)');
      expect(result.asNumeric(), closeTo(-1, 1e-10));
    });

    test('sin(-π) = 0', () {
      final result = evaluator.evaluate(r'\sin(-\pi)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });
  });

  group('Angles Greater Than 2π', () {
    test('sin(3π) = 0', () {
      final result = evaluator.evaluate(r'\sin(3 * \pi)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('cos(4π) = 1', () {
      final result = evaluator.evaluate(r'\cos(4 * \pi)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('sin(5π/2) = 1', () {
      final result = evaluator.evaluate(r'\sin(5 * \pi / 2)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('tan(5π/4) = 1', () {
      final result = evaluator.evaluate(r'\tan(5 * \pi / 4)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });
  });

  group('Inverse Trigonometric Functions', () {
    test('arcsin(0) = 0', () {
      final result = evaluator.evaluate(r'\arcsin(0)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('arcsin(1) = π/2', () {
      final result = evaluator.evaluate(r'\arcsin(1)');
      expect(result.asNumeric(), closeTo(math.pi / 2, 1e-10));
    });

    test('arcsin(-1) = -π/2', () {
      final result = evaluator.evaluate(r'\arcsin(-1)');
      expect(result.asNumeric(), closeTo(-math.pi / 2, 1e-10));
    });

    test('arcsin(1/2) = π/6', () {
      final result = evaluator.evaluate(r'\arcsin(0.5)');
      expect(result.asNumeric(), closeTo(math.pi / 6, 1e-10));
    });

    test('arccos(0) = π/2', () {
      final result = evaluator.evaluate(r'\arccos(0)');
      expect(result.asNumeric(), closeTo(math.pi / 2, 1e-10));
    });

    test('arccos(1) = 0', () {
      final result = evaluator.evaluate(r'\arccos(1)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('arccos(-1) = π', () {
      final result = evaluator.evaluate(r'\arccos(-1)');
      expect(result.asNumeric(), closeTo(math.pi, 1e-10));
    });

    test('arctan(0) = 0', () {
      final result = evaluator.evaluate(r'\arctan(0)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('arctan(1) = π/4', () {
      final result = evaluator.evaluate(r'\arctan(1)');
      expect(result.asNumeric(), closeTo(math.pi / 4, 1e-10));
    });

    test('arctan(-1) = -π/4', () {
      final result = evaluator.evaluate(r'\arctan(-1)');
      expect(result.asNumeric(), closeTo(-math.pi / 4, 1e-10));
    });
  });

  group('Hyperbolic Functions', () {
    test('sinh(0) = 0', () {
      final result = evaluator.evaluate(r'\sinh(0)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('cosh(0) = 1', () {
      final result = evaluator.evaluate(r'\cosh(0)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('tanh(0) = 0', () {
      final result = evaluator.evaluate(r'\tanh(0)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('sinh(1) computes correctly', () {
      final result = evaluator.evaluate(r'\sinh(1)');
      // sinh(1) = (e - 1/e) / 2 ≈ 1.1752
      expect(result.asNumeric(), closeTo(1.1752011936, 1e-9));
    });

    test('cosh(1) computes correctly', () {
      final result = evaluator.evaluate(r'\cosh(1)');
      // cosh(1) = (e + 1/e) / 2 ≈ 1.5431
      expect(result.asNumeric(), closeTo(1.5430806348, 1e-9));
    });

    test('tanh(1) computes correctly', () {
      final result = evaluator.evaluate(r'\tanh(1)');
      // tanh(1) = sinh(1)/cosh(1) ≈ 0.7616
      expect(result.asNumeric(), closeTo(0.7615941559, 1e-9));
    });

    test('sinh(-1) = -sinh(1)', () {
      final sinh1 = evaluator.evaluate(r'\sinh(1)').asNumeric();
      final result = evaluator.evaluate(r'\sinh(-1)');
      expect(result.asNumeric(), closeTo(-sinh1, 1e-10));
    });

    test('cosh(-1) = cosh(1)', () {
      final cosh1 = evaluator.evaluate(r'\cosh(1)').asNumeric();
      final result = evaluator.evaluate(r'\cosh(-1)');
      expect(result.asNumeric(), closeTo(cosh1, 1e-10));
    });
  });

  group('Trigonometric Identities', () {
    test('sin²(x) + cos²(x) = 1 for x=0.5', () {
      final result = evaluator.evaluate(r'\sin(0.5)^2 + \cos(0.5)^2');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('sin²(x) + cos²(x) = 1 for x=π/3', () {
      final result = evaluator.evaluate(r'\sin(\pi/3)^2 + \cos(\pi/3)^2');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('tan(x) = sin(x)/cos(x)', () {
      final result1 = evaluator.evaluate(r'\tan(\pi/6)');
      final result2 = evaluator.evaluate(r'\sin(\pi/6) / \cos(\pi/6)');
      expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-10));
    });

    test('sin(2x) = 2sin(x)cos(x)', () {
      final result1 = evaluator.evaluate(r'\sin(2 * \pi / 6)');
      final result2 = evaluator.evaluate(r'2 * \sin(\pi / 6) * \cos(\pi / 6)');
      expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-10));
    });

    test('cos(2x) = cos²(x) - sin²(x)', () {
      final result1 = evaluator.evaluate(r'\cos(2 * \pi / 4)');
      final result2 = evaluator.evaluate(r'\cos(\pi/4)^2 - \sin(\pi/4)^2');
      expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-10));
    });
  });
}
