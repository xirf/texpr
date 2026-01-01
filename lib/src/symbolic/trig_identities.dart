/// Trigonometric identity simplification.
library;

import '../ast.dart';
import 'dart:math' as math;

/// Applies trigonometric identities for simplification or expansion.
///
/// DESIGN PHILOSOPHY:
/// - SIMPLIFY mode: reduces complexity (Pythagorean, special values)
/// - EXPAND mode: applies formulas that increase AST size (double/half-angle)
///
/// Supported identities:
/// Simplification (reduces complexity):
/// - sin^2(x) + cos^2(x) = 1 (Pythagorean identity)
/// - sin(0) = 0, cos(0) = 1, tan(0) = 0
/// - sin(-x) = -sin(x) (odd function)
/// - cos(-x) = cos(x) (even function)
///
/// Expansion (increases complexity):
/// - sin(2x) = 2*sin(x)*cos(x) (double-angle)
/// - cos(2x) = cos^2(x) - sin^2(x) (double-angle)
/// - tan(2x) = 2*tan(x) / (1 - tan^2(x)) (double-angle)
/// - sin(x/2) = ±√((1-cos(x))/2) (half-angle, ASSUMES positive branch)
/// - cos(x/2) = ±√((1+cos(x))/2) (half-angle, ASSUMES positive branch)
/// - tan(x/2) = sin(x)/(1+cos(x)) (half-angle)
///
/// WARNING: Half-angle formulas assume positive branch without domain tracking.
/// This is a mathematical choice, not a bug.
class TrigIdentities {
  /// Whether to apply expansion rules (double/half-angle)
  final bool enableExpansion;

  /// Creates a trig identity handler.
  ///
  /// Set [enableExpansion] to false for pure simplification (default).
  /// Set to true to apply double/half-angle formulas (increases complexity).
  TrigIdentities({this.enableExpansion = false});

  /// Simplifies or expands trigonometric expressions.
  ///
  /// Behavior depends on [enableExpansion] flag.
  Expression simplify(Expression expr) {
    return _simplifyRecursive(expr);
  }

  Expression _simplifyRecursive(Expression expr) {
    if (expr is BinaryOp) {
      return _simplifyBinaryOp(expr);
    } else if (expr is FunctionCall) {
      return _simplifyFunctionCall(expr);
    }
    return expr;
  }

  Expression _simplifyBinaryOp(BinaryOp op) {
    final left = _simplifyRecursive(op.left);
    final right = _simplifyRecursive(op.right);

    // Check for sin^2(x) + cos^2(x) = 1
    if (op.operator == BinaryOperator.add) {
      final identity = _checkPythagoreanIdentity(left, right);
      if (identity != null) return identity;
    }

    return BinaryOp(left, op.operator, right, sourceToken: op.sourceToken);
  }

  Expression? _checkPythagoreanIdentity(Expression left, Expression right) {
    // Check if left is sin^2(x) and right is cos^2(x) (or vice versa)
    final sin2 = _isSinSquared(left);
    final cos2 = _isCosSquared(right);

    // WARNING: This uses structural equality (sin2 == cos2)
    // NOT mathematical equivalence. This means:
    // - sin²(x) + cos²(x) = 1 ✓ (correct)
    // - sin²(y) + cos²(x) = 1 ✗ (incorrect, but passes if AST happens to match)
    // - sin²(x+0) + cos²(x) might fail due to structure mismatch
    //
    // A proper CAS would:
    // 1. Canonicalize expressions before comparison
    // 2. Use symbolic equivalence checking
    // 3. Track variable scope and alpha-equivalence
    if (sin2 != null && cos2 != null && sin2 == cos2) {
      return const NumberLiteral(1);
    }

    // Check the reverse
    final sin2Rev = _isSinSquared(right);
    final cos2Rev = _isCosSquared(left);

    if (sin2Rev != null && cos2Rev != null && sin2Rev == cos2Rev) {
      return const NumberLiteral(1);
    }

    return null;
  }

