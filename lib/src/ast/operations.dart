import 'expression.dart';
import 'visitor.dart';

/// Binary operation types.
enum BinaryOperator {
  add,
  subtract,
  multiply,
  divide,
  power,
}

/// A binary operation (left op right).
class BinaryOp extends Expression {
  final Expression left;
  final BinaryOperator operator;
  final Expression right;

  /// The source token value (e.g., '\times', '\cdot', '*') for disambiguation.
  final String? sourceToken;

  const BinaryOp(this.left, this.operator, this.right, {this.sourceToken});

  @override
  String toString() => 'BinaryOp($left, $operator, $right)';

  @override
  String toLatex() {
    final leftLatex = _needsParens(left, operator, true)
        ? '\\left(${left.toLatex()}\\right)'
        : left.toLatex();
    final rightLatex = _needsParens(right, operator, false)
        ? '\\left(${right.toLatex()}\\right)'
        : right.toLatex();

    switch (operator) {
      case BinaryOperator.add:
        return '$leftLatex+$rightLatex';
      case BinaryOperator.subtract:
        return '$leftLatex-$rightLatex';
      case BinaryOperator.multiply:
        // Use sourceToken if available for accurate round-trip
        final op = sourceToken ?? '\\cdot';
        return '$leftLatex $op $rightLatex';
      case BinaryOperator.divide:
        return '\\frac{${left.toLatex()}}{${right.toLatex()}}';
      case BinaryOperator.power:
        return '$leftLatex^{${right.toLatex()}}';
    }
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitBinaryOp(this, context);
  }

  /// Determines if an expression needs parentheses based on operator precedence.
  bool _needsParens(Expression expr, BinaryOperator parentOp, bool isLeft) {
    if (expr is! BinaryOp) return false;

    final precedence = {
      BinaryOperator.add: 1,
      BinaryOperator.subtract: 1,
      BinaryOperator.multiply: 2,
      BinaryOperator.divide: 2,
      BinaryOperator.power: 3,
    };

    final exprPrec = precedence[expr.operator]!;
    final parentPrec = precedence[parentOp]!;

    // Lower precedence always needs parens
    if (exprPrec < parentPrec) return true;

    // Right-associative power needs parens on left
    if (parentOp == BinaryOperator.power && isLeft && exprPrec <= parentPrec) {
      return true;
    }

    // Subtraction/division need parens on right for same precedence
    if (!isLeft &&
        (parentOp == BinaryOperator.subtract ||
            parentOp == BinaryOperator.divide)) {
      if (exprPrec <= parentPrec) return true;
    }

    return false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BinaryOp &&
          runtimeType == other.runtimeType &&
          left == other.left &&
          operator == other.operator &&
          right == other.right &&
          sourceToken == other.sourceToken;

  /// Hash code implementation using [Object.hash] to preserve operand order.
  ///
  /// IMPORTANT: We use [Object.hash] instead of XOR-based hashing because
  /// XOR is commutative (a ^ b == b ^ a), which would cause cache collisions
  /// for non-commutative operations.
  ///
  /// For example, with XOR-based hashing:
  /// - `vec1 * vec2` and `vec2 * vec1` would have the same hash code
  /// - `a - b` and `b - a` would have the same hash code
  /// - `a / b` and `b / a` would have the same hash code
  ///
  /// This would cause the cache to return incorrect results for expressions
  /// where operand order matters. [Object.hash] preserves order, ensuring
  /// that `BinaryOp(a, op, b)` and `BinaryOp(b, op, a)` have different
  /// hash codes when `op` is non-commutative.
  @override
  int get hashCode => Object.hash(left, operator, right, sourceToken);
}

/// Unary operation types.
enum UnaryOperator {
  negate,
}

/// A unary operation (op operand).
class UnaryOp extends Expression {
  final UnaryOperator operator;
  final Expression operand;

  const UnaryOp(this.operator, this.operand);

  @override
  String toString() => 'UnaryOp($operator, $operand)';

  @override
  String toLatex() {
    switch (operator) {
      case UnaryOperator.negate:
        // Add parentheses if operand is a binary operation
        if (operand is BinaryOp) {
          return '-\\left(${operand.toLatex()}\\right)';
        }
        return '-${operand.toLatex()}';
    }
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitUnaryOp(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnaryOp &&
          runtimeType == other.runtimeType &&
          operator == other.operator &&
          operand == other.operand;

  @override
  int get hashCode => operator.hashCode ^ operand.hashCode;
}
