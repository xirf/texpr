import '../ast.dart';
import 'normalizer.dart';
import 'rule_engine.dart';
import 'rewrite_rule.dart';
import 'rules/all_rules.dart';
import 'polynomial_operations.dart';
import 'rational_simplifier.dart';

import 'assumptions.dart';

/// Main entry point for symbolic algebra operations.
///
/// The [SymbolicEngine] provides high-level symbolic manipulation capabilities
/// using a robust rule-based rewrite system and canonical normalization.
class SymbolicEngine {
  final ExpressionNormalizer _normalizer;
  final RuleEngine _simplifyEngine;
  final RuleEngine _expandEngine;

  /// Context for domain assumptions (e.g., x > 0).
  final Assumptions assumptions = Assumptions();

  // Legacy/Specialized components
  final PolynomialOperations _polynomialOps;
  final RationalSimplifier _rationalSimplifier;

  /// Creates a new symbolic engine.
  SymbolicEngine({int maxRecursionDepth = 500})
      : _normalizer = ExpressionNormalizer(),
        _polynomialOps = PolynomialOperations(),
        _rationalSimplifier =
            RationalSimplifier(maxRecursionDepth: maxRecursionDepth),
        _simplifyEngine = RuleEngine(
          rules: allSimplificationRules,
          enabledCategories: {
            RuleCategory.identity,
            RuleCategory.simplification
          },
          maxRecursionDepth: maxRecursionDepth,
        ),
        _expandEngine = RuleEngine(
          rules: [...allSimplificationRules, ...allExpansionRules],
          enabledCategories: {
            RuleCategory.identity,
            RuleCategory.simplification,
            RuleCategory.expansion
          },
          maxRecursionDepth: maxRecursionDepth,
        );

  /// Adds a domain assumption for a variable.
  void assume(String variable, Assumption assumption) {
    assumptions.assume(variable, assumption);
  }

  /// Simplifies an expression using complexity-reducing rules.
  Expression simplify(Expression expr) {
    // 1. Normalize first (canonical form)
    var result = _normalizer.normalize(expr);

    // 2. Apply simplification rules
    result = _simplifyEngine.applyRules(result, assumptions: assumptions);

    // 3. specialized simplifications (Rational)
    // Note: RationalSimplifier might need its own rewrite logic eventually
    result = _rationalSimplifier.simplify(result);

    // 4. Final normalization
    return _normalizer.normalize(result);
  }

  /// Expands trigonometric double/half-angle formulas and logs.
  Expression expandTrig(Expression expr) {
    var result = _normalizer.normalize(expr);
    return _expandEngine.applyRules(result, assumptions: assumptions);
  }

  /// Expands a polynomial expression.
  Expression expand(Expression expr) {
    return _polynomialOps.expand(expr);
  }

  /// Factors a polynomial expression.
  Expression factor(Expression expr) {
    return _polynomialOps.factor(expr);
  }

  /// Tests if two expressions are equivalent.
  ///
  /// Uses algebraic equivalence (normalization + simplification).
  bool areEquivalent(Expression expr1, Expression expr2) {
    final simplified1 = simplify(expr1);
    final simplified2 = simplify(expr2);
    // Use normalizer for final structural check (handles commutativity etc)
    return _normalizer.normalize(simplified1) ==
        _normalizer.normalize(simplified2);
  }

  /// Solves a linear equation of the form ax + b = 0.
  Expression? solveLinear(Expression equation, String variable) {
    return _polynomialOps.solveLinear(equation, variable);
  }

  /// Solves a quadratic equation of the form ax^2 + bx + c = 0.
  List<Expression> solveQuadratic(Expression equation, String variable) {
    return _polynomialOps.solveQuadratic(equation, variable);
  }
}
