/// Symbolic differentiation evaluator.
library;

import '../../ast.dart';
import '../../exceptions.dart';
import '../../symbolic/step_trace.dart';

/// Handles symbolic differentiation of expressions.
///
/// This evaluator implements standard differentiation rules including:
/// - Power rule: d/dx(x^n) = n*x^(n-1)
/// - Sum rule: d/dx(f+g) = f' + g'
/// - Product rule: d/dx(f*g) = f'*g + f*g'
/// - Quotient rule: d/dx(f/g) = (f'*g - f*g')/g^2
/// - Chain rule: d/dx(f(g(x))) = f'(g(x)) * g'(x)
/// - Trigonometric functions
/// - Exponential and logarithmic functions
class DifferentiationEvaluator {
  /// Callback to evaluate arbitrary expressions.
  final dynamic Function(Expression, Map<String, double>) _evaluate;

  /// Creates a differentiation evaluator.
  DifferentiationEvaluator(this._evaluate, [this.maxRecursionDepth = 500]);

  int _recursionDepth = 0;
  final int maxRecursionDepth;

  void _enterRecursion() {
    if (++_recursionDepth > maxRecursionDepth) {
      throw EvaluatorException(
        'Maximum differentiation depth exceeded',
        suggestion:
            'The expression is too complex to differentiate symbolically',
      );
    }
  }

  void _exitRecursion() {
    _recursionDepth--;
  }

  /// Differentiates an expression with respect to a variable.
  ///
  /// Returns a new [Expression] representing the symbolic derivative.
  Expression differentiate(
    Expression expr,
    String variable, {
    int order = 1,
  }) {
    if (order < 1) {
      throw EvaluatorException(
        'Derivative order must be positive',
        suggestion: 'Use order >= 1',
      );
    }

    if (order > 10) {
      throw EvaluatorException(
        'Derivative order too high',
        suggestion: 'Maximum supported order is 10',
      );
    }

    Expression result = expr;
    for (int i = 0; i < order; i++) {
      result = _differentiateOnce(result, variable);
    }
    return _simplify(result);
  }

  /// Differentiates an expression with step-by-step trace.
  ///
  /// Returns a [TracedResult] containing both the derivative and
  /// a list of transformation steps showing the work.
  ///
  /// Example:
  /// ```dart
  /// final result = evaluator.differentiateWithSteps(parse('x^3 + 2x'), 'x');
  /// print(result.formatSteps());
  /// // Step 1 [Differentiation] Power rule: d/dx(x^n) = n·x^(n-1)
  /// //   x^{3} → 3 · x^{2}
  /// // Step 2 [Differentiation] Constant multiple rule
  /// //   2 · x → 2 · 1
  /// ```
  TracedResult<Expression> differentiateWithSteps(
    Expression expr,
    String variable, {
    int order = 1,
  }) {
    if (order < 1) {
      throw EvaluatorException(
        'Derivative order must be positive',
        suggestion: 'Use order >= 1',
      );
    }

    if (order > 10) {
      throw EvaluatorException(
        'Derivative order too high',
        suggestion: 'Maximum supported order is 10',
      );
    }

    final tracer = StepTracer();
    Expression result = expr;

    for (int i = 0; i < order; i++) {
      final before = result;
      result = _differentiateOnceWithSteps(result, variable, tracer);

      if (order > 1 && before != result) {
        final ordinal = i == 0
            ? 'first'
            : i == 1
                ? 'second'
                : '${i + 1}th';
        tracer.record(
          StepType.differentiation,
          'Complete $ordinal derivative',
          before,
          result,
        );
      }
    }

    final simplified = _simplify(result);
    if (simplified != result) {
      tracer.record(
        StepType.simplification,
        'Simplify result',
        result,
        simplified,
      );
    }

    return tracer.complete(simplified);
  }

  /// Performs differentiation with step recording.
  Expression _differentiateOnceWithSteps(
      Expression expr, String variable, StepTracer tracer) {
    final result = _tracedDifferentiation(expr, variable, tracer);
    return result;
  }

