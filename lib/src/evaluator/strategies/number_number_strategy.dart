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
    return left is double && right is double;
  }

  @override
  double evaluate(dynamic left, BinaryOperator operator, dynamic right) {
    final l = left as double;
    final r = right as double;

    switch (operator) {
      case BinaryOperator.add:
        return l + r;
      case BinaryOperator.subtract:
        return l - r;
      case BinaryOperator.multiply:
        return l * r;
      case BinaryOperator.divide:
        if (r == 0) {
          throw EvaluatorException(
            'Division by zero',
            suggestion: 'Ensure the denominator is not zero',
          );
        }
        return l / r;
      case BinaryOperator.power:
        return math.pow(l, r).toDouble();
    }
  }
}
