import '../../ast.dart';
import '../rewrite_rule.dart';
import '../assumptions.dart';

import '../equivalence_checker.dart';

/// Rule: sin^2(x) + cos^2(x) = 1
class PythagoreanRule extends RewriteRule {
  final EquivalenceChecker _checker = EquivalenceChecker();

  @override
  String get name => 'pythagorean_identity';

  @override
  RuleCategory get category => RuleCategory.simplification;

  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is BinaryOp && expr.operator == BinaryOperator.add) {
      final sin2Arg =
          _extractSinSquaredArg(expr.left) ?? _extractSinSquaredArg(expr.right);
      final cos2Arg =
          _extractCosSquaredArg(expr.left) ?? _extractCosSquaredArg(expr.right);

      if (sin2Arg != null && cos2Arg != null) {
        // Use algebraic equivalence instead of structural equality
        final eq = _checker.areEquivalent(sin2Arg, cos2Arg,
            level: EquivalenceLevel.algebraic);
        return eq;
      }
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    return NumberLiteral(1);
  }

  Expression? _extractSinSquaredArg(Expression expr) {
    if (expr is BinaryOp && expr.operator == BinaryOperator.power) {
      if (expr.right is NumberLiteral &&
          (expr.right as NumberLiteral).value == 2) {
        if (expr.left is FunctionCall) {
          final func = expr.left as FunctionCall;
          if (func.name == 'sin' && func.args.length == 1) {
            return func.args[0];
          }
        }
      }
    }
    return null;
  }

  Expression? _extractCosSquaredArg(Expression expr) {
    if (expr is BinaryOp && expr.operator == BinaryOperator.power) {
      if (expr.right is NumberLiteral &&
          (expr.right as NumberLiteral).value == 2) {
        if (expr.left is FunctionCall) {
          final func = expr.left as FunctionCall;
          if (func.name == 'cos' && func.args.length == 1) {
            return func.args[0];
          }
        }
      }
    }
    return null;
  }
}

/// Rule: sin(2x) = 2sin(x)cos(x)
class DoubleAngleSinRule extends RewriteRule {
  @override
  String get name => 'sin_double_angle';
  @override
  RuleCategory get category => RuleCategory.expansion;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      _matchDoubleAngle(expr, 'sin');
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final arg = _isDoubleAngle((expr as FunctionCall).args[0])!;
    return BinaryOp(
        NumberLiteral(2),
        BinaryOperator.multiply,
        BinaryOp(FunctionCall('sin', arg), BinaryOperator.multiply,
            FunctionCall('cos', arg)));
  }
}

/// Rule: cos(2x) = cos^2(x) - sin^2(x)
class DoubleAngleCosRule extends RewriteRule {
  @override
  String get name => 'cos_double_angle';
  @override
  RuleCategory get category => RuleCategory.expansion;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      _matchDoubleAngle(expr, 'cos');
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final arg = _isDoubleAngle((expr as FunctionCall).args[0])!;
    return BinaryOp(
        BinaryOp(
            FunctionCall('cos', arg), BinaryOperator.power, NumberLiteral(2)),
        BinaryOperator.subtract,
        BinaryOp(
            FunctionCall('sin', arg), BinaryOperator.power, NumberLiteral(2)));
  }
}

Expression? _isDoubleAngle(Expression expr) {
  // Check for 2*x or x*2
  if (expr is BinaryOp && expr.operator == BinaryOperator.multiply) {
    if (expr.left is NumberLiteral && (expr.left as NumberLiteral).value == 2) {
      return expr.right;
    }
    if (expr.right is NumberLiteral &&
        (expr.right as NumberLiteral).value == 2) {
      return expr.left;
    }
  }
  return null;
}

/// Rule: sin(x/2) = sqrt((1-cos(x))/2)
class HalfAngleSinRule extends RewriteRule {
  @override
  String get name => 'sin_half_angle';
  @override
  RuleCategory get category => RuleCategory.expansion;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      _matchHalfAngle(expr, 'sin');
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final arg = _extractHalfAngleArg((expr as FunctionCall).args[0])!;
    // sqrt((1-cos(x))/2)
    return FunctionCall(
        'sqrt',
        BinaryOp(
            BinaryOp(NumberLiteral(1), BinaryOperator.subtract,
                FunctionCall('cos', arg)),
            BinaryOperator.divide,
            NumberLiteral(2)));
  }
}

/// Rule: cos(x/2) = sqrt((1+cos(x))/2)
class HalfAngleCosRule extends RewriteRule {
  @override
  String get name => 'cos_half_angle';
  @override
  RuleCategory get category => RuleCategory.expansion;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      _matchHalfAngle(expr, 'cos');
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final arg = _extractHalfAngleArg((expr as FunctionCall).args[0])!;
    // sqrt((1+cos(x))/2)
    return FunctionCall(
        'sqrt',
        BinaryOp(
            BinaryOp(
                NumberLiteral(1), BinaryOperator.add, FunctionCall('cos', arg)),
            BinaryOperator.divide,
            NumberLiteral(2)));
  }
}