  /// Differentiate with step tracing for the main expression types.
  Expression _tracedDifferentiation(
      Expression expr, String variable, StepTracer tracer) {
    switch (expr) {
      case NumberLiteral():
        tracer.record(
          StepType.differentiation,
          'Constant rule: d/dx(c) = 0',
          expr,
          const NumberLiteral(0),
          ruleName: 'constant_rule',
        );
        return const NumberLiteral(0);

      case Variable(:final name):
        final result =
            name == variable ? const NumberLiteral(1) : const NumberLiteral(0);
        if (name == variable) {
          tracer.record(
            StepType.differentiation,
            'Variable rule: d/dx(x) = 1',
            expr,
            result,
            ruleName: 'variable_rule',
          );
        }
        return result;

      case BinaryOp(:final left, :final right, :final operator)
          when operator == BinaryOperator.add ||
              operator == BinaryOperator.subtract:
        final ruleName =
            operator == BinaryOperator.add ? 'sum_rule' : 'difference_rule';
        final ruleDesc = operator == BinaryOperator.add
            ? "Sum rule: d/dx(f + g) = f' + g'"
            : "Difference rule: d/dx(f - g) = f' - g'";

        final leftDeriv = _differentiateOnce(left, variable);
        final rightDeriv = _differentiateOnce(right, variable);
        final result = BinaryOp(leftDeriv, operator, rightDeriv);

        tracer.record(
          StepType.differentiation,
          ruleDesc,
          expr,
          result,
          ruleName: ruleName,
        );
        return result;

      case BinaryOp(:final left, :final right, :final operator)
          when operator == BinaryOperator.multiply:
        final result = BinaryOp(
          BinaryOp(_differentiateOnce(left, variable), BinaryOperator.multiply,
              right),
          BinaryOperator.add,
          BinaryOp(left, BinaryOperator.multiply,
              _differentiateOnce(right, variable)),
        );

        tracer.record(
          StepType.differentiation,
          "Product rule: d/dx(f · g) = f' · g + f · g'",
          expr,
          result,
          ruleName: 'product_rule',
        );
        return result;

      case BinaryOp(:final left, :final right, :final operator)
          when operator == BinaryOperator.divide:
        final result = BinaryOp(
          BinaryOp(
            BinaryOp(_differentiateOnce(left, variable),
                BinaryOperator.multiply, right),
            BinaryOperator.subtract,
            BinaryOp(left, BinaryOperator.multiply,
                _differentiateOnce(right, variable)),
          ),
          BinaryOperator.divide,
          BinaryOp(right, BinaryOperator.power, const NumberLiteral(2)),
        );

        tracer.record(
          StepType.differentiation,
          "Quotient rule: d/dx(f/g) = (f'g - fg')/g²",
          expr,
          result,
          ruleName: 'quotient_rule',
        );
        return result;

      case BinaryOp(:final left, :final right, :final operator)
          when operator == BinaryOperator.power:
        final baseHasVar = _containsVariable(left, variable);
        final expHasVar = _containsVariable(right, variable);

        if (!baseHasVar && !expHasVar) {
          tracer.record(
            StepType.differentiation,
            'Constant rule: d/dx(c) = 0',
            expr,
            const NumberLiteral(0),
            ruleName: 'constant_rule',
          );
          return const NumberLiteral(0);
        } else if (baseHasVar && !expHasVar) {
          final result = _differentiatePower(left, right, variable);
          tracer.record(
            StepType.differentiation,
            'Power rule: d/dx(f^n) = n · f^(n-1) · f\'',
            expr,
            result,
            ruleName: 'power_rule',
          );
          return result;
        } else if (!baseHasVar && expHasVar) {
          final result = _differentiatePower(left, right, variable);
          tracer.record(
            StepType.differentiation,
            'Exponential rule: d/dx(a^g) = a^g · ln(a) · g\'',
            expr,
            result,
            ruleName: 'exponential_rule',
          );
          return result;
        } else {
          final result = _differentiatePower(left, right, variable);
          tracer.record(
            StepType.differentiation,
            'General power rule: d/dx(f^g) = f^g · (g\' · ln(f) + g · f\'/f)',
            expr,
            result,
            ruleName: 'general_power_rule',
          );
          return result;
        }

      case FunctionCall(:final name, :final args):
        final result = _differentiateFunctionCall(name, args, variable);
        tracer.record(
          StepType.differentiation,
          'Chain rule with $name: d/dx($name(u)) = $name\'(u) · u\'',
          expr,
          result,
          ruleName: 'chain_rule_$name',
        );
        return result;

      default:
        // Fall back to non-traced version for complex cases
        return _differentiateOnce(expr, variable);
    }
  }

