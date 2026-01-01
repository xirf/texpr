import '../ast.dart';

/// Normalizes expressions into a canonical form.
///
/// This facilitates robust equality checking and simplification.
class ExpressionNormalizer {
  /// Normalizes the given [expression].
  Expression normalize(Expression expression) {
    return _normalizeRecursive(expression);
  }

  Expression _normalizeRecursive(Expression expr) {
    // Bottom-up: normalize children first
    if (expr is BinaryOp) {
      final left = _normalizeRecursive(expr.left);
      final right = _normalizeRecursive(expr.right);

      // Reconstitute if changed, but we will process this node next
      expr =
          BinaryOp(left, expr.operator, right, sourceToken: expr.sourceToken);

      if (expr.operator == BinaryOperator.add ||
          expr.operator == BinaryOperator.multiply) {
        return _normalizeAssociative(expr);
      }
    } else if (expr is UnaryOp) {
      final operand = _normalizeRecursive(expr.operand);
      return UnaryOp(expr.operator, operand);
    } else if (expr is FunctionCall) {
      // Assuming FunctionCall exists in ast.dart
      // TODO: Handle function call normalization
    }

    return expr; // Leaf nodes: Variable, NumberLiteral
  }

  Expression _normalizeAssociative(BinaryOp op) {
    final operator = op.operator;
    // 1. Flatten into list
    final terms = <Expression>[];
    _flatten(op, operator, terms);

    // 2. Sort terms
    _sortTerms(terms);

    // 3. Constant fold / Combine terms
    // Simple constant folding: sum all NumberLiterals
    final foldedTerms = _foldConstants(terms, operator);

    if (foldedTerms.isEmpty) {
      return NumberLiteral(
          0); // Should not happen given logic, but safe fallback
    }
    if (foldedTerms.length == 1) {
      return foldedTerms.first;
    }

    // 4. Rebuild right-associative tree
    // a + b + c -> a + (b + c)
    var result = foldedTerms.last;
    for (int i = foldedTerms.length - 2; i >= 0; i--) {
      result = BinaryOp(foldedTerms[i], operator, result);
    }
    return result;
  }

  void _flatten(Expression expr, BinaryOperator op, List<Expression> terms) {
    if (expr is BinaryOp && expr.operator == op) {
      _flatten(expr.left, op, terms);
      _flatten(expr.right, op, terms);
    } else {
      terms.add(expr);
    }
  }

  void _sortTerms(List<Expression> terms) {
    terms.sort((a, b) {
      // 1. NumberLiteral first
      if (a is NumberLiteral && b is! NumberLiteral) return -1;
      if (a is! NumberLiteral && b is NumberLiteral) return 1;
      if (a is NumberLiteral && b is NumberLiteral) {
        return a.value.compareTo(b.value);
      }

      // 2. Variables alphabetically
      if (a is Variable && b is Variable) return a.name.compareTo(b.name);
      if (a is Variable && b is! Variable) {
        return -1; // Variables before complex exprs
      }
      if (a is! Variable && b is Variable) return 1;

      // 3. Complex expressions by string repr
      return a.toString().compareTo(b.toString());
    });
  }

  List<Expression> _foldConstants(List<Expression> terms, BinaryOperator op) {
    final numbers = <NumberLiteral>[];
    final others = <Expression>[];

    for (final term in terms) {
      if (term is NumberLiteral) {
        numbers.add(term);
      } else {
        others.add(term);
      }
    }

    if (numbers.isEmpty) {
      return terms;
    }
    // numbers.length == 1 might still need folding if it's an identity (0 or 1)

    double foldedValue;
    if (op == BinaryOperator.add) {
      foldedValue = numbers.fold(0.0, (sum, n) => sum + n.value);
    } else if (op == BinaryOperator.multiply) {
      foldedValue = numbers.fold(1.0, (prod, n) => prod * n.value);
    } else {
      return terms;
    }

    // Special cases
    if (op == BinaryOperator.multiply && foldedValue == 0) {
      return [NumberLiteral(0)];
    }
    if (op == BinaryOperator.multiply &&
        foldedValue == 1 &&
        others.isNotEmpty) {
      // 1 * x -> x
      return others;
    }
    if (op == BinaryOperator.add && foldedValue == 0 && others.isNotEmpty) {
      // 0 + x -> x
      return others;
    }

    // rebuild list with constant at start
    return [NumberLiteral(foldedValue), ...others];
  }
}
