/// Comparison and conditional evaluation logic.
library;

import '../../ast.dart';

/// Handles evaluation of comparison and conditional expressions.
class ComparisonEvaluator {
  /// Callback to evaluate arbitrary expressions as doubles.
  final double Function(Expression, Map<String, double>) _evaluateAsDouble;

  /// Callback to evaluate arbitrary expressions (may return Matrix or double).
  final dynamic Function(Expression, Map<String, double>) _evaluate;

  /// Creates a comparison evaluator with callbacks for evaluating expressions.
  ComparisonEvaluator(this._evaluateAsDouble, this._evaluate);

  /// Evaluates a simple comparison expression.
  ///
  /// Returns 1.0 if true, NaN if false.
  double evaluateComparison(Comparison comp, Map<String, double> variables) {
    final left = _evaluateAsDouble(comp.left, variables);
    final right = _evaluateAsDouble(comp.right, variables);

    bool result;
    switch (comp.operator) {
      case ComparisonOperator.less:
        result = left < right;
        break;
      case ComparisonOperator.greater:
        result = left > right;
        break;
      case ComparisonOperator.lessEqual:
        result = left <= right;
        break;
      case ComparisonOperator.greaterEqual:
        result = left >= right;
        break;
      case ComparisonOperator.member:
        // Set membership not fully supported in evaluation yet
        // For now, return false or throw runtime error?
        // Returning false to prevent crash, but this requires set logic.
        result = false;
        break;
      case ComparisonOperator.equal:
        // Use epsilon for float comparison
        result = (left - right).abs() < 1e-9;
        break;
    }

    return result ? 1.0 : double.nan;
  }

  /// Evaluates a chained comparison expression (e.g., a < b < c).
  ///
  /// Returns 1.0 if all comparisons are true, NaN otherwise.
  double evaluateChainedComparison(
      ChainedComparison chain, Map<String, double> variables) {
    // Evaluate all expressions in the chain
    final values =
        chain.expressions.map((e) => _evaluateAsDouble(e, variables)).toList();

    // Check each comparison in sequence
    for (int i = 0; i < chain.operators.length; i++) {
      final left = values[i];
      final right = values[i + 1];
      final op = chain.operators[i];

      bool result;
      switch (op) {
        case ComparisonOperator.less:
          result = left < right;
          break;
        case ComparisonOperator.greater:
          result = left > right;
          break;
        case ComparisonOperator.lessEqual:
          result = left <= right;
          break;
        case ComparisonOperator.greaterEqual:
          result = left >= right;
          break;
        case ComparisonOperator.member:
          // Placeholder for set membership.
          result = false;
          break;
        case ComparisonOperator.equal:
          result = (left - right).abs() < 1e-9;
          break;
      }

      // If any comparison fails, return NaN
      if (!result) {
        return double.nan;
      }
    }

    // All comparisons passed
    return 1.0;
  }

  /// Evaluates a conditional expression.
  ///
  /// Returns the expression value if condition is satisfied, NaN otherwise.
  dynamic evaluateConditional(
      ConditionalExpr cond, Map<String, double> variables) {
    // Evaluate the condition first
    final conditionResult = _evaluateAsDouble(cond.condition, variables);

    // If condition is not satisfied (returns NaN or 0), return NaN
    if (conditionResult.isNaN || conditionResult == 0.0) {
      return double.nan;
    }

    // If condition is satisfied, evaluate and return the expression
    return _evaluate(cond.expression, variables);
  }

  /// Evaluates a piecewise function with multiple cases.
  ///
  /// Cases are evaluated in order. The first case whose condition evaluates
  /// to true (non-NaN, non-zero) is used. If no condition matches, returns NaN.
  /// A case with null condition (otherwise case) always matches.
  dynamic evaluatePiecewise(
      PiecewiseExpr piecewise, Map<String, double> variables) {
    for (final c in piecewise.cases) {
      // If this is an "otherwise" case (no condition), it always matches
      if (c.condition == null) {
        return _evaluate(c.expression, variables);
      }

      // Evaluate the condition
      final conditionResult = _evaluateAsDouble(c.condition!, variables);

      // If condition is satisfied (not NaN and not 0), evaluate and return expression
      if (!conditionResult.isNaN && conditionResult != 0.0) {
        return _evaluate(c.expression, variables);
      }
    }

    // No condition matched
    return double.nan;
  }
}
