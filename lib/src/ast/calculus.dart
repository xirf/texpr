import 'expression.dart';
import 'visitor.dart';

/// A limit expression: \lim_{variable \to target} body.
class LimitExpr extends Expression {
  /// The limit variable (e.g., 'x' in \lim_{x \to 0}).
  final String variable;

  /// The target value (e.g., 0 in \lim_{x \to 0}).
  final Expression target;

  /// The expression body to evaluate at the limit.
  final Expression body;

  const LimitExpr(this.variable, this.target, this.body);

  @override
  String toString() => 'LimitExpr($variable -> $target, $body)';

  @override
  String toLatex() =>
      '\\lim_{$variable \\to ${target.toLatex()}}{${body.toLatex()}}';

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitLimitExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LimitExpr &&
          runtimeType == other.runtimeType &&
          variable == other.variable &&
          target == other.target &&
          body == other.body;

  @override
  int get hashCode => variable.hashCode ^ target.hashCode ^ body.hashCode;
}

/// A summation expression: \sum_{variable=start}^{end} body.
class SumExpr extends Expression {
  /// The index variable (e.g., 'i' in \sum_{i=1}^{10}).
  final String variable;

  /// The starting value.
  final Expression start;

  /// The ending value.
  final Expression end;

  /// The expression body to sum.
  final Expression body;

  const SumExpr(this.variable, this.start, this.end, this.body);

  @override
  String toString() => 'SumExpr($variable=$start to $end, $body)';

  @override
  String toLatex() =>
      '\\sum_{$variable=${start.toLatex()}}^{${end.toLatex()}}{${body.toLatex()}}';

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitSumExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SumExpr &&
          runtimeType == other.runtimeType &&
          variable == other.variable &&
          start == other.start &&
          end == other.end &&
          body == other.body;

  @override
  int get hashCode =>
      variable.hashCode ^ start.hashCode ^ end.hashCode ^ body.hashCode;
}

/// A product expression: \prod_{variable=start}^{end} body.
class ProductExpr extends Expression {
  /// The index variable (e.g., 'i' in \prod_{i=1}^{5}).
  final String variable;

  /// The starting value.
  final Expression start;

  /// The ending value.
  final Expression end;

  /// The expression body to multiply.
  final Expression body;

  const ProductExpr(this.variable, this.start, this.end, this.body);

  @override
  String toString() => 'ProductExpr($variable=$start to $end, $body)';

  @override
  String toLatex() =>
      '\\prod_{$variable=${start.toLatex()}}^{${end.toLatex()}}{${body.toLatex()}}';

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitProductExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductExpr &&
          runtimeType == other.runtimeType &&
          variable == other.variable &&
          start == other.start &&
          end == other.end &&
          body == other.body;

  @override
  int get hashCode =>
      variable.hashCode ^ start.hashCode ^ end.hashCode ^ body.hashCode;
}

/// An integral expression: \int_{lower}^{upper} body dx or \int body dx.
class IntegralExpr extends Expression {
  /// The lower bound of the integral (optional for indefinite integrals).
  final Expression? lower;

  /// The upper bound of the integral (optional for indefinite integrals).
  final Expression? upper;

  /// The expression body to integrate.
  final Expression body;

  /// The variable of integration (e.g., 'x' in dx).
  final String variable;

  /// Whether this is a closed integral (\oint).
  final bool isClosed;

  const IntegralExpr(this.lower, this.upper, this.body, this.variable,
      {this.isClosed = false});

  @override
  String toString() {
    if (lower == null && upper == null) {
      return 'IntegralExpr(${isClosed ? "closed, " : ""}$body d$variable)';
    }
    return 'IntegralExpr(${isClosed ? "closed, " : ""}$lower to $upper, $body d$variable)';
  }

  @override
  String toLatex() {
    final bounds = (lower != null && upper != null)
        ? '_{${lower!.toLatex()}}^{${upper!.toLatex()}}'
        : (lower != null ? '_{${lower!.toLatex()}}' : '');
    final cmd = isClosed ? '\\oint' : '\\int';
    return '$cmd$bounds{${body.toLatex()}} d$variable';
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitIntegralExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IntegralExpr &&
          runtimeType == other.runtimeType &&
          lower == other.lower &&
          upper == other.upper &&
          body == other.body &&
          variable == other.variable &&
          isClosed == other.isClosed;

  @override
  int get hashCode =>
      lower.hashCode ^
      upper.hashCode ^
      body.hashCode ^
      variable.hashCode ^
      isClosed.hashCode;
}

/// A derivative expression: \frac{d}{dx} body or \frac{d^n}{dx^n} body.
class DerivativeExpr extends Expression {
  /// The expression body to differentiate.
  final Expression body;

