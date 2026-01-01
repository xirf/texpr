/// Complex number binary operation strategy.
library;

import '../../ast/operations.dart';
import '../../complex.dart';
import 'binary_operation_strategy.dart';

/// Strategy for evaluating binary operations involving complex numbers.
class ComplexStrategy implements BinaryOperationStrategy {
  @override
  bool canHandle(dynamic left, dynamic right) {
    return left is Complex || right is Complex;
  }

  @override
  Complex evaluate(dynamic left, BinaryOperator operator, dynamic right) {
    final l = left is Complex ? left : Complex.fromNum(left as num);
    final r = right is Complex ? right : Complex.fromNum(right as num);

    switch (operator) {
      case BinaryOperator.add:
        return l + r;
      case BinaryOperator.subtract:
        return l - r;
      case BinaryOperator.multiply:
        return l * r;
      case BinaryOperator.divide:
        return l / r;
      case BinaryOperator.power:
        return l.pow(r);
    }
  }
}
