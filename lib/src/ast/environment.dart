import 'expression.dart';
import 'visitor.dart';

/// Represents a variable assignment (e.g. `let x = 5`).
class AssignmentExpr extends Expression {
  /// The name of the variable being assigned.
  final String variable;

  /// The value being assigned to the variable.
  final Expression value;

  AssignmentExpr(this.variable, this.value);

  @override
  String toLatex() => 'let $variable = ${value.toLatex()}';

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitAssignmentExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentExpr &&
          runtimeType == other.runtimeType &&
          variable == other.variable &&
          value == other.value;

  @override
  int get hashCode => variable.hashCode ^ value.hashCode;

  @override
  String toString() => 'AssignmentExpr($variable = $value)';
}

/// Represents a user-defined function definition (e.g. `f(x) = x^2`).
class FunctionDefinitionExpr extends Expression {
  /// The name of the function.
  final String name;

  /// The parameter names.
  final List<String> parameters;

  /// The function body.
  final Expression body;

  FunctionDefinitionExpr(this.name, this.parameters, this.body);

  @override
  String toLatex() => '$name(${parameters.join(", ")}) = ${body.toLatex()}';

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitFunctionDefinitionExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FunctionDefinitionExpr &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          // List equality check needed
          parameters.length == other.parameters.length &&
          parameters
              .asMap()
              .entries
              .every((e) => other.parameters[e.key] == e.value) &&
          body == other.body;

  @override
  int get hashCode =>
      name.hashCode ^ Object.hashAll(parameters) ^ body.hashCode;

  @override
  String toString() =>
      'FunctionDefinitionExpr($name(${parameters.join(", ")}) = $body)';
}
