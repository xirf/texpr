import '../ast/expression.dart';
import '../ast/basic.dart';
import '../ast/operations.dart';
import '../ast/functions.dart';
import '../ast/calculus.dart';
import '../ast/logic.dart';
import '../ast/matrix.dart';
import '../ast/visitor.dart';

/// Visitor that converts an AST to MathML presentation markup.
///
/// MathML is an XML-based format for displaying mathematical notation
/// in web browsers. This visitor generates presentation MathML that
/// describes how expressions should be visually rendered.
///
/// ## Usage
///
/// ```dart
/// final evaluator = LatexMathEvaluator();
/// final expr = evaluator.parse(r'\frac{x^2 + 1}{2}');
/// final mathml = expr.toMathML();
/// // Returns: <math xmlns="..."><mfrac>...</mfrac></math>
/// ```
///
/// ## Output Format
///
/// The output is valid MathML presentation markup that can be embedded
/// in HTML5 documents or XHTML.
class MathMLVisitor implements ExpressionVisitor<String, void> {
  /// Whether to wrap output in &lt;math&gt; element with namespace.
  final bool includeWrapper;

  const MathMLVisitor({this.includeWrapper = true});

  /// Converts an expression to MathML representation.
  String convert(Expression expr) {
    final content = expr.accept(this, null);
    if (includeWrapper) {
      return '<math xmlns="http://www.w3.org/1998/Math/MathML">$content</math>';
    }
    return content;
  }

  /// Wraps content in mrow if it contains multiple elements.
  String _mrow(String content) => '<mrow>$content</mrow>';

  /// Creates an identifier element.
  String _mi(String text) => '<mi>$text</mi>';

  /// Creates a number element.
  String _mn(String text) => '<mn>$text</mn>';

  /// Creates an operator element with XML escaping.
  String _mo(String text) {
    // Escape XML special characters
    final escaped = text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
    return '<mo>$escaped</mo>';
  }

  @override
  String visitNumberLiteral(NumberLiteral node, void context) {
    if (node.value.isInfinite) {
      return _mi(node.value.isNegative ? '-∞' : '∞');
    }
    if (node.value.isNaN) {
      return _mi('NaN');
    }
    // Format nicely
    if (node.value == node.value.toInt()) {
      return _mn(node.value.toInt().toString());
    }
    return _mn(node.value.toString());
  }

  @override
  String visitVariable(Variable node, void context) {
    // Handle Greek letters
    final greekMap = {
      'alpha': 'α',
      'beta': 'β',
      'gamma': 'γ',
      'delta': 'δ',
      'epsilon': 'ε',
      'zeta': 'ζ',
      'eta': 'η',
      'theta': 'θ',
      'iota': 'ι',
      'kappa': 'κ',
      'lambda': 'λ',
      'mu': 'μ',
      'nu': 'ν',
      'xi': 'ξ',
      'omicron': 'ο',
      'pi': 'π',
      'rho': 'ρ',
      'sigma': 'σ',
      'tau': 'τ',
      'upsilon': 'υ',
      'phi': 'φ',
      'chi': 'χ',
      'psi': 'ψ',
      'omega': 'ω',
      'Gamma': 'Γ',
      'Delta': 'Δ',
      'Theta': 'Θ',
      'Lambda': 'Λ',
      'Xi': 'Ξ',
      'Pi': 'Π',
      'Sigma': 'Σ',
      'Upsilon': 'Υ',
      'Phi': 'Φ',
      'Psi': 'Ψ',
      'Omega': 'Ω',
    };

    final symbol = greekMap[node.name] ?? node.name;
    return _mi(symbol);
  }

