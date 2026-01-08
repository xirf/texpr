import '../ast/expression.dart';
import '../ast/basic.dart';
import '../ast/operations.dart';
import '../ast/functions.dart';
import '../ast/calculus.dart';
import '../ast/logic.dart';
import '../ast/matrix.dart';
import '../ast/environment.dart';
import '../ast/visitor.dart';

/// Visitor that converts an AST to a JSON-serializable Map.
///
/// This enables debugging, external tooling integration, and
/// AST visualization.
///
/// ## Usage
///
/// ```dart
/// import 'dart:convert';
///
/// final evaluator = Texpr();
/// final expr = evaluator.parse(r'\frac{x^2 + 1}{2}');
/// final json = expr.toJson();
/// print(jsonEncode(json));
/// ```
///
/// ## Output Format
///
/// Each node is represented as a Map with:
/// - `type`: The node type name (e.g., "BinaryOp", "FunctionCall")
/// - Additional properties specific to each node type
///
/// Example output:
/// ```json
/// {
///   "type": "BinaryOp",
///   "operator": "divide",
///   "left": { "type": "BinaryOp", ... },
///   "right": { "type": "NumberLiteral", "value": 2 }
/// }
/// ```
class JsonAstVisitor implements ExpressionVisitor<Map<String, dynamic>, void> {
  const JsonAstVisitor();

  /// Converts an expression to JSON representation.
  Map<String, dynamic> convert(Expression expr) {
    return expr.accept(this, null);
  }

  @override
  Map<String, dynamic> visitNumberLiteral(NumberLiteral node, void context) {
    return {
      'type': 'NumberLiteral',
      'value': node.value,
    };
  }

  @override
  Map<String, dynamic> visitVariable(Variable node, void context) {
    return {
      'type': 'Variable',
      'name': node.name,
    };
  }

  @override
  Map<String, dynamic> visitBinaryOp(BinaryOp node, void context) {
    return {
      'type': 'BinaryOp',
      'operator': node.operator.name,
      'left': node.left.accept(this, context),
      'right': node.right.accept(this, context),
      if (node.sourceToken != null) 'sourceToken': node.sourceToken,
    };
  }