  /// Performs a single differentiation step.
  Expression _differentiateOnce(Expression expr, String variable) {
    _enterRecursion();
    try {
      return switch (expr) {
        // Constant rule: d/dx(c) = 0
        NumberLiteral() => const NumberLiteral(0),

        // Variable rule: d/dx(x) = 1, d/dx(y) = 0
        Variable(:final name) =>
          name == variable ? const NumberLiteral(1) : const NumberLiteral(0),

        // Sum/Difference rule: d/dx(f ± g) = f' ± g'
        BinaryOp(:final left, :final right, :final operator)
            when operator == BinaryOperator.add ||
                operator == BinaryOperator.subtract =>
          BinaryOp(
            _differentiateOnce(left, variable),
            operator,
            _differentiateOnce(right, variable),
          ),

        // Product rule: d/dx(f * g) = f' * g + f * g'
        BinaryOp(:final left, :final right, :final operator)
            when operator == BinaryOperator.multiply =>
          BinaryOp(
            BinaryOp(
              _differentiateOnce(left, variable),
              BinaryOperator.multiply,
              right,
            ),
            BinaryOperator.add,
            BinaryOp(
              left,
              BinaryOperator.multiply,
              _differentiateOnce(right, variable),
            ),
          ),

        // Quotient rule: d/dx(f / g) = (f' * g - f * g') / g^2
        BinaryOp(:final left, :final right, :final operator)
            when operator == BinaryOperator.divide =>
          BinaryOp(
            BinaryOp(
              BinaryOp(
                _differentiateOnce(left, variable),
                BinaryOperator.multiply,
                right,
              ),
              BinaryOperator.subtract,
              BinaryOp(
                left,
                BinaryOperator.multiply,
                _differentiateOnce(right, variable),
              ),
            ),
            BinaryOperator.divide,
            BinaryOp(right, BinaryOperator.power, const NumberLiteral(2)),
          ),

        // Power rule: d/dx(f^g)
        BinaryOp(:final left, :final right, :final operator)
            when operator == BinaryOperator.power =>
          _differentiatePower(left, right, variable),

        // Unary minus: d/dx(-f) = -f'
        UnaryOp(:final operand, :final operator)
            when operator == UnaryOperator.negate =>
          UnaryOp(UnaryOperator.negate, _differentiateOnce(operand, variable)),

        // Absolute value: d/dx(|f|) = f' * sign(f)
        AbsoluteValue(:final argument) => BinaryOp(
            _differentiateOnce(argument, variable),
            BinaryOperator.multiply,
            FunctionCall('sign', argument),
          ),

        // Function calls (trig, exp, log, etc.)
        FunctionCall(:final name, :final args) =>
          _differentiateFunctionCall(name, args, variable),

        // Derivative expression (higher order)
        DerivativeExpr(:final body, :final variable, :final order) =>
          DerivativeExpr(body, variable, order: order + 1),

        // Conditional expression (piecewise): d/dx[f(x), condition] = d/dx[f(x)], condition
        ConditionalExpr(:final expression, :final condition) =>
          ConditionalExpr(_differentiateOnce(expression, variable), condition),

        // Piecewise function: differentiate each case's expression while preserving conditions
        PiecewiseExpr(:final cases) => PiecewiseExpr(
            cases
                .map((c) => PiecewiseCase(
                      _differentiateOnce(c.expression, variable),
                      c.condition,
                    ))
                .toList(),
          ),

        // Other types not yet supported
        _ => throw EvaluatorException(
            'Cannot differentiate expression of type ${expr.runtimeType}',
            suggestion: 'Symbolic differentiation is only supported for '
                'basic arithmetic, functions, and variables',
          ),
      };
    } finally {
      _exitRecursion();
    }
  }

  /// Differentiates a power expression f^g.
  Expression _differentiatePower(
    Expression base,
    Expression exponent,
    String variable,
  ) {
    // Check if both base and exponent are constants w.r.t. variable
    final baseHasVar = _containsVariable(base, variable);
    final expHasVar = _containsVariable(exponent, variable);

    if (!baseHasVar && !expHasVar) {
      // d/dx(c^k) = 0
      return const NumberLiteral(0);
    } else if (baseHasVar && !expHasVar) {
      // Power rule: d/dx(f^n) = n * f^(n-1) * f'
      return BinaryOp(
        BinaryOp(
          exponent,
          BinaryOperator.multiply,
          BinaryOp(
            base,
            BinaryOperator.power,
            BinaryOp(exponent, BinaryOperator.subtract, const NumberLiteral(1)),
          ),
        ),
        BinaryOperator.multiply,
        _differentiateOnce(base, variable),
      );
    } else if (!baseHasVar && expHasVar) {
      // Exponential rule: d/dx(a^g) = a^g * ln(a) * g'
      return BinaryOp(
        BinaryOp(
          BinaryOp(base, BinaryOperator.power, exponent),
          BinaryOperator.multiply,
          FunctionCall('ln', base),
        ),
        BinaryOperator.multiply,
        _differentiateOnce(exponent, variable),
      );
    } else {
      // General case: d/dx(f^g) = f^g * (g' * ln(f) + g * f' / f)
      return BinaryOp(
        BinaryOp(base, BinaryOperator.power, exponent),
        BinaryOperator.multiply,
        BinaryOp(
          BinaryOp(
            _differentiateOnce(exponent, variable),
            BinaryOperator.multiply,
            FunctionCall('ln', base),
          ),
          BinaryOperator.add,
          BinaryOp(
            BinaryOp(
              exponent,
              BinaryOperator.multiply,
              _differentiateOnce(base, variable),
            ),
            BinaryOperator.divide,
            base,
          ),
        ),
      );
    }
  }

