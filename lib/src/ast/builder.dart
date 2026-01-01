/// Fluent builder for constructing AST expressions programmatically.
library;

import 'expression.dart';
import 'basic.dart';
import 'operations.dart';
import 'functions.dart';
import 'calculus.dart';
import 'logic.dart';
import 'matrix.dart';

/// A fluent builder for constructing mathematical expressions.
///
/// This class provides a more readable and maintainable way to build
/// complex AST structures programmatically, especially useful for:
/// - Testing
/// - Symbolic algebra systems
/// - Code generation
/// - Expression templates
///
/// Example:
/// ```dart
/// final b = ExpressionBuilder();
///
/// // Build: x^2 + 2x + 1
/// final quadratic = b.add(
///   b.add(
///     b.power(b.variable('x'), b.number(2)),
///     b.multiply(b.number(2), b.variable('x'))
///   ),
///   b.number(1)
/// );
///
/// // Build using chaining: sin(x) + cos(x)
/// final trig = b.add(
///   b.sin(b.variable('x')),
///   b.cos(b.variable('x'))
/// );
/// ```
class ExpressionBuilder {
  /// Creates a numeric literal expression.
  Expression number(double value) => NumberLiteral(value);

  /// Creates a variable expression.
  Expression variable(String name) => Variable(name);

  /// Creates a binary operation: left + right.
  Expression add(Expression left, Expression right) =>
      BinaryOp(left, BinaryOperator.add, right);

  /// Creates a binary operation: left - right.
  Expression subtract(Expression left, Expression right) =>
      BinaryOp(left, BinaryOperator.subtract, right);

  /// Creates a binary operation: left * right.
  Expression multiply(Expression left, Expression right) =>
      BinaryOp(left, BinaryOperator.multiply, right);

  /// Creates a binary operation: left / right.
  Expression divide(Expression left, Expression right) =>
      BinaryOp(left, BinaryOperator.divide, right);

  /// Creates a binary operation: left ^ right.
  Expression power(Expression base, Expression exponent) =>
      BinaryOp(base, BinaryOperator.power, exponent);

  /// Creates a unary negation: -operand.
  Expression negate(Expression operand) =>
      UnaryOp(UnaryOperator.negate, operand);

  /// Creates a function call.
  Expression call(String name, Expression argument,
          {Expression? base, Expression? optionalParam}) =>
      FunctionCall(name, argument, base: base, optionalParam: optionalParam);

  // Trigonometric functions
  Expression sin(Expression arg) => FunctionCall('sin', arg);
  Expression cos(Expression arg) => FunctionCall('cos', arg);
  Expression tan(Expression arg) => FunctionCall('tan', arg);
  Expression cot(Expression arg) => FunctionCall('cot', arg);
  Expression sec(Expression arg) => FunctionCall('sec', arg);
  Expression csc(Expression arg) => FunctionCall('csc', arg);

  // Inverse trigonometric
  Expression asin(Expression arg) => FunctionCall('asin', arg);
  Expression acos(Expression arg) => FunctionCall('acos', arg);
  Expression atan(Expression arg) => FunctionCall('atan', arg);

  // Hyperbolic
  Expression sinh(Expression arg) => FunctionCall('sinh', arg);
  Expression cosh(Expression arg) => FunctionCall('cosh', arg);
  Expression tanh(Expression arg) => FunctionCall('tanh', arg);

  // Logarithmic
  Expression ln(Expression arg) => FunctionCall('ln', arg);
  Expression log(Expression arg, {Expression? base}) =>
      FunctionCall('log', arg, base: base);

  /// Creates a square root: √arg.
  Expression sqrt(Expression arg) => FunctionCall('sqrt', arg);

  /// Creates an nth root: ⁿ√arg.
  Expression nthRoot(Expression arg, Expression n) =>
      FunctionCall('sqrt', arg, optionalParam: n);

  /// Creates an absolute value: |arg|.
  Expression abs(Expression arg) => AbsoluteValue(arg);

  /// Creates a derivative expression.
  ///
  /// Example: d/dx f(x)
  Expression derivative(Expression expr, String variable, {int order = 1}) =>
      DerivativeExpr(expr, variable, order: order);

  /// Creates a limit expression.
  ///
  /// Example: lim(xtoa) f(x)
  Expression limit(
          Expression body, String variable, Expression approachValue) =>
      LimitExpr(variable, approachValue, body);

  /// Creates a summation expression.
  ///
  /// Example: Σ(i=start to end) body
  Expression sum(
          String variable, Expression start, Expression end, Expression body) =>
      SumExpr(variable, start, end, body);

  /// Creates a product expression.
  ///
  /// Example: ∏(i=start to end) body
  Expression product(
          String variable, Expression start, Expression end, Expression body) =>
      ProductExpr(variable, start, end, body);

  /// Creates an integral expression.
  Expression integral(
          Expression start, Expression end, Expression body, String variable) =>
      IntegralExpr(start, end, body, variable);

  /// Creates a comparison expression.
  Expression comparison(
          Expression left, ComparisonOperator op, Expression right) =>
      Comparison(left, op, right);

  /// Creates a chained comparison.
  ///
  /// Example: 0 < x < 10
  Expression chainedComparison(
          List<Expression> expressions, List<ComparisonOperator> operators) =>
      ChainedComparison(expressions, operators);

  /// Creates a conditional expression (piecewise function).
  Expression conditional(Expression expression, Expression condition) =>
      ConditionalExpr(expression, condition);

  /// Creates a matrix expression.
  Expression matrix(List<List<Expression>> rows) => MatrixExpr(rows);

  /// Creates a vector expression.
  Expression vector(List<Expression> components, {bool isUnitVector = false}) =>
      VectorExpr(components, isUnitVector: isUnitVector);

  // Convenience methods for common patterns

  /// Creates a fraction: numerator / denominator.
  Expression fraction(Expression numerator, Expression denominator) =>
      divide(numerator, denominator);

  /// Creates a polynomial term: coefficient * x^power.
  Expression term(double coefficient, String variable, int power) => multiply(
      number(coefficient),
      this.power(this.variable(variable), number(power.toDouble())));

  /// Creates a quadratic: ax^2 + bx + c.
  Expression quadratic(String variable, double a, double b, double c) =>
      add(add(term(a, variable, 2), term(b, variable, 1)), number(c));
}
