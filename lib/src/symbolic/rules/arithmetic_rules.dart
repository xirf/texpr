import 'dart:math' as math;
import '../../ast.dart';
import '../rewrite_rule.dart';
import '../assumptions.dart';

/// Rule: x - x = 0
class SubtractSelfRule extends RewriteRule {
  @override
  String get name => 'simplify_subtract_self';

  @override
  RuleCategory get category => RuleCategory.simplification;

  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is BinaryOp && expr.operator == BinaryOperator.subtract) {
      return expr.left == expr.right; // Structural equality for now
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    return NumberLiteral(0);
  }
}

/// Rule: x - 0 = x
class SubtractZeroRule extends RewriteRule {
  @override
  String get name => 'subtract_zero';
  @override
  RuleCategory get category => RuleCategory.identity;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      expr is BinaryOp &&
      expr.operator == BinaryOperator.subtract &&
      expr.right is NumberLiteral &&
      (expr.right as NumberLiteral).value == 0;
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      (expr as BinaryOp).left;
}

/// Rule: 0 - x = -x
class ZeroSubtractRule extends RewriteRule {
  @override
  String get name => 'zero_subtract';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      expr is BinaryOp &&
      expr.operator == BinaryOperator.subtract &&
      expr.left is NumberLiteral &&
      (expr.left as NumberLiteral).value == 0;
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      UnaryOp(UnaryOperator.negate, (expr as BinaryOp).right);
}

/// Rule: x / 1 = x
class DivideByOneRule extends RewriteRule {
  @override
  String get name => 'divide_by_one';
  @override
  RuleCategory get category => RuleCategory.identity;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      expr is BinaryOp &&
      expr.operator == BinaryOperator.divide &&
      expr.right is NumberLiteral &&
      (expr.right as NumberLiteral).value == 1;
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      (expr as BinaryOp).left;
}

/// Rule: 0 / x = 0
class ZeroDivideRule extends RewriteRule {
  @override
  String get name => 'zero_divide';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      expr is BinaryOp &&
      expr.operator == BinaryOperator.divide &&
      expr.left is NumberLiteral &&
      (expr.left as NumberLiteral).value == 0;
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      NumberLiteral(0);
}

/// Rule: x / x = 1 (assuming x != 0)
class DivideSelfRule extends RewriteRule {
  @override
  String get name => 'divide_self';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      expr is BinaryOp &&
      expr.operator == BinaryOperator.divide &&
      expr.left == expr.right && // Structural equality
      !(expr.left is NumberLiteral &&
          (expr.left as NumberLiteral).value == 0); // Avoid 0/0
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      NumberLiteral(1);
}

/// Rule: x^0 = 1
class PowerZeroRule extends RewriteRule {
  @override
  String get name => 'power_zero';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      expr is BinaryOp &&
      expr.operator == BinaryOperator.power &&
      expr.right is NumberLiteral &&
      (expr.right as NumberLiteral).value == 0;
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      NumberLiteral(1);
}

/// Rule: x^1 = x
class PowerOneRule extends RewriteRule {
  @override
  String get name => 'power_one';
  @override
  RuleCategory get category => RuleCategory.identity;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      expr is BinaryOp &&
      expr.operator == BinaryOperator.power &&
      expr.right is NumberLiteral &&
      (expr.right as NumberLiteral).value == 1;
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      (expr as BinaryOp).left;
}

/// Rule: 1^x = 1
class OnePowerRule extends RewriteRule {
  @override
  String get name => 'one_power';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      expr is BinaryOp &&
      expr.operator == BinaryOperator.power &&
      expr.left is NumberLiteral &&
      (expr.left as NumberLiteral).value == 1;
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      NumberLiteral(1);
}

/// Rule: --x = x
class DoubleNegationRule extends RewriteRule {
  @override
  String get name => 'double_negation';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      expr is UnaryOp &&
      expr.operator == UnaryOperator.negate &&
      expr.operand is UnaryOp &&
      (expr.operand as UnaryOp).operator == UnaryOperator.negate;
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      ((expr as UnaryOp).operand as UnaryOp).operand;
}

/// Rule: 0^x = 0 (for x > 0)
class ZeroBasePowerRule extends RewriteRule {
  @override
  String get name => 'zero_base_power';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      expr is BinaryOp &&
      expr.operator == BinaryOperator.power &&
      expr.left is NumberLiteral &&
      (expr.left as NumberLiteral).value == 0 &&
      expr.right is NumberLiteral &&
      (expr.right as NumberLiteral).value > 0;
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      NumberLiteral(0);
}

