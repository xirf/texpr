/// Core simplification rules for algebraic expressions.
library;

import 'dart:math' as math;
import '../ast.dart';
import '../exceptions.dart';

/// Applies basic algebraic simplification rules.
///
/// Handles fundamental simplification patterns like:
/// - Identity operations: 0+x = x, 1*x = x, x^1 = x
/// - Zero operations: x*0 = 0, 0^x = 0 (x > 0)
/// - Constant folding: 2+3 = 5, 4*5 = 20
/// - Double negation: --x = x
class Simplifier {
  /// Simplifies an expression by applying basic algebraic rules.
  Expression simplify(Expression expr) {
    try {
      return _simplifyRecursive(expr);
    } finally {
      _recursionDepth = 0; // Reset after top-level call
    }
  }

  final int maxRecursionDepth;

  Simplifier({this.maxRecursionDepth = 500});

  int _recursionDepth = 0;

  void _enterRecursion() {
    if (++_recursionDepth > maxRecursionDepth) {
      throw EvaluatorException(
        'Maximum simplification depth exceeded',
        suggestion: 'The expression structure is too complex to simplify',
      );
    }
  }

  void _exitRecursion() {
    _recursionDepth--;
  }

  Expression _simplifyRecursive(Expression expr) {
    _enterRecursion();
    try {
      if (expr is BinaryOp) {
        return _simplifyBinaryOp(expr);
      } else if (expr is UnaryOp) {
        return _simplifyUnaryOp(expr);
      } else if (expr is FunctionCall) {
        return _simplifyFunctionCall(expr);
      }
      return expr;
    } finally {
      _exitRecursion();
    }
  }

  Expression _simplifyBinaryOp(BinaryOp op) {
    // Recursively simplify operands first
    final left = _simplifyRecursive(op.left);
    final right = _simplifyRecursive(op.right);

    // Constant folding
    if (left is NumberLiteral && right is NumberLiteral) {
      return _foldConstants(left, op.operator, right);
    }

    switch (op.operator) {
      case BinaryOperator.add:
        return _simplifyAddition(left, right, op.sourceToken);
      case BinaryOperator.subtract:
        return _simplifySubtraction(left, right, op.sourceToken);
      case BinaryOperator.multiply:
        return _simplifyMultiplication(left, right, op.sourceToken);
      case BinaryOperator.divide:
        return _simplifyDivision(left, right, op.sourceToken);
      case BinaryOperator.power:
        return _simplifyPower(left, right, op.sourceToken);
    }
  }

  Expression _simplifyUnaryOp(UnaryOp op) {
    final operand = _simplifyRecursive(op.operand);

    if (op.operator == UnaryOperator.negate) {
      // Double negation: --x = x
      if (operand is UnaryOp && operand.operator == UnaryOperator.negate) {
        return operand.operand;
      }
      // Negate constant
      if (operand is NumberLiteral) {
        return NumberLiteral(-operand.value);
      }
    }

    return UnaryOp(op.operator, operand);
  }

  Expression _simplifyFunctionCall(FunctionCall call) {
    // Recursively simplify arguments
    final simplifiedArgs =
        call.args.map((arg) => _simplifyRecursive(arg)).toList();
    return FunctionCall.multivar(call.name, simplifiedArgs,
        base: call.base, optionalParam: call.optionalParam);
  }

  Expression _simplifyAddition(
      Expression left, Expression right, String? sourceToken) {
    // 0 + x = x
    if (left is NumberLiteral && left.value == 0) return right;
    // x + 0 = x
    if (right is NumberLiteral && right.value == 0) return left;

    // Combine like terms: x + x = 2*x
    if (left == right) {
      return BinaryOp(
        const NumberLiteral(2),
        BinaryOperator.multiply,
        left,
        sourceToken: sourceToken,
      );
    }

    return BinaryOp(left, BinaryOperator.add, right, sourceToken: sourceToken);
  }

