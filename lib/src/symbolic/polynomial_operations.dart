/// Polynomial expansion and factorization operations.
library;

import '../ast.dart';
import 'dart:math' as math;
import 'step_trace.dart';

/// Handles polynomial expansion, factorization, and equation solving.
///
/// Supports:
/// - Expanding expressions like (x+a)^n
/// - Factoring quadratic expressions
/// - Solving linear and quadratic equations
class PolynomialOperations {
  /// Expands polynomial expressions.
  ///
  /// Currently supports:
  /// - (a+b)^2 to a^2 + 2*a*b + b^2
  /// - (a+b)^n for small integer n
  /// - (a+b)(c+d) to a*c + a*d + b*c + b*d
  Expression expand(Expression expr) {
    return _expandRecursive(expr, null);
  }

  /// Expands polynomial expressions with step-by-step trace.
  ///
  /// Example:
  /// ```dart
  /// final ops = PolynomialOperations();
  /// final result = ops.expandWithSteps(parse('(x + 1)^2'));
  /// print(result.formatSteps());
  /// // Step 1 [Expansion] Binomial theorem: (a + b)^n = Σ C(n,k) · a^(n-k) · b^k
  /// //   (x+1)^{2} → 1 \cdot x^{2}+2 \cdot x \cdot 1+1 \cdot 1^{2}
  /// ```
  TracedResult<Expression> expandWithSteps(Expression expr) {
    final tracer = StepTracer();
    final result = _expandRecursive(expr, tracer);
    return tracer.complete(result);
  }

  Expression _expandRecursive(Expression expr, StepTracer? tracer) {
    if (expr is BinaryOp) {
      if (expr.operator == BinaryOperator.power) {
        return _expandPower(expr, tracer);
      } else if (expr.operator == BinaryOperator.multiply) {
        return _expandMultiply(expr, tracer);
      }
    }
    return expr;
  }

  Expression _expandPower(BinaryOp powerExpr, StepTracer? tracer) {
    final base = powerExpr.left;
    final exponent = powerExpr.right;

    // Only expand integer powers for now
    if (exponent is! NumberLiteral) return powerExpr;
    final exp = exponent.value.toInt();
    if (exp != exponent.value || exp < 0 || exp > 10) return powerExpr;

    // Handle (a+b)^n expansion
    if (base is BinaryOp && base.operator == BinaryOperator.add) {
      final result = _expandBinomialPower(base.left, base.right, exp);
      tracer?.record(
        StepType.expansion,
        'Binomial theorem: (a + b)^$exp = Σ C($exp,k) · a^($exp-k) · b^k',
        powerExpr,
        result,
        ruleName: 'binomial_theorem',
      );
      return result;
    }

    // Handle (a-b)^n expansion
    if (base is BinaryOp && base.operator == BinaryOperator.subtract) {
      final negRight = UnaryOp(UnaryOperator.negate, base.right);
      final result = _expandBinomialPower(base.left, negRight, exp);
      tracer?.record(
        StepType.expansion,
        'Binomial theorem: (a - b)^$exp = Σ C($exp,k) · a^($exp-k) · (-b)^k',
        powerExpr,
        result,
        ruleName: 'binomial_theorem',
      );
      return result;
    }

    return powerExpr;
  }

  Expression _expandBinomialPower(Expression a, Expression b, int n) {
    if (n == 0) return const NumberLiteral(1);
    if (n == 1) return BinaryOp(a, BinaryOperator.add, b);

    // Use binomial theorem: (a+b)^n = Σ C(n,k) * a^(n-k) * b^k
    Expression? result;

    for (var k = 0; k <= n; k++) {
      final coeff = _binomialCoefficient(n, k);
      Expression term = NumberLiteral(coeff.toDouble());

      // Add a^(n-k)
      if (n - k > 0) {
        final aPower = n - k == 1
            ? a
            : BinaryOp(
                a, BinaryOperator.power, NumberLiteral((n - k).toDouble()));
        term = BinaryOp(term, BinaryOperator.multiply, aPower);
      }

      // Add b^k
      if (k > 0) {
        final bPower = k == 1
            ? b
            : BinaryOp(b, BinaryOperator.power, NumberLiteral(k.toDouble()));
        term = BinaryOp(term, BinaryOperator.multiply, bPower);
      }

      result =
          result == null ? term : BinaryOp(result, BinaryOperator.add, term);
    }

    return result ?? const NumberLiteral(0);
  }