  Expression? _isSinSquared(Expression expr) {
    // Check if expr is sin(x)^2 or sin^2(x)
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

  Expression? _isCosSquared(Expression expr) {
    // Check if expr is cos(x)^2 or cos^2(x)
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

  Expression _simplifyFunctionCall(FunctionCall call) {
    // Simplify arguments first
    final simplifiedArgs =
        call.args.map((arg) => _simplifyRecursive(arg)).toList();

    // Apply specific identities based on function
    switch (call.name) {
      case 'sin':
        return _simplifySin(simplifiedArgs);
      case 'cos':
        return _simplifyCos(simplifiedArgs);
      case 'tan':
        return _simplifyTan(simplifiedArgs);
      default:
        return FunctionCall.multivar(call.name, simplifiedArgs,
            base: call.base, optionalParam: call.optionalParam);
    }
  }

  Expression _simplifySin(List<Expression> args) {
    if (args.length != 1) return FunctionCall.multivar('sin', args);

    final arg = args[0];

    // sin(0) = 0
    if (arg is NumberLiteral && arg.value == 0) {
      return const NumberLiteral(0);
    }

    // sin(-x) = -sin(x)
    if (arg is UnaryOp && arg.operator == UnaryOperator.negate) {
      return UnaryOp(
        UnaryOperator.negate,
        FunctionCall('sin', arg.operand),
      );
    }

    // sin(π/2) = 1
    if (_isValue(arg, math.pi / 2)) {
      return const NumberLiteral(1);
    }

    // sin(π) = 0
    if (_isValue(arg, math.pi)) {
      return const NumberLiteral(0);
    }

    // sin(2x) = 2*sin(x)*cos(x) - Double-angle formula (EXPANSION)
    if (enableExpansion) {
      final doubleArg = _extractDoubleAngle(arg);
      if (doubleArg != null) {
        // 2 * sin(x) * cos(x)
        final sinX = FunctionCall('sin', doubleArg);
        final cosX = FunctionCall('cos', doubleArg);
        final sinCos = BinaryOp(sinX, BinaryOperator.multiply, cosX);
        return BinaryOp(
            const NumberLiteral(2), BinaryOperator.multiply, sinCos);
      }
    }

    // sin(x/2) = √((1-cos(x))/2) - Half-angle formula (EXPANSION, positive branch only)
    if (enableExpansion) {
      final halfArg = _extractHalfAngle(arg);
      if (halfArg != null) {
        // √((1-cos(x))/2)
        final cosX = FunctionCall('cos', halfArg);
        final oneMinusCos =
            BinaryOp(const NumberLiteral(1), BinaryOperator.subtract, cosX);
        final divided = BinaryOp(
            oneMinusCos, BinaryOperator.divide, const NumberLiteral(2));
        return FunctionCall('sqrt', divided);
      }
    }

    return FunctionCall.multivar('sin', args);
  }

  Expression _simplifyCos(List<Expression> args) {
    if (args.length != 1) return FunctionCall.multivar('cos', args);

    final arg = args[0];

    // cos(0) = 1
    if (arg is NumberLiteral && arg.value == 0) {
      return const NumberLiteral(1);
    }

    // cos(-x) = cos(x)
    if (arg is UnaryOp && arg.operator == UnaryOperator.negate) {
      return FunctionCall('cos', arg.operand);
    }

    // cos(π/2) = 0
    if (_isValue(arg, math.pi / 2)) {
      return const NumberLiteral(0);
    }

    // cos(π) = -1
    if (_isValue(arg, math.pi)) {
      return const NumberLiteral(-1);
    }

    // cos(2x) = cos²(x) - sin²(x) - Double-angle formula (EXPANSION)
    if (enableExpansion) {
      final doubleArg = _extractDoubleAngle(arg);
      if (doubleArg != null) {
        // cos(x)^2 - sin(x)^2
        final cosX = FunctionCall('cos', doubleArg);
        final cos2X =
            BinaryOp(cosX, BinaryOperator.power, const NumberLiteral(2));
        final sinX = FunctionCall('sin', doubleArg);
        final sin2X =
            BinaryOp(sinX, BinaryOperator.power, const NumberLiteral(2));
        return BinaryOp(cos2X, BinaryOperator.subtract, sin2X);
      }
    }

    // cos(x/2) = √((1+cos(x))/2) - Half-angle formula (EXPANSION, positive branch only)
    if (enableExpansion) {
      final halfArg = _extractHalfAngle(arg);
      if (halfArg != null) {
        // √((1+cos(x))/2)
        final cosX = FunctionCall('cos', halfArg);
        final onePlusCos =
            BinaryOp(const NumberLiteral(1), BinaryOperator.add, cosX);
        final divided =
            BinaryOp(onePlusCos, BinaryOperator.divide, const NumberLiteral(2));
        return FunctionCall('sqrt', divided);
      }
    }

    return FunctionCall.multivar('cos', args);
  }

  Expression _simplifyTan(List<Expression> args) {
    if (args.length != 1) return FunctionCall.multivar('tan', args);

    final arg = args[0];

    // tan(0) = 0
    if (arg is NumberLiteral && arg.value == 0) {
      return const NumberLiteral(0);
    }

    // tan(2x) = 2*tan(x) / (1 - tan²(x)) - Double-angle formula (EXPANSION)
    if (enableExpansion) {
      final doubleArg = _extractDoubleAngle(arg);
      if (doubleArg != null) {
        // 2*tan(x)
        final tanX = FunctionCall('tan', doubleArg);
        final twoTanX =
            BinaryOp(const NumberLiteral(2), BinaryOperator.multiply, tanX);

        // 1 - tan²(x)
        final tan2X =
            BinaryOp(tanX, BinaryOperator.power, const NumberLiteral(2));
        final denominator =
            BinaryOp(const NumberLiteral(1), BinaryOperator.subtract, tan2X);

        return BinaryOp(twoTanX, BinaryOperator.divide, denominator);
      }
    }

    // tan(x/2) = sin(x)/(1+cos(x)) - Half-angle formula (EXPANSION)
    if (enableExpansion) {
      final halfArg = _extractHalfAngle(arg);
      if (halfArg != null) {
        // sin(x)/(1+cos(x))
        final sinX = FunctionCall('sin', halfArg);
        final cosX = FunctionCall('cos', halfArg);
        final onePlusCos =
            BinaryOp(const NumberLiteral(1), BinaryOperator.add, cosX);
        return BinaryOp(sinX, BinaryOperator.divide, onePlusCos);
      }
    }

    // tan(x) could be converted to sin(x)/cos(x) but we keep it as is for now
    return FunctionCall('tan', arg);
  }

  /// Extracts the argument from a double-angle expression like 2*x.
  /// Returns null if not a double-angle pattern.
  Expression? _extractDoubleAngle(Expression expr) {
    // Check for 2*x pattern
    if (expr is BinaryOp && expr.operator == BinaryOperator.multiply) {
      if (expr.left is NumberLiteral &&
          (expr.left as NumberLiteral).value == 2) {
        return expr.right;
      }
      if (expr.right is NumberLiteral &&
          (expr.right as NumberLiteral).value == 2) {
        return expr.left;
      }
    }
    return null;
  }

  /// Extracts the argument from a half-angle expression like x/2.
  /// Returns null if not a half-angle pattern.
  Expression? _extractHalfAngle(Expression expr) {
    // Check for x/2 pattern
    if (expr is BinaryOp && expr.operator == BinaryOperator.divide) {
      if (expr.right is NumberLiteral &&
          (expr.right as NumberLiteral).value == 2) {
        return expr.left;
      }
    }
    return null;
  }

  bool _isValue(Expression expr, double value) {
    if (expr is NumberLiteral) {
      return (expr.value - value).abs() < 1e-10;
    }
    return false;
  }
}
