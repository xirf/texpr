import 'basic.dart';
import 'calculus.dart';
import 'environment.dart';
import 'expression.dart';
import 'functions.dart';
import 'logic.dart';
import 'matrix.dart';
import 'operations.dart';
import 'visitor.dart';

const Set<String> _knownConstants = {
  'pi',
  'π',
  'e',
  'i',
  'phi',
  'φ',
  'tau',
  'τ',
  'infty',
  '∞',
};

final Expando<EvaluabilityInfo> _compileTimeEvaluability =
    Expando<EvaluabilityInfo>('compileTimeEvaluability');

/// Describes whether an expression can be numerically evaluated.
///
/// This enum makes the distinction between "can parse" and "can evaluate"
/// explicit in the type system. As the parsed surface area grows (tensors,
/// quantifiers, set notation), the gap between parsing and evaluation
/// becomes a usability hazard. Explicit evaluability prevents false expectations.
///
/// Example:
/// ```dart
/// final expr = parser.parse(r'\nabla f');
/// final evaluability = expr.getEvaluability();
/// if (evaluability == Evaluability.symbolic) {
///   print('This expression is symbolic-only');
/// }
/// ```
enum Evaluability {
  /// Expression can be fully evaluated to a numeric/complex/matrix result.
  ///
  /// Examples: `2 + 3`, `\sin{\pi}`, `\sum_{i=1}^{10} i`
  numeric,

  /// Expression is symbolic-only and cannot produce a numeric result.
  ///
  /// Examples: `\nabla f`, `R_{\mu\nu}` (tensor notation), `\frac{\partial}{\partial x} f`
  symbolic,

  /// Expression cannot be evaluated due to missing context or undefined variables.
  ///
  /// Examples: `x + 1` without `x` defined, undefined function calls
  unevaluable,
}

/// Compile-time evaluability metadata attached to AST nodes.
///
/// [evaluability] captures structural evaluability at parse time:
/// - [Evaluability.symbolic] for symbolic-only forms
/// - [Evaluability.numeric] when no unresolved variables remain
/// - [Evaluability.unevaluable] when free variables must be supplied
///
/// [freeVariables] stores unresolved symbols required for numeric evaluation.
class EvaluabilityInfo {
  final Evaluability evaluability;
  final Set<String> freeVariables;

  const EvaluabilityInfo(this.evaluability, [Set<String> freeVariables = const {}])
      : freeVariables = freeVariables;

  Evaluability resolve([Set<String>? knownVariables]) {
    if (evaluability == Evaluability.symbolic) {
      return Evaluability.symbolic;
    }
    if (freeVariables.isEmpty) {
      return Evaluability.numeric;
    }
    if (knownVariables == null) {
      return Evaluability.unevaluable;
    }
    final hasAll = freeVariables.every(knownVariables.contains);
    return hasAll ? Evaluability.numeric : Evaluability.unevaluable;
  }
}

/// Annotates an AST with compile-time evaluability metadata.
///
/// This runs once after parsing and stores node-level metadata in an [Expando],
/// avoiding API-breaking changes to expression node classes.
void annotateCompileTimeEvaluability(Expression expression) {
  const visitor = CompileTimeEvaluabilityVisitor();
  expression.accept(visitor, <String>{});
}

