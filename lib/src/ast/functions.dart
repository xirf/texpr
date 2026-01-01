import 'expression.dart';
import 'visitor.dart';

/// Absolute value expression: |x|
class AbsoluteValue extends Expression {
  final Expression argument;

  const AbsoluteValue(this.argument);

  @override
  String toString() => 'AbsoluteValue($argument)';

  @override
  String toLatex() => '\\left|${argument.toLatex()}\\right|';

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitAbsoluteValue(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AbsoluteValue &&
          runtimeType == other.runtimeType &&
          argument == other.argument;

  @override
  int get hashCode => argument.hashCode;
}

/// A function call expression (e.g., \log{x}, \ln{x}, \sin{x}).
///
/// For functions with a subscript base like \log_{2}{x}, use [base].
class FunctionCall extends Expression {
  /// The function name (e.g., 'log', 'ln', 'sin').
  final String name;

  /// The function arguments.
  final List<Expression> args;

  /// The function argument (first argument).
  Expression get argument => args[0];

  /// Optional base for functions like \log_{base}{arg}.
  final Expression? base;

  /// Optional parameter for functions like \sqrt[n]{x}.
  final Expression? optionalParam;

  FunctionCall(this.name, Expression argument, {this.base, this.optionalParam})
      : args = [argument];

  FunctionCall.multivar(this.name, this.args, {this.base, this.optionalParam});

  @override
  String toString() {
    final parts = ['FunctionCall($name'];
    if (base != null) parts.add('base: $base');
    if (optionalParam != null) parts.add('optionalParam: $optionalParam');
    parts.add('args: $args)');
    return parts.join(', ');
  }

  @override
  String toLatex() {
    // Handle special cases
    if (name == 'sqrt') {
      if (optionalParam != null) {
        return '\\sqrt[${optionalParam!.toLatex()}]{${argument.toLatex()}}';
      }
      return '\\sqrt{${argument.toLatex()}}';
    }

    // Handle logarithm with base
    if ((name == 'log' || name == 'lg') && base != null) {
      return '\\log_{${base!.toLatex()}}{${argument.toLatex()}}';
    }

    // Multi-argument functions
    if (args.length > 1) {
      final argsLatex = args.map((a) => a.toLatex()).join(',');
      return '\\$name{$argsLatex}';
    }

    // Standard single-argument function
    return '\\$name{${argument.toLatex()}}';
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitFunctionCall(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionCall &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          // Deep equality for list
          args.length == other.args.length &&
          base == other.base &&
          optionalParam == other.optionalParam; // Simplified check

  @override
  int get hashCode =>
      Object.hash(name, Object.hashAll(args), base, optionalParam);
}
