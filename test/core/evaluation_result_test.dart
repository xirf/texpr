import 'package:test/test.dart';
import 'package:texpr/texpr.dart';
import 'package:texpr/src/complex.dart';

void main() {
  group('EvaluationResult', () {
    group('NumericResult', () {
      test('isNumeric returns true', () {
        final result = NumericResult(5.0);
        expect(result.isNumeric, isTrue);
        expect(result.isMatrix, isFalse);
        expect(result.isComplex, isFalse);
        expect(result.isVector, isFalse);
      });

      test('asNumeric returns value', () {
        final result = NumericResult(5.0);
        expect(result.asNumeric(), 5.0);
      });

      test('asComplex returns Complex with value', () {
        final result = NumericResult(5.0);
        final complex = result.asComplex();
        expect(complex.real, 5.0);
        expect(complex.imaginary, 0.0);
      });

      test('asMatrix throws StateError', () {
        final result = NumericResult(5.0);
        expect(() => result.asMatrix(), throwsStateError);
      });

      test('asVector throws StateError', () {
        final result = NumericResult(5.0);
        expect(() => result.asVector(), throwsStateError);
      });

      test('isNaN returns true for NaN value', () {
        final result = NumericResult(double.nan);
        expect(result.isNaN, isTrue);
      });

      test('isNaN returns false for finite value', () {
        final result = NumericResult(5.0);
        expect(result.isNaN, isFalse);
      });

      test('isNaN returns false for infinity', () {
        final result = NumericResult(double.infinity);
        expect(result.isNaN, isFalse);
      });

      test('equality works correctly', () {
        final result1 = NumericResult(5.0);
        final result2 = NumericResult(5.0);
        final result3 = NumericResult(10.0);

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
        expect(result1 == result1, isTrue); // identical
      });

      test('hashCode is consistent', () {
        final result1 = NumericResult(5.0);
        final result2 = NumericResult(5.0);
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('toString returns correct format', () {
        final result = NumericResult(42.0);
        expect(result.toString(), contains('NumericResult'));
        expect(result.toString(), contains('42'));
      });
    });

    group('ComplexResult', () {
      test('isComplex returns true', () {
        final result = ComplexResult(Complex(2, 3));
        expect(result.isComplex, isTrue);
        expect(result.isNumeric, isFalse);
        expect(result.isMatrix, isFalse);
        expect(result.isVector, isFalse);
      });

      test('asComplex returns complex value', () {
        final complex = Complex(2, 3);
        final result = ComplexResult(complex);
        expect(result.asComplex(), equals(complex));
      });

      test('asNumeric returns real part when imaginary is zero', () {
        final result = ComplexResult(Complex(5, 0));
        expect(result.asNumeric(), equals(5.0));
      });

      test('asNumeric throws StateError when imaginary is non-zero', () {
        final result = ComplexResult(Complex(2, 3));
        expect(() => result.asNumeric(), throwsStateError);
      });

      test('asMatrix throws StateError', () {
        final result = ComplexResult(Complex(2, 3));
        expect(() => result.asMatrix(), throwsStateError);
      });

      test('asVector throws StateError', () {
        final result = ComplexResult(Complex(2, 3));
        expect(() => result.asVector(), throwsStateError);
      });

      test('isNaN returns true when real is NaN', () {
        final result = ComplexResult(Complex(double.nan, 3));
        expect(result.isNaN, isTrue);
      });

      test('isNaN returns true when imaginary is NaN', () {
        final result = ComplexResult(Complex(2, double.nan));
        expect(result.isNaN, isTrue);
      });

      test('isNaN returns false for normal complex', () {
        final result = ComplexResult(Complex(2, 3));
        expect(result.isNaN, isFalse);
      });

      test('equality works correctly', () {
        final result1 = ComplexResult(Complex(2, 3));
        final result2 = ComplexResult(Complex(2, 3));
        final result3 = ComplexResult(Complex(2, 4));

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });

      test('hashCode is consistent', () {
        final result1 = ComplexResult(Complex(2, 3));
        final result2 = ComplexResult(Complex(2, 3));
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('toString returns correct format', () {
        final result = ComplexResult(Complex(2, 3));
        expect(result.toString(), contains('ComplexResult'));
      });
    });

    group('MatrixResult', () {
      final matrix = Matrix([
        [1, 2],
        [3, 4]
      ]);

      test('isMatrix returns true', () {
        final result = MatrixResult(matrix);
        expect(result.isMatrix, isTrue);
        expect(result.isNumeric, isFalse);
        expect(result.isComplex, isFalse);
        expect(result.isVector, isFalse);
      });

      test('asMatrix returns matrix', () {
        final result = MatrixResult(matrix);
        expect(result.asMatrix(), matrix);
      });

      test('asNumeric throws StateError', () {
        final result = MatrixResult(matrix);
        expect(() => result.asNumeric(), throwsStateError);
      });

      test('asComplex throws StateError', () {
        final result = MatrixResult(matrix);
        expect(() => result.asComplex(), throwsStateError);
      });

      test('asVector throws StateError', () {
        final result = MatrixResult(matrix);
        expect(() => result.asVector(), throwsStateError);
      });

      test('isNaN always returns false', () {
        final result = MatrixResult(matrix);
        expect(result.isNaN, isFalse);
      });

      test('equality works correctly', () {
        final result1 = MatrixResult(matrix);
        final result2 = MatrixResult(matrix);
        final result3 = MatrixResult(Matrix([
          [1]
        ]));

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });

      test('hashCode is consistent', () {
        final result1 = MatrixResult(matrix);
        final result2 = MatrixResult(matrix);
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('toString returns correct format', () {
        final result = MatrixResult(matrix);
        expect(result.toString(), contains('MatrixResult'));
      });
    });

    group('VectorResult', () {
      final vector = Vector([1, 2, 3]);

      test('isVector returns true', () {
        final result = VectorResult(vector);
        expect(result.isVector, isTrue);
        expect(result.isNumeric, isFalse);
        expect(result.isComplex, isFalse);
        expect(result.isMatrix, isFalse);
      });

      test('asVector returns vector', () {
        final result = VectorResult(vector);
        expect(result.asVector(), vector);
      });

      test('asNumeric throws StateError', () {
        final result = VectorResult(vector);
        expect(() => result.asNumeric(), throwsStateError);
      });

      test('asComplex throws StateError', () {
        final result = VectorResult(vector);
        expect(() => result.asComplex(), throwsStateError);
      });

      test('asMatrix throws StateError', () {
        final result = VectorResult(vector);
        expect(() => result.asMatrix(), throwsStateError);
      });

      test('isNaN always returns false', () {
        final result = VectorResult(vector);
        expect(result.isNaN, isFalse);
      });

      test('equality works correctly', () {
        final result1 = VectorResult(vector);
        final result2 = VectorResult(vector);
        final result3 = VectorResult(Vector([1, 2]));

        expect(result1, equals(result2));
        expect(result1, isNot(equals(result3)));
      });

      test('hashCode is consistent', () {
        final result1 = VectorResult(vector);
        final result2 = VectorResult(vector);
        expect(result1.hashCode, equals(result2.hashCode));
      });

      test('toString returns correct format', () {
        final result = VectorResult(vector);
        expect(result.toString(), contains('VectorResult'));
      });
    });
  });
}