/// Visitor that computes compile-time evaluability and free variables.
///
/// The result is attached to every visited node.
class CompileTimeEvaluabilityVisitor
    implements ExpressionVisitor<EvaluabilityInfo, Set<String>> {
  const CompileTimeEvaluabilityVisitor();

  EvaluabilityInfo _record(Expression node, EvaluabilityInfo info) {
    final frozen = Set<String>.unmodifiable(info.freeVariables);
    final value = EvaluabilityInfo(info.evaluability, frozen);
    _compileTimeEvaluability[node] = value;
    return value;
  }

  EvaluabilityInfo _combine(Expression node, List<EvaluabilityInfo> children) {
    final freeVariables = <String>{};
    for (final child in children) {
      freeVariables.addAll(child.freeVariables);
    }

    final evaluability = children.any((e) => e.evaluability == Evaluability.symbolic)
        ? Evaluability.symbolic
        : children.any((e) => e.evaluability == Evaluability.unevaluable)
            ? Evaluability.unevaluable
            : Evaluability.numeric;

    return _record(node, EvaluabilityInfo(evaluability, freeVariables));
  }

  @override
  EvaluabilityInfo visitNumberLiteral(NumberLiteral node, Set<String>? context) {
    return _record(node, const EvaluabilityInfo(Evaluability.numeric));
  }

  @override
  EvaluabilityInfo visitVariable(Variable node, Set<String>? context) {
    if ((context?.contains(node.name) ?? false) ||
        _knownConstants.contains(node.name)) {
      return _record(node, const EvaluabilityInfo(Evaluability.numeric));
    }
    return _record(node, EvaluabilityInfo(Evaluability.unevaluable, {node.name}));
  }

  @override
  EvaluabilityInfo visitBinaryOp(BinaryOp node, Set<String>? context) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);
    return _combine(node, [left, right]);
  }

  @override
  EvaluabilityInfo visitUnaryOp(UnaryOp node, Set<String>? context) {
    final operand = node.operand.accept(this, context);
    return _combine(node, [operand]);
  }

  @override
  EvaluabilityInfo visitFunctionCall(FunctionCall node, Set<String>? context) {
    final children = <EvaluabilityInfo>[];
    for (final arg in node.args) {
      children.add(arg.accept(this, context));
    }
    if (node.base != null) {
      children.add(node.base!.accept(this, context));
    }
    if (node.optionalParam != null) {
      children.add(node.optionalParam!.accept(this, context));
    }
    return _combine(node, children);
  }

  @override
  EvaluabilityInfo visitAbsoluteValue(AbsoluteValue node, Set<String>? context) {
    final argument = node.argument.accept(this, context);
    return _combine(node, [argument]);
  }

  @override
  EvaluabilityInfo visitLimitExpr(LimitExpr node, Set<String>? context) {
    final target = node.target.accept(this, context);
    final extendedContext = {...?context, node.variable};
    final body = node.body.accept(this, extendedContext);
    return _combine(node, [target, body]);
  }

  @override
  EvaluabilityInfo visitSumExpr(SumExpr node, Set<String>? context) {
    final start = node.start.accept(this, context);
    final end = node.end.accept(this, context);
    final extendedContext = {...?context, node.variable};
    final body = node.body.accept(this, extendedContext);
    return _combine(node, [start, end, body]);
  }

  @override
  EvaluabilityInfo visitProductExpr(ProductExpr node, Set<String>? context) {
    final start = node.start.accept(this, context);
    final end = node.end.accept(this, context);
    final extendedContext = {...?context, node.variable};
    final body = node.body.accept(this, extendedContext);
    return _combine(node, [start, end, body]);
  }

  @override
  EvaluabilityInfo visitIntegralExpr(IntegralExpr node, Set<String>? context) {
    final extendedContext = {...?context, node.variable};

    if (node.lower != null && node.upper != null) {
      final lower = node.lower!.accept(this, context);
      final upper = node.upper!.accept(this, context);
      final body = node.body.accept(this, extendedContext);
      return _combine(node, [lower, upper, body]);
    }

    final body = node.body.accept(this, extendedContext);
    return _record(node,
        EvaluabilityInfo(Evaluability.symbolic, Set<String>.from(body.freeVariables)));
  }

  @override
  EvaluabilityInfo visitMultiIntegralExpr(
      MultiIntegralExpr node, Set<String>? context) {
    final extendedContext = {...?context, ...node.variables};
    final body = node.body.accept(this, extendedContext);
    return _record(node,
        EvaluabilityInfo(Evaluability.symbolic, Set<String>.from(body.freeVariables)));
  }

  @override
  EvaluabilityInfo visitDerivativeExpr(DerivativeExpr node, Set<String>? context) {
    final extendedContext = {...?context, node.variable};
    final body = node.body.accept(this, extendedContext);
    return _combine(node, [body]);
  }

  @override
  EvaluabilityInfo visitPartialDerivativeExpr(
      PartialDerivativeExpr node, Set<String>? context) {
    final extendedContext = {...?context, node.variable};
    final body = node.body.accept(this, extendedContext);
    if (node.body is Variable) {
      return _record(node,
          EvaluabilityInfo(Evaluability.symbolic, Set<String>.from(body.freeVariables)));
    }
    return _combine(node, [body]);
  }

  @override
  EvaluabilityInfo visitBinomExpr(BinomExpr node, Set<String>? context) {
    final n = node.n.accept(this, context);
    final k = node.k.accept(this, context);
    return _combine(node, [n, k]);
  }

  @override
  EvaluabilityInfo visitGradientExpr(GradientExpr node, Set<String>? context) {
    final body = node.body.accept(this, context);
    if (node.body is Variable) {
      return _record(node,
          EvaluabilityInfo(Evaluability.symbolic, Set<String>.from(body.freeVariables)));
    }
    return _combine(node, [body]);
  }

  @override
  EvaluabilityInfo visitComparison(Comparison node, Set<String>? context) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);
    return _combine(node, [left, right]);
  }

  @override
  EvaluabilityInfo visitChainedComparison(
      ChainedComparison node, Set<String>? context) {
    final children =
        node.expressions.map((expression) => expression.accept(this, context)).toList();
    return _combine(node, children);
  }

  @override
  EvaluabilityInfo visitConditionalExpr(
      ConditionalExpr node, Set<String>? context) {
    final expression = node.expression.accept(this, context);
    final condition = node.condition.accept(this, context);
    return _combine(node, [expression, condition]);
  }

  @override
  EvaluabilityInfo visitPiecewise(PiecewiseExpr node, Set<String>? context) {
    final children = <EvaluabilityInfo>[];
    for (final currentCase in node.cases) {
      children.add(currentCase.expression.accept(this, context));
      if (currentCase.condition != null) {
        children.add(currentCase.condition!.accept(this, context));
      }
    }
    return _combine(node, children);
  }

  @override
  EvaluabilityInfo visitBooleanBinaryExpr(
      BooleanBinaryExpr node, Set<String>? context) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);
    return _combine(node, [left, right]);
  }

  @override
  EvaluabilityInfo visitBooleanUnaryExpr(
      BooleanUnaryExpr node, Set<String>? context) {
    final operand = node.operand.accept(this, context);
    return _combine(node, [operand]);
  }

  @override
  EvaluabilityInfo visitMatrixExpr(MatrixExpr node, Set<String>? context) {
    final children = <EvaluabilityInfo>[];
    for (final row in node.rows) {
      for (final cell in row) {
        children.add(cell.accept(this, context));
      }
    }
    return _combine(node, children);
  }

  @override
  EvaluabilityInfo visitVectorExpr(VectorExpr node, Set<String>? context) {
    final children = node.components.map((component) => component.accept(this, context)).toList();
    return _combine(node, children);
  }

  @override
  EvaluabilityInfo visitIntervalExpr(IntervalExpr node, Set<String>? context) {
    final lower = node.lower.accept(this, context);
    final upper = node.upper.accept(this, context);
    return _combine(node, [lower, upper]);
  }

  @override
  EvaluabilityInfo visitAssignmentExpr(AssignmentExpr node, Set<String>? context) {
    final value = node.value.accept(this, context);
    return _combine(node, [value]);
  }

  @override
  EvaluabilityInfo visitFunctionDefinitionExpr(
      FunctionDefinitionExpr node, Set<String>? context) {
    final extendedContext = {...?context, ...node.parameters};
    final body = node.body.accept(this, extendedContext);
    return _combine(node, [body]);
  }
}

