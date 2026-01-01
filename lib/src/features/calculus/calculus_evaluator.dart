/// Calculus operations evaluation logic (limits, sums, products, integrals).
library;

import '../../ast.dart';
import '../../exceptions.dart';
import '../../complex.dart';

/// Handles evaluation of calculus operations.
class CalculusEvaluator {
  /// Callback to evaluate arbitrary expressions.
  final dynamic Function(Expression, Map<String, double>) _evaluate;

  /// Creates a calculus evaluator with a callback for evaluating expressions.
  CalculusEvaluator(this._evaluate);

  /// Maximum allowed iterations for sums and products.
  static const int maxIterations = 100000;

  void _checkIterations(int start, int end) {
    if (end < start) return; // Loop won't execute
    final count = end - start + 1;
    if (count > maxIterations) {
      throw EvaluatorException(
        'Iteration limit exceeded: $count iterations (max $maxIterations)',
        suggestion:
            'Reduce the range of your sum or product to fewer than $maxIterations iterations',
      );
    }
  }

  /// Evaluates a limit expression.
  dynamic evaluateLimit(LimitExpr limit, Map<String, double> variables) {
    final targetValue = _evaluate(limit.target, variables);

    if (targetValue is! double) {
      // Simple fallback for now
      throw EvaluatorException('Limits only supported for real targets');
    }

    // Handle infinity
    if (targetValue.isInfinite) {
      return _evaluateLimitAtInfinity(limit, variables, targetValue > 0);
    }

    // Numeric approximation: evaluate approaching from both sides
    const epsilon = 1e-7;
    const steps = [1e-1, 1e-3, 1e-5, 1e-7, 1e-9];

    dynamic leftApproach;
    dynamic rightApproach;

    // Approach from left
    for (final h in steps) {
      final vars = Map<String, double>.from(variables);
      vars[limit.variable] = targetValue - h;
      try {
        leftApproach = _evaluate(limit.body, vars);
      } catch (_) {
        // Continue to next step
      }
    }

    // Approach from right
    for (final h in steps) {
      final vars = Map<String, double>.from(variables);
      vars[limit.variable] = targetValue + h;
      try {
        rightApproach = _evaluate(limit.body, vars);
      } catch (_) {
        // Continue to next step
      }
    }

    // If only one side works, use that
    if (leftApproach != null && rightApproach == null) return leftApproach;
    if (rightApproach != null && leftApproach == null) return rightApproach;

    if (leftApproach != null && rightApproach != null) {
      if (leftApproach is double && rightApproach is double) {
        if ((leftApproach - rightApproach).abs() < epsilon) {
          return (leftApproach + rightApproach) / 2;
        }
      } else if (leftApproach is Complex && rightApproach is Complex) {
        if ((leftApproach - rightApproach).abs < epsilon) {
          return (leftApproach + rightApproach) * 0.5;
        }
      }
    }

    throw EvaluatorException(
      'Limit does not exist or cannot be computed',
      suggestion:
          'The limit may not converge or may have different left/right limits',
    );
  }

  /// Evaluates limit as x approaches infinity using numerical approximation.
  ///
  /// Strategy: Evaluate the expression at increasingly large values and return
  /// the last successful result. This works well for converging limits but may
  /// be inaccurate for slowly converging or oscillating functions.
  ///
  /// Limitation: This is a numerical approximation, not symbolic analysis.
  /// See KNOWN_ISSUES.md section "Infinity Approximation in Calculus Operations".
  dynamic _evaluateLimitAtInfinity(
    LimitExpr limit,
    Map<String, double> variables,
    bool positive,
  ) {
    // Sample at increasingly large values: 100, 10000, 1000000, 100000000
    const steps = [1e2, 1e4, 1e6, 1e8];
    dynamic lastValue;

    for (final n in steps) {
      final vars = Map<String, double>.from(variables);
      vars[limit.variable] = positive ? n : -n;
      try {
        lastValue = _evaluate(limit.body, vars);
      } catch (_) {
        // Continue to next step if evaluation fails
      }
    }

    if (lastValue != null) {
      return lastValue;
    }

    throw EvaluatorException(
      'Limit at infinity cannot be computed',
      suggestion: 'The expression may not have a limit at infinity',
    );
  }

