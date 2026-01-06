/// Type-safe evaluation result classes.
library;

import 'complex.dart';
import 'matrix.dart';
import 'vector.dart';

/// Base sealed class for evaluation results.
///
/// All evaluation results are either [NumericResult], [ComplexResult],
/// [MatrixResult], or [VectorResult].
/// This provides type safety when working with evaluation results.
///
/// Example:
/// ```dart
/// final evaluator = Texpr();
/// final result = evaluator.evaluate('2 + 3');
///
/// switch (result) {
///   case NumericResult(:final value):
///     print('Numeric result: $value');
///   case ComplexResult(:final value):
///     print('Complex result: $value');
///   case MatrixResult(:final matrix):
///     print('Matrix result: $matrix');
///   case VectorResult(:final vector):
///     print('Vector result: $vector');
/// }
/// ```
sealed class EvaluationResult {
  const EvaluationResult();

  /// Converts the result to a numeric value.
  ///
  /// Throws [StateError] if the result is a [MatrixResult], [VectorResult],
  /// or a non-real [ComplexResult].
  double asNumeric() {
    return switch (this) {
      NumericResult(:final value) => value,
      ComplexResult(:final value) => value.isReal
          ? value.real
          : throw StateError('Result is a complex number, not a real number'),
      MatrixResult() => throw StateError('Result is a matrix, not a number'),
      VectorResult() => throw StateError('Result is a vector, not a number'),
      FunctionResult() =>
        throw StateError('Result is a function, not a number'),
    };
  }

  /// Converts the result to a complex value.
  ///
  /// Throws [StateError] if the result is a [MatrixResult] or [VectorResult].
  Complex asComplex() {
    return switch (this) {
      NumericResult(:final value) => Complex(value),
      ComplexResult(:final value) => value,
      MatrixResult() => throw StateError('Result is a matrix, not a number'),
      VectorResult() => throw StateError('Result is a vector, not a number'),
      FunctionResult() =>
        throw StateError('Result is a function, not a number'),
    };
  }

  /// Converts the result to a matrix.
  ///
  /// Throws [StateError] if the result is a [NumericResult], [ComplexResult], or [VectorResult].
  Matrix asMatrix() {
    return switch (this) {
      NumericResult() => throw StateError('Result is a number, not a matrix'),
      ComplexResult() => throw StateError('Result is a number, not a matrix'),
      MatrixResult(:final matrix) => matrix,
      VectorResult() => throw StateError('Result is a vector, not a matrix'),
      FunctionResult() =>
        throw StateError('Result is a function, not a matrix'),
    };
  }

  /// Converts the result to a vector.
  ///
  /// Throws [StateError] if the result is a [NumericResult], [ComplexResult], or [MatrixResult].
  Vector asVector() {
    return switch (this) {
      NumericResult() => throw StateError('Result is a number, not a vector'),
      ComplexResult() => throw StateError('Result is a number, not a vector'),
      MatrixResult() => throw StateError('Result is a matrix, not a vector'),
      VectorResult(:final vector) => vector,
      FunctionResult() =>
        throw StateError('Result is a function, not a vector'),
    };
  }

  /// Returns true if this is a numeric result.
  bool get isNumeric => this is NumericResult;

  /// Returns true if this is a complex result.
  bool get isComplex => this is ComplexResult;

  /// Returns true if this is a matrix result.
  bool get isMatrix => this is MatrixResult;

  /// Returns true if this is a vector result.
  bool get isVector => this is VectorResult;

  /// Returns true if the result is Not-a-Number (NaN).
  ///
  /// For [NumericResult], this returns true if the value is NaN.
  /// For [ComplexResult], this returns true if real or imaginary part is NaN.
  /// For [MatrixResult] and [VectorResult], this always returns false.
  bool get isNaN;
}

/// Represents a numeric evaluation result.
final class NumericResult extends EvaluationResult {
  /// The numeric value of the result.
  final double value;

  /// Creates a numeric result with the given [value].
  const NumericResult(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumericResult &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'NumericResult($value)';

  @override
  bool get isNaN => value.isNaN;
}

/// Represents a complex evaluation result.
final class ComplexResult extends EvaluationResult {
  /// The complex value of the result.
  final Complex value;

  /// Creates a complex result with the given [value].
  const ComplexResult(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ComplexResult &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ComplexResult($value)';

  @override
  bool get isNaN => value.real.isNaN || value.imaginary.isNaN;
}

/// Represents a matrix evaluation result.
final class MatrixResult extends EvaluationResult {
  /// The matrix value of the result.
  final Matrix matrix;

  /// Creates a matrix result with the given [matrix].
  const MatrixResult(this.matrix);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatrixResult &&
          runtimeType == other.runtimeType &&
          matrix == other.matrix;

  @override
  int get hashCode => matrix.hashCode;

  @override
  String toString() => 'MatrixResult($matrix)';

  @override
  bool get isNaN => false;
}

/// Represents a vector evaluation result.
final class VectorResult extends EvaluationResult {
  /// The vector value of the result.
  final Vector vector;

  /// Creates a vector result with the given [vector].
  const VectorResult(this.vector);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorResult &&
          runtimeType == other.runtimeType &&
          vector == other.vector;

  @override
  int get hashCode => vector.hashCode;

  @override
  String toString() => 'VectorResult($vector)';

  @override
  bool get isNaN => false;
}

/// Represents a function definition result.
final class FunctionResult extends EvaluationResult {
  /// The function definition (e.g., AST node).
  final dynamic function;

  /// Creates a function result with the given [function].
  const FunctionResult(this.function);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionResult &&
          runtimeType == other.runtimeType &&
          function == other.function;

  @override
  int get hashCode => function.hashCode;

  @override
  String toString() => 'FunctionResult($function)';

  @override
  bool get isNaN => false;
}
