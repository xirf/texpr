import '../../ast.dart';
import '../rewrite_rule.dart';
import '../assumptions.dart';

/// Rule: x + x = 2*x
class CombineLikeTermsRule extends RewriteRule {
  @override
  String get name => 'combine_like_terms';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    return expr is BinaryOp &&
        expr.operator == BinaryOperator.add &&
        expr.left == expr.right;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    return BinaryOp(
        NumberLiteral(2), BinaryOperator.multiply, (expr as BinaryOp).left);
  }
}

/// Rule: x * x = x^2
class CombinePowersRule extends RewriteRule {
  @override
  String get name => 'combine_powers';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    return expr is BinaryOp &&
        expr.operator == BinaryOperator.multiply &&
        expr.left == expr.right;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    return BinaryOp(
        (expr as BinaryOp).left, BinaryOperator.power, NumberLiteral(2));
  }
}

/// Rule: Evaluate trig functions at common constants (0, pi/2, etc)
class TrigEvaluationRule extends RewriteRule {
  @override
  String get name => 'trig_evaluation';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is FunctionCall &&
        expr.args.length == 1 &&
        expr.args[0] is NumberLiteral) {
      final val = (expr.args[0] as NumberLiteral).value;
      final name = expr.name;
      if (val == 0) {
        return name == 'sin' ||
            name == 'cos' ||
            name == 'tan' ||
            name == 'asin' ||
            name == 'atan';
      }
      // Add pi/2 etc if needed, but 0 is most common
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final call = expr as FunctionCall;
    // ... apply logic ...
    // Note: Trig evaluation usually returns NumberLiteral or original expression
    // Implementing basic evaluation for 0
    if (call.args[0] is NumberLiteral) {
      final val = (call.args[0] as NumberLiteral).value;
      if (val == 0) {
        if (call.name == 'sin') return NumberLiteral(0);
        if (call.name == 'cos') return NumberLiteral(1);
        if (call.name == 'tan') return NumberLiteral(0);
      }
    }
    return expr;
  }
}

/// Rule: sqrt(x) = x^0.5
class SqrtToPowerRule extends RewriteRule {
  @override
  String get name => 'sqrt_to_power';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      expr is FunctionCall && expr.name == 'sqrt' && expr.args.length == 1;

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    return BinaryOp((expr as FunctionCall).args[0], BinaryOperator.power,
        NumberLiteral(0.5));
  }
}

final List<RewriteRule> extraSimplificationRules = [
  CombineLikeTermsRule(),
  CombinePowersRule(),
  TrigEvaluationRule(),
  SqrtToPowerRule(),
];
