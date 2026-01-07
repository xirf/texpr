import 'expression.dart';
import 'visitor.dart';

/// A numeric literal value.
class NumberLiteral extends Expression {
  final double value;

  const NumberLiteral(this.value);

  @override
  String toString() => 'NumberLiteral($value)';

  @override
  String toLatex() {
    // Handle special cases for cleaner output
    if (value.isInfinite) return value.isNegative ? '-\\infty' : '\\infty';
    if (value.isNaN) return '\\text{NaN}';

    // Format the number nicely
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitNumberLiteral(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumberLiteral &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// A variable reference.
class Variable extends Expression {
  final String name;

  const Variable(this.name);

  @override
  String toString() => 'Variable($name)';

  @override
  String toLatex() => name;

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitVariable(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Variable &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// Represents a closed interval [a, b].
class IntervalExpr extends Expression {
  final Expression lower;
  final Expression upper;

  const IntervalExpr(this.lower, this.upper);

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, [C? context]) =>
      visitor.visitIntervalExpr(this, context);

  @override
  bool operator ==(Object other) =>
      other is IntervalExpr && lower == other.lower && upper == other.upper;

  @override
  int get hashCode => Object.hash(lower, upper);

  @override
  String toLatex() => '[${lower.toLatex()}, ${upper.toLatex()}]';
}
