/// Vector binary operation strategy.
library;

import 'dart:math' as math;
import '../../ast/operations.dart';
import '../../exceptions.dart';
import '../../vector.dart';
import 'binary_operation_strategy.dart';

/// Strategy for evaluating binary operations involving vectors.
class VectorStrategy implements BinaryOperationStrategy {
  @override
  bool canHandle(dynamic left, dynamic right) {
    return left is Vector || right is Vector;
  }

  @override
  dynamic evaluate(
    dynamic left,
    BinaryOperator operator,
    dynamic right, {
    String? sourceToken,
  }) {
    if (left is Vector && right is Vector) {
      return _evaluateVectorVector(left, operator, right, sourceToken ?? '');
    } else if (left is Vector && right is num) {
      return _evaluateVectorScalar(left, operator, right);
    } else if (left is num && right is Vector) {
      return _evaluateScalarVector(left, operator, right);
    }

    throw EvaluatorException(
      'Invalid vector operation',
      suggestion: 'Vectors can be combined with other vectors or scalars',
    );
  }

  dynamic _evaluateVectorVector(
    Vector left,
    BinaryOperator operator,
    Vector right,
    String sourceToken,
  ) {
    switch (operator) {
      case BinaryOperator.add:
        return left + right;
      case BinaryOperator.subtract:
        return left - right;
      case BinaryOperator.multiply:
        // Disambiguate: \times for cross product, \cdot or * for dot product
        if (sourceToken == r'\times') {
          return left.cross(right);
        } else {
          return left.dot(right);
        }
      case BinaryOperator.power:
        if (left.dimension != right.dimension) {
          throw EvaluatorException(
            'Vector dimensions must match for component-wise power',
            suggestion: 'Both vectors must have the same number of components',
          );
        }
        final components = List.generate(
          left.dimension,
          (i) => math.pow(left[i], right[i]).toDouble(),
        );
        return Vector(components);
      default:
        throw EvaluatorException(
          'Operator $operator not supported for vectors',
          suggestion: 'Vectors support +, -, ⋅ (dot), * (cross) operations',
        );
    }
  }

  Vector _evaluateVectorScalar(
    Vector left,
    BinaryOperator operator,
    num right,
  ) {
    switch (operator) {
      case BinaryOperator.multiply:
        return left * right;
      case BinaryOperator.divide:
        if (right == 0) {
          throw EvaluatorException(
            'Division by zero',
            suggestion: 'Cannot divide a vector by zero',
          );
        }
        return left / right;
      case BinaryOperator.power:
        final components =
            left.components.map((c) => math.pow(c, right).toDouble()).toList();
        return Vector(components);
      default:
        throw EvaluatorException(
          'Operator $operator not supported for vector and scalar',
          suggestion:
              'You can multiply, divide, or raise a vector to a scalar power',
        );
    }
  }

  Vector _evaluateScalarVector(
    num left,
    BinaryOperator operator,
    Vector right,
  ) {
    switch (operator) {
      case BinaryOperator.multiply:
        return right * left;
      default:
        throw EvaluatorException(
          'Operator $operator not supported for scalar and vector',
          suggestion: 'You can multiply a scalar by a vector: 2 * v',
        );
    }
  }
}