  /// The variable to differentiate with respect to (e.g., 'x' in d/dx).
  final String variable;

  /// The order of differentiation (1 for first derivative, 2 for second, etc.).
  final int order;

  const DerivativeExpr(this.body, this.variable, {this.order = 1});

  @override
  String toString() {
    if (order == 1) {
      return 'DerivativeExpr(d/d$variable, $body)';
    }
    return 'DerivativeExpr(d^$order/d$variable^$order, $body)';
  }

  @override
  String toLatex() {
    if (order == 1) {
      return '\\frac{d}{d$variable}{${body.toLatex()}}';
    }
    return '\\frac{d^{$order}}{d$variable^{$order}}{${body.toLatex()}}';
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitDerivativeExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DerivativeExpr &&
          runtimeType == other.runtimeType &&
          body == other.body &&
          variable == other.variable &&
          order == other.order;

  @override
  int get hashCode => body.hashCode ^ variable.hashCode ^ order.hashCode;
}

/// A partial derivative expression: \frac{\partial f}{\partial x}.
class PartialDerivativeExpr extends Expression {
  /// The expression body to differentiate.
  final Expression body;

  /// The variable to differentiate with respect to.
  final String variable;

  /// The order of differentiation.
  final int order;

  const PartialDerivativeExpr(this.body, this.variable, {this.order = 1});

  @override
  String toString() =>
      'PartialDerivativeExpr(∂^$order/∂$variable^$order, $body)';

  @override
  String toLatex() {
    final orderStr = order > 1 ? '^{$order}' : '';
    return '\\frac{\\partial$orderStr}{\\partial $variable$orderStr}{${body.toLatex()}}';
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitPartialDerivativeExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartialDerivativeExpr &&
          runtimeType == other.runtimeType &&
          body == other.body &&
          variable == other.variable &&
          order == other.order;

  @override
  int get hashCode => body.hashCode ^ variable.hashCode ^ order.hashCode;
}

/// A multiple integral expression: \iint, \iiint.
class MultiIntegralExpr extends Expression {
  /// The order of the integral (2 for double, 3 for triple).
  final int order;

  /// The lower bound (optional).
  final Expression? lower;

  /// The upper bound (optional).
  final Expression? upper;

  /// The expression body to integrate.
  final Expression body;

  /// The variables of integration.
  final List<String> variables;

  const MultiIntegralExpr(
    this.order,
    this.lower,
    this.upper,
    this.body,
    this.variables,
  );

  @override
  String toString() =>
      'MultiIntegralExpr(order: $order, $body d${variables.join(' d')})';

  @override
  String toLatex() {
    final cmd = order == 2 ? '\\iint' : '\\iiint';
    final bounds = (lower != null && upper != null)
        ? '_{${lower!.toLatex()}}^{${upper!.toLatex()}}'
        : (lower != null ? '_{${lower!.toLatex()}}' : '');
    return '$cmd$bounds{${body.toLatex()}} d${variables.join(' d')}';
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitMultiIntegralExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MultiIntegralExpr &&
          runtimeType == other.runtimeType &&
          order == other.order &&
          lower == other.lower &&
          upper == other.upper &&
          body == other.body &&
          Object.hashAll(variables) == Object.hashAll(other.variables);

  @override
  int get hashCode =>
      Object.hash(order, lower, upper, body, Object.hashAll(variables));
}

/// Binomial coefficient expression: \binom{n}{k}.
class BinomExpr extends Expression {
  final Expression n;
  final Expression k;

  const BinomExpr(this.n, this.k);

  @override
  String toString() => 'BinomExpr($n, $k)';

  @override
  String toLatex() => '\\binom{${n.toLatex()}}{${k.toLatex()}}';

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitBinomExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BinomExpr &&
          runtimeType == other.runtimeType &&
          n == other.n &&
          k == other.k;

  @override
  int get hashCode => n.hashCode ^ k.hashCode;
}

/// Gradient expression: \nabla f.
///
/// Represents the gradient operator applied to a scalar function.
/// The gradient produces a vector of partial derivatives with respect
/// to all variables in the expression.
///
/// Example: \nabla (x^2 + y^2) = [2x, 2y]
class GradientExpr extends Expression {
  /// The scalar function to compute the gradient of.
  final Expression body;

  /// Optional list of variables to compute gradient with respect to.
  /// If null, variables are auto-discovered from the expression.
  final List<String>? variables;

  const GradientExpr(this.body, {this.variables});

  @override
  String toString() => 'GradientExpr(∇$body)';

  @override
  String toLatex() => '\\nabla ${body.toLatex()}';

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitGradientExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GradientExpr &&
          runtimeType == other.runtimeType &&
          body == other.body;

  @override
  int get hashCode => body.hashCode;
}