  @override
  String visitBinaryOp(BinaryOp node, void context) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);

    switch (node.operator) {
      case BinaryOperator.add:
        return _mrow('$left${_mo("+")}$right');
      case BinaryOperator.subtract:
        return _mrow('$left${_mo("−")}$right');
      case BinaryOperator.multiply:
        return _mrow('$left${_mo("⋅")}$right');
      case BinaryOperator.divide:
        return '<mfrac>$left$right</mfrac>';
      case BinaryOperator.power:
        return '<msup>$left$right</msup>';
    }
  }

  @override
  String visitUnaryOp(UnaryOp node, void context) {
    final operand = node.operand.accept(this, context);
    switch (node.operator) {
      case UnaryOperator.negate:
        return _mrow('${_mo("-")}$operand');
    }
  }

  @override
  String visitAbsoluteValue(AbsoluteValue node, void context) {
    final arg = node.argument.accept(this, context);
    return _mrow('${_mo("|")}$arg${_mo("|")}');
  }

  @override
  String visitFunctionCall(FunctionCall node, void context) {
    final arg = node.argument.accept(this, context);

    // Special handling for sqrt
    if (node.name == 'sqrt') {
      if (node.optionalParam != null) {
        final index = node.optionalParam!.accept(this, context);
        return '<mroot>$arg$index</mroot>';
      }
      return '<msqrt>$arg</msqrt>';
    }

    // Logarithm with base
    if ((node.name == 'log' || node.name == 'lg') && node.base != null) {
      final base = node.base!.accept(this, context);
      return _mrow('<msub>${_mi("log")}$base</msub>${_mo("⁡")}$arg');
    }

    // Standard function: sin, cos, tan, etc.
    return _mrow('${_mi(node.name)}${_mo("⁡")}$arg');
  }

  @override
  String visitLimitExpr(LimitExpr node, void context) {
    final target = node.target.accept(this, context);
    final body = node.body.accept(this, context);

    return _mrow('<munder>${_mo("lim")}'
        '${_mrow("${_mi(node.variable)}${_mo("to")}$target")}'
        '</munder>$body');
  }

  @override
  String visitSumExpr(SumExpr node, void context) {
    final start = node.start.accept(this, context);
    final end = node.end.accept(this, context);
    final body = node.body.accept(this, context);

    return _mrow('<munderover>${_mo("∑")}'
        '${_mrow("${_mi(node.variable)}${_mo("=")}$start")}'
        '$end</munderover>$body');
  }

  @override
  String visitProductExpr(ProductExpr node, void context) {
    final start = node.start.accept(this, context);
    final end = node.end.accept(this, context);
    final body = node.body.accept(this, context);

    return _mrow('<munderover>${_mo("∏")}'
        '${_mrow("${_mi(node.variable)}${_mo("=")}$start")}'
        '$end</munderover>$body');
  }

  @override
  String visitIntegralExpr(IntegralExpr node, void context) {
    final body = node.body.accept(this, context);
    final symbol = node.isClosed ? '∮' : '∫';

    String integral;
    if (node.lower != null && node.upper != null) {
      final lower = node.lower!.accept(this, context);
      final upper = node.upper!.accept(this, context);
      integral = '<msubsup>${_mo(symbol)}$lower$upper</msubsup>';
    } else if (node.lower != null) {
      final lower = node.lower!.accept(this, context);
      integral = '<msub>${_mo(symbol)}$lower</msub>';
    } else {
      integral = _mo(symbol);
    }

    return _mrow('$integral$body${_mi("d")}${_mi(node.variable)}');
  }

  @override
  String visitMultiIntegralExpr(MultiIntegralExpr node, void context) {
    final body = node.body.accept(this, context);
    final symbol = node.order == 2 ? '∬' : '∭';

    String integral;
    if (node.lower != null && node.upper != null) {
      final lower = node.lower!.accept(this, context);
      final upper = node.upper!.accept(this, context);
      integral = '<msubsup>${_mo(symbol)}$lower$upper</msubsup>';
    } else if (node.lower != null) {
      final lower = node.lower!.accept(this, context);
      integral = '<msub>${_mo(symbol)}$lower</msub>';
    } else {
      integral = _mo(symbol);
    }

    final vars = node.variables.map((v) => '${_mi("d")}${_mi(v)}').join();
    return _mrow('$integral$body$vars');
  }

  @override
  String visitDerivativeExpr(DerivativeExpr node, void context) {
    final body = node.body.accept(this, context);

    if (node.order == 1) {
      return _mrow('<mfrac>${_mi("d")}'
          '${_mrow("${_mi("d")}${_mi(node.variable)}")}'
          '</mfrac>$body');
    }

    return _mrow('<mfrac><msup>${_mi("d")}${_mn(node.order.toString())}</msup>'
        '${_mrow("<msup>${_mi("d")}${_mi(node.variable)}</msup>${_mn(node.order.toString())}")}'
        '</mfrac>$body');
  }

  @override
  String visitPartialDerivativeExpr(PartialDerivativeExpr node, void context) {
    final body = node.body.accept(this, context);

    if (node.order == 1) {
      return _mrow('<mfrac>${_mo("∂")}'
          '${_mrow("${_mo("∂")}${_mi(node.variable)}")}'
          '</mfrac>$body');
    }

    return _mrow('<mfrac><msup>${_mo("∂")}${_mn(node.order.toString())}</msup>'
        '${_mrow("<msup>${_mo("∂")}${_mi(node.variable)}</msup>${_mn(node.order.toString())}")}'
        '</mfrac>$body');
  }

  @override
  String visitBinomExpr(BinomExpr node, void context) {
    final n = node.n.accept(this, context);
    final k = node.k.accept(this, context);

    return _mrow('${_mo("(")}'
        '<mfrac linethickness="0">$n$k</mfrac>'
        '${_mo(")")}');
  }

  @override
  String visitComparison(Comparison node, void context) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);

    final op = switch (node.operator) {
      ComparisonOperator.less => '<',
      ComparisonOperator.greater => '>',
      ComparisonOperator.lessEqual => '≤',
      ComparisonOperator.greaterEqual => '≥',
      ComparisonOperator.equal => '=',
      ComparisonOperator.member => '∈',
    };

    return _mrow('$left${_mo(op)}$right');
  }

  @override
  String visitChainedComparison(ChainedComparison node, void context) {
    final buffer = StringBuffer();
    for (int i = 0; i < node.expressions.length; i++) {
      buffer.write(node.expressions[i].accept(this, context));
      if (i < node.operators.length) {
        final op = switch (node.operators[i]) {
          ComparisonOperator.less => '<',
          ComparisonOperator.greater => '>',
          ComparisonOperator.lessEqual => '≤',
          ComparisonOperator.greaterEqual => '≥',
          ComparisonOperator.equal => '=',
          ComparisonOperator.member => '∈',
        };
        buffer.write(_mo(op));
      }
    }
    return _mrow(buffer.toString());
  }

  @override
  String visitConditionalExpr(ConditionalExpr node, void context) {
    final expr = node.expression.accept(this, context);
    final cond = node.condition.accept(this, context);

    return _mrow('$expr${_mo(",")}${_mrow("${_mi("where")}$cond")}');
  }

  @override
  String visitPiecewise(PiecewiseExpr node, void context) {
    final rows = node.cases.map((c) {
      final expr = c.expression.accept(this, context);
      final cond = c.condition?.accept(this, context) ?? _mi('otherwise');
      return '<mtr><mtd>$expr</mtd><mtd>${_mi("if")}$cond</mtd></mtr>';
    }).join();

    return _mrow('${_mo("{")}' '<mtable>$rows</mtable>');
  }

  @override
  String visitMatrixExpr(MatrixExpr node, void context) {
    final rows = node.rows.map((row) {
      final cells =
          row.map((e) => '<mtd>${e.accept(this, context)}</mtd>').join();
      return '<mtr>$cells</mtr>';
    }).join();

    return _mrow('${_mo("[")}' '<mtable>$rows</mtable>' '${_mo("]")}');
  }

  @override
  String visitVectorExpr(VectorExpr node, void context) {
    final components =
        node.components.map((c) => c.accept(this, context)).join(_mo(','));

    if (node.isUnitVector) {
      return '<mover>${_mrow(components)}${_mo("^")}</mover>';
    }
    return '<mover>${_mrow(components)}${_mo("to")}</mover>';
  }
}

/// Extension to add toMathML() method to all Expression types.
extension MathMLExport on Expression {
  /// Converts this expression to MathML presentation markup.
  ///
  /// MathML can be embedded directly in HTML5 for rendering in browsers.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final expr = evaluator.parse(r'\sin{x} + 1');
  /// final mathml = expr.toMathML();
  /// // <math xmlns="..."><mrow><mi>sin</mi>...</mrow></math>
  /// ```
  ///
  /// ## Parameters
  ///
  /// [includeWrapper] - Whether to wrap output in `<math>` element (default: true).
  String toMathML({bool includeWrapper = true}) {
    final visitor = MathMLVisitor(includeWrapper: includeWrapper);
    return visitor.convert(this);
  }
}
