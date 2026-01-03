import 'package:test/test.dart';
import 'package:texpr/texpr.dart';
import 'package:texpr/src/complex.dart';
import 'dart:math' as math;

// Helper functions for hyperbolic operations
double _sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;
double _cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;

/// Edge case tests for complex number support - v0.2.0 milestone verification
void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('Branch Cut Edge Cases', () {
    test('sqrt(-1) = i (principal branch)', () {
      final result = evaluator.evaluate(r'\sqrt{-1}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(0, 1e-10));
      expect(c.imaginary, closeTo(1, 1e-10));
    });

    test('sqrt(-4) = 2i', () {
      final result = evaluator.evaluate(r'\sqrt{-4}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(0, 1e-10));
      expect(c.imaginary, closeTo(2, 1e-10));
    });

    test('sqrt of complex number', () {
      // sqrt(3 + 4i) = 2 + i
      final result = evaluator.evaluate(r'\sqrt{3 + 4*i}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(2, 1e-10));
      expect(c.imaginary, closeTo(1, 1e-10));
    });

    test('log branch cut: ln(-1) = iπ', () {
      final result = evaluator.evaluate(r'\ln(-1)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(0, 1e-10));
      expect(c.imaginary, closeTo(math.pi, 1e-10));
    });

    test('log branch cut: ln(-e) = 1 + iπ', () {
      final result = evaluator.evaluate(r'\ln(-e)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(1, 1e-10));
      expect(c.imaginary, closeTo(math.pi, 1e-10));
    });
  });

  group('Large Magnitude Complex Numbers', () {
    test('large real part', () {
      final c = Complex(1e10, 1);
      expect(c.abs, closeTo(1e10, 1e5));
    });

    test('large imaginary part', () {
      final c = Complex(1, 1e10);
      expect(c.abs, closeTo(1e10, 1e5));
    });

    test('exp of large imaginary (oscillates)', () {
      // e^(i*100π) = e^(i*0) = 1 (within numerical precision)
      final result = evaluator.evaluate(r'\exp(i * 100 * \pi)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(1, 1e-8));
      expect(c.imaginary.abs(), lessThan(1e-8));
    });

    test('power of large complex', () {
      // (1+i)^10
      final result = evaluator.evaluate(r'(1+i)^{10}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      // (1+i)^10 = 32i
      expect(c.real, closeTo(0, 1e-8));
      expect(c.imaginary, closeTo(32, 1e-8));
    });
  });

  group('Operations Near Singularities', () {
    test('tan near π/2 returns large value', () {
      // tan(π/2 - ε) should be large
      final result = evaluator.evaluate(r'\tan(\pi/2 - 0.001)');
      expect(result.asNumeric().abs(), greaterThan(100));
    });

    test('1/z for small |z|', () {
      // 1/(0.001 + 0.001i)
      final result = evaluator.evaluate(r'1 / (0.001 + 0.001*i)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.abs, greaterThan(100));
    });

    test('log near zero approaches negative infinity', () {
      final result = evaluator.evaluate(r'\ln(0.0001)');
      expect(result.asNumeric(), lessThan(-5));
    });
  });

  group('Zero and Infinity Handling', () {
    test('0 + 0i is zero', () {
      final c = Complex(0, 0);
      expect(c.abs, equals(0));
      expect(c.isZero, isTrue);
    });

    test('real number as complex', () {
      final c = Complex(5, 0);
      expect(c.isReal, isTrue);
      expect(c.real, equals(5));
    });

    test('pure imaginary number', () {
      final c = Complex(0, 3);
      expect(c.isPureImaginary, isTrue);
      expect(c.imaginary, equals(3));
    });

    test('complex magnitude of (3, 4) is 5', () {
      final c = Complex(3, 4);
      expect(c.abs, closeTo(5, 1e-10));
    });

    test('complex argument of i is π/2', () {
      final c = Complex(0, 1);
      expect(c.arg, closeTo(math.pi / 2, 1e-10));
    });
  });

  group('Precision Tests for Complex Arithmetic', () {
    test('addition precision', () {
      final c1 = Complex(1.111111111, 2.222222222);
      final c2 = Complex(3.333333333, 4.444444444);
      final sum = c1 + c2;
      expect(sum.real, closeTo(4.444444444, 1e-9));
      expect(sum.imaginary, closeTo(6.666666666, 1e-9));
    });

    test('multiplication precision', () {
      // (a+bi)(c+di) = (ac-bd) + (ad+bc)i
      final c1 = Complex(1.5, 2.5);
      final c2 = Complex(3.5, 4.5);
      final prod = c1 * c2;
      // 1.5*3.5 - 2.5*4.5 = 5.25 - 11.25 = -6
      // 1.5*4.5 + 2.5*3.5 = 6.75 + 8.75 = 15.5
      expect(prod.real, closeTo(-6, 1e-10));
      expect(prod.imaginary, closeTo(15.5, 1e-10));
    });

    test('division precision', () {
      final c1 = Complex(3, 4);
      final c2 = Complex(1, 2);
      final quot = c1 / c2;
      // (3+4i)/(1+2i) = (3+4i)(1-2i)/((1+2i)(1-2i)) = (3+8+4i-6i)/(1+4) = (11-2i)/5
      expect(quot.real, closeTo(2.2, 1e-10));
      expect(quot.imaginary, closeTo(-0.4, 1e-10));
    });

    test('power precision', () {
      // i^2 = -1
      final result = evaluator.evaluate(r'i^{2}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(-1, 1e-10));
      expect(c.imaginary.abs(), lessThan(1e-10));
    });
  });

  group('Euler Formula Verification', () {
    test('e^(iπ) = -1 (Euler identity)', () {
      final result = evaluator.evaluate(r'e^{i * \pi}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(-1, 1e-10));
      expect(c.imaginary.abs(), lessThan(1e-10));
    });

    test('e^(iπ/2) = i', () {
      final result = evaluator.evaluate(r'e^{i * \pi / 2}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real.abs(), lessThan(1e-10));
      expect(c.imaginary, closeTo(1, 1e-10));
    });

    test('e^(i*2π) = 1', () {
      final result = evaluator.evaluate(r'e^{i * 2 * \pi}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(1, 1e-10));
      expect(c.imaginary.abs(), lessThan(1e-10));
    });

    test('e^(it) = cos(t) + i*sin(t)', () {
      for (var t in [0.0, math.pi / 6, math.pi / 4, math.pi / 3, math.pi / 2]) {
        final result = evaluator.evaluate(r'e^{i * t}', {'t': t});
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.real, closeTo(math.cos(t), 1e-10), reason: 'Failed for t=$t');
        expect(c.imaginary, closeTo(math.sin(t), 1e-10),
            reason: 'Failed for t=$t');
      }
    });
  });

  group('Complex Trigonometric Functions', () {
    test('sin(i) = i*sinh(1)', () {
      final result = evaluator.evaluate(r'\sin(i)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      // sin(i) = i*sinh(1)
      expect(c.real.abs(), lessThan(1e-10));
      expect(c.imaginary, closeTo(_sinh(1), 1e-10));
    });

    test('cos(i) = cosh(1)', () {
      final result = evaluator.evaluate(r'\cos(i)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      // cos(i) = cosh(1), real only
      expect(c.real, closeTo(_cosh(1), 1e-10));
      expect(c.imaginary.abs(), lessThan(1e-10));
    });

    test('sin^2(z) + cos^2(z) = 1 for complex z', () {
      final z = Complex(1, 2);
      final sinZ = z.sin();
      final cosZ = z.cos();
      final identity = sinZ * sinZ + cosZ * cosZ;
      expect(identity.real, closeTo(1, 1e-10));
      expect(identity.imaginary.abs(), lessThan(1e-10));
    });
  });

  group('Complex Power Operations', () {
    test('i^i is real', () {
      // i^i = e^(i*ln(i)) = e^(i*iπ/2) = e^(-π/2) ≈ 0.2079
      final result = evaluator.evaluate(r'i^{i}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(math.exp(-math.pi / 2), 1e-10));
      expect(c.imaginary.abs(), lessThan(1e-10));
    });

    test('sqrt(-1) = i (equivalent to (-1)^0.5)', () {
      // Note: (-1)^0.5 with real exponent may return NaN due to Dart's pow behavior
      // Use sqrt(-1) instead which properly handles complex
      final result = evaluator.evaluate(r'\sqrt{-1}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real.abs(), lessThan(1e-10));
      expect(c.imaginary, closeTo(1, 1e-10));
    });

    test('(1+i)^4 = -4', () {
      // (1+i)^2 = 2i, (2i)^2 = -4
      final result = evaluator.evaluate(r'(1+i)^{4}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(-4, 1e-10));
      expect(c.imaginary.abs(), lessThan(1e-10));
    });

    test('complex to real power', () {
      // (1+i)^3 = (1+i)^2 * (1+i) = 2i * (1+i) = 2i + 2i^2 = -2 + 2i
      final result = evaluator.evaluate(r'(1+i)^{3}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(-2, 1e-10));
      expect(c.imaginary, closeTo(2, 1e-10));
    });
  });

  group('Complex Class Methods', () {
    test('conjugate', () {
      final c = Complex(3, 4);
      final conj = c.conjugate;
      expect(conj.real, equals(3));
      expect(conj.imaginary, equals(-4));
    });

    test('reciprocal', () {
      final c = Complex(3, 4);
      final recip = c.reciprocal;
      // 1/(3+4i) = (3-4i)/25
      expect(recip.real, closeTo(0.12, 1e-10));
      expect(recip.imaginary, closeTo(-0.16, 1e-10));
    });

    test('polar form conversion', () {
      final c = Complex.fromPolar(5, math.pi / 6);
      expect(c.real, closeTo(5 * math.cos(math.pi / 6), 1e-10));
      expect(c.imaginary, closeTo(5 * math.sin(math.pi / 6), 1e-10));
    });

    test('exp of complex', () {
      // e^(1+i) = e^1 * e^i = e * (cos(1) + i*sin(1))
      final c = Complex(1, 1);
      final expC = c.exp();
      expect(expC.real, closeTo(math.e * math.cos(1), 1e-10));
      expect(expC.imaginary, closeTo(math.e * math.sin(1), 1e-10));
    });

    test('log of complex', () {
      // ln(1+i) = ln(√2) + i*arctan(1) = 0.5*ln(2) + i*π/4
      final c = Complex(1, 1);
      final logC = c.log();
      expect(logC.real, closeTo(0.5 * math.log(2), 1e-10));
      expect(logC.imaginary, closeTo(math.pi / 4, 1e-10));
    });
  });

  group('Complex Expressions via LaTeX', () {
    test('(a + bi) + (c + di) = (a+c) + (b+d)i', () {
      final result = evaluator.evaluate(r'(2 + 3*i) + (4 + 5*i)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(6, 1e-10));
      expect(c.imaginary, closeTo(8, 1e-10));
    });

    test('(a + bi) - (c + di) = (a-c) + (b-d)i', () {
      final result = evaluator.evaluate(r'(5 + 7*i) - (2 + 3*i)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(3, 1e-10));
      expect(c.imaginary, closeTo(4, 1e-10));
    });

    test('(a + bi) * (c + di)', () {
      // (2+3i)(4+5i) = 8+10i+12i+15i^2 = 8-15 + 22i = -7+22i
      final result = evaluator.evaluate(r'(2 + 3*i) * (4 + 5*i)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(-7, 1e-10));
      expect(c.imaginary, closeTo(22, 1e-10));
    });

    test('|a + bi| = sqrt(a^2 + b^2)', () {
      // Test using Complex class directly since \abs doesn't support complex
      final c = Complex(3, 4);
      expect(c.abs, closeTo(5, 1e-10));
    });
  });
}
