import '../ast.dart';
import 'assumptions.dart';
import 'step_trace.dart';

/// Categories for rewrite rules to control application strategy.
enum RuleCategory {
  normalization, // Canonical forms (e.g. sorting terms)
  simplification, // Reducing complexity (e.g. x + 0 -> x)
  expansion, // Increasing complexity (e.g. sin(2x) -> 2sin(x)cos(x))
  identity, // Mathematical identities
}

/// Abstract base class for all rewrite rules.
abstract class RewriteRule {
  /// Unique name for the rule.
  String get name;

  /// Category of the rule.
  RuleCategory get category;

  /// Priority of application (higher means earlier).
  int get priority => 0;

  /// Human-readable description for step trace output.
  ///
  /// Override this to provide a meaningful explanation of what the rule does.
  /// Default implementation uses the rule name.
  String get description => name;

  /// The step type for step tracing.
  ///
  /// Override this to categorize the rule appropriately.
  StepType get stepType {
    return switch (category) {
      RuleCategory.identity => StepType.identity,
      RuleCategory.simplification => StepType.simplification,
      RuleCategory.expansion => StepType.expansion,
      RuleCategory.normalization => StepType.normalization,
    };
  }

  /// Checks if the rule applies to the given expression.
  /// [assumptions] can be used to check domain constraints.
  bool matches(Expression expr, {Assumptions? assumptions});

  /// Applies the rule to the expression.
  /// Returns a new transformed expression.
  /// [assumptions] can be passed if transformation depends on them.
  Expression apply(Expression expr, {Assumptions? assumptions});
}
