/// AST evaluator with variable binding support.
library;

import 'ast.dart';
import 'cache/cache_manager.dart';
import 'complex.dart';
import 'interval.dart';
import 'features/calculus/differentiation_evaluator.dart';
import 'features/calculus/integration_evaluator.dart';
import 'exceptions.dart';
import 'extensions.dart';
import 'matrix.dart';
import 'vector.dart';

/// Evaluates an expression tree with variable bindings.
///
/// The [Evaluator] class is the core component for calculating the result of
/// parsed mathematical expressions. It supports:
/// - Basic arithmetic operations (+, -, *, /, ^)
/// - Function calls (sin, cos, log, etc.)
/// - Variable bindings
/// - Matrix operations
/// - Complex number operations
/// - Custom extensions via [ExtensionRegistry]
///
/// Example:
/// ```dart
/// final evaluator = Evaluator();
/// final expr = Parser(Tokenizer('2 + x').tokenize()).parse();
/// final result = evaluator.evaluate(expr, {'x': 3});
/// print(result.asNumeric()); // 5.0
/// ```
class Evaluator {
  late final EvaluationVisitor _visitor;

  /// Optional cache manager for sub-expression caching.
  // ignore: unused_field
  final CacheManager? _cacheManager;

  /// Creates an evaluator with optional extension registry and cache manager.
  ///
  /// [extensions] allows adding custom functions and variables to the evaluator.
  /// [cacheManager] enables sub-expression caching for better performance.
  /// [realOnly] when true, operations that would produce complex numbers
  /// (like sqrt of negative) return NaN instead. Useful for graphing where
  /// Desmos-like behavior is expected. Defaults to false.
  Evaluator(
      {ExtensionRegistry? extensions,
      CacheManager? cacheManager,
      int maxRecursionDepth = 500,
      bool realOnly = false})
      : _cacheManager = cacheManager {
    _visitor = EvaluationVisitor(
        extensions: extensions,
        maxRecursionDepth: maxRecursionDepth,
        realOnly: realOnly);
  }

  /// Gets the differentiation evaluator (for internal use by public API).
  DifferentiationEvaluator get differentiationEvaluator =>
      _visitor.differentiationEvaluator;

  /// Gets the integration evaluator (for internal use by public API).
  IntegrationEvaluator get integrationEvaluator =>
      _visitor.integrationEvaluator;

  /// Evaluates the given expression using the provided variable bindings.
  ///
  /// [expr] is the expression tree to evaluate.
  /// [variables] is a map of variable names to their values.
  ///
  /// Returns the computed result as an [EvaluationResult], which can be
  /// either a [NumericResult], [ComplexResult], or [MatrixResult].
  ///
  /// Throws [EvaluatorException] if:
  /// - A variable is not found in the bindings
  /// - Division by zero occurs
  /// - An unknown expression type is encountered
  /// - Type mismatch (e.g. adding a number to a matrix)
  EvaluationResult evaluate(Expression expr,
      [Map<String, dynamic> variables = const {}]) {
    final rawResult = expr.accept(_visitor, variables);
    return _wrapResult(rawResult);
  }

  /// Wraps a raw dynamic result into an EvaluationResult.
  EvaluationResult _wrapResult(dynamic result) {
    if (result is bool) {
      return BooleanResult(result);
    } else if (result is num) {
      return NumericResult(result.toDouble());
    } else if (result is Complex) {
      return ComplexResult(result);
    } else if (result is Matrix) {
      return MatrixResult(result);
    } else if (result is Vector) {
      return VectorResult(result);
    } else if (result is FunctionDefinitionExpr) {
      return FunctionResult(result);
    } else if (result is Interval) {
      return IntervalResult(result);
    } else {
      throw EvaluatorException(
        'Invalid result type: ${result.runtimeType}',
        suggestion:
            'Results must be either a number, boolean, complex number, matrix, vector, or interval',
      );
    }
  }
}