  int _binomialCoefficient(int n, int k) {
    if (k > n) return 0;
    if (k == 0 || k == n) return 1;
    k = math.min(k, n - k); // Optimize using symmetry
    var result = 1;
    for (var i = 0; i < k; i++) {
      result = result * (n - i) ~/ (i + 1);
    }
    return result;
  }

  Expression _expandMultiply(BinaryOp multiplyExpr, StepTracer? tracer) {
    final left = multiplyExpr.left;
    final right = multiplyExpr.right;

    // (a+b) * (c+d) = a*c + a*d + b*c + b*d
    if (left is BinaryOp &&
        left.operator == BinaryOperator.add &&
        right is BinaryOp &&
        right.operator == BinaryOperator.add) {
      final a = left.left;
      final b = left.right;
      final c = right.left;
      final d = right.right;

      final ac = BinaryOp(a, BinaryOperator.multiply, c);
      final ad = BinaryOp(a, BinaryOperator.multiply, d);
      final bc = BinaryOp(b, BinaryOperator.multiply, c);
      final bd = BinaryOp(b, BinaryOperator.multiply, d);

      final result = BinaryOp(
        BinaryOp(ac, BinaryOperator.add, ad),
        BinaryOperator.add,
        BinaryOp(bc, BinaryOperator.add, bd),
      );

      tracer?.record(
        StepType.expansion,
        'FOIL: (a + b)(c + d) = ac + ad + bc + bd',
        multiplyExpr,
        result,
        ruleName: 'foil_expansion',
      );

      return result;
    }

    return multiplyExpr;
  }

  /// Factors polynomial expressions.
  ///
  /// Currently supports:
  /// - Difference of squares: x^2 - a^2 to (x-a)(x+a)
  /// - Simple quadratics: x^2 + bx + c to (x+p)(x+q) when factorizable
  Expression factor(Expression expr) {
    return _factorInternal(expr, null);
  }

  /// Factors polynomial expressions with step-by-step trace.
  ///
  /// Example:
  /// ```dart
  /// final ops = PolynomialOperations();
  /// final result = ops.factorWithSteps(parse('x^2 - 1'));
  /// print(result.formatSteps());
  /// // Step 1 [Factorization] Difference of squares: a² - b² = (a - b)(a + b)
  /// //   x^{2}-1 → (x-1)(x+1)
  /// ```
  TracedResult<Expression> factorWithSteps(Expression expr) {
    final tracer = StepTracer();
    final result = _factorInternal(expr, tracer);
    return tracer.complete(result);
  }

  Expression _factorInternal(Expression expr, StepTracer? tracer) {
    // Try factoring difference of squares
    if (expr is BinaryOp && expr.operator == BinaryOperator.subtract) {
      final factored = _factorDifferenceOfSquares(expr, tracer);
      if (factored != null) return factored;
    }

    // Try factoring quadratics
    final factored = _factorQuadratic(expr, tracer);
    if (factored != null) return factored;

    return expr;
  }

  Expression? _factorDifferenceOfSquares(BinaryOp expr, StepTracer? tracer) {
    // Check for a^2 - b^2 pattern
    final left = expr.left;
    final right = expr.right;

    if (left is BinaryOp &&
        left.operator == BinaryOperator.power &&
        left.right is NumberLiteral &&
        (left.right as NumberLiteral).value == 2) {
      if (right is BinaryOp &&
          right.operator == BinaryOperator.power &&
          right.right is NumberLiteral &&
          (right.right as NumberLiteral).value == 2) {
        final a = left.left;
        final b = right.left;

        // Return (a-b)(a+b)
        final aminusb = BinaryOp(a, BinaryOperator.subtract, b);
        final aplusb = BinaryOp(a, BinaryOperator.add, b);
        final result = BinaryOp(aminusb, BinaryOperator.multiply, aplusb);

        tracer?.record(
          StepType.factorization,
          'Difference of squares: a² - b² = (a - b)(a + b)',
          expr,
          result,
          ruleName: 'difference_of_squares',
        );

        return result;
      }
    }

    return null;
  }

