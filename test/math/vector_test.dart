import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('Vector Creation', () {
    test('creates vector using \\vec{} notation', () {
      final result = evaluator.evaluate(r'\vec{1, 2, 3}');
      expect(result.isVector, isTrue);
      final vec = result.asVector();
      expect(vec.dimension, equals(3));
      expect(vec[0], equals(1.0));
      expect(vec[1], equals(2.0));
      expect(vec[2], equals(3.0));
    });

    test('creates 2D vector', () {
      final result = evaluator.evaluate(r'\vec{3, 4}');
      final vec = result.asVector();
      expect(vec.dimension, equals(2));
      expect(vec[0], equals(3.0));
      expect(vec[1], equals(4.0));
    });

    test('creates vector with expressions', () {
      final result = evaluator.evaluate(r'\vec{2+3, 4*5, 6^2}');
      final vec = result.asVector();
      expect(vec[0], equals(5.0));
      expect(vec[1], equals(20.0));
      expect(vec[2], equals(36.0));
    });

    test('creates vector with variables', () {
      final result =
          evaluator.evaluate(r'\vec{x, y, z}', {'x': 1, 'y': 2, 'z': 3});
      final vec = result.asVector();
      expect(vec[0], equals(1.0));
      expect(vec[1], equals(2.0));
      expect(vec[2], equals(3.0));
    });
  });

  group('Unit Vectors', () {
    test('creates unit vector using \\hat{} notation', () {
      final result = evaluator.evaluate(r'\hat{3, 4}');
      expect(result.isVector, isTrue);
      final vec = result.asVector();
      expect(vec.dimension, equals(2));
      // 3-4-5 triangle: unit vector should be (0.6, 0.8)
      expect(vec[0], closeTo(0.6, 0.0001));
      expect(vec[1], closeTo(0.8, 0.0001));
    });

    test('unit vector has magnitude 1', () {
      final result = evaluator.evaluate(r'\hat{1, 2, 3}');
      final vec = result.asVector();
      expect(vec.magnitude, closeTo(1.0, 0.0001));
    });

    test('throws error for zero vector normalization', () {
      expect(
        () => evaluator.evaluate(r'\hat{0, 0, 0}'),
        throwsA(isA<EvaluatorException>()),
      );
    });
  });

  group('Vector Magnitude', () {
    test('calculates magnitude using absolute value notation', () {
      final result = evaluator.evaluate(r'|\vec{3, 4}|');
      expect(result.asNumeric(), equals(5.0));
    });

    test('calculates magnitude of 3D vector', () {
      final result = evaluator.evaluate(r'|\vec{1, 2, 2}|');
      expect(result.asNumeric(), equals(3.0));
    });

    test('magnitude of unit vector is 1', () {
      final result = evaluator.evaluate(r'|\hat{5, 12}|');
      expect(result.asNumeric(), closeTo(1.0, 0.0001));
    });

    test('magnitude of zero vector is 0', () {
      final result = evaluator.evaluate(r'|\vec{0, 0}|');
      expect(result.asNumeric(), equals(0.0));
    });
  });

  group('Dot Product', () {
    test('calculates dot product using \\cdot', () {
      final result = evaluator.evaluate(r'\vec{1, 2, 3} \cdot \vec{4, 5, 6}');
      expect(result.asNumeric(), equals(32.0)); // 1*4 + 2*5 + 3*6 = 32
    });

    test('dot product of orthogonal vectors is zero', () {
      final result = evaluator.evaluate(r'\vec{1, 0} \cdot \vec{0, 1}');
      expect(result.asNumeric(), equals(0.0));
    });

    test('dot product is commutative', () {
      final result1 = evaluator.evaluate(r'\vec{2, 3} \cdot \vec{4, 5}');
      final result2 = evaluator.evaluate(r'\vec{4, 5} \cdot \vec{2, 3}');
      expect(result1.asNumeric(), equals(result2.asNumeric()));
    });

    test('throws error for dimension mismatch in dot product', () {
      expect(
        () => evaluator.evaluate(r'\vec{1, 2} \cdot \vec{3, 4, 5}'),
        throwsA(isA<EvaluatorException>()),
      );
    });
  });

  group('Cross Product', () {
    test('calculates cross product using \\times', () {
      final result = evaluator.evaluate(r'\vec{1, 0, 0} \times \vec{0, 1, 0}');
      final vec = result.asVector();
      expect(vec[0], equals(0.0));
      expect(vec[1], equals(0.0));
      expect(vec[2], equals(1.0));
    });

    test('cross product of general 3D vectors', () {
      final result = evaluator.evaluate(r'\vec{1, 2, 3} \times \vec{4, 5, 6}');
      final vec = result.asVector();
      // [2*6 - 3*5, 3*4 - 1*6, 1*5 - 2*4] = [-3, 6, -3]
      expect(vec[0], equals(-3.0));
      expect(vec[1], equals(6.0));
      expect(vec[2], equals(-3.0));
    });

    test('cross product is anti-commutative', () {
      final result1 = evaluator.evaluate(r'\vec{1, 2, 3} \times \vec{4, 5, 6}');
      final result2 = evaluator.evaluate(r'\vec{4, 5, 6} \times \vec{1, 2, 3}');
      final vec1 = result1.asVector();
      final vec2 = result2.asVector();
      expect(vec1[0], equals(-vec2[0]));
      expect(vec1[1], equals(-vec2[1]));
      expect(vec1[2], equals(-vec2[2]));
    });

    test('throws error for non-3D vectors in cross product', () {
      expect(
        () => evaluator.evaluate(r'\vec{1, 2} \times \vec{3, 4}'),
        throwsA(isA<EvaluatorException>()),
      );
    });

    test('cross product of parallel vectors is zero', () {
      final result = evaluator.evaluate(r'\vec{1, 2, 3} \times \vec{2, 4, 6}');
      final vec = result.asVector();
      expect(vec[0], equals(0.0));
      expect(vec[1], equals(0.0));
      expect(vec[2], equals(0.0));
    });
  });

  group('Vector Addition and Subtraction', () {
    test('adds two vectors', () {
      final result = evaluator.evaluate(r'\vec{1, 2} + \vec{3, 4}');
      final vec = result.asVector();
      expect(vec[0], equals(4.0));
      expect(vec[1], equals(6.0));
    });

    test('subtracts two vectors', () {
      final result = evaluator.evaluate(r'\vec{5, 7} - \vec{2, 3}');
      final vec = result.asVector();
      expect(vec[0], equals(3.0));
      expect(vec[1], equals(4.0));
    });

    test('throws error for dimension mismatch in addition', () {
      expect(
        () => evaluator.evaluate(r'\vec{1, 2} + \vec{3, 4, 5}'),
        throwsA(isA<EvaluatorException>()),
      );
    });

    test('throws error for dimension mismatch in subtraction', () {
      expect(
        () => evaluator.evaluate(r'\vec{1, 2, 3} - \vec{4, 5}'),
        throwsA(isA<EvaluatorException>()),
      );
    });
  });

  group('Scalar Multiplication', () {
    test('multiplies vector by scalar from left', () {
      final result = evaluator.evaluate(r'3 * \vec{1, 2, 3}');
      final vec = result.asVector();
      expect(vec[0], equals(3.0));
      expect(vec[1], equals(6.0));
      expect(vec[2], equals(9.0));
    });

    test('multiplies vector by scalar from right', () {
      final result = evaluator.evaluate(r'\vec{2, 4, 6} * 0.5');
      final vec = result.asVector();
      expect(vec[0], equals(1.0));
      expect(vec[1], equals(2.0));
      expect(vec[2], equals(3.0));
    });

    test('divides vector by scalar', () {
      final result = evaluator.evaluate(r'\vec{6, 9, 12} / 3');
      final vec = result.asVector();
      expect(vec[0], equals(2.0));
      expect(vec[1], equals(3.0));
      expect(vec[2], equals(4.0));
    });

    test('throws error for division by zero', () {
      expect(
        () => evaluator.evaluate(r'\vec{1, 2} / 0'),
        throwsA(isA<EvaluatorException>()),
      );
    });

    test('multiplication by zero creates zero vector', () {
      final result = evaluator.evaluate(r'0 * \vec{5, 10, 15}');
      final vec = result.asVector();
      expect(vec[0], equals(0.0));
      expect(vec[1], equals(0.0));
      expect(vec[2], equals(0.0));
    });
  });

  group('Unary Negation', () {
    test('negates a vector', () {
      final result = evaluator.evaluate(r'-\vec{1, -2, 3}');
      final vec = result.asVector();
      expect(vec[0], equals(-1.0));
      expect(vec[1], equals(2.0));
      expect(vec[2], equals(-3.0));
    });
  });

  group('Complex Expressions', () {
    test('combines multiple operations', () {
      final result =
          evaluator.evaluate(r'(\vec{1, 2} + \vec{3, 4}) \cdot \vec{2, 1}');
      expect(result.asNumeric(), equals(14.0)); // (4,6) · (2,1) = 8+6 = 14
    });

    test('dot product with scalar multiplication', () {
      final result = evaluator.evaluate(r'2 * \vec{1, 2} \cdot \vec{3, 4}');
      expect(result.asNumeric(), equals(22.0)); // 2*(1*3 + 2*4) = 2*11 = 22
    });

    test('magnitude of sum', () {
      final result = evaluator.evaluate(r'|\vec{3, 0} + \vec{0, 4}|');
      expect(result.asNumeric(), equals(5.0));
    });

    test('unit vector from expression', () {
      final result = evaluator.evaluate(r'\hat{x, y}', {'x': 3, 'y': 4});
      final vec = result.asVector();
      expect(vec.magnitude, closeTo(1.0, 0.0001));
      expect(vec[0], closeTo(0.6, 0.0001));
      expect(vec[1], closeTo(0.8, 0.0001));
    });
  });

  group('Edge Cases', () {
    test('single component vector', () {
      final result = evaluator.evaluate(r'\vec{42}');
      final vec = result.asVector();
      expect(vec.dimension, equals(1));
      expect(vec[0], equals(42.0));
    });

    test('vector with negative components', () {
      final result = evaluator.evaluate(r'\vec{-1, -2, -3}');
      final vec = result.asVector();
      expect(vec[0], equals(-1.0));
      expect(vec[1], equals(-2.0));
      expect(vec[2], equals(-3.0));
    });

    test('vector with decimal components', () {
      final result = evaluator.evaluate(r'\vec{1.5, 2.7, 3.9}');
      final vec = result.asVector();
      expect(vec[0], equals(1.5));
      expect(vec[1], equals(2.7));
      expect(vec[2], equals(3.9));
    });
  });

  group('Type Conversion Errors', () {
    test('cannot convert vector to numeric', () {
      final result = evaluator.evaluate(r'\vec{1, 2, 3}');
      expect(() => result.asNumeric(), throwsA(isA<StateError>()));
    });

    test('cannot convert vector to matrix', () {
      final result = evaluator.evaluate(r'\vec{1, 2, 3}');
      expect(() => result.asMatrix(), throwsA(isA<StateError>()));
    });

    test('cannot convert number to vector', () {
      final result = evaluator.evaluate('42');
      expect(() => result.asVector(), throwsA(isA<StateError>()));
    });
  });
}
