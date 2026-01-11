import '../ast/expression.dart';
import '../ast/basic.dart';
import '../ast/operations.dart';
import '../ast/functions.dart';
import '../ast/calculus.dart';
import '../ast/logic.dart';
import '../ast/matrix.dart';
import '../ast/environment.dart';
import '../ast/visitor.dart';

/// Visitor that converts an AST to SymPy (Python) code.
///
/// SymPy is the most popular Python library for symbolic mathematics.
/// This visitor generates valid Python code that can be executed
/// with SymPy to perform symbolic computation.
///
/// ## Usage
///
/// ```dart
/// final evaluator = Texpr();
/// final expr = evaluator.parse(r'\frac{x^2 + 1}{2}');
/// final sympy = expr.toSymPy();
/// // Returns: (x**2 + 1)/2
/// ```
///
/// ## With Variables
///
/// ```dart
/// final code = expr.toSymPyScript(variables: ['x', 'y']);
/// // Returns complete Python script:
/// // from sympy import *
/// // x, y = symbols('x y')
/// // expr = (x**2 + 1)/2
/// ```
class SymPyVisitor implements ExpressionVisitor<String, void> {
  const SymPyVisitor();

  /// Converts an expression to SymPy code.
  String convert(Expression expr) {
    return expr.accept(this, null);
  }

  /// Generates a complete Python script with symbol declarations.
  String generateScript(Expression expr, {List<String>? variables}) {
    final buffer = StringBuffer();
    buffer.writeln('from sympy import *');
    buffer.writeln();

    // Collect variables if not provided
    final vars = variables ?? _collectVariables(expr);
    if (vars.isNotEmpty) {
      buffer.writeln("${vars.join(', ')} = symbols('${vars.join(' ')}')");
    }
    buffer.writeln();
    buffer.writeln('expr = ${convert(expr)}');

    return buffer.toString();
  }

  /// Collects all variable names from an expression.
  List<String> _collectVariables(Expression expr) {
    final vars = <String>{};
    _collectVarsRecursive(expr, vars);
    return vars.toList()..sort();
  }

  void _collectVarsRecursive(Expression expr, Set<String> vars) {
    if (expr is Variable) {
      // Skip constants
      if (!['e', 'pi', 'i', 'E', 'I'].contains(expr.name)) {
        vars.add(expr.name);
      }
    } else if (expr is BinaryOp) {
      _collectVarsRecursive(expr.left, vars);
      _collectVarsRecursive(expr.right, vars);
    } else if (expr is UnaryOp) {
      _collectVarsRecursive(expr.operand, vars);
    } else if (expr is FunctionCall) {
      for (final arg in expr.args) {
        _collectVarsRecursive(arg, vars);
      }
      if (expr.base != null) _collectVarsRecursive(expr.base!, vars);
      if (expr.optionalParam != null) {
        _collectVarsRecursive(expr.optionalParam!, vars);
      }
    } else if (expr is AbsoluteValue) {
      _collectVarsRecursive(expr.argument, vars);
    } else if (expr is SumExpr) {
      _collectVarsRecursive(expr.body, vars);
      vars.remove(expr.variable); // Don't include index variable
    } else if (expr is ProductExpr) {
      _collectVarsRecursive(expr.body, vars);
      vars.remove(expr.variable);
    } else if (expr is IntegralExpr) {
      _collectVarsRecursive(expr.body, vars);
    } else if (expr is DerivativeExpr) {
      _collectVarsRecursive(expr.body, vars);
    } else if (expr is LimitExpr) {
      _collectVarsRecursive(expr.body, vars);
      _collectVarsRecursive(expr.target, vars);
    }
  }

  @override
  String visitNumberLiteral(NumberLiteral node, void context) {
    if (node.value.isInfinite) {
      return node.value.isNegative ? '-oo' : 'oo';
    }
    if (node.value.isNaN) {
      return 'nan';
    }
    if (node.value == node.value.toInt()) {
      return node.value.toInt().toString();
    }
    return node.value.toString();
  }

