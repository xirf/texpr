import 'dart:math' as math;
import '../../ast.dart';
import '../rewrite_rule.dart';
import '../assumptions.dart';

bool _isLogFunction(String name) {
  return name == 'log' || name == 'ln' || name == 'log10' || name == 'log2';
}

/// Rule: log(1) = 0
class LogOneRule extends RewriteRule {
  @override
  String get name => 'log_one';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is FunctionCall &&
        _isLogFunction(expr.name) &&
        expr.args.isNotEmpty) {
      final arg = expr.args[0];
      return arg is NumberLiteral && arg.value == 1;
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      NumberLiteral(0);
}

/// Rule: log(a*b) = log(a) + log(b)
class LogProductRule extends RewriteRule {
  @override
  String get name => 'log_product';
  @override
  RuleCategory get category => RuleCategory.expansion; // Expands terms
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is FunctionCall &&
        _isLogFunction(expr.name) &&
        expr.args.isNotEmpty) {
      return expr.args[0] is BinaryOp &&
          (expr.args[0] as BinaryOp).operator == BinaryOperator.multiply;
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final call = expr as FunctionCall;
    final arg = call.args[0] as BinaryOp;
    return BinaryOp(FunctionCall(call.name, arg.left), BinaryOperator.add,
        FunctionCall(call.name, arg.right));
  }
}

/// Rule: log(a/b) = log(a) - log(b)
class LogQuotientRule extends RewriteRule {
  @override
  String get name => 'log_quotient';
  @override
  RuleCategory get category => RuleCategory.expansion;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is FunctionCall &&
        _isLogFunction(expr.name) &&
        expr.args.isNotEmpty) {
      return expr.args[0] is BinaryOp &&
          (expr.args[0] as BinaryOp).operator == BinaryOperator.divide;
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final call = expr as FunctionCall;
    final arg = call.args[0] as BinaryOp;
    return BinaryOp(FunctionCall(call.name, arg.left), BinaryOperator.subtract,
        FunctionCall(call.name, arg.right));
  }
}

/// Rule: log(a^b) = b*log(a) (if a > 0) OR b*log(|a|) (if b is even integer)
class LogPowerRule extends RewriteRule {
  @override
  String get name => 'log_power';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is FunctionCall &&
        _isLogFunction(expr.name) &&
        expr.args.isNotEmpty) {
      if (expr.args[0] is BinaryOp &&
          (expr.args[0] as BinaryOp).operator == BinaryOperator.power) {
        return true;
      }
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final call = expr as FunctionCall;
    final arg = call.args[0] as BinaryOp;
    final base = arg.left;
    final exponent = arg.right;

    // Check availability of positive assumption
    bool isPositive = false;
    if (base is NumberLiteral && base.value > 0) isPositive = true;
    if (base is Variable && assumptions != null) {
      if (assumptions.check(base.name, Assumption.positive) ||
          assumptions.check(base.name, Assumption.nonNegative)) {
        // Technically log(0) is undefined, so strict positive is better,
        // but nonNegative usually implies "domain appropriate" in simple CAS
        isPositive = true;
      }
    }

    // Check if exponent is even integer
    bool isEvenPower = false;
    if (exponent is NumberLiteral &&
        exponent.value % 2 == 0 &&
        exponent.value == exponent.value.toInt()) {
      isEvenPower = true;
    }

    if (isPositive) {
      return BinaryOp(
          exponent, BinaryOperator.multiply, FunctionCall(call.name, base));
    } else if (isEvenPower) {
      // log(x^2) -> 2*log(|x|)
      return BinaryOp(exponent, BinaryOperator.multiply,
          FunctionCall(call.name, AbsoluteValue(base)));
    }

    return expr;
  }
}

/// Rule: log10(10) = 1, ln(e) = 1
class LogBaseIdentityRule extends RewriteRule {
  @override
  String get name => 'log_base_identity';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is FunctionCall &&
        expr.args.length == 1 &&
        expr.args[0] is NumberLiteral) {
      final val = (expr.args[0] as NumberLiteral).value;
      if (expr.name == 'log10' && val == 10) return true;
      if (expr.name == 'ln' && (val - math.e).abs() < 1e-9) return true;
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      NumberLiteral(1);
}

final List<RewriteRule> allLogRules = [
  LogOneRule(),
  LogBaseIdentityRule(),
  LogProductRule(),
  LogQuotientRule(),
  LogPowerRule(),
];