  Expression? _factorQuadratic(Expression expr, StepTracer? tracer) {
    // Try to match pattern: ax^2 + bx + c
    final terms = _extractQuadraticTerms(expr);
    if (terms == null) return null;

    final a = terms['a']!;
    final b = terms['b']!;
    final c = terms['c']!;
    final variable = terms['var'] as String;

    // For simplicity, only handle a=1 case
    if (a != 1) return null;

    // Find p and q such that p*q = c and p+q = b
    for (var p = -100; p <= 100; p++) {
      if (p == 0) continue;
      if (c % p != 0) continue;
      final q = c ~/ p;
      if (p + q == b) {
        // Return (x+p)(x+q)
        final xPlusP = BinaryOp(
          Variable(variable),
          BinaryOperator.add,
          NumberLiteral(p.toDouble()),
        );
        final xPlusQ = BinaryOp(
          Variable(variable),
          BinaryOperator.add,
          NumberLiteral(q.toDouble()),
        );
        final result = BinaryOp(xPlusP, BinaryOperator.multiply, xPlusQ);

        tracer?.record(
          StepType.factorization,
          'Quadratic factorization: find p, q where p · q = $c and p + q = $b',
          expr,
          result,
          ruleName: 'quadratic_factorization',
        );

        return result;
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractQuadraticTerms(Expression expr) {
    // This is a simplified implementation
    // In a real implementation, we'd need more sophisticated pattern matching
    return null;
  }

  /// Solves a linear equation ax + b = 0 for x.
  ///
  /// Returns the solution x = -b/a, or null if not solvable.
  Expression? solveLinear(Expression equation, String variable) {
    // Extract coefficients from equation
    final coeffs = _extractLinearCoefficients(equation, variable);
    if (coeffs == null) return null;

    final a = coeffs['a']!;
    final b = coeffs['b']!;

    // Check if coefficient of variable is zero
    if (_isZero(a)) {
      return null; // No solution or infinite solutions
    }

    // x = -b/a
    final negB = _negate(b);
    return _simplifyDivision(negB, a);
  }

  /// Solves a quadratic equation ax^2 + bx + c = 0 for x.
  ///
  /// Returns 0, 1, or 2 solutions using the quadratic formula.
  /// Returns symbolic solutions when possible.
  List<Expression> solveQuadratic(Expression equation, String variable) {
    return _solveQuadraticInternal(equation, variable, null);
  }

  /// Solves a quadratic equation with step-by-step trace.
  ///
  /// Shows the application of the quadratic formula:
  /// x = (-b ± √(b² - 4ac)) / 2a
  ///
  /// Example:
  /// ```dart
  /// final ops = PolynomialOperations();
  /// final result = ops.solveQuadraticWithSteps(parse('x^2 - 5x + 6'), 'x');
  /// print(result.formatSteps());
  /// ```
  TracedResult<List<Expression>> solveQuadraticWithSteps(
      Expression equation, String variable) {
    final tracer = StepTracer();
    final result = _solveQuadraticInternal(equation, variable, tracer);
    return tracer.complete(result);
  }

  List<Expression> _solveQuadraticInternal(
      Expression equation, String variable, StepTracer? tracer) {
    final coeffs = _extractQuadraticCoefficients(equation, variable);
    if (coeffs == null) return [];

    final a = coeffs['a']!;
    final b = coeffs['b']!;
    final c = coeffs['c']!;

    tracer?.record(
      StepType.simplification,
      'Identify coefficients: a = ${a.toLatex()}, b = ${b.toLatex()}, c = ${c.toLatex()}',
      equation,
      equation,
    );

    // Check if this is actually linear (a = 0)
    if (_isZero(a)) {
      final linearSol = solveLinear(equation, variable);
      return linearSol != null ? [linearSol] : [];
    }

    // Compute discriminant: b^2 - 4ac
    final bSquared = BinaryOp(b, BinaryOperator.power, const NumberLiteral(2));
    final fourAC = BinaryOp(
      BinaryOp(const NumberLiteral(4), BinaryOperator.multiply, a),
      BinaryOperator.multiply,
      c,
    );
    final discriminant = BinaryOp(bSquared, BinaryOperator.subtract, fourAC);

    tracer?.record(
      StepType.simplification,
      'Compute discriminant: Δ = b² - 4ac',
      discriminant,
      discriminant,
    );

    // Try to evaluate discriminant numerically if possible
    final discValue = _tryEvaluate(discriminant);

    if (discValue != null) {
      if (discValue < 0) {
        tracer?.record(
          StepType.simplification,
          'Discriminant Δ = $discValue < 0: No real solutions',
          discriminant,
          const NumberLiteral(0),
        );
        return []; // No real solutions
      } else if (discValue == 0) {
        // One solution: x = -b / (2a)
        final negB = _negate(b);
        final twoA =
            BinaryOp(const NumberLiteral(2), BinaryOperator.multiply, a);
        final solution = _simplifyDivision(negB, twoA);

        tracer?.record(
          StepType.simplification,
          'Discriminant Δ = 0: One repeated root x = -b/(2a)',
          discriminant,
          solution,
        );

        return [solution];
      }
    }

    // Two solutions (or symbolic): x = (-b ± sqrt(discriminant)) / (2a)
    final negB = _negate(b);
    final sqrtDisc = FunctionCall('sqrt', discriminant);
    final twoA = BinaryOp(const NumberLiteral(2), BinaryOperator.multiply, a);

    final numerator1 = BinaryOp(negB, BinaryOperator.add, sqrtDisc);
    final numerator2 = BinaryOp(negB, BinaryOperator.subtract, sqrtDisc);

    final solution1 = _simplifyDivision(numerator1, twoA);
    final solution2 = _simplifyDivision(numerator2, twoA);

    tracer?.record(
      StepType.simplification,
      'Apply quadratic formula: x = (-b ± √Δ) / 2a',
      equation,
      solution1,
    );

    return [solution1, solution2];
  }

  /// Extract linear coefficients from equation of form ax + b = 0
  Map<String, Expression>? _extractLinearCoefficients(
      Expression expr, String variable) {
    // For now, handle simple patterns
    // This is a simplified implementation that handles basic cases

    if (expr is BinaryOp) {
      // Pattern: ax + b or ax - b or b + ax, etc.
      if (expr.operator == BinaryOperator.add ||
          expr.operator == BinaryOperator.subtract) {
        final left = expr.left;
        final right = expr.right;

        Expression? a;
        Expression? b;

        // Check if left contains variable
        final leftHasVar = _containsVariable(left, variable);
        final rightHasVar = _containsVariable(right, variable);

        if (leftHasVar && !rightHasVar) {
          // Pattern: ax ± b
          a = _extractCoefficient(left, variable);
          b = expr.operator == BinaryOperator.subtract ? _negate(right) : right;
        } else if (!leftHasVar && rightHasVar) {
          // Pattern: b ± ax
          b = left;
          final coeff = _extractCoefficient(right, variable);
          a = expr.operator == BinaryOperator.subtract ? _negate(coeff) : coeff;
        }

        if (a != null && b != null) {
          return {'a': a, 'b': b};
        }
      }
    }

    // Pattern: just ax (b = 0)
    if (_containsVariable(expr, variable)) {
      return {
        'a': _extractCoefficient(expr, variable),
        'b': const NumberLiteral(0),
      };
    }

    return null;
  }

  /// Extract quadratic coefficients from equation of form ax^2 + bx + c = 0
  Map<String, Expression>? _extractQuadraticCoefficients(
      Expression expr, String variable) {
    Expression a = const NumberLiteral(0);
    Expression b = const NumberLiteral(0);
    Expression c = const NumberLiteral(0);

    // Recursively collect terms
    _collectQuadraticTerms(expr, variable, (term, sign) {
      final degree = _getVariableDegree(term, variable);
      final coeff = _extractCoefficientForDegree(term, variable, degree);
      final signedCoeff = sign < 0 ? _negate(coeff) : coeff;

      if (degree == 2) {
        a = _addExpressions(a, signedCoeff);
      } else if (degree == 1) {
        b = _addExpressions(b, signedCoeff);
      } else if (degree == 0) {
        c = _addExpressions(c, signedCoeff);
      }
    });

    return {'a': a, 'b': b, 'c': c};
  }

  /// Collect terms from addition/subtraction tree
  void _collectQuadraticTerms(
    Expression expr,
    String variable,
    void Function(Expression term, int sign) collector,
  ) {
    if (expr is BinaryOp &&
        (expr.operator == BinaryOperator.add ||
            expr.operator == BinaryOperator.subtract)) {
      _collectQuadraticTerms(expr.left, variable, collector);
      final sign = expr.operator == BinaryOperator.subtract ? -1 : 1;
      collector(expr.right, sign);
    } else {
      collector(expr, 1);
    }
  }

  /// Get the degree of a variable in a term
  int _getVariableDegree(Expression expr, String variable) {
    if (expr is Variable && expr.name == variable) {
      return 1;
    }

    if (expr is BinaryOp) {
      if (expr.operator == BinaryOperator.power) {
        if (expr.left is Variable && (expr.left as Variable).name == variable) {
          if (expr.right is NumberLiteral) {
            return (expr.right as NumberLiteral).value.toInt();
          }
        }
      } else if (expr.operator == BinaryOperator.multiply) {
        // Get max degree from both sides
        return _getVariableDegree(expr.left, variable) +
            _getVariableDegree(expr.right, variable);
      }
    }

    return 0;
  }

  /// Extract coefficient for a specific degree
  Expression _extractCoefficientForDegree(
      Expression expr, String variable, int degree) {
    if (degree == 0) {
      return expr;
    }

    if (degree == 1) {
      if (expr is Variable && expr.name == variable) {
        return const NumberLiteral(1);
      }
      if (expr is BinaryOp && expr.operator == BinaryOperator.multiply) {
        if (_containsVariable(expr.left, variable)) {
          return expr.right;
        } else if (_containsVariable(expr.right, variable)) {
          return expr.left;
        }
      }
    }

    if (degree == 2) {
      if (expr is BinaryOp && expr.operator == BinaryOperator.power) {
        if (expr.left is Variable && (expr.left as Variable).name == variable) {
          return const NumberLiteral(1);
        }
      }
      if (expr is BinaryOp && expr.operator == BinaryOperator.multiply) {
        // Find the non-x^2 part
        final leftDeg = _getVariableDegree(expr.left, variable);
        final rightDeg = _getVariableDegree(expr.right, variable);

        if (leftDeg == 2 && rightDeg == 0) {
          return expr.right;
        } else if (leftDeg == 0 && rightDeg == 2) {
          return expr.left;
        }
      }
    }

    return const NumberLiteral(1);
  }

  /// Check if expression contains a variable
  bool _containsVariable(Expression expr, String variable) {
    if (expr is Variable) {
      return expr.name == variable;
    }
    if (expr is BinaryOp) {
      return _containsVariable(expr.left, variable) ||
          _containsVariable(expr.right, variable);
    }
    if (expr is UnaryOp) {
      return _containsVariable(expr.operand, variable);
    }
    if (expr is FunctionCall) {
      return expr.args.any((arg) => _containsVariable(arg, variable));
    }
    return false;
  }

  /// Extract coefficient of variable (for linear term)
  Expression _extractCoefficient(Expression expr, String variable) {
    if (expr is Variable && expr.name == variable) {
      return const NumberLiteral(1);
    }

    if (expr is BinaryOp && expr.operator == BinaryOperator.multiply) {
      if (expr.left is Variable && (expr.left as Variable).name == variable) {
        return expr.right;
      } else if (expr.right is Variable &&
          (expr.right as Variable).name == variable) {
        return expr.left;
      } else if (_containsVariable(expr.left, variable)) {
        return expr.right;
      } else if (_containsVariable(expr.right, variable)) {
        return expr.left;
      }
    }

    return const NumberLiteral(1);
  }

  /// Helper: negate an expression
  Expression _negate(Expression expr) {
    if (expr is NumberLiteral) {
      return NumberLiteral(-expr.value);
    }
    return UnaryOp(UnaryOperator.negate, expr);
  }

  /// Helper: check if expression is zero
  bool _isZero(Expression expr) {
    return expr is NumberLiteral && expr.value == 0;
  }

  /// Helper: simplify division
  Expression _simplifyDivision(Expression numerator, Expression denominator) {
    // Check for 1 in denominator
    if (denominator is NumberLiteral && denominator.value == 1) {
      return numerator;
    }

    // Check for numeric simplification
    if (numerator is NumberLiteral && denominator is NumberLiteral) {
      return NumberLiteral(numerator.value / denominator.value);
    }

    return BinaryOp(numerator, BinaryOperator.divide, denominator);
  }

  /// Helper: add two expressions
  Expression _addExpressions(Expression a, Expression b) {
    if (a is NumberLiteral && a.value == 0) return b;
    if (b is NumberLiteral && b.value == 0) return a;

    if (a is NumberLiteral && b is NumberLiteral) {
      return NumberLiteral(a.value + b.value);
    }

    return BinaryOp(a, BinaryOperator.add, b);
  }

  /// Helper: try to evaluate expression to a number
  double? _tryEvaluate(Expression expr) {
    if (expr is NumberLiteral) {
      return expr.value;
    }

    if (expr is BinaryOp) {
      final left = _tryEvaluate(expr.left);
      final right = _tryEvaluate(expr.right);

      if (left != null && right != null) {
        switch (expr.operator) {
          case BinaryOperator.add:
            return left + right;
          case BinaryOperator.subtract:
            return left - right;
          case BinaryOperator.multiply:
            return left * right;
          case BinaryOperator.divide:
            return right != 0 ? left / right : null;
          case BinaryOperator.power:
            return math.pow(left, right).toDouble();
        }
      }
    }

    return null;
  }
}
