import 'dart:math' as math;
import 'exceptions.dart';

/// Represents a mathematical vector of double values.
///
/// This class provides methods for vector operations such as dot product,
/// cross product, magnitude, and normalization.
///
/// Example:
/// ```dart
/// final v1 = Vector([1, 2, 3]);
/// final v2 = Vector([4, 5, 6]);
/// print(v1.dot(v2)); // 32.0
/// print(v1.magnitude); // ~3.74
/// ```
class Vector {
  /// The components of the vector.
  final List<double> components;

  /// Creates a vector from a list of components.
  ///
  /// [components] must be a non-empty list of doubles.
  Vector(this.components) {
    if (components.isEmpty) {
      throw EvaluatorException(
        'Vector must have at least one component',
        suggestion: 'Provide a non-empty list of components',
      );
    }
  }

  /// Creates a 2D vector from x and y coordinates.
  Vector.fromXY(double x, double y) : components = [x, y];

  /// Creates a 3D vector from x, y, and z coordinates.
  Vector.fromXYZ(double x, double y, double z) : components = [x, y, z];

  /// The dimension (number of components) of this vector.
  int get dimension => components.length;

  /// Returns the component at the given [index].
  double operator [](int index) => components[index];

  /// Calculates the magnitude (length) of this vector.
  ///
  /// The magnitude is the square root of the sum of the squares of all components.
  double get magnitude {
    double sumSquares = 0;
    for (final component in components) {
      sumSquares += component * component;
    }
    return math.sqrt(sumSquares);
  }

  /// Returns the unit vector (normalized vector) in the same direction.
  ///
  /// A unit vector has a magnitude of 1. Throws [EvaluatorException] if
  /// the magnitude is zero.
  Vector normalize() {
    final mag = magnitude;
    if (mag == 0) {
      throw EvaluatorException(
        'Cannot normalize zero vector',
        suggestion: 'A zero-length vector has no direction',
      );
    }
    return Vector(components.map((c) => c / mag).toList());
  }

  /// Calculates the dot product of this vector with [other].
  ///
  /// Both vectors must have the same dimension.
  /// Throws [EvaluatorException] if dimensions mismatch.
  double dot(Vector other) {
    if (dimension != other.dimension) {
      throw EvaluatorException(
        'Vector dimension mismatch for dot product: $dimension vs ${other.dimension}',
        suggestion: 'Both vectors must have the same dimension',
      );
    }
    double sum = 0;
    for (int i = 0; i < dimension; i++) {
      sum += components[i] * other.components[i];
    }
    return sum;
  }

  /// Calculates the cross product of this vector with [other].
  ///
  /// Both vectors must be 3-dimensional.
  /// Throws [EvaluatorException] if either vector is not 3D.
  Vector cross(Vector other) {
    if (dimension != 3 || other.dimension != 3) {
      throw EvaluatorException(
        'Cross product is only defined for 3D vectors',
        suggestion: 'Ensure both vectors have exactly 3 components',
      );
    }
    return Vector([
      components[1] * other.components[2] - components[2] * other.components[1],
      components[2] * other.components[0] - components[0] * other.components[2],
      components[0] * other.components[1] - components[1] * other.components[0],
    ]);
  }

  /// Adds this vector to [other].
  ///
  /// Both vectors must have the same dimension.
  /// Throws [EvaluatorException] if dimensions mismatch.
  Vector operator +(Vector other) {
    if (dimension != other.dimension) {
      throw EvaluatorException(
        'Vector dimension mismatch for addition: $dimension vs ${other.dimension}',
        suggestion: 'Both vectors must have the same dimension',
      );
    }
    return Vector(List.generate(
      dimension,
      (i) => components[i] + other.components[i],
    ));
  }

  /// Subtracts [other] from this vector.
  ///
  /// Both vectors must have the same dimension.
  /// Throws [EvaluatorException] if dimensions mismatch.
  Vector operator -(Vector other) {
    if (dimension != other.dimension) {
      throw EvaluatorException(
        'Vector dimension mismatch for subtraction: $dimension vs ${other.dimension}',
        suggestion: 'Both vectors must have the same dimension',
      );
    }
    return Vector(List.generate(
      dimension,
      (i) => components[i] - other.components[i],
    ));
  }

  /// Multiplies this vector by a scalar.
  ///
  /// Returns a new vector with each component multiplied by [scalar].
  Vector operator *(num scalar) {
    return Vector(components.map((c) => c * scalar).toList());
  }

  /// Divides this vector by a scalar.
  ///
  /// Returns a new vector with each component divided by [scalar].
  /// Throws [EvaluatorException] if [scalar] is zero.
  Vector operator /(num scalar) {
    if (scalar == 0) {
      throw EvaluatorException(
        'Division by zero',
        suggestion: 'Cannot divide a vector by zero',
      );
    }
    return Vector(components.map((c) => c / scalar).toList());
  }

  /// Negates this vector.
  ///
  /// Returns a new vector with all components negated.
  Vector operator -() {
    return Vector(components.map((c) => -c).toList());
  }

  @override
  String toString() {
    return components.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Vector) return false;
    if (dimension != other.dimension) return false;
    for (int i = 0; i < dimension; i++) {
      if (components[i] != other.components[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(components);
}
