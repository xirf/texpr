/// Rational expression simplification.
library;

import '../ast.dart';
import '../exceptions.dart';

/// Simplifies rational expressions (fractions).
///
/// Handles:
/// - Canceling common factors
/// - Simplifying complex fractions
/// - Combining fractions with common denominators
class RationalSimplifier {
  /// Simplifies rational expressions.
  Expression simplify(Expression expr) {
    try {
      return _simplifyRecursive(expr);
    } finally {
      _recursionDepth = 0; // Reset
    }
  }

  final int maxRecursionDepth;

  RationalSimplifier({this.maxRecursionDepth = 500});

  int _recursionDepth = 0;

  void _enterRecursion() {
    if (++_recursionDepth > maxRecursionDepth) {
      throw EvaluatorException(
        'Maximum rational simplification depth exceeded',
        suggestion: 'The expression structure is too complex to simplify',
      );
    }
  }

  void _exitRecursion() {
    _recursionDepth--;
  }

  Expression _simplifyRecursive(Expression expr) {
    _enterRecursion();
    try {
      if (expr is BinaryOp && expr.operator == BinaryOperator.divide) {
        return _simplifyDivision(expr);
      } else if (expr is BinaryOp) {
        final left = _simplifyRecursive(expr.left);
        final right = _simplifyRecursive(expr.right);
        return BinaryOp(left, expr.operator, right,
            sourceToken: expr.sourceToken);
      }
      return expr;
    } finally {
      _exitRecursion();
    }
  }

  Expression _simplifyDivision(BinaryOp division) {
    final numerator = _simplifyRecursive(division.left);
    final denominator = _simplifyRecursive(division.right);

    // Cancel common factors
    if (numerator == denominator) {
      return const NumberLiteral(1);
    }

    // (a*b) / b = a
    if (numerator is BinaryOp &&
        numerator.operator == BinaryOperator.multiply) {
      if (numerator.right == denominator) {
        return numerator.left;
      }
      if (numerator.left == denominator) {
        return numerator.right;
      }
    }

    // a / (a*b) = 1/b
    if (denominator is BinaryOp &&
        denominator.operator == BinaryOperator.multiply) {
      if (denominator.right == numerator) {
        return BinaryOp(
          const NumberLiteral(1),
          BinaryOperator.divide,
          denominator.left,
          sourceToken: division.sourceToken,
        );
      }
      if (denominator.left == numerator) {
        return BinaryOp(
          const NumberLiteral(1),
          BinaryOperator.divide,
          denominator.right,
          sourceToken: division.sourceToken,
        );
      }
    }

    // Simplify numeric fractions
    if (numerator is NumberLiteral && denominator is NumberLiteral) {
      final gcd = _gcd(numerator.value.toInt(), denominator.value.toInt());
      if (gcd > 1) {
        return BinaryOp(
          NumberLiteral((numerator.value / gcd)),
          BinaryOperator.divide,
          NumberLiteral((denominator.value / gcd)),
          sourceToken: division.sourceToken,
        );
      }
    }

    return BinaryOp(numerator, BinaryOperator.divide, denominator,
        sourceToken: division.sourceToken);
  }

  int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }
}
