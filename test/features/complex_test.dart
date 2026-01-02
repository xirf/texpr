import 'package:test/test.dart';
import 'package:texpr/texpr.dart';
import 'package:texpr/src/complex.dart';

void main() {
  group('Complex Number Support', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    test('Complex arithmetic', () {
      final c1 = Complex(1, 2);
      final c2 = Complex(3, 4);

      expect(c1 + c2, Complex(4, 6));
      expect(c1 - c2, Complex(-2, -2));
      expect(c1 * c2, Complex(-5, 10));
      // (1+2i)/(3+4i) = (1+2i)(3-4i)/25 = (3-4i+6i+8)/25 = (11+2i)/25 = 0.44 + 0.08i
      expect(c1 / c2, Complex(0.44, 0.08));
    });

    test('Evaluator handles "i" constant', () {
      final result = evaluator.evaluate('i');
      expect(result, isA<ComplexResult>());
      expect((result as ComplexResult).value, Complex(0, 1));
    });

    test('Complex arithmetic in evaluator', () {
      // (1 + 2i) + (3 + 4i)
      var result = evaluator.evaluate('(1 + 2*i) + (3 + 4*i)');
      expect((result as ComplexResult).value, Complex(4, 6));

      // i * i = -1
      result = evaluator.evaluate('i * i');
      expect((result as ComplexResult).value, Complex(-1, 0));

      // i^2 = -1 (using power operator, note: small floating point error possible)
      result = evaluator.evaluate('i^2');
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(-1.0, 1e-10));
      expect(c.imaginary, closeTo(0.0, 1e-10));
    });

    test('Complex functions', () {
      // Re(2 + 3i) = 2
      var result = evaluator.evaluate(r'\Re(2 + 3*i)');
      expect(result.asNumeric(), 2.0);

      // Im(2 + 3i) = 3
      result = evaluator.evaluate(r'\Im(2 + 3*i)');
      expect(result.asNumeric(), 3.0);

      // conjugate(2 + 3i) = 2 - 3i
      result = evaluator.evaluate(r'\conjugate(2 + 3*i)');
      expect((result as ComplexResult).value, Complex(2, -3));
    });

    test('Mixed arithmetic', () {
      // 5 + i
      var result = evaluator.evaluate('5 + i');
      expect((result as ComplexResult).value, Complex(5, 1));

      // 5 * i
      result = evaluator.evaluate('5 * i');
      expect((result as ComplexResult).value, Complex(0, 5));
    });

    test('Type safety', () {
      final result = evaluator.evaluate('2 + 3*i');
      expect(result.isComplex, true);
      expect(result.isNumeric, false);
      expect(() => result.asNumeric(), throwsStateError);
      expect(result.asComplex(), Complex(2, 3));
    });
  });
}
