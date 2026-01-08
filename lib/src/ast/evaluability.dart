import 'basic.dart';
import 'calculus.dart';
import 'environment.dart';
import 'expression.dart';
import 'functions.dart';
import 'logic.dart';
import 'matrix.dart';
import 'operations.dart';
import 'visitor.dart';

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
    const knownConstants = {
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
    if (knownConstants.contains(node.name)) {
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
    const visitor = EvaluabilityVisitor();
    return accept(visitor, knownVariables);
  }
}
