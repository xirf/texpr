// ignore_for_file: unrelated_type_equality_checks

import 'package:test/test.dart';
import 'package:texpr/src/complex.dart';
import 'dart:math' as math;

void main() {
  group('Complex class', () {
    test('creates complex number with real and imaginary parts', () {
      final c = Complex(3, 4);
      expect(c.real, equals(3));
      expect(c.imaginary, equals(4));
    });

    test('creates complex number with only real part', () {
      final c = Complex(5);
      expect(c.real, equals(5));
      expect(c.imaginary, equals(0));
    });

    test('factory fromNum creates from integer', () {
      final c = Complex.fromNum(7);
      expect(c.real, equals(7.0));
      expect(c.imaginary, equals(0.0));
    });

    test('factory fromNum creates from double', () {
      final c = Complex.fromNum(3.14);
      expect(c.real, equals(3.14));
      expect(c.imaginary, equals(0.0));
    });

    test('isReal returns true when imaginary is zero', () {
      final c = Complex(5, 0);
      expect(c.isReal, isTrue);
    });

    test('isReal returns false when imaginary is non-zero', () {
      final c = Complex(5, 2);
      expect(c.isReal, isFalse);
    });

    test('isImaginary returns true when real is zero and imaginary is non-zero',
        () {
      final c = Complex(0, 5);
      expect(c.isImaginary, isTrue);
    });

    test('isImaginary returns false when real is non-zero', () {
      final c = Complex(3, 5);
      expect(c.isImaginary, isFalse);
    });

    test('isImaginary returns false when both are zero', () {
      final c = Complex(0, 0);
      expect(c.isImaginary, isFalse);
    });

    test('abs calculates magnitude correctly', () {
      final c = Complex(3, 4);
      expect(c.abs, equals(5.0)); // sqrt(9 + 16) = 5
    });

    test('abs for real number', () {
      final c = Complex(5, 0);
      expect(c.abs, equals(5.0));
    });

    test('arg calculates argument correctly', () {
      final c = Complex(1, 1);
      expect(c.arg, closeTo(math.pi / 4, 0.0001));
    });

    test('arg for real positive number', () {
      final c = Complex(5, 0);
      expect(c.arg, equals(0.0));
    });

    test('arg for imaginary number', () {
      final c = Complex(0, 5);
      expect(c.arg, closeTo(math.pi / 2, 0.0001));
    });

    test('conjugate returns complex conjugate', () {
      final c = Complex(3, 4);
      final conj = c.conjugate;
      expect(conj.real, equals(3));
      expect(conj.imaginary, equals(-4));
    });

    test('conjugate of real number', () {
      final c = Complex(5, 0);
      final conj = c.conjugate;
      expect(conj.real, equals(5));
      expect(conj.imaginary, equals(0));
    });

    test('addition with another complex number', () {
      final c1 = Complex(1, 2);
      final c2 = Complex(3, 4);
      final result = c1 + c2;
      expect(result.real, equals(4));
      expect(result.imaginary, equals(6));
    });

    test('addition with a num', () {
      final c = Complex(1, 2);
      final result = c + 5;
      expect(result.real, equals(6));
      expect(result.imaginary, equals(2));
    });

    test('addition with double', () {
      final c = Complex(1, 2);
      final result = c + 3.5;
      expect(result.real, equals(4.5));
      expect(result.imaginary, equals(2));
    });

    test('addition throws ArgumentError for invalid type', () {
      final c = Complex(1, 2);
      expect(() => c + 'invalid', throwsArgumentError);
    });

    test('subtraction with another complex number', () {
      final c1 = Complex(5, 7);
      final c2 = Complex(2, 3);
      final result = c1 - c2;
      expect(result.real, equals(3));
      expect(result.imaginary, equals(4));
    });

    test('subtraction with a num', () {
      final c = Complex(5, 3);
      final result = c - 2;
      expect(result.real, equals(3));
      expect(result.imaginary, equals(3));
    });

    test('subtraction with double', () {
      final c = Complex(5, 3);
      final result = c - 1.5;
      expect(result.real, equals(3.5));
      expect(result.imaginary, equals(3));
    });

    test('subtraction throws ArgumentError for invalid type', () {
      final c = Complex(1, 2);
      expect(() => c - 'invalid', throwsArgumentError);
    });

    test('multiplication with another complex number', () {
      final c1 = Complex(1, 2);
      final c2 = Complex(3, 4);
      final result = c1 * c2;
      // (1+2i)(3+4i) = 3 + 4i + 6i + 8i² = 3 + 10i - 8 = -5 + 10i
      expect(result.real, equals(-5));
      expect(result.imaginary, equals(10));
    });

    test('multiplication with a num', () {
      final c = Complex(2, 3);
      final result = c * 4;
      expect(result.real, equals(8));
      expect(result.imaginary, equals(12));
    });

    test('multiplication with double', () {
      final c = Complex(2, 3);
      final result = c * 0.5;
      expect(result.real, equals(1));
      expect(result.imaginary, equals(1.5));
    });

    test('multiplication throws ArgumentError for invalid type', () {
      final c = Complex(1, 2);
      expect(() => c * 'invalid', throwsArgumentError);
    });

    test('division with another complex number', () {
      final c1 = Complex(1, 2);
      final c2 = Complex(3, 4);
      final result = c1 / c2;
      // (1+2i)/(3+4i) = (1+2i)(3-4i)/(9+16) = (3-4i+6i+8)/25 = (11+2i)/25
      expect(result.real, closeTo(0.44, 0.0001));
      expect(result.imaginary, closeTo(0.08, 0.0001));
    });

    test('division with a num', () {
      final c = Complex(8, 4);
      final result = c / 2;
      expect(result.real, equals(4));
      expect(result.imaginary, equals(2));
    });

    test('division with double', () {
      final c = Complex(5, 10);
      final result = c / 2.5;
      expect(result.real, equals(2));
      expect(result.imaginary, equals(4));
    });

    test('division throws ArgumentError for invalid type', () {
      final c = Complex(1, 2);
      expect(() => c / 'invalid', throwsArgumentError);
    });

    test('unary minus negates both parts', () {
      final c = Complex(3, 4);
      final result = -c;
      expect(result.real, equals(-3));
      expect(result.imaginary, equals(-4));
    });

    test('unary minus on zero', () {
      final c = Complex(0, 0);
      final result = -c;
      expect(result.real, equals(0));
      expect(result.imaginary, equals(0));
    });

    test('toString for real number', () {
      final c = Complex(5, 0);
      expect(c.toString(), equals('5.0'));
    });

    test('toString for imaginary number', () {
      final c = Complex(0, 3);
      expect(c.toString(), equals('3.0i'));
    });

    test('toString for complex with positive imaginary', () {
      final c = Complex(2, 3);
      final str = c.toString();
      expect(str, contains('2.0'));
      expect(str, contains('+'));
      expect(str, contains('3.0i'));
    });

    test('toString for complex with negative imaginary', () {
      final c = Complex(2, -3);
      final str = c.toString();
      expect(str, contains('2.0'));
      expect(str, contains('-'));
      expect(str, contains('3.0i'));
    });

    test('equality with identical complex', () {
      final c = Complex(3, 4);
      expect(c == c, isTrue);
    });

    test('equality with equal complex', () {
      final c1 = Complex(3, 4);
      final c2 = Complex(3, 4);
      expect(c1, equals(c2));
    });

    test('equality with different complex', () {
      final c1 = Complex(3, 4);
      final c2 = Complex(3, 5);
      expect(c1, isNot(equals(c2)));
    });

    test('equality with num when imaginary is zero', () {
      final c = Complex(5, 0);
      expect(c == 5, isTrue);
      expect(c == 5.0, isTrue);
    });

    test('equality with num when imaginary is non-zero', () {
      final c = Complex(5, 1);
      expect(c == 5, isFalse);
    });

    test('equality with different real part', () {
      final c1 = Complex(3, 4);
      final c2 = Complex(4, 4);
      expect(c1, isNot(equals(c2)));
    });

    test('hashCode is consistent', () {
      final c1 = Complex(3, 4);
      final c2 = Complex(3, 4);
      expect(c1.hashCode, equals(c2.hashCode));
    });

    test('hashCode differs for different values', () {
      final c1 = Complex(3, 4);
      final c2 = Complex(3, 5);
      expect(c1.hashCode, isNot(equals(c2.hashCode)));
    });
  });
}