  /// Differentiates a function call.
  Expression _differentiateFunctionCall(
    String name,
    List<Expression> args,
    String variable,
  ) {
    if (args.isEmpty) {
      throw EvaluatorException(
        'Cannot differentiate function with no arguments',
        suggestion: 'Check function call syntax',
      );
    }

    final arg = args[0];
    final argDerivative = _differentiateOnce(arg, variable);

    // Chain rule: d/dx(f(g(x))) = f'(g(x)) * g'(x)
    final derivative = switch (name) {
      // Trigonometric functions
      'sin' => FunctionCall('cos', arg),
      'cos' => UnaryOp(UnaryOperator.negate, FunctionCall('sin', arg)),
      'tan' => BinaryOp(
          const NumberLiteral(1),
          BinaryOperator.divide,
          BinaryOp(FunctionCall('cos', arg), BinaryOperator.power,
              const NumberLiteral(2)),
        ),
      'cot' => UnaryOp(
          UnaryOperator.negate,
          BinaryOp(
            const NumberLiteral(1),
            BinaryOperator.divide,
            BinaryOp(FunctionCall('sin', arg), BinaryOperator.power,
                const NumberLiteral(2)),
          ),
        ),
      'sec' => BinaryOp(
          FunctionCall('sec', arg),
          BinaryOperator.multiply,
          FunctionCall('tan', arg),
        ),
      'csc' => UnaryOp(
          UnaryOperator.negate,
          BinaryOp(
            FunctionCall('csc', arg),
            BinaryOperator.multiply,
            FunctionCall('cot', arg),
          ),
        ),

      // Inverse trigonometric functions
      'arcsin' || 'asin' => BinaryOp(
          const NumberLiteral(1),
          BinaryOperator.divide,
          FunctionCall(
            'sqrt',
            BinaryOp(const NumberLiteral(1), BinaryOperator.subtract,
                BinaryOp(arg, BinaryOperator.power, const NumberLiteral(2))),
          ),
        ),
      'arccos' || 'acos' => UnaryOp(
          UnaryOperator.negate,
          BinaryOp(
            const NumberLiteral(1),
            BinaryOperator.divide,
            FunctionCall(
              'sqrt',
              BinaryOp(const NumberLiteral(1), BinaryOperator.subtract,
                  BinaryOp(arg, BinaryOperator.power, const NumberLiteral(2))),
            ),
          ),
        ),
      'arctan' || 'atan' => BinaryOp(
          const NumberLiteral(1),
          BinaryOperator.divide,
          BinaryOp(
            const NumberLiteral(1),
            BinaryOperator.add,
            BinaryOp(arg, BinaryOperator.power, const NumberLiteral(2)),
          ),
        ),

      // Hyperbolic functions
      'sinh' => FunctionCall('cosh', arg),
      'cosh' => FunctionCall('sinh', arg),
      'tanh' => BinaryOp(
          const NumberLiteral(1),
          BinaryOperator.divide,
          BinaryOp(FunctionCall('cosh', arg), BinaryOperator.power,
              const NumberLiteral(2)),
        ),

      // Exponential and logarithmic
      'exp' => FunctionCall('exp', arg),
      'ln' => BinaryOp(const NumberLiteral(1), BinaryOperator.divide, arg),
      'log' => BinaryOp(
          const NumberLiteral(1),
          BinaryOperator.divide,
          BinaryOp(arg, BinaryOperator.multiply,
              FunctionCall('ln', const NumberLiteral(10))),
        ),
      'log2' => BinaryOp(
          const NumberLiteral(1),
          BinaryOperator.divide,
          BinaryOp(arg, BinaryOperator.multiply,
              FunctionCall('ln', const NumberLiteral(2))),
        ),

      // Square root: d/dx(sqrt(f)) = 1/(2*sqrt(f)) * f'
      'sqrt' => BinaryOp(
          const NumberLiteral(1),
          BinaryOperator.divide,
          BinaryOp(
            const NumberLiteral(2),
            BinaryOperator.multiply,
            FunctionCall('sqrt', arg),
          ),
        ),

      // Sign function: derivative is 0 (except at discontinuity)
      'sign' => const NumberLiteral(0),

      // Floor, ceil, round: derivative is 0 (except at discontinuities)
      'floor' || 'ceil' || 'round' => const NumberLiteral(0),
      _ => throw EvaluatorException(
          'Cannot differentiate function: $name',
          suggestion: 'Function derivative not implemented',
        ),
    };

    // Apply chain rule
    return BinaryOp(derivative, BinaryOperator.multiply, argDerivative);
  }

