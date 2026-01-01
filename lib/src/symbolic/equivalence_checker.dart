import 'dart:math';
import '../ast.dart';
import 'normalizer.dart';

enum EquivalenceLevel {
  structural, // AST equality (==)
  algebraic, // Mathematically equivalent after normalization
  numeric, // Equal at sample points (probabilistic)
}

/// Checks if two expressions are equivalent at varying levels of rigor.
class EquivalenceChecker {
  final ExpressionNormalizer _normalizer = ExpressionNormalizer();

  /// Checks if [a] and [b] are equivalent at the specified [level].
  bool areEquivalent(Expression a, Expression b,
      {EquivalenceLevel level = EquivalenceLevel.algebraic}) {
    switch (level) {
      case EquivalenceLevel.structural:
        return a == b;

      case EquivalenceLevel.algebraic:
        return _checkAlgebraic(a, b);

      case EquivalenceLevel.numeric:
        return _checkNumeric(a, b);
    }
  }

  bool _checkAlgebraic(Expression a, Expression b) {
    if (a == b) return true;
    final normA = _normalizer.normalize(a);
    final normB = _normalizer.normalize(b);
    return normA == normB;
  }

  bool _checkNumeric(Expression a, Expression b, {int samples = 10}) {
    if (a == b) return true;

    // Collect variables
    final vars = <String>{};
    _collectVariables(a, vars);
    _collectVariables(b, vars);

    final random = Random(42); // Fixed seed for reproducibility

    for (int i = 0; i < samples; i++) {
      final context = <String, double>{};
      for (final v in vars) {
        // Random value between -10 and 10, avoiding 0 somewhat
        context[v] = (random.nextDouble() * 20 - 10);
        if (context[v]!.abs() < 1e-6) context[v] = 1.0;
      }

      try {
        final valA = evaluate(a, context);
        final valB = evaluate(b, context);

        if (valA.isNaN || valB.isNaN) continue; // Skip bad points
        if (valA.isInfinite || valB.isInfinite) continue;

        if ((valA - valB).abs() > 1e-9) {
          return false; // Counter-example found
        }
      } catch (e) {
        // Evaluation failed (e.g. div by zero), skip point
        continue;
      }
    }

    return true; // Probabilistically equivalent
  }

  void _collectVariables(Expression expr, Set<String> vars) {
    if (expr is Variable) {
      vars.add(expr.name);
    } else if (expr is BinaryOp) {
      _collectVariables(expr.left, vars);
      _collectVariables(expr.right, vars);
    } else if (expr is UnaryOp) {
      _collectVariables(expr.operand, vars);
    } else if (expr is FunctionCall) {
      for (final arg in expr.args) {
        _collectVariables(arg, vars);
      }
    }
  }

  double evaluate(Expression expr, Map<String, double> context) {
    final visitor = EvaluationVisitor();
    final result = expr.accept(visitor, context);

    if (result is double) return result;
    if (result is int) return result.toDouble();
    if (result is EvaluationResult) {
      if (result.isNumeric) return result.asNumeric();
      // For now, fail on complex/matrix in numeric check
      throw StateError('Non-numeric result in equivalence check');
    }
    throw StateError('Unknown result type: $result');
  }
}
