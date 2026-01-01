import '../ast.dart';
import 'rewrite_rule.dart';
import 'assumptions.dart';
import '../exceptions.dart';

/// Engine to apply rewrite rules to expressions.
class RuleEngine {
  final List<RewriteRule> rules;
  final Set<RuleCategory> enabledCategories;

  /// Applies enabled rules to [expr] until no more changes occur or maxIterations is reached.
  Expression applyRules(Expression expr,
      {int maxIterations = 100, Assumptions? assumptions}) {
    var current = expr;

    for (int i = 0; i < maxIterations; i++) {
      final next = _applyOnePass(current, assumptions);
      if (next == current) {
        return current; // Fixed point reached
      }
      current = next;
    }

    return current;
  }

  final int maxRecursionDepth;

  RuleEngine({
    required this.rules,
    required this.enabledCategories,
    this.maxRecursionDepth = 500,
  });

  int _recursionDepth = 0;

  void _enterRecursion() {
    if (++_recursionDepth > maxRecursionDepth) {
      throw EvaluatorException(
        'Maximum simplification depth exceeded',
        suggestion: 'The symbolic simplification process is too complex',
      );
    }
  }

  void _exitRecursion() {
    _recursionDepth--;
  }

  /// Performs one pass of rule application.
  Expression _applyOnePass(Expression expr, Assumptions? assumptions) {
    _enterRecursion();
    try {
      // 1. Simplify children first (Bottom-Up)
      Expression simplifiedChildren = expr;
      if (expr is BinaryOp) {
        simplifiedChildren = BinaryOp(_applyOnePass(expr.left, assumptions),
            expr.operator, _applyOnePass(expr.right, assumptions),
            sourceToken: expr.sourceToken);
      } else if (expr is UnaryOp) {
        simplifiedChildren =
            UnaryOp(expr.operator, _applyOnePass(expr.operand, assumptions));
      } else if (expr is FunctionCall) {
        final newArgs =
            expr.args.map((a) => _applyOnePass(a, assumptions)).toList();
        final newBase =
            expr.base != null ? _applyOnePass(expr.base!, assumptions) : null;
        final newParam = expr.optionalParam != null
            ? _applyOnePass(expr.optionalParam!, assumptions)
            : null;

        if (newArgs.length == 1) {
          simplifiedChildren = FunctionCall(expr.name, newArgs[0],
              base: newBase, optionalParam: newParam);
        } else {
          simplifiedChildren = FunctionCall.multivar(expr.name, newArgs,
              base: newBase, optionalParam: newParam);
        }
      }

      // 2. Simplify self using rules
      var current = simplifiedChildren;

      // Filter and sort rules
      final activeRules = rules
          .where((r) => enabledCategories.contains(r.category))
          .toList()
        ..sort((a, b) => b.priority.compareTo(a.priority));

      for (final rule in activeRules) {
        if (rule.matches(current, assumptions: assumptions)) {
          final next = rule.apply(current, assumptions: assumptions);
          if (next != current) {
            return next;
          }
        }
      }

      return current;
    } finally {
      _exitRecursion();
    }
  }
}