  /// Evaluates a summation expression.
  dynamic evaluateSum(SumExpr sum, Map<String, double> variables) {
    final startVal = (_evaluate(sum.start, variables) as num).toInt();
    final endVal = (_evaluate(sum.end, variables) as num).toInt();

    dynamic result = 0.0;
    bool isFirst = true;

    _checkIterations(startVal, endVal);

    for (int i = startVal; i <= endVal; i++) {
      final vars = Map<String, double>.from(variables);
      vars[sum.variable] = i.toDouble();
      final val = _evaluate(sum.body, vars);

      if (isFirst) {
        result = val;
        isFirst = false;
      } else {
        if (result is double) {
          result += (val as num);
        } else if (result is Complex) {
          result += (val is Complex ? val : Complex.fromNum(val as num));
        }
      }
    }

    return result;
  }

  /// Evaluates a product expression.
  dynamic evaluateProduct(ProductExpr prod, Map<String, double> variables) {
    final startVal = (_evaluate(prod.start, variables) as num).toInt();
    final endVal = (_evaluate(prod.end, variables) as num).toInt();

    dynamic result = 1.0;

    _checkIterations(startVal, endVal);

    for (int i = startVal; i <= endVal; i++) {
      final vars = Map<String, double>.from(variables);
      vars[prod.variable] = i.toDouble();
      final val = _evaluate(prod.body, vars);

      if (result is double) {
        result *= (val as num);
      } else if (result is Complex) {
        result *= (val is Complex ? val : Complex.fromNum(val as num));
      }
    }

    return result;
  }

  /// Evaluates an integral expression using Simpson's rule.
  dynamic evaluateIntegral(IntegralExpr expr, Map<String, double> variables) {
    if (expr.lower == null || expr.upper == null) {
      throw EvaluatorException(
        'Cannot numerically evaluate indefinite integral',
        suggestion:
            'Provide lower and upper bounds for numerical integration (e.g., \\int_{0}^{1})',
      );
    }

    var lower = _evaluate(expr.lower!, variables);
    var upper = _evaluate(expr.upper!, variables);

    if (lower is! num || upper is! num) {
      throw EvaluatorException('Integral bounds must be numeric');
    }

    // Handle Improper Integrals (infinite bounds)
    // Numerical approximation: Replace ±∞ with ±100.0
    // This works well for functions that decay rapidly (e.g., e^(-x²), 1/(1+x²)).
    // Caution: Slowly decaying or oscillating functions may be inaccurate.
    // See KNOWN_ISSUES.md section "Infinity Approximation in Calculus Operations".
    const largeNumber = 100.0;
    if (lower == double.negativeInfinity) lower = -largeNumber;
    if (upper == double.infinity) upper = largeNumber;

    final n = 10000; // Increase steps for better accuracy
    final h = (upper - lower) / n;

    // Helper to evaluate body at x
    dynamic f(dynamic x) {
      final newVars = Map<String, double>.from(variables);
      if (x is num) {
        newVars[expr.variable] = x.toDouble();
      } else {
        throw EvaluatorException('Integration variable must be numeric');
      }
      return _evaluate(expr.body, newVars);
    }

    // Simpson's Rule
    dynamic sum = 0.0;

    final fLower = f(lower);
    if (fLower is Complex) {
      sum = Complex(0, 0); // Initialize sum as Complex if needed
    }

    sum = _addToSum(sum, fLower, 1);
    sum = _addToSum(sum, f(upper), 1);

    for (var i = 1; i < n; i++) {
      final x = lower + i * h;
      final weight = (i % 2 == 0) ? 2 : 4;
      sum = _addToSum(sum, f(x), weight);
    }

    if (sum is double) return (h / 3) * sum;
    if (sum is Complex) return sum * (h / 3);
    return sum; // Should not happen
  }

  dynamic _addToSum(dynamic sum, dynamic val, int weight) {
    if (sum is double) {
      if (val is num) return sum + (weight * val).toDouble();
      if (val is Complex) return Complex.fromNum(sum) + val * weight;
    }
    if (sum is Complex) {
      if (val is num) return sum + Complex.fromNum(val * weight);
      if (val is Complex) return sum + val * weight;
    }
    return sum;
  }
}
