/// Symbolic integration evaluator.
library;

import '../../ast.dart';
import '../../exceptions.dart';

/// Handles symbolic integration of expressions.
///
/// This evaluator implements standard integration rules including:
/// - Power rule: \int x^n dx = x^(n+1)/(n+1)
/// - Sum rule: \int (f+g) dx = \int f dx + \int g dx
/// - Constant multiple: \int c*f dx = c * \int f dx
/// - Trigonometric integrals: sin, cos, sec^2, etc.
/// - Exponential integrals: e^x, a^x
/// - Logarithmic integrals: 1/x -> ln|x|
class IntegrationEvaluator {
  IntegrationEvaluator();

  int _recursionDepth = 0;
  static const int maxRecursionDepth = 500;

  void _enterRecursion() {
    if (++_recursionDepth > maxRecursionDepth) {
      throw EvaluatorException(
        'Maximum integration depth exceeded',
        suggestion: 'The expression is too complex to integrate symbolically',
      );
    }
  }

  void _exitRecursion() {
    _recursionDepth--;
  }

  /// Integrates an expression with respect to a variable.
  ///
  /// Returns a new [Expression] representing the symbolic antiderivative.
  Expression integrate(
    Expression expr,
    String variable,
  ) {
    return _integrateRec(expr, variable);
  }