/// Rule: tan(x/2) = sin(x)/(1+cos(x))
class HalfAngleTanRule extends RewriteRule {
  @override
  String get name => 'tan_half_angle';
  @override
  RuleCategory get category => RuleCategory.expansion;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      _matchHalfAngle(expr, 'tan');
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final arg = _extractHalfAngleArg((expr as FunctionCall).args[0])!;
    // sin(x) / (1+cos(x))
    return BinaryOp(
        FunctionCall('sin', arg),
        BinaryOperator.divide,
        BinaryOp(
            NumberLiteral(1), BinaryOperator.add, FunctionCall('cos', arg)));
  }
}

bool _matchHalfAngle(Expression expr, String funcName) {
  if (expr is FunctionCall && expr.name == funcName && expr.args.length == 1) {
    return _extractHalfAngleArg(expr.args[0]) != null;
  }
  return false;
}

Expression? _extractHalfAngleArg(Expression expr) {
  // x/2 or x * 0.5
  if (expr is BinaryOp) {
    if (expr.operator == BinaryOperator.divide &&
        expr.right is NumberLiteral &&
        (expr.right as NumberLiteral).value == 2) {
      return expr.left;
    }
    if (expr.operator == BinaryOperator.multiply) {
      if (expr.right is NumberLiteral &&
          (expr.right as NumberLiteral).value == 0.5) {
        return expr.left;
      }
      if (expr.left is NumberLiteral &&
          (expr.left as NumberLiteral).value == 0.5) {
        return expr.right;
      }
    }
  }
  return null;
}

/// Rule: sin(-x) = -sin(x), tan(-x) = -tan(x)
class OddTrigFunctionRule extends RewriteRule {
  @override
  String get name => 'odd_trig_function';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is FunctionCall &&
        (expr.name == 'sin' || expr.name == 'tan') &&
        expr.args.length == 1) {
      return _isNegated(expr.args[0]);
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final call = expr as FunctionCall;
    final arg = _extractNegatedArg(call.args[0])!;
    return UnaryOp(UnaryOperator.negate, FunctionCall(call.name, arg));
  }
}

/// Rule: cos(-x) = cos(x)
class EvenTrigFunctionRule extends RewriteRule {
  @override
  String get name => 'even_trig_function';
  @override
  RuleCategory get category => RuleCategory.simplification;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) {
    if (expr is FunctionCall && expr.name == 'cos' && expr.args.length == 1) {
      return _isNegated(expr.args[0]);
    }
    return false;
  }

  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final call = expr as FunctionCall;
    final arg = _extractNegatedArg(call.args[0])!;
    return FunctionCall(call.name, arg);
  }
}

bool _isNegated(Expression expr) {
  return expr is UnaryOp && expr.operator == UnaryOperator.negate;
  // Note: Normalizer might handle negative numbers, but here we look for -x
}

Expression? _extractNegatedArg(Expression expr) {
  if (expr is UnaryOp && expr.operator == UnaryOperator.negate) {
    return expr.operand;
  }
  return null;
}

/// Rule: tan(2x) = 2tan(x)/(1-tan^2(x))
class DoubleAngleTanRule extends RewriteRule {
  @override
  String get name => 'tan_double_angle';
  @override
  RuleCategory get category => RuleCategory.expansion;
  @override
  bool matches(Expression expr, {Assumptions? assumptions}) =>
      _matchDoubleAngle(expr, 'tan');
  @override
  Expression apply(Expression expr, {Assumptions? assumptions}) {
    final arg = _isDoubleAngle((expr as FunctionCall).args[0])!;
    // 2tan(x) / (1 - tan^2(x))
    final tanX = FunctionCall('tan', arg);
    return BinaryOp(
        BinaryOp(NumberLiteral(2), BinaryOperator.multiply, tanX),
        BinaryOperator.divide,
        BinaryOp(NumberLiteral(1), BinaryOperator.subtract,
            BinaryOp(tanX, BinaryOperator.power, NumberLiteral(2))));
  }
}

bool _matchDoubleAngle(Expression expr, String funcName) {
  if (expr is FunctionCall && expr.name == funcName && expr.args.length == 1) {
    return _isDoubleAngle(expr.args[0]) != null;
  }
  return false;
}

final List<RewriteRule> simplificationTrigRules = [
  PythagoreanRule(),
  OddTrigFunctionRule(),
  EvenTrigFunctionRule(),
];

final List<RewriteRule> expansionTrigRules = [
  DoubleAngleSinRule(),
  DoubleAngleCosRule(),
  DoubleAngleTanRule(),
  HalfAngleSinRule(),
  HalfAngleCosRule(),
  HalfAngleTanRule(),
];