  /// Checks if an expression contains a specific variable.
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
      DerivativeExpr(:final body) => _containsVariable(body, variable),
      _ => true, // Conservative: assume it contains the variable
    };
  }

  /// Simplifies a derivative expression.
  ///
  /// This performs basic algebraic simplifications to make the result
  /// more readable.
  Expression _simplify(Expression expr) {
    _enterRecursion();
    try {
      return switch (expr) {
        // Simplify 0 + x = x, x + 0 = x
        BinaryOp(left: NumberLiteral(value: 0), :final operator, :final right)
            when operator == BinaryOperator.add =>
          _simplify(right),
        BinaryOp(:final left, :final operator, right: NumberLiteral(value: 0))
            when operator == BinaryOperator.add =>
          _simplify(left),

        // Simplify x - 0 = x
        BinaryOp(:final left, :final operator, right: NumberLiteral(value: 0))
            when operator == BinaryOperator.subtract =>
          _simplify(left),

        // Simplify 0 * x = 0, x * 0 = 0
        BinaryOp(left: NumberLiteral(value: 0), :final operator, right: _)
            when operator == BinaryOperator.multiply =>
          const NumberLiteral(0),
        BinaryOp(left: _, :final operator, right: NumberLiteral(value: 0))
            when operator == BinaryOperator.multiply =>
          const NumberLiteral(0),

        // Simplify 1 * x = x, x * 1 = x
        BinaryOp(left: NumberLiteral(value: 1), :final operator, :final right)
            when operator == BinaryOperator.multiply =>
          _simplify(right),
        BinaryOp(:final left, :final operator, right: NumberLiteral(value: 1))
            when operator == BinaryOperator.multiply =>
          _simplify(left),

        // Simplify x / 1 = x
        BinaryOp(:final left, :final operator, right: NumberLiteral(value: 1))
            when operator == BinaryOperator.divide =>
          _simplify(left),

        // Simplify x ^ 0 = 1
        BinaryOp(left: _, :final operator, right: NumberLiteral(value: 0))
            when operator == BinaryOperator.power =>
          const NumberLiteral(1),

        // Simplify x ^ 1 = x
        BinaryOp(:final left, :final operator, right: NumberLiteral(value: 1))
            when operator == BinaryOperator.power =>
          _simplify(left),

        // Simplify -(-x) = x
        UnaryOp(
          operator: UnaryOperator.negate,
          operand: UnaryOp(operator: UnaryOperator.negate, :final operand)
        ) =>
          _simplify(operand),

        // Recursively simplify binary operations
        BinaryOp(:final left, :final operator, :final right) =>
          BinaryOp(_simplify(left), operator, _simplify(right)),

        // Recursively simplify unary operations
        UnaryOp(:final operator, :final operand) =>
          UnaryOp(operator, _simplify(operand)),

        // Recursively simplify absolute values
        AbsoluteValue(:final argument) => AbsoluteValue(_simplify(argument)),

        // Recursively simplify function calls
        FunctionCall(:final name, :final args) =>
          FunctionCall.multivar(name, args.map(_simplify).toList()),

        // Return other expressions as-is
        _ => expr,
      };
    } finally {
      _exitRecursion();
    }
  }

  /// Evaluates a derivative at a specific point.
  ///
  /// This computes the symbolic derivative and then evaluates it numerically.
  dynamic evaluateDerivative(
    DerivativeExpr derivative,
    Map<String, double> variables,
  ) {
    // Get the symbolic derivative
    final symbolicDerivative = differentiate(
      derivative.body,
      derivative.variable,
      order: derivative.order,
    );

    // Evaluate it numerically
    return _evaluate(symbolicDerivative, variables);
  }
}