  @override
  String visitVariable(Variable node, void context) {
    // Map special constants - but only for known mathematical constants
    // Note: 'i' is ambiguous - could be imaginary unit or loop variable
    // We only use I for standalone 'i' that's likely the imaginary unit
    switch (node.name) {
      case 'pi':
        return 'pi';
      case 'e':
        return 'E';
      case 'infty':
        return 'oo';
      default:
        return node.name;
    }
  }

  @override
  String visitBinaryOp(BinaryOp node, void context) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);

    // Wrap in parentheses if needed for precedence
    final needsParensLeft = _needsParens(node.left, node.operator, true);
    final needsParensRight = _needsParens(node.right, node.operator, false);
    final leftStr = needsParensLeft ? '($left)' : left;
    final rightStr = needsParensRight ? '($right)' : right;

    switch (node.operator) {
      case BinaryOperator.add:
        return '$leftStr + $rightStr';
      case BinaryOperator.subtract:
        return '$leftStr - $rightStr';
      case BinaryOperator.multiply:
        return '$leftStr*$rightStr';
      case BinaryOperator.divide:
        return '($leftStr)/($rightStr)';
      case BinaryOperator.power:
        return '$leftStr**$rightStr';
    }
  }

  bool _needsParens(Expression expr, BinaryOperator parentOp, bool isLeft) {
    if (expr is! BinaryOp) return false;
    final prec = {
      BinaryOperator.add: 1,
      BinaryOperator.subtract: 1,
      BinaryOperator.multiply: 2,
      BinaryOperator.divide: 2,
      BinaryOperator.power: 3,
    };
    return prec[expr.operator]! < prec[parentOp]!;
  }

  @override
  String visitUnaryOp(UnaryOp node, void context) {
    final operand = node.operand.accept(this, context);
    switch (node.operator) {
      case UnaryOperator.negate:
        if (node.operand is BinaryOp) {
          return '-($operand)';
        }
        return '-$operand';
    }
  }

  @override
  String visitAbsoluteValue(AbsoluteValue node, void context) {
    final arg = node.argument.accept(this, context);
    return 'Abs($arg)';
  }

  @override
  String visitFunctionCall(FunctionCall node, void context) {
    final arg = node.argument.accept(this, context);

    // Special handling for sqrt with index
    if (node.name == 'sqrt') {
      if (node.optionalParam != null) {
        final n = node.optionalParam!.accept(this, context);
        return 'root($arg, $n)';
      }
      return 'sqrt($arg)';
    }

    // Logarithm with base
    if (node.name == 'log' || node.name == 'lg') {
      if (node.base != null) {
        final base = node.base!.accept(this, context);
        return 'log($arg, $base)';
      }
      return 'log($arg, 10)'; // log defaults to base 10
    }

    // Natural log
    if (node.name == 'ln') {
      return 'log($arg)'; // SymPy uses log for natural log
    }

    // Map function names to SymPy equivalents
    final funcMap = {
      'sin': 'sin',
      'cos': 'cos',
      'tan': 'tan',
      'cot': 'cot',
      'sec': 'sec',
      'csc': 'csc',
      'arcsin': 'asin',
      'arccos': 'acos',
      'arctan': 'atan',
      'asin': 'asin',
      'acos': 'acos',
      'atan': 'atan',
      'sinh': 'sinh',
      'cosh': 'cosh',
      'tanh': 'tanh',
      'coth': 'coth',
      'sech': 'sech',
      'csch': 'csch',
      'asinh': 'asinh',
      'acosh': 'acosh',
      'atanh': 'atanh',
      'exp': 'exp',
      'floor': 'floor',
      'ceil': 'ceiling',
      'round': 'round',
      'abs': 'Abs',
      'sign': 'sign',
      'sgn': 'sign',
      'factorial': 'factorial',
      'fibonacci': 'fibonacci',
      'gcd': 'gcd',
      'lcm': 'lcm',
      'Re': 're',
      'Im': 'im',
      'conjugate': 'conjugate',
    };

    final sympyFunc = funcMap[node.name] ?? node.name;

    // Multi-argument functions
    if (node.args.length > 1) {
      final argsStr = node.args.map((a) => a.accept(this, context)).join(', ');
      return '$sympyFunc($argsStr)';
    }

    return '$sympyFunc($arg)';
  }

  @override
  String visitLimitExpr(LimitExpr node, void context) {
    final body = node.body.accept(this, context);
    final target = node.target.accept(this, context);
    return 'limit($body, ${node.variable}, $target)';
  }

  @override
  String visitSumExpr(SumExpr node, void context) {
    final body = node.body.accept(this, context);
    final start = node.start.accept(this, context);
    final end = node.end.accept(this, context);
    return 'Sum($body, (${node.variable}, $start, $end))';
  }

  @override
  String visitProductExpr(ProductExpr node, void context) {
    final body = node.body.accept(this, context);
    final start = node.start.accept(this, context);
    final end = node.end.accept(this, context);
    return 'Product($body, (${node.variable}, $start, $end))';
  }

  @override
  String visitIntegralExpr(IntegralExpr node, void context) {
    final body = node.body.accept(this, context);

    if (node.lower != null && node.upper != null) {
      final lower = node.lower!.accept(this, context);
      final upper = node.upper!.accept(this, context);
      return 'integrate($body, (${node.variable}, $lower, $upper))';
    }
    return 'integrate($body, ${node.variable})';
  }

  @override
  String visitMultiIntegralExpr(MultiIntegralExpr node, void context) {
    final body = node.body.accept(this, context);

    // Build nested integration
    var result = body;
    for (final variable in node.variables.reversed) {
      result = 'integrate($result, $variable)';
    }
    return result;
  }

  @override
  String visitDerivativeExpr(DerivativeExpr node, void context) {
    final body = node.body.accept(this, context);
    if (node.order == 1) {
      return 'diff($body, ${node.variable})';
    }
    return 'diff($body, ${node.variable}, ${node.order})';
  }

  @override
  String visitPartialDerivativeExpr(PartialDerivativeExpr node, void context) {
    final body = node.body.accept(this, context);
    if (node.order == 1) {
      return 'diff($body, ${node.variable})';
    }
    return 'diff($body, ${node.variable}, ${node.order})';
  }

  @override
  String visitBinomExpr(BinomExpr node, void context) {
    final n = node.n.accept(this, context);
    final k = node.k.accept(this, context);
    return 'binomial($n, $k)';
  }

  @override
  String visitGradientExpr(GradientExpr node, void context) {
    final body = node.body.accept(this, context);
    // SymPy uses gradient function from sympy.vector or derive manually
    // For simplicity, we'll express it as a list of partial derivatives
    if (node.variables != null && node.variables!.isNotEmpty) {
      final derivs = node.variables!.map((v) => 'diff($body, $v)').join(', ');
      return 'Matrix([$derivs])';
    }
    // Without explicit variables, we can't generate SymPy gradient
    return 'gradient($body)';
  }

  @override
  String visitComparison(Comparison node, void context) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);

    final op = switch (node.operator) {
      ComparisonOperator.less => '<',
      ComparisonOperator.greater => '>',
      ComparisonOperator.lessEqual => '<=',
      ComparisonOperator.greaterEqual => '>=',
      ComparisonOperator.equal => '==',
      ComparisonOperator.member => 'in', // Python set membership
    };

    return '$left $op $right';
  }

  @override
  String visitChainedComparison(ChainedComparison node, void context) {
    final parts = <String>[];
    for (int i = 0; i < node.expressions.length; i++) {
      parts.add(node.expressions[i].accept(this, context));
      if (i < node.operators.length) {
        final op = switch (node.operators[i]) {
          ComparisonOperator.less => '<',
          ComparisonOperator.greater => '>',
          ComparisonOperator.lessEqual => '<=',
          ComparisonOperator.greaterEqual => '>=',
          ComparisonOperator.equal => '==',
          ComparisonOperator.member => 'in',
        };
        parts.add(op);
      }
    }
    return parts.join(' ');
  }

  @override
  String visitConditionalExpr(ConditionalExpr node, void context) {
    final expr = node.expression.accept(this, context);
    final cond = node.condition.accept(this, context);
    return 'Piecewise(($expr, $cond))';
  }

  @override
  String visitPiecewise(PiecewiseExpr node, void context) {
    final cases = node.cases.map((c) {
      final expr = c.expression.accept(this, context);
      if (c.condition != null) {
        final cond = c.condition!.accept(this, context);
        return '($expr, $cond)';
      }
      return '($expr, True)'; // Otherwise case
    }).join(', ');
    return 'Piecewise($cases)';
  }

  @override
  String visitMatrixExpr(MatrixExpr node, void context) {
    final rows = node.rows.map((row) {
      final cells = row.map((e) => e.accept(this, context)).join(', ');
      return '[$cells]';
    }).join(', ');
    return 'Matrix([$rows])';
  }

  @override
  String visitVectorExpr(VectorExpr node, void context) {
    final elements =
        node.components.map((c) => c.accept(this, context)).join(', ');
    return 'Matrix([[$elements]])'; // SymPy vectors are column matrices usually? Or just list?
    // Using Matrix([[...]]) for row vector or Transpose if needed. Sticking to simple list representation if valid or Matrix.
  }

  @override
  String visitIntervalExpr(IntervalExpr node, void context) {
    return 'Interval(${node.lower.accept(this, context)}, ${node.upper.accept(this, context)})';
  }

  @override
  String visitAssignmentExpr(AssignmentExpr node, void context) {
    final value = node.value.accept(this, context);
    // Represent assignments as Equality in SymPy
    return 'Eq(${node.variable}, $value)';
  }

  @override
  String visitFunctionDefinitionExpr(
      FunctionDefinitionExpr node, void context) {
    final body = node.body.accept(this, context);
    final params = node.parameters.join(', ');
    if (node.parameters.isEmpty) {
      return 'Eq(${node.name}, $body)';
    }
    return 'Eq(${node.name}($params), $body)';
  }

  @override
  String visitBooleanBinaryExpr(BooleanBinaryExpr node, void context) {
    final left = node.left.accept(this, context);
    final right = node.right.accept(this, context);

    final op = switch (node.operator) {
      BooleanOperator.and => '&',
      BooleanOperator.or => '|',
      BooleanOperator.xor => '^',
      BooleanOperator.implies => 'Implies',
      BooleanOperator.iff => 'Equivalent',
    };

    // Implies and Equivalent are functions in SymPy
    if (node.operator == BooleanOperator.implies ||
        node.operator == BooleanOperator.iff) {
      return '$op($left, $right)';
    }
    return '($left) $op ($right)';
  }

  @override
  String visitBooleanUnaryExpr(BooleanUnaryExpr node, void context) {
    final operand = node.operand.accept(this, context);
    return '~($operand)';
  }
}

/// Extension to add toSymPy() method to all Expression types.
extension SymPyExport on Expression {
  /// Converts this expression to SymPy (Python) code.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final expr = evaluator.parse(r'\sin{x}^2 + \cos{x}^2');
  /// final sympy = expr.toSymPy();
  /// // Returns: sin(x)**2 + cos(x)**2
  /// ```
  String toSymPy() {
    const visitor = SymPyVisitor();
    return visitor.convert(this);
  }

  /// Generates a complete Python script with SymPy imports.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final expr = evaluator.parse(r'\int x^2 dx');
  /// final script = expr.toSymPyScript();
  /// // Returns:
  /// // from sympy import *
  /// //
  /// // x = symbols('x')
  /// //
  /// // expr = integrate(x**2, x)
  /// ```
  String toSymPyScript({List<String>? variables}) {
    const visitor = SymPyVisitor();
    return visitor.generateScript(this, variables: variables);
  }
}
