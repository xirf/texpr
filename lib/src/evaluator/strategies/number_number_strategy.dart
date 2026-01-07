/// Number-number binary operation strategy.
library;

import 'dart:math' as math;
import '../../ast/operations.dart';
import '../../exceptions.dart';
import 'binary_operation_strategy.dart';

/// Strategy for evaluating binary operations between two numbers.
class NumberNumberStrategy implements BinaryOperationStrategy {
  @override
  bool canHandle(dynamic left, dynamic right) {
    return left is num && right is num;
  }

  @override
  double evaluate(dynamic left, BinaryOperator operator, dynamic right) {
    final l = left as num;
    final r = right as num;

    switch (operator) {
      case BinaryOperator.add:
        return (l + r).toDouble();
      case BinaryOperator.subtract:
        return (l - r).toDouble();
      case BinaryOperator.multiply:
        return (l * r).toDouble();
      case BinaryOperator.divide:
        if (r == 0) {
          throw EvaluatorException(
            'Division by zero',
            suggestion: 'Ensure the denominator is not zero',
          );
        }
        return (l / r).toDouble();
      case BinaryOperator.power:
        return math.pow(l, r).toDouble();
    }
  }
}
