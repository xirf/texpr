/// Extension system for customizing LaTeX math parsing and evaluation.
library;

import 'ast.dart';
import 'token.dart';

/// Handler for custom LaTeX commands during tokenization.
///
/// Returns a Token if the command is handled, null otherwise.
/// [command] is the command name without the backslash (e.g., 'sqrt' for '\sqrt').
/// [position] is the position in the source where the command starts.
typedef CommandTokenizer = Token? Function(String command, int position);

/// Handler for custom expression evaluation.
///
/// Returns the result if the expression is handled, null otherwise.
/// [expr] is the expression to evaluate.
/// [variables] are the current variable bindings.
/// [evaluate] is a callback to evaluate sub-expressions.
typedef CustomEvaluator = double? Function(
  Expression expr,
  Map<String, double> variables,
  double Function(Expression) evaluate,
);

/// Registry for custom extensions.
///
/// Allows users to register custom LaTeX commands and evaluation handlers.
///
/// Example:
/// ```dart
/// final registry = ExtensionRegistry();
///
/// // Register \sqrt command
/// registry.registerCommand('sqrt', (cmd, pos) =>
///   Token(type: TokenType.function, value: 'sqrt', position: pos));
///
/// // Register sqrt evaluator
/// registry.registerEvaluator((expr, vars, eval) {
///   if (expr is FunctionCall && expr.name == 'sqrt') {
///     return math.sqrt(eval(expr.argument));
///   }
///   return null;
/// });
/// ```
class ExtensionRegistry {
  final Map<String, CommandTokenizer> _tokenizers = {};
  final List<CustomEvaluator> _evaluators = [];

  /// Registers a handler for a custom LaTeX command.
  ///
  /// [command] is the command name without backslash (e.g., 'sqrt').
  void registerCommand(String command, CommandTokenizer handler) {
    _tokenizers[command] = handler;
  }

  /// Registers a custom evaluator.
  ///
  /// Evaluators are tried in order until one returns a non-null result.
  void registerEvaluator(CustomEvaluator handler) {
    _evaluators.add(handler);
  }

  /// Tries to tokenize a command using registered handlers.
  ///
  /// Returns null if no handler matches.
  Token? tryTokenize(String command, int position) {
    final handler = _tokenizers[command];
    if (handler != null) {
      return handler(command, position);
    }
    return null;
  }

  /// Tries to evaluate an expression using registered handlers.
  ///
  /// Returns null if no handler matches.
  double? tryEvaluate(
    Expression expr,
    Map<String, double> variables,
    double Function(Expression) evaluate,
  ) {
    for (final handler in _evaluators) {
      final result = handler(expr, variables, evaluate);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Whether any custom commands are registered.
  bool get hasCustomCommands => _tokenizers.isNotEmpty;

  /// Whether any custom evaluators are registered.
  bool get hasCustomEvaluators => _evaluators.isNotEmpty;
}
