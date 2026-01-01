/// Logarithm law simplification.
library;

import '../ast.dart';
import 'dart:math' as math;

/// Applies logarithm laws for simplification.
///
/// Supports laws like:
/// - log(a*b) = log(a) + log(b)
/// - log(a/b) = log(a) - log(b)
/// - log(a^b) = b*log(a)
/// - log(1) = 0
/// - log(base^x) = x (for log with same base)
class LogarithmLaws {
  /// Simplifies logarithmic expressions using laws.
  Expression simplify(Expression expr) {
    return _simplifyRecursive(expr);
  }

  Expression _simplifyRecursive(Expression expr) {
    if (expr is FunctionCall) {
      return _simplifyLogFunction(expr);
    } else if (expr is BinaryOp) {
      final left = _simplifyRecursive(expr.left);
      final right = _simplifyRecursive(expr.right);
      return BinaryOp(left, expr.operator, right,
          sourceToken: expr.sourceToken);
    }
    return expr;
  }

  Expression _simplifyLogFunction(FunctionCall call) {
    // Handle log, ln, log10
    if (!_isLogFunction(call.name)) {
      return call;
    }

    if (call.args.isEmpty) return call;

    final arg = _simplifyRecursive(call.args[0]);

    // log(1) = 0
    if (arg is NumberLiteral && arg.value == 1) {
      return const NumberLiteral(0);
    }

    // ln(e) = 1
    if (call.name == 'ln' &&
        arg is NumberLiteral &&
        (arg.value - math.e).abs() < 1e-10) {
      return const NumberLiteral(1);
    }

    // log10(10) = 1
    if (call.name == 'log10' && arg is NumberLiteral && arg.value == 10) {
      return const NumberLiteral(1);
    }

    // log(a*b) = log(a) + log(b)
    if (arg is BinaryOp && arg.operator == BinaryOperator.multiply) {
      final logA = FunctionCall(call.name, arg.left);
      final logB = FunctionCall(call.name, arg.right);
      return BinaryOp(logA, BinaryOperator.add, logB);
    }

    // log(a/b) = log(a) - log(b)
    if (arg is BinaryOp && arg.operator == BinaryOperator.divide) {
      final logA = FunctionCall(call.name, arg.left);
      final logB = FunctionCall(call.name, arg.right);
      return BinaryOp(logA, BinaryOperator.subtract, logB);
    }

    // log(a^b) = b*log(a)
    if (arg is BinaryOp && arg.operator == BinaryOperator.power) {
      final logA = FunctionCall(call.name, arg.left);
      return BinaryOp(arg.right, BinaryOperator.multiply, logA);
    }

    return FunctionCall(call.name, arg);
  }

  bool _isLogFunction(String name) {
    return name == 'log' || name == 'ln' || name == 'log10' || name == 'log2';
  }
}