  @override
  Map<String, dynamic> visitUnaryOp(UnaryOp node, void context) {
    return {
      'type': 'UnaryOp',
      'operator': node.operator.name,
      'operand': node.operand.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitAbsoluteValue(AbsoluteValue node, void context) {
    return {
      'type': 'AbsoluteValue',
      'argument': node.argument.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitFunctionCall(FunctionCall node, void context) {
    return {
      'type': 'FunctionCall',
      'name': node.name,
      'args': node.args.map((a) => a.accept(this, context)).toList(),
      if (node.base != null) 'base': node.base!.accept(this, context),
      if (node.optionalParam != null)
        'optionalParam': node.optionalParam!.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitLimitExpr(LimitExpr node, void context) {
    return {
      'type': 'LimitExpr',
      'variable': node.variable,
      'target': node.target.accept(this, context),
      'body': node.body.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitSumExpr(SumExpr node, void context) {
    return {
      'type': 'SumExpr',
      'variable': node.variable,
      'start': node.start.accept(this, context),
      'end': node.end.accept(this, context),
      'body': node.body.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitProductExpr(ProductExpr node, void context) {
    return {
      'type': 'ProductExpr',
      'variable': node.variable,
      'start': node.start.accept(this, context),
      'end': node.end.accept(this, context),
      'body': node.body.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitIntegralExpr(IntegralExpr node, void context) {
    return {
      'type': 'IntegralExpr',
      'variable': node.variable,
      'body': node.body.accept(this, context),
      if (node.lower != null) 'lower': node.lower!.accept(this, context),
      if (node.upper != null) 'upper': node.upper!.accept(this, context),
      'isClosed': node.isClosed,
    };
  }

  @override
  Map<String, dynamic> visitMultiIntegralExpr(
      MultiIntegralExpr node, void context) {
    return {
      'type': 'MultiIntegralExpr',
      'order': node.order,
      'variables': node.variables,
      'body': node.body.accept(this, context),
      if (node.lower != null) 'lower': node.lower!.accept(this, context),
      if (node.upper != null) 'upper': node.upper!.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitDerivativeExpr(DerivativeExpr node, void context) {
    return {
      'type': 'DerivativeExpr',
      'variable': node.variable,
      'order': node.order,
      'body': node.body.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitPartialDerivativeExpr(
      PartialDerivativeExpr node, void context) {
    return {
      'type': 'PartialDerivativeExpr',
      'variable': node.variable,
      'order': node.order,
      'body': node.body.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitBinomExpr(BinomExpr node, void context) {
    return {
      'type': 'BinomExpr',
      'n': node.n.accept(this, context),
      'k': node.k.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitGradientExpr(GradientExpr node, void context) {
    return {
      'type': 'GradientExpr',
      'body': node.body.accept(this, context),
      if (node.variables != null) 'variables': node.variables,
    };
  }

  @override
  Map<String, dynamic> visitComparison(Comparison node, void context) {
    return {
      'type': 'Comparison',
      'operator': node.operator.name,
      'left': node.left.accept(this, context),
      'right': node.right.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitChainedComparison(
      ChainedComparison node, void context) {
    return {
      'type': 'ChainedComparison',
      'expressions':
          node.expressions.map((e) => e.accept(this, context)).toList(),
      'operators': node.operators.map((o) => o.name).toList(),
    };
  }

  @override
  Map<String, dynamic> visitConditionalExpr(
      ConditionalExpr node, void context) {
    return {
      'type': 'ConditionalExpr',
      'expression': node.expression.accept(this, context),
      'condition': node.condition.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitPiecewise(PiecewiseExpr node, void context) {
    return {
      'type': 'PiecewiseExpr',
      'cases': node.cases.map((c) {
        return {
          'expression': c.expression.accept(this, context),
          if (c.condition != null)
            'condition': c.condition!.accept(this, context),
        };
      }).toList(),
    };
  }

  @override
  Map<String, dynamic> visitMatrixExpr(MatrixExpr node, void context) {
    return {
      'type': 'MatrixExpr',
      'rows': node.rows
          .map((row) => row.map((e) => e.accept(this, context)).toList())
          .toList(),
    };
  }

  @override
  Map<String, dynamic> visitVectorExpr(VectorExpr node, void context) {
    return {
      'type': 'VectorExpr',
      'components':
          node.components.map((e) => e.accept(this, context)).toList(),
      'isUnitVector': node.isUnitVector,
    };
  }

  @override
  Map<String, dynamic> visitIntervalExpr(IntervalExpr node, void context) {
    return {
      'type': 'IntervalExpr',
      'lower': node.lower.accept(this, context),
      'upper': node.upper.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitAssignmentExpr(AssignmentExpr node, void context) {
    return {
      'type': 'AssignmentExpr',
      'variable': node.variable,
      'value': node.value.accept(this, context),
    };
  }

  @override
  Map<String, dynamic> visitFunctionDefinitionExpr(
      FunctionDefinitionExpr node, void context) {
    return {
      'type': 'FunctionDefinitionExpr',
      'name': node.name,
      'parameters': node.parameters,
      'body': node.body.accept(this, context),
    };
  }
}

/// Extension to add toJson() method to all Expression types.
extension JsonExport on Expression {
  /// Converts this expression to a JSON-serializable Map.
  ///
  /// This is useful for debugging, logging, and integration with
  /// external tools.
  ///
  /// ## Example
  ///
  /// ```dart
  /// import 'dart:convert';
  ///
  /// final expr = evaluator.parse(r'\sin{x} + 1');
  /// print(jsonEncode(expr.toJson()));
  /// // {"type":"BinaryOp","operator":"add",...}
  /// ```
  Map<String, dynamic> toJson() {
    const visitor = JsonAstVisitor();
    return accept(visitor, null);
  }
}