/// Visitor that determines the evaluability of an expression.
///
/// This visitor traverses the AST and computes whether each node can be
/// evaluated numerically. The evaluability of composite expressions depends
/// on their children:
/// - All children numeric → numeric
/// - Any child symbolic → symbolic
/// - Any child unevaluable (and none symbolic) → unevaluable
class EvaluabilityVisitor
    implements ExpressionVisitor<Evaluability, Set<String>> {
  const EvaluabilityVisitor();

  /// Combines multiple child evaluabilities into a single result.
  ///
  /// Uses the "worst case" rule:
  /// - symbolic > unevaluable > numeric
  Evaluability _combine(List<Evaluability> children) {
    if (children.any((e) => e == Evaluability.symbolic)) {
      return Evaluability.symbolic;
    }
    if (children.any((e) => e == Evaluability.unevaluable)) {
      return Evaluability.unevaluable;
    }
    return Evaluability.numeric;
  }

  @override
  Evaluability visitNumberLiteral(NumberLiteral node, Set<String>? context) {
    return Evaluability.numeric;
  }

  @override
  Evaluability visitVariable(Variable node, Set<String>? context) {
    // Check if variable is defined in context
    if (context != null && context.contains(node.name)) {
      return Evaluability.numeric;
    }
    // Check for known constants
    if (_knownConstants.contains(node.name)) {
      return Evaluability.numeric;
    }
    return Evaluability.unevaluable;
  }

  @override
  Evaluability visitBinaryOp(BinaryOp node, Set<String>? context) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);
    return _combine([left, right]);
  }

  @override
  Evaluability visitUnaryOp(UnaryOp node, Set<String>? context) {
    return node.operand.accept(this, context);
  }

  @override
  Evaluability visitFunctionCall(FunctionCall node, Set<String>? context) {
    final argEvaluabilities = node.args.map((a) => a.accept(this, context));
    final baseEval = node.base?.accept(this, context);
    final optParamEval = node.optionalParam?.accept(this, context);

    final all = [
      ...argEvaluabilities,
      if (baseEval != null) baseEval,
      if (optParamEval != null) optParamEval,
    ];

    return _combine(all);
  }

  @override
  Evaluability visitAbsoluteValue(AbsoluteValue node, Set<String>? context) {
    return node.argument.accept(this, context);
  }

  @override
  Evaluability visitLimitExpr(LimitExpr node, Set<String>? context) {
    // Limit introduces a bound variable
    final extendedContext = {...?context, node.variable};
    final targetEval = node.target.accept(this, context);
    final bodyEval = node.body.accept(this, extendedContext);
    return _combine([targetEval, bodyEval]);
  }

  @override
  Evaluability visitSumExpr(SumExpr node, Set<String>? context) {
    final extendedContext = {...?context, node.variable};
    final startEval = node.start.accept(this, context);
    final endEval = node.end.accept(this, context);
    final bodyEval = node.body.accept(this, extendedContext);
    return _combine([startEval, endEval, bodyEval]);
  }

  @override
  Evaluability visitProductExpr(ProductExpr node, Set<String>? context) {
    final extendedContext = {...?context, node.variable};
    final startEval = node.start.accept(this, context);
    final endEval = node.end.accept(this, context);
    final bodyEval = node.body.accept(this, extendedContext);
    return _combine([startEval, endEval, bodyEval]);
  }

  @override
  Evaluability visitIntegralExpr(IntegralExpr node, Set<String>? context) {
    final extendedContext = {...?context, node.variable};

    // Definite integrals with bounds can be evaluated numerically
    if (node.lower != null && node.upper != null) {
      final lowerEval = node.lower!.accept(this, context);
      final upperEval = node.upper!.accept(this, context);
      final bodyEval = node.body.accept(this, extendedContext);
      return _combine([lowerEval, upperEval, bodyEval]);
    }

    // Indefinite integrals are symbolic
    return Evaluability.symbolic;
  }

  @override
  Evaluability visitMultiIntegralExpr(
      MultiIntegralExpr node, Set<String>? context) {
    // Multi-integrals are always symbolic (line/surface integrals)
    return Evaluability.symbolic;
  }

  @override
  Evaluability visitDerivativeExpr(DerivativeExpr node, Set<String>? context) {
    // Derivatives are computed symbolically first, then can be evaluated
    final extendedContext = {...?context, node.variable};
    return node.body.accept(this, extendedContext);
  }

  @override
  Evaluability visitPartialDerivativeExpr(
      PartialDerivativeExpr node, Set<String>? context) {
    // Partial derivatives with bare symbols (∂f/∂x where f is just a symbol)
    // are symbolic. With concrete bodies, they can be evaluated.
    if (node.body is Variable) {
      // Just a symbol like "f" - purely symbolic
      return Evaluability.symbolic;
    }
    final extendedContext = {...?context, node.variable};
    return node.body.accept(this, extendedContext);
  }

  @override
  Evaluability visitBinomExpr(BinomExpr node, Set<String>? context) {
    final nEval = node.n.accept(this, context);
    final kEval = node.k.accept(this, context);
    return _combine([nEval, kEval]);
  }

  @override
  Evaluability visitGradientExpr(GradientExpr node, Set<String>? context) {
    // Gradient of a bare symbol is symbolic
    if (node.body is Variable) {
      return Evaluability.symbolic;
    }
    // Gradient of a concrete expression can be evaluated
    return node.body.accept(this, context);
  }

  @override
  Evaluability visitComparison(Comparison node, Set<String>? context) {
    final leftEval = node.left.accept(this, context);
    final rightEval = node.right.accept(this, context);
    return _combine([leftEval, rightEval]);
  }

  @override
  Evaluability visitChainedComparison(
      ChainedComparison node, Set<String>? context) {
    final evals = node.expressions.map((e) => e.accept(this, context));
    return _combine(evals.toList());
  }

  @override
  Evaluability visitConditionalExpr(
      ConditionalExpr node, Set<String>? context) {
    final exprEval = node.expression.accept(this, context);
    final condEval = node.condition.accept(this, context);
    return _combine([exprEval, condEval]);
  }

  @override
  Evaluability visitPiecewise(PiecewiseExpr node, Set<String>? context) {
    final evals = <Evaluability>[];
    for (final c in node.cases) {
      evals.add(c.expression.accept(this, context));
      if (c.condition != null) {
        evals.add(c.condition!.accept(this, context));
      }
    }
    return _combine(evals);
  }

  @override
  Evaluability visitBooleanBinaryExpr(
      BooleanBinaryExpr node, Set<String>? context) {
    final leftEval = node.left.accept(this, context);
    final rightEval = node.right.accept(this, context);
    return _combine([leftEval, rightEval]);
  }

  @override
  Evaluability visitBooleanUnaryExpr(
      BooleanUnaryExpr node, Set<String>? context) {
    return node.operand.accept(this, context);
  }

  @override
  Evaluability visitMatrixExpr(MatrixExpr node, Set<String>? context) {
    final evals = <Evaluability>[];
    for (final row in node.rows) {
      for (final cell in row) {
        evals.add(cell.accept(this, context));
      }
    }
    return _combine(evals);
  }

  @override
  Evaluability visitVectorExpr(VectorExpr node, Set<String>? context) {
    final evals = node.components.map((e) => e.accept(this, context));
    return _combine(evals.toList());
  }

  @override
  Evaluability visitIntervalExpr(IntervalExpr node, Set<String>? context) {
    final lowerEval = node.lower.accept(this, context);
    final upperEval = node.upper.accept(this, context);
    return _combine([lowerEval, upperEval]);
  }

  @override
  Evaluability visitAssignmentExpr(AssignmentExpr node, Set<String>? context) {
    // Assignment can be evaluated if the value can be evaluated
    return node.value.accept(this, context);
  }

  @override
  Evaluability visitFunctionDefinitionExpr(
      FunctionDefinitionExpr node, Set<String>? context) {
    // Function definitions are always evaluable (they define a function)
    // The body is checked with parameters in context
    final extendedContext = {...?context, ...node.parameters};
    return node.body.accept(this, extendedContext);
  }
}

/// Extension to add evaluability checking to Expression.
extension ExpressionEvaluability on Expression {
  /// Gets compile-time evaluability metadata attached during parsing.
  ///
  /// Returns `null` for expression trees that were not annotated
  /// (for example, manually constructed ASTs).
  EvaluabilityInfo? get compileTimeEvaluabilityInfo =>
      _compileTimeEvaluability[this];

  /// Determines the evaluability of this expression.
  ///
  /// [knownVariables] is an optional set of variable names that are defined
  /// in the evaluation context. Variables not in this set are considered
  /// unevaluable.
  ///
  /// Example:
  /// ```dart
  /// final expr = parser.parse('x + 1');
  ///
  /// // Without context - x is undefined
  /// expr.getEvaluability(); // Evaluability.unevaluable
  ///
  /// // With x defined
  /// expr.getEvaluability({'x'}); // Evaluability.numeric
  /// ```
  Evaluability getEvaluability([Set<String>? knownVariables]) {
    final compileTimeInfo = _compileTimeEvaluability[this];
    if (compileTimeInfo != null) {
      return compileTimeInfo.resolve(knownVariables);
    }

    const visitor = EvaluabilityVisitor();
    return accept(visitor, knownVariables);
  }
}
