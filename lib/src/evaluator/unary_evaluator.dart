import '../ast.dart';
import '../complex.dart';
import '../exceptions.dart';
import '../matrix.dart';
import '../vector.dart';

/// Handles evaluation of unary operations.
class UnaryEvaluator {
  /// Evaluates a unary operation on an expression.
  ///
  /// Supports negation of numbers, complex numbers, matrices, and vectors.
  dynamic evaluate(
    UnaryOperator operator,
    dynamic operandValue,
  ) {
    if (operandValue is Vector) {
      if (operator == UnaryOperator.negate) {
        return -operandValue;
      }
      throw EvaluatorException(
        'Operator $operator not supported for vector',
        suggestion: 'Use scalar multiplication with -1 instead: -1 * v',
      );
    }

    if (operandValue is Matrix) {
      if (operator == UnaryOperator.negate) {
        return operandValue * -1;
      }
      throw EvaluatorException(
        'Operator $operator not supported for matrix',
        suggestion: 'Use scalar multiplication with -1 instead: -1 * M',
      );
    }

    if (operandValue is Complex) {
      switch (operator) {
        case UnaryOperator.negate:
          return -operandValue;
      }
    }

    if (operandValue is double) {
      switch (operator) {
        case UnaryOperator.negate:
          return -operandValue;
      }
    }

    throw EvaluatorException(
      'Type mismatch in unary operation',
      suggestion:
          'Unary operators can only be applied to numbers, complex numbers, matrices, or vectors',
    );
  }
}