  Expression _simplifySubtraction(
      Expression left, Expression right, String? sourceToken) {
    // x - 0 = x
    if (right is NumberLiteral && right.value == 0) return left;
    // 0 - x = -x
    if (left is NumberLiteral && left.value == 0) {
      return UnaryOp(UnaryOperator.negate, right);
    }
    // x - x = 0
    if (left == right) return const NumberLiteral(0);

    return BinaryOp(left, BinaryOperator.subtract, right,
        sourceToken: sourceToken);
  }

  Expression _simplifyMultiplication(
      Expression left, Expression right, String? sourceToken) {
    // 0 * x = 0
    if (left is NumberLiteral && left.value == 0) return const NumberLiteral(0);
    // x * 0 = 0
    if (right is NumberLiteral && right.value == 0) {
      return const NumberLiteral(0);
    }
    // 1 * x = x
    if (left is NumberLiteral && left.value == 1) return right;
    // x * 1 = x
    if (right is NumberLiteral && right.value == 1) return left;
    // (-1) * x = -x
    if (left is NumberLiteral && left.value == -1) {
      return UnaryOp(UnaryOperator.negate, right);
    }
    // x * (-1) = -x
    if (right is NumberLiteral && right.value == -1) {
      return UnaryOp(UnaryOperator.negate, left);
    }

    // x * x = x^2
    if (left == right) {
      return BinaryOp(left, BinaryOperator.power, const NumberLiteral(2),
          sourceToken: sourceToken);
    }

    return BinaryOp(left, BinaryOperator.multiply, right,
        sourceToken: sourceToken);
  }

  Expression _simplifyDivision(
      Expression left, Expression right, String? sourceToken) {
    // 0 / x = 0 (assuming x != 0)
    if (left is NumberLiteral && left.value == 0) return const NumberLiteral(0);
    // x / 1 = x
    if (right is NumberLiteral && right.value == 1) return left;
    // x / x = 1 (assuming x != 0)
    if (left == right) return const NumberLiteral(1);

    return BinaryOp(left, BinaryOperator.divide, right,
        sourceToken: sourceToken);
  }

  Expression _simplifyPower(
      Expression left, Expression right, String? sourceToken) {
    // x^0 = 1
    if (right is NumberLiteral && right.value == 0) {
      return const NumberLiteral(1);
    }
    // x^1 = x
    if (right is NumberLiteral && right.value == 1) return left;
    // 0^x = 0 (for x > 0)
    if (left is NumberLiteral &&
        left.value == 0 &&
        right is NumberLiteral &&
        right.value > 0) {
      return const NumberLiteral(0);
    }
    // 1^x = 1
    if (left is NumberLiteral && left.value == 1) return const NumberLiteral(1);

    return BinaryOp(left, BinaryOperator.power, right,
        sourceToken: sourceToken);
  }

  NumberLiteral _foldConstants(
      NumberLiteral left, BinaryOperator op, NumberLiteral right) {
    switch (op) {
      case BinaryOperator.add:
        return NumberLiteral(left.value + right.value);
      case BinaryOperator.subtract:
        return NumberLiteral(left.value - right.value);
      case BinaryOperator.multiply:
        return NumberLiteral(left.value * right.value);
      case BinaryOperator.divide:
        return NumberLiteral(left.value / right.value);
      case BinaryOperator.power:
        return NumberLiteral(_pow(left.value, right.value));
    }
  }

  double _pow(double base, double exponent) {
    if (exponent == 0) return 1;
    if (exponent == 1) return base;
    if (exponent.toInt() == exponent) {
      // Integer exponent - use repeated multiplication for better precision
      final exp = exponent.toInt();
      if (exp > 0) {
        var result = 1.0;
        for (var i = 0; i < exp; i++) {
          result *= base;
        }
        return result;
      } else {
        var result = 1.0;
        for (var i = 0; i < -exp; i++) {
          result /= base;
        }
        return result;
      }
    }
    // Use dart's built-in pow for non-integer exponents
    return _dartPow(base, exponent);
  }

  double _dartPow(double base, double exp) {
    return math.pow(base, exp).toDouble();
  }
}