/// Rule: Evaluate constants (e.g. 2+3, 4*5, 10/2, 2^3)
/// Note: + and * are handled by Normalizer, but / and ^ and - are not.
class ConstantCalculationRule extends RewriteRule {
  @override
  String get name => 'constant_calculation';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is BinaryOp &&
        expr.left is NumberLiteral &&
        expr.right is NumberLiteral) {
      // Include all basic arithmetic to ensure simplification within rule engine passes
      return expr.operator == BinaryOperator.divide ||
          expr.operator == BinaryOperator.power ||
          expr.operator == BinaryOperator.subtract ||
          expr.operator == BinaryOperator.multiply ||
          expr.operator == BinaryOperator.add;
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final op = expr as BinaryOp;
    final left = (op.left as NumberLiteral).value;
    final right = (op.right as NumberLiteral).value;

    switch (op.operator) {
      case BinaryOperator.add: // Handled by normalizer
        return NumberLiteral(left + right);
      case BinaryOperator.subtract:
        return NumberLiteral(left - right);
      case BinaryOperator.multiply: // Normalizer
        return NumberLiteral(left * right);
      case BinaryOperator.divide:
        if (right == 0) return expr; // Don't eval div by zero here?
        return NumberLiteral(left / right);
      case BinaryOperator.power:
        // Use dart math pow
        return NumberLiteral(math.pow(left, right).toDouble());
    }
  }
}

/// Rule: (-1) * x = -x
class NegateTimesRule extends RewriteRule {
  @override
  String get name => 'negate_times';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is BinaryOp &&
        expr.operator == BinaryOperator.multiply &&
        expr.left is NumberLiteral &&
        (expr.left as NumberLiteral).value == -1) {
      return true;
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) =>
      UnaryOp(UnaryOperator.negate, (expr as BinaryOp).right);
}

/// Rule: (x^a)^b = x^(a*b) (if x >= 0) OR |x|^(a*b) (if a is even)
class PowerPowerRule extends RewriteRule {
  @override
  String get name => 'power_power';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is BinaryOp &&
        expr.operator == BinaryOperator.power &&
        expr.left is BinaryOp) {
      final inner = expr.left as BinaryOp;
      if (inner.operator == BinaryOperator.power) {
        // Match structurally, refined logic in apply
        return true;
      }
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final outer = expr as BinaryOp;
    final inner = outer.left as BinaryOp;
    final x = inner.left;
    final a = inner.right;
    final b = outer.right;

    // Check if x >= 0
    bool isNonNegative = false;
    if (x is NumberLiteral && x.value >= 0) isNonNegative = true;
    if (x is Variable && assumptions != null) {
      if (assumptions.check(x.name, Assumption.nonNegative) ||
          assumptions.check(x.name, Assumption.positive)) {
        isNonNegative = true;
      }
    }

    // Check if 'a' is even integer
    bool isAEven = false;
    if (a is NumberLiteral && a.value % 2 == 0 && a.value == a.value.toInt()) {
      isAEven = true;
    }

    // x^(a*b)
    final newPower = BinaryOp(a, BinaryOperator.multiply, b);
    // We rely on normalization/constant calculation to fold a*b if they are numbers later,
    // but for logic here, let's peek values if they are literals
    double? productVal;
    if (a is NumberLiteral && b is NumberLiteral) {
      productVal = a.value * b.value;
    }

    if (isNonNegative) {
      // Safe to multiply powers
      if (productVal != null) {
        return BinaryOp(x, BinaryOperator.power, NumberLiteral(productVal));
      }
      return BinaryOp(x, BinaryOperator.power, newPower);
    } else if (isAEven) {
      // (x^even)^b -> |x|^(even*b)
      // e.g. (x^2)^0.5 -> |x|^1
      // e.g. (x^2)^1 -> |x|^2 -> x^2 (handled by other rules if we output |x|^2?)
      // Let's produce |x|^(a*b)

      // Optimization: if product is even integer, |x|^even = x^even
      if (productVal != null &&
          productVal % 2 == 0 &&
          productVal == productVal.toInt()) {
        return BinaryOp(x, BinaryOperator.power, NumberLiteral(productVal));
      }

      // Use AbsoluteValue
      final absX = AbsoluteValue(x);
      if (productVal != null) {
        return BinaryOp(absX, BinaryOperator.power, NumberLiteral(productVal));
      }
      return BinaryOp(absX, BinaryOperator.power, newPower);
    }

    return expr;
  }
}

/// All arithmetic rules.
final List<RewriteRule> allArithmeticRules = [
  ConstantCalculationRule(),
  NegateTimesRule(),
  SubtractSelfRule(),
  SubtractZeroRule(),
  ZeroSubtractRule(),
  DivideByOneRule(),
  ZeroDivideRule(),
  DivideSelfRule(),
  PowerZeroRule(),
  PowerOneRule(),
  OnePowerRule(),
  ZeroBasePowerRule(),
  DoubleNegationRule(),
  PowerPowerRule(),
];