  Expression _integrateRec(Expression expr, String variable) {
    _enterRecursion();
    try {
      // 1. Check for linearity (Sum/Difference)
      if (expr is BinaryOp) {
        if (expr.operator == BinaryOperator.add) {
          return BinaryOp(_integrateRec(expr.left, variable),
              BinaryOperator.add, _integrateRec(expr.right, variable));
        }
        if (expr.operator == BinaryOperator.subtract) {
          return BinaryOp(_integrateRec(expr.left, variable),
              BinaryOperator.subtract, _integrateRec(expr.right, variable));
        }
      }

      // 2. Check for constant factor: c * f(x)
      // We need to determine if a term is constant w.r.t variable.
      if (expr is BinaryOp && expr.operator == BinaryOperator.multiply) {
        final leftIsConst = !_containsVariable(expr.left, variable);
        final rightIsConst = !_containsVariable(expr.right, variable);

        if (leftIsConst && rightIsConst) {
          // entire expression is constant c -> \int c dx = c*x
          return BinaryOp(expr, BinaryOperator.multiply, Variable(variable));
        }
        if (leftIsConst) {
          // c * f(x) -> c * \int f(x)
          return BinaryOp(expr.left, BinaryOperator.multiply,
              _integrateRec(expr.right, variable));
        }
        if (rightIsConst) {
          // f(x) * c -> c * \int f(x)
          return BinaryOp(expr.right, BinaryOperator.multiply,
              _integrateRec(expr.left, variable));
        }
      }

      // 3. Constant rule alone
      if (!_containsVariable(expr, variable)) {
        return BinaryOp(expr, BinaryOperator.multiply, Variable(variable));
      }

      // 4. Power Rule: x^n
      if (expr is BinaryOp && expr.operator == BinaryOperator.power) {
        // Check base is x and exponent is constant check
        if (expr.left is Variable && (expr.left as Variable).name == variable) {
          if (!_containsVariable(expr.right, variable)) {
            // Special case: n = -1 -> ln|x|
            // We can check if exponent is NumberLiteral(-1)
            if (expr.right is NumberLiteral &&
                (expr.right as NumberLiteral).value == -1) {
              return FunctionCall('ln', AbsoluteValue(Variable(variable)));
            }
            if (expr.right is UnaryOp &&
                (expr.right as UnaryOp).operator == UnaryOperator.negate &&
                (expr.right as UnaryOp).operand is NumberLiteral &&
                ((expr.right as UnaryOp).operand as NumberLiteral).value == 1) {
              return FunctionCall('ln', AbsoluteValue(Variable(variable)));
            }
            // x^(n+1) / (n+1)
            Expression newExponent;
            if (expr.right is NumberLiteral) {
              newExponent =
                  NumberLiteral((expr.right as NumberLiteral).value + 1);
            } else {
              newExponent =
                  BinaryOp(expr.right, BinaryOperator.add, NumberLiteral(1));
            }

            return BinaryOp(
                BinaryOp(expr.left, BinaryOperator.power, newExponent),
                BinaryOperator.divide,
                newExponent // In a real System we'd simplify this
                );
          }
        }

        // Check for e^x
        if (expr.right is Variable &&
            (expr.right as Variable).name == variable) {
          // Base should be 'e' or 'E'
          if (expr.left is Variable &&
              ['e', 'E'].contains((expr.left as Variable).name)) {
            return expr; // \int e^x = e^x
          }
        }
      }

      // Check for 1/x -> ln|x|
      if (expr is BinaryOp && expr.operator == BinaryOperator.divide) {
        if (expr.left is NumberLiteral &&
            (expr.left as NumberLiteral).value == 1) {
          if (expr.right is Variable &&
              (expr.right as Variable).name == variable) {
            return FunctionCall('ln', AbsoluteValue(Variable(variable)));
          }
        }
      }

      // 5. Basic Variable: x -> x^2 / 2
      if (expr is Variable && expr.name == variable) {
        return BinaryOp(
            BinaryOp(
                Variable(variable), BinaryOperator.power, NumberLiteral(2)),
            BinaryOperator.divide,
            NumberLiteral(2));
      }

      // 6. Exponential: e^x or a^x
      if (expr is FunctionCall && expr.name == 'exp') {
        if (expr.args.length == 1) {
          final linear = _extractLinearCoefficients(expr.args[0], variable);
          if (linear != null) {
            final (a, b) = linear;
            // \int e^(ax+b) dx = (1/a) * e^(ax+b)
            // If a=1, b=0, it's e^x
            final result = expr;

            if (a is NumberLiteral && a.value == 1) return result;

            return BinaryOp(result, BinaryOperator.divide, a);
          }
        }
      }

      // 7. Trig functions
      if (expr is FunctionCall) {
        if (expr.args.length == 1) {
          final linear = _extractLinearCoefficients(expr.args[0], variable);
          if (linear != null) {
            final (a, _) = linear;

            if (expr.name == 'sin') {
              // \int sin(ax+b) = -cos(ax+b)/a
              final antideriv = UnaryOp(
                  UnaryOperator.negate, FunctionCall('cos', expr.args[0]));
              if (a is NumberLiteral && a.value == 1) return antideriv;
              return BinaryOp(antideriv, BinaryOperator.divide, a);
            }
            if (expr.name == 'cos') {
              // \int cos(ax+b) = sin(ax+b)/a
              final antideriv = FunctionCall('sin', expr.args[0]);
              if (a is NumberLiteral && a.value == 1) return antideriv;
              return BinaryOp(antideriv, BinaryOperator.divide, a);
            }
          }
        }
        // TODO: Add more like sec^2(x) -> tan(x) if identified
      }

      // 8. Piecewise function: integrate each case's expression
      if (expr is PiecewiseExpr) {
        final integratedCases = expr.cases.map((c) {
          return PiecewiseCase(
            _integrateRec(c.expression, variable),
            c.condition,
          );
        }).toList();
        return PiecewiseExpr(integratedCases);
      }

      // 9. Conditional expression: integrate the expression, preserve condition
      if (expr is ConditionalExpr) {
        return ConditionalExpr(
          _integrateRec(expr.expression, variable),
          expr.condition,
        );
      }

      // Indefinite integral: IntegralExpr(null, null, expr, variable)
      return IntegralExpr(null, null, expr, variable);
    } finally {
      _exitRecursion();
    }
  }

