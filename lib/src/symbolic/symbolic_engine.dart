import '../ast.dart';
import 'normalizer.dart';
import 'rule_engine.dart';
import 'rewrite_rule.dart';
import 'rules/all_rules.dart';
import 'polynomial_operations.dart';
import 'rational_simplifier.dart';
import 'step_trace.dart';

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

  /// Simplifies an expression with step-by-step trace.
  ///
  /// Returns a [TracedResult] containing both the simplified expression
  /// and a list of transformation steps.
  ///
  /// Example:
  /// ```dart
  /// final engine = SymbolicEngine();
  /// final result = engine.simplifyWithSteps(parse('x + 0'));
  /// print(result.formatSteps());
  /// // Step 1 [Identity] Additive identity: x + 0 = x
  /// //   x+0 → x
  /// ```
  TracedResult<Expression> simplifyWithSteps(Expression expr) {
    final tracer = StepTracer();

    // 1. Normalize first (canonical form)
    final normalized = _normalizer.normalize(expr);
    if (normalized != expr) {
      tracer.record(
        StepType.normalization,
        'Normalize to canonical form',
        expr,
        normalized,
      );
    }

    // 2. Apply simplification rules with tracing
    final ruleResult = _simplifyEngine.applyRulesWithSteps(
      normalized,
      assumptions: assumptions,
    );
    tracer.addStepsFrom(
        StepTracer().._steps.addAll(ruleResult.steps as Iterable<Step>));

    var result = ruleResult.result;

    // 3. specialized simplifications (Rational)
    final rationalResult = _rationalSimplifier.simplify(result);
    if (rationalResult != result) {
      tracer.record(
        StepType.simplification,
        'Simplify rational expression',
        result,
        rationalResult,
      );
      result = rationalResult;
    }

    // 4. Final normalization
    final finalResult = _normalizer.normalize(result);
    if (finalResult != result) {
      tracer.record(
        StepType.normalization,
        'Final normalization',
        result,
        finalResult,
      );
    }

    return tracer.complete(finalResult);
  }

  /// Expands trigonometric double/half-angle formulas and logs.
  Expression expandTrig(Expression expr) {
    var result = _normalizer.normalize(expr);
    return _expandEngine.applyRules(result, assumptions: assumptions);
  }

  /// Expands trigonometric expressions with step-by-step trace.
  TracedResult<Expression> expandTrigWithSteps(Expression expr) {
    final tracer = StepTracer();

    final normalized = _normalizer.normalize(expr);
    if (normalized != expr) {
      tracer.record(
        StepType.normalization,
        'Normalize to canonical form',
        expr,
        normalized,
      );
    }

    final result =
        _expandEngine.applyRulesWithSteps(normalized, assumptions: assumptions);
    tracer.addStepsFrom(
        StepTracer().._steps.addAll(result.steps as Iterable<Step>));

    return tracer.complete(result.result);
  }

  /// Expands a polynomial expression.
  Expression expand(Expression expr) {
    return _polynomialOps.expand(expr);
  }

  /// Expands a polynomial expression with step-by-step trace.
  ///
  /// Example:
  /// ```dart
  /// final engine = SymbolicEngine();
  /// final result = engine.expandWithSteps(parse('(x + 1)^2'));
  /// print(result.formatSteps());
  /// // Step 1 [Expansion] Binomial expansion: (a + b)^n
  /// //   (x+1)^{2} → x^{2}+2x+1
  /// ```
  TracedResult<Expression> expandWithSteps(Expression expr) {
    return _polynomialOps.expandWithSteps(expr);
  }

  /// Factors a polynomial expression.
  Expression factor(Expression expr) {
    return _polynomialOps.factor(expr);
  }

  /// Factors a polynomial expression with step-by-step trace.
  ///
  /// Example:
  /// ```dart
  /// final engine = SymbolicEngine();
  /// final result = engine.factorWithSteps(parse('x^2 - 1'));
  /// print(result.formatSteps());
  /// // Step 1 [Factorization] Difference of squares: a² - b² = (a-b)(a+b)
  /// //   x^{2}-1 → (x-1)(x+1)
  /// ```
  TracedResult<Expression> factorWithSteps(Expression expr) {
    return _polynomialOps.factorWithSteps(expr);
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

  /// Solves a quadratic equation with step-by-step trace.
  ///
  /// Shows the application of the quadratic formula.
  TracedResult<List<Expression>> solveQuadraticWithSteps(
      Expression equation, String variable) {
    return _polynomialOps.solveQuadraticWithSteps(equation, variable);
  }
}

// Private extension to allow adding steps directly
extension on StepTracer {
  // ignore: unused_element
  List<Step> get _steps {
    // Access via currentSteps since _steps is private
    return currentSteps.toList();
  }
}
