import '../../ast.dart';
import '../../exceptions.dart';
import '../../interval.dart';
import 'binary_operation_strategy.dart';

/// Strategy for binary operations involving intervals.
class IntervalStrategy implements BinaryOperationStrategy {
  @override
  bool canHandle(dynamic left, dynamic right) {
    return left is Interval || right is Interval;
  }

  @override
  dynamic evaluate(dynamic left, BinaryOperator operator, dynamic right) {
    // Case 1: Interval op something
    if (left is Interval) {
      switch (operator) {
        case BinaryOperator.add:
          return left + right;
        case BinaryOperator.subtract:
          return left - right;
        case BinaryOperator.multiply:
          return left * right;
        case BinaryOperator.divide:
          return left / right;
        case BinaryOperator.power:
          return _evaluatePower(left, right);
      }
    }

    // Case 2: num op Interval
    if (left is num && right is Interval) {
      final l = Interval.point(left.toDouble());
      switch (operator) {
        case BinaryOperator.add:
          return l + right;
        case BinaryOperator.subtract:
          return l - right;
        case BinaryOperator.multiply:
          return l * right;
        case BinaryOperator.divide:
          return l / right;
        case BinaryOperator.power:
          // a^X = exp(X * ln(a))
          if (left <= 0) {
            throw EvaluatorException(
                'Base must be positive for interval exponent');
          }
          return (right * l.log()).exp();
      }
    }

    throw EvaluatorException(
        'Type mismatch: expected Interval or num, got ${left.runtimeType} and ${right.runtimeType}');
  }

  Interval _evaluatePower(Interval base, dynamic exponent) {
    if (exponent is int) {
      return base.pow(exponent);
    }

    // Convert right to interval if it's a number
    Interval expInterval;
    if (exponent is num) {
      // Optimization: if it's an integer stored as double, use integer pow
      if (exponent == exponent.truncate()) {
        return base.pow(exponent.truncate());
      }
      expInterval = Interval.point(exponent.toDouble());
    } else if (exponent is Interval) {
      expInterval = exponent;
    } else {
      throw EvaluatorException(
          'Invalid exponent type for Interval power: ${exponent.runtimeType}');
    }

    // x^y = exp(y * ln(x))
    // Base must be positive for real results with fractional/interval exponents?
    // Generally yes, unless we move to Complex intervals, which is out of scope.
    if (base.lower <= 0) {
      // If exp is integer (even/odd), we handled it above via base.pow(int).
      // If we are here, exp involves fraction or interval, so base must be > 0.
      throw EvaluatorException(
          'Base must be positive for non-integer or interval exponent');
    }

    return (expInterval * base.log()).exp();
  }
}