  /// Extracts coefficients a, b from expression (ax + b).
  /// Returns null if not linear in variable.
  (Expression, Expression)? _extractLinearCoefficients(
      Expression expr, String variable) {
    if (expr is Variable && expr.name == variable) {
      return (NumberLiteral(1), NumberLiteral(0));
    }
    if (expr is BinaryOp) {
      if (expr.operator == BinaryOperator.multiply) {
        // c * x
        if (expr.right is Variable &&
            (expr.right as Variable).name == variable) {
          if (!_containsVariable(expr.left, variable)) {
            return (expr.left, NumberLiteral(0));
          }
        }
        if (expr.left is Variable && (expr.left as Variable).name == variable) {
          if (!_containsVariable(expr.right, variable)) {
            return (expr.right, NumberLiteral(0));
          }
        }
      }
      if (expr.operator == BinaryOperator.add) {
        // term1 + term2
        // one term must be linear, other constant
        final linearLeft = _extractLinearCoefficients(expr.left, variable);
        if (linearLeft != null && !_containsVariable(expr.right, variable)) {
          // (ax+b) + c = ax + (b+c)
          // But let's simplified: assume ax + c
          // Simplify b+c? AST construction.
          // Actually we return expressions.
          // a = linearLeft.a
          // b = linearLeft.b + right
          final (la, lb) = linearLeft;
          return (la, BinaryOp(lb, BinaryOperator.add, expr.right));
        }

        final linearRight = _extractLinearCoefficients(expr.right, variable);
        if (linearRight != null && !_containsVariable(expr.left, variable)) {
          final (ra, rb) = linearRight;
          return (ra, BinaryOp(expr.left, BinaryOperator.add, rb));
        }
      }
      // TODO: handle subtraction
    }
    return null;
  }

  bool _containsVariable(Expression expr, String variable) {
    return switch (expr) {
      NumberLiteral() => false,
      Variable(:final name) => name == variable,
      BinaryOp(:final left, :final right) =>
        _containsVariable(left, variable) || _containsVariable(right, variable),
      UnaryOp(:final operand) => _containsVariable(operand, variable),
      AbsoluteValue(:final argument) => _containsVariable(argument, variable),
      FunctionCall(:final args) =>
        args.any((arg) => _containsVariable(arg, variable)),
      IntegralExpr(:final lower, :final upper, :final body) =>
        _containsVariable(body, variable) ||
            (lower != null && _containsVariable(lower, variable)) ||
            (upper != null && _containsVariable(upper, variable)),
      _ => true,
    };
  }

  /// Integrates an explicit IntegralExpr (parsed from \int ...).
  ///
  /// Handles both indefinite (\int f(x) dx) and definite (\int_a^b f(x) dx) integrals.
  Expression integrateIntegralExpr(IntegralExpr expr) {
    // 1. Find antiderivative F(x)
    final antiderivative = integrate(expr.body, expr.variable);

    // 2. If indefinite, return F(x)
    if (expr.lower == null || expr.upper == null) {
      return antiderivative;
    }

    // 3. If definite, return F(upper) - F(lower)
    final fUpper = _substitute(antiderivative, expr.variable, expr.upper!);
    final fLower = _substitute(antiderivative, expr.variable, expr.lower!);

    return BinaryOp(fUpper, BinaryOperator.subtract, fLower);
  }

  /// Substitutes a variable with a value in an expression.
  Expression _substitute(Expression expr, String variable, Expression value) {
    _enterRecursion();
    try {
      return switch (expr) {
        NumberLiteral() => expr,
        Variable(:final name) => name == variable ? value : expr,
        BinaryOp(:final left, :final operator, :final right) => BinaryOp(
            _substitute(left, variable, value),
            operator,
            _substitute(right, variable, value),
          ),
        UnaryOp(:final operator, :final operand) => UnaryOp(
            operator,
            _substitute(operand, variable, value),
          ),
        AbsoluteValue(:final argument) =>
          AbsoluteValue(_substitute(argument, variable, value)),
        FunctionCall(:final name, :final args) => FunctionCall.multivar(
            name,
            args.map((arg) => _substitute(arg, variable, value)).toList(),
          ),
        // For now, don't substitute inside nested integrals/derivatives blindly
        _ => expr,
      };
    } finally {
      _exitRecursion();
    }
  }
}
