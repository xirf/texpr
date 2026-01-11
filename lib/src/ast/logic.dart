import 'expression.dart';
import 'visitor.dart';

/// Comparison operation types.
enum ComparisonOperator {
  less,
  greater,
  lessEqual,
  greaterEqual,
  equal,
  member,
}

/// A comparison operation (left op right).
class Comparison extends Expression {
  final Expression left;
  final ComparisonOperator operator;
  final Expression right;

  const Comparison(this.left, this.operator, this.right);

  @override
  String toString() => 'Comparison($left, $operator, $right)';

  @override
  String toLatex() {
    final op = switch (operator) {
      ComparisonOperator.less => '<',
      ComparisonOperator.greater => '>',
      ComparisonOperator.lessEqual => '\\leq',
      ComparisonOperator.greaterEqual => '\\geq',
      ComparisonOperator.equal => '=',
      ComparisonOperator.member => '\\in',
    };
    return '${left.toLatex()} $op ${right.toLatex()}';
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitComparison(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comparison &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          operator == other.operator &&
          right == other.right;

  @override
  int get hashCode => left.hashCode ^ operator.hashCode ^ right.hashCode;
}

/// A conditional expression with a condition constraint.
/// Example: x^2 - 2 where -1 < x < 2
class ConditionalExpr extends Expression {
  /// The main expression to evaluate
  final Expression expression;

  /// The condition that must be satisfied
  final Expression condition;

  const ConditionalExpr(this.expression, this.condition);

  @override
  String toString() => 'ConditionalExpr($expression, condition: $condition)';

  @override
  String toLatex() =>
      '${expression.toLatex()} \\text{ where } ${condition.toLatex()}';

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitConditionalExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConditionalExpr &&
          runtimeType == other.runtimeType &&
          expression == other.expression &&
          condition == other.condition;

  @override
  int get hashCode => expression.hashCode ^ condition.hashCode;
}

/// A chained comparison expression.
/// Example: -1 < x < 2 (evaluates as -1 < x AND x < 2)
class ChainedComparison extends Expression {
  /// The list of expressions in the chain
  final List<Expression> expressions;

  /// The list of operators between expressions
  final List<ComparisonOperator> operators;

  const ChainedComparison(this.expressions, this.operators);

  @override
  String toString() => 'ChainedComparison($expressions, $operators)';

  @override
  String toLatex() {
    final buffer = StringBuffer();
    for (int i = 0; i < expressions.length; i++) {
      buffer.write(expressions[i].toLatex());
      if (i < operators.length) {
        final op = switch (operators[i]) {
          ComparisonOperator.less => '<',
          ComparisonOperator.greater => '>',
          ComparisonOperator.lessEqual => '\\leq',
          ComparisonOperator.greaterEqual => '\\geq',
          ComparisonOperator.equal => '=',
          ComparisonOperator.member => '\\in',
        };
        buffer.write(' $op ');
      }
    }
    return buffer.toString();
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitChainedComparison(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainedComparison &&
          runtimeType == other.runtimeType &&
          _listEquals(expressions, other.expressions) &&
          _listEquals(operators, other.operators);

  @override
  int get hashCode => expressions.hashCode ^ operators.hashCode;

  static bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// A single case in a piecewise function.
///
/// Each case has an expression and an optional condition.
/// If condition is null, it represents an "otherwise" case.
///
/// Example in LaTeX: `x^2 & x < 0`
class PiecewiseCase {
  /// The expression to evaluate when this case applies
  final Expression expression;

  /// The condition that must be satisfied for this case to apply.
  /// If null, this is the "otherwise" catch-all case.
  final Expression? condition;

  const PiecewiseCase(this.expression, this.condition);

  @override
  String toString() => 'PiecewiseCase($expression, condition: $condition)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PiecewiseCase &&
          runtimeType == other.runtimeType &&
          expression == other.expression &&
          condition == other.condition;

  @override
  int get hashCode => expression.hashCode ^ condition.hashCode;
}

/// A piecewise function with multiple cases.
///
/// This represents the `\begin{cases}...\end{cases}` LaTeX environment.
/// Cases are evaluated in order, and the first matching condition determines
/// the result. If no condition matches, the result is NaN.
///
/// Example:
/// ```latex
/// \begin{cases}
///   x^2 & x < 0 \\
///   2x & x \geq 0
/// \end{cases}
/// ```
class PiecewiseExpr extends Expression {
  /// The list of cases in this piecewise function.
  /// Cases are evaluated in order until a matching condition is found.
  final List<PiecewiseCase> cases;

  const PiecewiseExpr(this.cases);

  @override
  String toString() => 'PiecewiseExpr($cases)';

  @override
  String toLatex() {
    final buffer = StringBuffer(r'\begin{cases}');
    for (int i = 0; i < cases.length; i++) {
      final c = cases[i];
      buffer.write(' ');
      buffer.write(c.expression.toLatex());
      buffer.write(' & ');
      if (c.condition != null) {
        buffer.write(c.condition!.toLatex());
      } else {
        buffer.write(r'\text{otherwise}');
      }
      if (i < cases.length - 1) {
        buffer.write(r' \\');
      }
    }
    buffer.write(r' \end{cases}');
    return buffer.toString();
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitPiecewise(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PiecewiseExpr &&
          runtimeType == other.runtimeType &&
          ChainedComparison._listEquals(cases, other.cases);

  @override
  int get hashCode => cases.hashCode;
}

/// Boolean binary operator types for propositional logic.
enum BooleanOperator {
  /// Logical AND (∧): `\land`, `\wedge`
  and,

  /// Logical OR (∨): `\lor`, `\vee`
  or,

  /// Logical XOR (⊕): `\oplus`
  xor,

  /// Logical implication (⇒): `\Rightarrow`, `\implies`
  implies,

  /// Logical biconditional (⇔): `\Leftrightarrow`, `\iff`
  iff,
}

/// A boolean binary expression (A ∧ B, A ∨ B, A ⊕ B, A ⇒ B, A ⇔ B).
///
/// Operands are typically comparison expressions or other boolean expressions.
///
/// Example in LaTeX:
/// ```latex
/// (x > 0) \land (y < 5)
/// A \lor B
/// P \Rightarrow Q
/// ```
class BooleanBinaryExpr extends Expression {
  /// The left operand
  final Expression left;

  /// The boolean operator
  final BooleanOperator operator;

  /// The right operand
  final Expression right;

  const BooleanBinaryExpr(this.left, this.operator, this.right);

  @override
  String toString() => 'BooleanBinaryExpr($left, $operator, $right)';

  @override
  String toLatex() {
    final op = switch (operator) {
      BooleanOperator.and => r'\land',
      BooleanOperator.or => r'\lor',
      BooleanOperator.xor => r'\oplus',
      BooleanOperator.implies => r'\Rightarrow',
      BooleanOperator.iff => r'\Leftrightarrow',
    };
    return '${left.toLatex()} $op ${right.toLatex()}';
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitBooleanBinaryExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooleanBinaryExpr &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          operator == other.operator &&
          right == other.right;

  @override
  int get hashCode => left.hashCode ^ operator.hashCode ^ right.hashCode;
}

/// A boolean unary expression (¬A).
///
/// Example in LaTeX:
/// ```latex
/// \neg(x > 0)
/// \lnot P
/// ```
class BooleanUnaryExpr extends Expression {
  /// The operand to negate
  final Expression operand;

  const BooleanUnaryExpr(this.operand);

  @override
  String toString() => 'BooleanUnaryExpr($operand)';

  @override
  String toLatex() => r'\neg ' + operand.toLatex();

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitBooleanUnaryExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooleanUnaryExpr &&
          runtimeType == other.runtimeType &&
          operand == other.operand;

  @override
  int get hashCode => operand.hashCode;
}
