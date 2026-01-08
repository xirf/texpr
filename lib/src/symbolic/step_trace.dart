/// Step-by-step computation trace for symbolic operations.
library;

import '../ast.dart';

/// Types of symbolic transformation steps.
enum StepType {
  /// Identity rules (x + 0 = x, x * 1 = x)
  identity('Identity'),

  /// Simplification (x * x = x²)
  simplification('Simplification'),

  /// Constant folding (2 + 3 = 5)
  constantFolding('Constant Folding'),

  /// Differentiation rule (power rule, chain rule, etc.)
  differentiation('Differentiation'),

  /// Integration rule
  integration('Integration'),

  /// Polynomial expansion
  expansion('Expansion'),

  /// Factorization
  factorization('Factorization'),

  /// Algebraic normalization
  normalization('Normalization'),

  /// Trigonometric identity
  trigonometric('Trigonometric'),

  /// Logarithm law
  logarithmic('Logarithmic');

  /// Human-readable display name.
  final String displayName;

  const StepType(this.displayName);
}

/// A single step in a symbolic computation.
///
/// Records the transformation applied, including the expression
/// before and after the transformation.
class Step {
  /// Type of transformation applied.
  final StepType type;

  /// Human-readable description of the transformation.
  ///
  /// Example: "Power rule: d/dx(x^n) = n·x^(n-1)"
  final String description;

  /// Expression before the transformation.
  final Expression before;

  /// Expression after the transformation.
  final Expression after;

  /// Optional rule name for programmatic identification.
  ///
  /// Example: "power_rule", "sum_rule"
  final String? ruleName;

  /// Creates a step record.
  const Step({
    required this.type,
    required this.description,
    required this.before,
    required this.after,
    this.ruleName,
  });

  @override
  String toString() {
    return '[${type.displayName}] $description';
  }

  /// Formats this step with LaTeX expressions.
  String format({bool includeLatex = true}) {
    final buffer = StringBuffer();
    buffer.write('[${type.displayName}] $description');
    if (includeLatex) {
      buffer.write('\n  ${before.toLatex()} → ${after.toLatex()}');
    }
    return buffer.toString();
  }
}

/// A traced result containing both the final expression and transformation steps.
///
/// This allows users to see the step-by-step work that led to a result,
/// similar to "show your work" in mathematical problem solving.
class TracedResult<T> {
  /// The final result of the computation.
  final T result;

  /// Ordered list of steps taken to reach the result.
  final List<Step> steps;

  /// Creates a traced result.
  const TracedResult(this.result, this.steps);

  /// Creates a traced result with no steps (result was already in final form).
  const TracedResult.unchanged(this.result) : steps = const [];

  /// Total number of transformations applied.
  int get stepCount => steps.length;

  /// Whether any transformations were applied.
  bool get hasSteps => steps.isNotEmpty;

  /// Formats all steps as human-readable text.
  ///
  /// If [includeLatex] is true (default), includes the before/after
  /// LaTeX expressions for each step.
  ///
  /// Example output:
  /// ```
  /// Step 1 [Power Rule]: d/dx(x^n) = n·x^(n-1)
  ///   x^{3} → 3 \cdot x^{2}
  /// Step 2 [Simplify]: Combine constants
  ///   3 \cdot x^{2} → 3x^{2}
  /// ```
  String formatSteps({bool includeLatex = true, bool numbered = true}) {
    if (steps.isEmpty) {
      return 'No transformations applied.';
    }

    final buffer = StringBuffer();
    for (var i = 0; i < steps.length; i++) {
      if (numbered) {
        buffer.write('Step ${i + 1} ');
      }
      buffer.writeln(steps[i].format(includeLatex: includeLatex));
    }
    return buffer.toString().trimRight();
  }

  @override
  String toString() {
    if (result is Expression) {
      return 'TracedResult(${(result as Expression).toLatex()}, ${steps.length} steps)';
    }
    return 'TracedResult($result, ${steps.length} steps)';
  }
}

/// Context for recording steps during symbolic computation.
///
/// Create a [StepTracer] at the start of a traced operation and pass it
/// through the computation. Call [record] for each transformation, then
/// call [complete] to get the final [TracedResult].
///
/// Example:
/// ```dart
/// final tracer = StepTracer();
/// var expr = originalExpr;
///
/// // Apply transformation
/// final newExpr = applyRule(expr);
/// tracer.record(
///   StepType.simplification,
///   'Applied identity rule: x + 0 = x',
///   expr,
///   newExpr,
/// );
/// expr = newExpr;
///
/// return tracer.complete(expr);
/// ```
class StepTracer {
  final List<Step> _steps = [];

  /// Records a transformation step.
  ///
  /// [type] categorizes the kind of transformation.
  /// [description] explains what happened in human-readable form.
  /// [before] is the expression before transformation.
  /// [after] is the expression after transformation.
  /// [ruleName] is an optional identifier for the rule applied.
  void record(
    StepType type,
    String description,
    Expression before,
    Expression after, {
    String? ruleName,
  }) {
    // Only record if there was an actual change
    if (before != after) {
      _steps.add(Step(
        type: type,
        description: description,
        before: before,
        after: after,
        ruleName: ruleName,
      ));
    }
  }

  /// Records a step with a custom Step object.
  void recordStep(Step step) {
    if (step.before != step.after) {
      _steps.add(step);
    }
  }

  /// Returns the number of steps recorded so far.
  int get stepCount => _steps.length;

  /// Whether any steps have been recorded.
  bool get hasSteps => _steps.isNotEmpty;

  /// Gets a copy of the current steps (for inspection during computation).
  List<Step> get currentSteps => List.unmodifiable(_steps);

  /// Completes the trace and returns a [TracedResult].
  ///
  /// After calling this, the tracer should not be reused.
  TracedResult<T> complete<T>(T result) {
    return TracedResult(result, List.unmodifiable(_steps));
  }

  /// Adds all steps from another tracer (for composing traces).
  void addStepsFrom(StepTracer other) {
    _steps.addAll(other._steps);
  }
}
