import 'package:test/test.dart';
import 'package:texpr/texpr.dart';
import 'package:texpr/src/complex.dart';
import 'dart:math' as math;

void main() {
  group('Complex Function Support', () {
    late LatexMathEvaluator evaluator;

    setUp(() {
      evaluator = LatexMathEvaluator();
    });

    group('Complex Trigonometric Functions', () {
      test('sin(1+2i) evaluates correctly', () {
        final result = evaluator.evaluate(r'\sin(1 + 2*i)');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        // sin(1+2i) ≈ 3.1658 + 1.9596i
        expect(c.real, closeTo(3.1658, 0.001));
        expect(c.imaginary, closeTo(1.9596, 0.001));
      });

      test('cos(1+2i) evaluates correctly', () {
        final result = evaluator.evaluate(r'\cos(1 + 2*i)');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        // cos(1+2i) ≈ 2.0327 - 3.0519i
        expect(c.real, closeTo(2.0327, 0.001));
        expect(c.imaginary, closeTo(-3.0519, 0.001));
      });

      test('tan(i) evaluates correctly', () {
        final result = evaluator.evaluate(r'\tan(i)');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        // tan(i) ≈ 0.7616i
        expect(c.real, closeTo(0, 0.001));
        expect(c.imaginary, closeTo(0.7616, 0.001));
      });
    });

    group('Complex Exponential and Logarithms', () {
      test("Euler's identity: e^(iπ) = -1", () {
        final result = evaluator.evaluate(r'e^{i*\pi}');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.real, closeTo(-1.0, 1e-10));
        expect(c.imaginary, closeTo(0.0, 1e-10));
      });

      test('exp(i*π/2) = i', () {
        final result = evaluator.evaluate(r'\exp(i*\pi/2)');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.real, closeTo(0.0, 1e-10));
        expect(c.imaginary, closeTo(1.0, 1e-10));
      });

      test('ln(i) = iπ/2', () {
        final result = evaluator.evaluate(r'\ln(i)');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.real, closeTo(0.0, 1e-10));
        expect(c.imaginary, closeTo(math.pi / 2, 1e-10));
      });

      test('ln(-1) = iπ', () {
        final result = evaluator.evaluate(r'\ln(-1)');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.real, closeTo(0.0, 1e-10));
        expect(c.imaginary, closeTo(math.pi, 1e-10));
      });
    });

    group('Complex Power and Roots', () {
      test('sqrt(-1) = i', () {
        final result = evaluator.evaluate(r'\sqrt{-1}');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.real, closeTo(0.0, 1e-10));
        expect(c.imaginary, closeTo(1.0, 1e-10));
      });

      test('sqrt(-4) = 2i', () {
        final result = evaluator.evaluate(r'\sqrt{-4}');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.real, closeTo(0.0, 1e-10));
        expect(c.imaginary, closeTo(2.0, 1e-10));
      });

      test('i^i evaluates correctly', () {
        // i^i = e^(i*ln(i)) = e^(i*iπ/2) = e^(-π/2) ≈ 0.2079
        final result = evaluator.evaluate(r'i^i');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.real, closeTo(math.exp(-math.pi / 2), 1e-10));
        expect(c.imaginary, closeTo(0.0, 1e-10));
      });

      test('complex power: (1+i)^3', () {
        // (1+i)^3 = (1+i)*(1+i)*(1+i) = -2 + 2i
        final result = evaluator.evaluate(r'(1+i)^3');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.real, closeTo(-2.0, 1e-10));
        expect(c.imaginary, closeTo(2.0, 1e-10));
      });
    });

    group('Complex Hyperbolic Functions', () {
      test('sinh(i) = i*sin(1)', () {
        final result = evaluator.evaluate(r'\sinh(i)');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        // sinh(i) = i*sin(1), since sinh(ix) = i*sin(x)
        expect(c.real, closeTo(0.0, 1e-10));
        expect(c.imaginary, closeTo(math.sin(1), 1e-10));
      });

      test('cosh(i) = cos(1)', () {
        final result = evaluator.evaluate(r'\cosh(i)');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        // cosh(i) = cos(1), since cosh(ix) = cos(x)
        expect(c.real, closeTo(math.cos(1), 1e-10));
        expect(c.imaginary, closeTo(0.0, 1e-10));
      });
    });

    group('Complex Class Methods', () {
      test('Complex.fromPolar works correctly', () {
        // r=2, θ=π/4 => 2*(cos(π/4) + i*sin(π/4)) = √2 + √2i
        final c = Complex.fromPolar(2, math.pi / 4);
        expect(c.real, closeTo(math.sqrt(2), 1e-10));
        expect(c.imaginary, closeTo(math.sqrt(2), 1e-10));
      });

      test('Complex.toPolar works correctly', () {
        final c = Complex(1, 1);
        final polar = c.toPolar();
        // |1+i| = √2 ≈ 1.4142, arg(1+i) = π/4 ≈ 0.7854
        expect(polar, contains('1.4142'));
        expect(polar, contains('0.7854'));
      });

      test('Complex methods directly', () {
        final c = Complex(1, 2);

        // exp
        final expC = c.exp();
        expect(
            expC.abs,
            closeTo(
                math.exp(1) *
                    math.sqrt(
                        math.cos(2) * math.cos(2) + math.sin(2) * math.sin(2)),
                1e-10));

        // log
        final logC = c.log();
        expect(logC.real, closeTo(math.log(c.abs), 1e-10));
        expect(logC.imaginary, closeTo(c.arg, 1e-10));

        // sqrt
        final sqrtC = c.sqrt();
        final sqrtSquared = sqrtC * sqrtC;
        expect((sqrtSquared).real, closeTo(c.real, 1e-10));
        expect(sqrtSquared.imaginary, closeTo(c.imaginary, 1e-10));
      });
    });
  });
}
