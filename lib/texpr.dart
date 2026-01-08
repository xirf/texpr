/* A library for parsing and evaluating LaTeX-formatted math expressions.
///
/// ## Usage
///
/// ```dart
/// import 'package:texpr/texpr.dart';
///
/// // Parse and evaluate a simple expression
/// final result = Texpr().evaluate('2 + 3 \\times 4');
/// print(result.asNumeric()); // 14.0
///
/// // With variables
/// final result2 = Texpr().evaluate('x^{2} + 1', {'x': 3});
/// print(result2.asNumeric()); // 10.0
///
/// // Logarithms
/// final result3 = Texpr().evaluate('\\log_{2}{8}');
/// print(result3.asNumeric()); // 3.0
///
/// // Limits
/// final result4 = Texpr().evaluate('\\lim_{x \\to 0} x');
/// print(result4.asNumeric()); // 0.0
///
/// // Pattern matching on result type
/// final result5 = Texpr().evaluate('2 + 3');
/// switch (result5) {
///   case NumericResult(:final value):
///     print('Got number: $value');
///   case MatrixResult(:final matrix):
///     print('Got matrix: $matrix');
/// }
/// ```
///
/// ## Parse Once, Evaluate Many Times (Memory Efficient)
///
/// ```dart
/// final evaluator = Texpr();
///
/// // Parse the expression once
/// final equation = evaluator.parse('x^{2} + 2x + 1');
///
/// // Reuse with different variable values
/// print(evaluator.evaluateParsed(equation, {'x': 1}).asNumeric()); // 4.0
/// print(evaluator.evaluateParsed(equation, {'x': 2}).asNumeric()); // 9.0
/// print(evaluator.evaluateParsed(equation, {'x': 3}).asNumeric()); // 16.0
/// ```
///
/// ## Custom Extensions
///
/// ```dart
/// final registry = ExtensionRegistry();
/// registry.registerCommand('sqrt', (cmd, pos) =>
///   Token(type: TokenType.function, value: 'sqrt', position: pos));
/// registry.registerEvaluator((expr, vars, eval) {
///   if (expr is FunctionCall && expr.name == 'sqrt') {
///     return math.sqrt(eval(expr.argument));
///   }
///   return null;
/// });
/// final evaluator = Texpr(extensions: registry);
*/

// Public API - organized by module
// For modular imports, use: import 'package:texpr/src/core/core.dart';
export 'src/ast.dart';
export 'src/evaluator.dart';
export 'src/exceptions.dart';
export 'src/extensions.dart';
export 'src/matrix.dart';
export 'src/vector.dart';
export 'src/parser.dart';
export 'src/token.dart';
export 'src/tokenizer.dart';
export 'src/symbolic.dart';
export 'src/interval.dart';
export 'src/cache/cache.dart';
export 'src/visitors/json_ast_visitor.dart';
export 'src/visitors/mathml_visitor.dart';
export 'src/visitors/sympy_visitor.dart';

import 'src/ast.dart';
import 'src/evaluator.dart';
import 'src/exceptions.dart';
import 'src/extensions.dart';
import 'src/matrix.dart';
import 'src/parser.dart';
import 'src/tokenizer.dart';
import 'src/cache/cache_config.dart';
import 'src/cache/cache_manager.dart';
import 'src/cache/cache_statistics.dart';
import 'src/symbolic/step_trace.dart';
import 'src/symbolic/symbolic_engine.dart';

/// A convenience class that combines tokenizing, parsing, and evaluation.
///
/// Supports multi-layer caching for optimal performance:
/// - L1: Parsed expression cache (String to AST)
/// - L2: Evaluation result cache (AST + Variables to Result)
/// - L3: Differentiation result cache (AST + Variable to Derivative)
///
/// Example with advanced caching:
/// ```dart
/// // High-performance configuration for graphing
/// final evaluator = Texpr(
///   cacheConfig: CacheConfig.highPerformance,
/// );
///
/// // With statistics for monitoring
/// final evaluatorWithStats = Texpr(
///   cacheConfig: CacheConfig.withStatistics,
/// );
/// // After some evaluations...
/// print(evaluatorWithStats.cacheStatistics);
/// ```
class Texpr {
  final ExtensionRegistry? _extensions;
  final bool allowImplicitMultiplication;
  late final Evaluator _evaluator;
  late final CacheManager _cacheManager;

  final Map<String, dynamic> _globalEnvironment = {};

  /// The cache configuration for this evaluator.
  final CacheConfig cacheConfig;

  /// Maximum number of parsed expressions kept in the LRU cache.
  ///
  /// Set to 0 to disable caching.
  /// @deprecated Use [cacheConfig] instead for more control.
  final int parsedExpressionCacheSize;

  /// Creates an evaluator with optional extension registry.
  ///
  /// [extensions]: Optional [ExtensionRegistry] instance for custom commands.
  /// [allowImplicitMultiplication]: When true (default), adjacent tokens are
  /// interpreted as multiplication (e.g. `xy` -> `x * y`).
  /// [cacheConfig]: Advanced cache configuration. If provided, this takes
  /// precedence over [parsedExpressionCacheSize].
  /// [parsedExpressionCacheSize]: Size of the internal parsed-expression LRU
  /// cache. Set to 0 to disable caching. Defaults to 128.
  /// [maxRecursionDepth]: Maximum recursion depth for parsing and evaluation.
  /// Defaults to 500.
  /// @deprecated Use [cacheConfig] instead for more control.
  Texpr({
    ExtensionRegistry? extensions,
    this.allowImplicitMultiplication = true,
    CacheConfig? cacheConfig,
    this.parsedExpressionCacheSize = 128,
    this.maxRecursionDepth = 500,
  })  : _extensions = extensions,
        cacheConfig = cacheConfig ??
            CacheConfig(parsedExpressionCacheSize: parsedExpressionCacheSize) {
    _cacheManager = CacheManager(this.cacheConfig);
    _evaluator = Evaluator(
      extensions: _extensions,
      cacheManager: _cacheManager,
      maxRecursionDepth: maxRecursionDepth,
    );
  }

  /// Maximum recursion depth for parsing and evaluation.
  final int maxRecursionDepth;

  /// Gets cache statistics for all layers.
  ///
  /// Only available when [CacheConfig.collectStatistics] is true.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr(
  ///   cacheConfig: CacheConfig.withStatistics,
  /// );
  ///
  /// // Perform many evaluations...
  /// for (var i = 0; i < 1000; i++) {
  ///   evaluator.evaluate('x^2 + 1', {'x': i.toDouble()});
  /// }
  ///
  /// final stats = evaluator.cacheStatistics;
  /// print('Hit rate: ${(stats.overallHitRate * 100).toStringAsFixed(1)}%');
  /// print('Parsed expression hits: ${stats.parsedExpressions.hits}');
  /// print('Evaluation result hits: ${stats.evaluationResults.hits}');
  /// ```
  MultiLayerCacheStatistics get cacheStatistics => _cacheManager.statistics;

  /// Clears the internal parsed-expression cache.
  void clearParsedExpressionCache() {
    _cacheManager.clearLayer(CacheLayer.parsedExpressions);
  }

  /// Clears all caches (parsed expressions, evaluation results, etc.).
  void clearAllCaches() {
    _cacheManager.clear();
  }

  /// Clears the persistent global environment (variables defined via `let`).
  void clearEnvironment() {
    _globalEnvironment.clear();
  }

  /// Warms up the cache with common expressions.
  ///
  /// Use this to preload frequently-used expressions before heavy computation.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  /// evaluator.warmUpCache([
  ///   'x^2',
  ///   'sin(x)',
  ///   'cos(x)',
  ///   'e^x',
  /// ]);
  /// ```
  void warmUpCache(List<String> expressions) {
    _cacheManager.warmUp(expressions, _parseInternal);
  }

  /// Parses a LaTeX math expression into an AST without evaluating.
  ///
  /// This allows you to parse once and evaluate multiple times with different
  /// variable bindings, which is more memory efficient.
  ///
  /// [expression] is the LaTeX math string to parse.
  ///
  /// Returns the parsed AST [Expression] that can be reused.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  /// final equation = evaluator.parse('x^{2} + 2x + 1');
  ///
  /// // Reuse the parsed equation with different values
  /// final result1 = evaluator.evaluateParsed(equation, {'x': 1}); // 4.0
  /// final result2 = evaluator.evaluateParsed(equation, {'x': 2}); // 9.0
  /// final result3 = evaluator.evaluateParsed(equation, {'x': 3}); // 16.0
  /// ```
  Expression parse(String expression) {
    final cached = _cacheManager.getParsedExpression(expression);
    if (cached != null) return cached;

    final ast = _parseInternal(expression);

    // Skip L1 cache for oversized expressions to prevent memory exhaustion.
    // This is a soft limit: large expressions parse normally, just aren't cached.
    final maxLen = cacheConfig.maxCacheInputLength;
    if (maxLen == 0 || expression.length <= maxLen) {
      _cacheManager.putParsedExpression(expression, ast);
    }

    return ast;
  }

  /// Internal parse without caching.
  Expression _parseInternal(String expression) {
    final tokens = Tokenizer(expression,
            extensions: _extensions,
            allowImplicitMultiplication: allowImplicitMultiplication)
        .tokenize();
    return Parser(tokens, expression, false, maxRecursionDepth).parse();
  }

  /// Evaluates a pre-parsed expression with variable bindings.
  ///
  /// [ast] is the parsed expression from [parse()].
  /// [variables] is a map of variable names to their values.
  ///
  /// Returns the computed result as an [EvaluationResult], which can be
  /// either a [NumericResult] or [MatrixResult].
  ///
  /// **Performance note:** For hot loops, reuse the same [variables] Map
  /// instance to maximize cache hits. Creating a new Map each iteration
  /// will bypass the evaluation cache.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  /// final equation = evaluator.parse('x + y');
  /// final result = evaluator.evaluateParsed(equation, {'x': 10, 'y': 5});
  /// print(result.asNumeric()); // 15.0
  /// ```
  EvaluationResult evaluateParsed(Expression ast,
      [Map<String, dynamic> variables = const {}]) {
    // Only consult L2 cache for computationally expensive operations.
    // For cheap expressions, cache lookup overhead exceeds evaluation cost.
    // Also skip cache if we have side-effects (assignments)
    final isAssignment = ast is AssignmentExpr || ast is FunctionDefinitionExpr;
    final shouldCache =
        !isAssignment && (_isCostlyExpression(ast) || variables.isEmpty);

    // Merge global environment with provided variables
    // Provided variables take precedence over global ones

    if (_globalEnvironment.isNotEmpty) {
      // We can iterate and add if not present, but for performance we usually
      // pass the environment down. However, Evaluator expects a single map.
      // Creating a new map might be costly.
      // If variables is empty, we can just use globals.
      if (variables.isEmpty) {
        // Safe to pass _globalEnvironment directly?
        // Evaluator might modify it if it encounters assignments.
        // Yes, that's desired behavior for global scope.
        return _evaluator.evaluate(ast, _globalEnvironment);
      } else {
        // Mixed. We need a combined view.
        // A simple approach is {..._globalEnvironment, ...variables}
        // but that copies.
        final merged = {..._globalEnvironment, ...variables};
        // Note: Assignments in this scope will only affect 'merged', not '_globalEnvironment'
        // unless we explicitly handle it in Evaluator.
        // Wait, if I want `let x=5` to persist, Evaluator needs a reference to the mutable store.
        // Current design passes Map by value (reference), but typical usage creates new Map.
        // If we want persistence, we should probably pass _globalEnvironment as a "parent scope"
        // or handle assignments specially.

        // For now, let's pass a merged map, but if there's an assignment, we might want
        // to capture the result and update _globalEnvironment?
        // Actually, `evaluate` returns EvaluationResult.
        // If `ast` is AssignmentExpr, it returns the value.
        // But the side effect of updating the map happens inside Evaluator.

        // Let's refine:
        // If variables is NOT persistent (user passed it), we shouldn't leak assignments into it?
        // Or should we?
        // Usually `let` defines a variable in the current scope.

        // Let's assume `_globalEnvironment` is the base.
        // If user provides variables, they shadow globals.
        // New assignments usually go to the "current" scope.
        // If we want a REPL experience, variables should go to `_globalEnvironment`.

        // Implementation detail:
        // Evaluator will accept a Mutable Map.
        // We should probably pass `_globalEnvironment` if `variables` is empty.
        // If `variables` is present, it's a temporary scope?

        // Let's stick to simple: Merge.
        // If users want peristence, they rely on `let` statements executed one by one, usually with empty variables.

        // BUT: If I do `texpr.evaluate('let x = 5')`, I want `x` to be in `_globalEnvironment`.
        // If I pass `merged`, the assignment adds to `merged`. `_globalEnvironment` is untouched.
        // This is a problem.

        // Fix: Evaluator needs to know about the "persistent" scope vs "temporary" scope?
        // Or we manually handle top-level assignments here in `evaluateParsed`?

        if (isAssignment) {
          // It's a top-level assignment. We want to update _globalEnvironment.
          // But if `variables` provided conflicts, what happens?
          // Let's execute against `merged`, but COPY the result to `_globalEnvironment`?
          // No, Evaluator logic for AssignmentExpr is `variables[name] = value`.

          // Allow direct modification of _globalEnvironment if variables is generic.
          // If the user effectively wants a session, they use `evaluate('let...')`.

          // To support this properly without a complex scope chain implementation in Evaluator:
          // We can detect if it's an assignment and update `_globalEnvironment`.

          final result = _evaluator.evaluate(ast, merged);

          // If it was an assignment, the `merged` map was updated.
          // We need to extract the new key?
          // Or simpler: We update `_globalEnvironment` explicitly if the AST is assignment.

          if (ast is AssignmentExpr) {
            _globalEnvironment[ast.variable] =
                (result as dynamic).value ?? result;
            // Wrapper logic might differ. result is EvaluationResult.
            // We need to store the raw value or the result?
            // Evaluator stores raw values usually.
          } else if (ast is FunctionDefinitionExpr) {
            // FunctionDef result IS the function (UserFunction or similar).
            // We need to retrieve it from `merged`.
            // Or better, let Evaluator handle it and we just accept that if we passed a copy, nothing stuck.
          }
        }
      }
    }

    // Simplification:
    // If we want persistence, we use `_globalEnvironment`.
    // If user provides `variables`, we assume it's a one-off evaluation context that shadows globals.
    // If `variables` is empty, we use `_globalEnvironment` directly.

    final effectiveVars = variables.isEmpty
        ? _globalEnvironment
        : {..._globalEnvironment, ...variables};

    // If we passed a copy, assignments won't persist to _globalEnvironment.
    // We need to handle top-level assignments explicitly if we want them to stick to Global.

    // Check L2 cache if enabled/applicable
    Map<String, double>? cacheKeyVars;
    if (shouldCache) {
      if (effectiveVars.isEmpty) {
        cacheKeyVars = const <String, double>{};
      } else if (effectiveVars is Map<String, double>) {
        cacheKeyVars = effectiveVars;
      } else {
        // Try to convert to Map<String, double> for caching
        // If variables contain non-numbers (e.g. matrices), we skip L2 caching
        bool allNumbers = true;
        final converted = <String, double>{};
        for (final entry in effectiveVars.entries) {
          if (entry.value is num) {
            converted[entry.key] = (entry.value as num).toDouble();
          } else {
            allNumbers = false;
            break;
          }
        }
        if (allNumbers) {
          cacheKeyVars = converted;
        }
      }

      if (cacheKeyVars != null) {
        final cached = _cacheManager.getEvaluationResult(ast, cacheKeyVars);
        if (cached != null) return cached;
      }
    }

    final result = _evaluator.evaluate(ast, effectiveVars);

    // Persist top-level assignments to global environment
    if (ast is AssignmentExpr) {
      // Extract value from result.
      // Result is EvaluationResult. We need to unwrap it to store raw if Evaluator expects raw.
      // Evaluator.evaluate wraps result.
      // But inside Evaluator, it stores raw.
      // So effectiveVars has the raw value.
      if (effectiveVars.containsKey(ast.variable)) {
        _globalEnvironment[ast.variable] = effectiveVars[ast.variable];
      }
    } else if (ast is FunctionDefinitionExpr) {
      if (effectiveVars.containsKey(ast.name)) {
        _globalEnvironment[ast.name] = effectiveVars[ast.name];
      }
    }

    if (shouldCache && cacheKeyVars != null) {
      _cacheManager.putEvaluationResult(ast, cacheKeyVars, result);
    }
    return result;
  }

  /// Determines if an expression is computationally expensive enough
  /// to warrant L2 cache overhead.
  ///
  /// Cache lookup has ~0.5µs overhead. Only cache operations that
  /// exceed this cost significantly.
  bool _isCostlyExpression(Expression ast) {
    return ast is IntegralExpr ||
        ast is SumExpr ||
        ast is ProductExpr ||
        ast is LimitExpr ||
        (ast is MatrixExpr && ast.rows.length > 4);
  }

  /// Parses and evaluates a LaTeX math expression.
  ///
  /// [expression] is the LaTeX math string to evaluate.
  /// [variables] is an optional map of variable names to their numeric values.
  ///
  /// Returns the computed result as an [EvaluationResult], which can be
  /// either a [NumericResult] or [MatrixResult].
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  /// final result = evaluator.evaluate('2 + 3');
  /// print(result.asNumeric()); // 5.0
  ///
  /// final result2 = evaluator.evaluate('x + 1', {'x': 2});
  /// print(result2.asNumeric()); // 3.0
  ///
  /// final result3 = evaluator.evaluate('\\log{10}');
  /// print(result3.asNumeric()); // 1.0
  ///
  /// final result4 = evaluator.evaluate('\\lim_{x \\to 1} x^{2}');
  /// print(result4.asNumeric()); // 1.0
  /// ```
  EvaluationResult evaluate(String expression,
      [Map<String, dynamic> variables = const {}]) {
    final ast = parse(expression);
    return evaluateParsed(ast, variables);
  }

  /// Evaluates a LaTeX expression and returns a numeric result.
  ///
  /// This is a convenience method that evaluates the expression and automatically
  /// extracts the numeric value. Use this when you know the result will be numeric.
  ///
  /// [expression] is the LaTeX math string to evaluate.
  /// [variables] is an optional map of variable names to their numeric values.
  ///
  /// Returns the computed result as a [double].
  ///
  /// Throws [StateError] if the result is a matrix or non-real complex number.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  ///
  /// final result = evaluator.evaluateNumeric('2 + 3'); // 5.0
  /// final result2 = evaluator.evaluateNumeric('x^{2}', {'x': 3}); // 9.0
  /// final result3 = evaluator.evaluateNumeric('\\sin{0}'); // 0.0
  /// ```
  double evaluateNumeric(String expression,
      [Map<String, dynamic> variables = const {}]) {
    return evaluate(expression, variables).asNumeric();
  }

  /// Evaluates a LaTeX expression and returns a matrix result.
  ///
  /// This is a convenience method that evaluates the expression and automatically
  /// extracts the matrix value. Use this when you know the result will be a matrix.
  ///
  /// [expression] is the LaTeX math string to evaluate.
  /// [variables] is an optional map of variable names to their numeric values.
  ///
  /// Returns the computed result as a [Matrix].
  ///
  /// Throws [StateError] if the result is not a matrix.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  ///
  /// final matrix = evaluator.evaluateMatrix(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}');
  /// print(matrix); // [[1.0, 2.0], [3.0, 4.0]]
  /// ```
  Matrix evaluateMatrix(String expression,
      [Map<String, dynamic> variables = const {}]) {
    return evaluate(expression, variables).asMatrix();
  }

  /// Checks if a LaTeX math expression is syntactically valid.
  ///
  /// This is a quick check that only validates syntax during tokenization
  /// and parsing. It does not check for undefined variables or evaluate
  /// the expression.
  ///
  /// [expression] is the LaTeX math string to validate.
  ///
  /// Returns `true` if the expression can be parsed successfully,
  /// `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  ///
  /// evaluator.isValid(r'2 + 3');        // true
  /// evaluator.isValid(r'\sin{x}');      // true (variables are OK)
  /// evaluator.isValid(r'\sin{');        // false (unclosed brace)
  /// evaluator.isValid(r'\unknown{5}');  // false (unknown command)
  /// ```
  bool isValid(String expression) {
    try {
      parse(expression);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Validates a LaTeX math expression and returns detailed error information.
  ///
  /// Unlike [isValid], this method returns a [ValidationResult] containing
  /// detailed information about any errors, including position and suggestions.
  ///
  /// This only validates syntax during tokenization and parsing. Variables
  /// are allowed in expressions and won't cause validation to fail.
  ///
  /// [expression] is the LaTeX math string to validate.
  ///
  /// Returns a [ValidationResult] with validation status and error details.
  ///
  ///
  /// This method attempts to recover from errors to report multiple issues
  /// if possible. Check [ValidationResult.subErrors] for additional errors.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  ///
  /// final result = evaluator.validate(r'\sin{');
  /// if (!result.isValid) {
  ///   print('Error: ${result.errorMessage}');
  ///   // Check for multiple errors
  ///   for (final subError in result.subErrors) {
  ///      print('Also found: ${subError.errorMessage}');
  ///   }
  /// }
  /// ```
  ValidationResult validate(String expression) {
    try {
      final tokens = Tokenizer(expression,
              extensions: _extensions,
              allowImplicitMultiplication: allowImplicitMultiplication)
          .tokenize();

      final parser = Parser(tokens, expression, true, maxRecursionDepth);
      parser.parse();

      if (parser.errors.isNotEmpty) {
        return ValidationResult.fromExceptions(parser.errors,
            expression: expression);
      }

      return const ValidationResult.valid();
    } on TexprException catch (e) {
      return ValidationResult.fromException(e);
    } catch (e) {
      // Handle unexpected errors
      return ValidationResult(
        isValid: false,
        errorMessage: 'Unexpected error: $e',
        suggestion:
            'If this is unexpected, please report this as a bug at https://github.com/xirf/texpr/issues',
      );
    }
  }

  /// Computes the symbolic derivative of an expression.
  ///
  /// This method performs symbolic differentiation and returns a simplified
  /// expression representing the derivative. The result is not evaluated
  /// numerically unless you later call [evaluateParsed] on it.
  ///
  /// Results are cached for performance when computing the same derivative
  /// multiple times.
  ///
  /// [expression] can be either:
  /// - A parsed [Expression] AST (from [parse])
  /// - A LaTeX string that will be automatically parsed
  ///
  /// [variable] is the variable to differentiate with respect to (e.g., 'x').
  /// [order] is the order of differentiation (default is 1 for first derivative).
  ///
  /// Returns the symbolic derivative as an [Expression] AST node.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  ///
  /// // Option 1: Parse then differentiate
  /// final expr = evaluator.parse('x^{2}');
  /// final derivative = evaluator.differentiate(expr, 'x');
  ///
  /// // Option 2: Direct string (more convenient)
  /// final derivative2 = evaluator.differentiate('x^{2}', 'x');
  ///
  /// // Evaluate at x = 3
  /// final result = evaluator.evaluateParsed(derivative, {'x': 3});
  /// print(result.asNumeric()); // 6.0
  ///
  /// // Second derivative: d²/dx²(x^3) = 6x
  /// final secondDerivative = evaluator.differentiate('x^{3}', 'x', order: 2);
  ///
  /// // Works with piecewise functions too
  /// final piecewise = evaluator.differentiate(r'|\sin{x}|, -3 < x < 3', 'x');
  /// ```
  Expression differentiate(dynamic expression, String variable,
      {int order = 1}) {
    // Parse string expressions automatically
    final expr =
        expression is String ? parse(expression) : expression as Expression;

    // Check differentiation cache
    final cached =
        _cacheManager.getDifferentiationResult(expr, variable, order);
    if (cached != null) return cached;

    final derivative = _evaluator.differentiationEvaluator.differentiate(
      expr,
      variable,
      order: order,
    );

    _cacheManager.putDifferentiationResult(expr, variable, order, derivative);
    return derivative;
  }

  /// Computes the symbolic antiderivative of an expression (indefinite integral).
  ///
  /// This method performs symbolic integration rules and returns an expression
  /// representing the integral. Note that the "+ C" constant is not explicitly added.
  ///
  /// [expression] can be either:
  /// - A parsed [Expression] AST (from [parse])
  /// - A LaTeX string that will be automatically parsed
  ///
  /// [variable] is the variable to integrate with respect to (e.g., 'x').
  ///
  /// Returns the symbolic integral as an [Expression] AST node.
  /// If an analytical solution cannot be determined, it returns an [IntegralExpr].
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  ///
  /// // Option 1: Parse then integrate
  /// final expr = evaluator.parse('x^2');
  /// final integral = evaluator.integrate(expr, 'x'); // x^3 / 3
  ///
  /// // Option 2: Direct string (more convenient)
  /// final integral2 = evaluator.integrate('x^2', 'x');
  /// ```
  Expression integrate(dynamic expression, String variable) {
    // Parse string expressions automatically
    final expr =
        expression is String ? parse(expression) : expression as Expression;

    if (expr is IntegralExpr) {
      return _evaluator.integrationEvaluator.integrateIntegralExpr(expr);
    }
    return _evaluator.integrationEvaluator.integrate(expr, variable);
  }

  // ============================================================
  // Step-by-Step Traced Operations
  // ============================================================

  /// Computes symbolic derivative with step-by-step trace.
  ///
  /// Returns a [TracedResult] containing both the derivative and
  /// a list of transformation steps showing the work.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  /// final result = evaluator.differentiateWithSteps('x^3 + 2x', 'x');
  ///
  /// print('Result: ${result.result.toLatex()}'); // 3x^2 + 2
  /// print('Steps: ${result.stepCount}');
  /// print(result.formatSteps());
  /// // Step 1 [Differentiation] Sum rule: d/dx(f + g) = f' + g'
  /// //   x^{3}+2x → 3x^{2}+2
  /// ```
  TracedResult<Expression> differentiateWithSteps(
    dynamic expression,
    String variable, {
    int order = 1,
  }) {
    final expr =
        expression is String ? parse(expression) : expression as Expression;
    return _evaluator.differentiationEvaluator.differentiateWithSteps(
      expr,
      variable,
      order: order,
    );
  }

  /// Simplifies expression with step-by-step trace.
  ///
  /// Returns a [TracedResult] containing both the simplified expression
  /// and a list of transformation steps.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  /// final result = evaluator.simplifyWithSteps('x + 0 + x');
  ///
  /// print('Result: ${result.result.toLatex()}'); // 2x
  /// print(result.formatSteps());
  /// // Step 1 [Identity] Additive identity: x + 0 = x
  /// //   x+0+x → x+x
  /// // Step 2 [Simplification] Combine like terms: x + x = 2x
  /// //   x+x → 2x
  /// ```
  TracedResult<Expression> simplifyWithSteps(dynamic expression) {
    final expr =
        expression is String ? parse(expression) : expression as Expression;
    final engine = SymbolicEngine(maxRecursionDepth: maxRecursionDepth);
    return engine.simplifyWithSteps(expr);
  }

  /// Expands polynomial expression with step-by-step trace.
  ///
  /// Returns a [TracedResult] containing both the expanded expression
  /// and a list of transformation steps.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  /// final result = evaluator.expandWithSteps('(x + 1)^2');
  ///
  /// print('Result: ${result.result.toLatex()}'); // x^2 + 2x + 1
  /// print(result.formatSteps());
  /// // Step 1 [Expansion] Binomial theorem: (a + b)^2 = Σ C(2,k) · a^(2-k) · b^k
  /// //   (x+1)^{2} → x^{2}+2x+1
  /// ```
  TracedResult<Expression> expandWithSteps(dynamic expression) {
    final expr =
        expression is String ? parse(expression) : expression as Expression;
    final engine = SymbolicEngine(maxRecursionDepth: maxRecursionDepth);
    return engine.expandWithSteps(expr);
  }

  /// Factors expression with step-by-step trace.
  ///
  /// Returns a [TracedResult] containing both the factored expression
  /// and a list of transformation steps.
  ///
  /// Example:
  /// ```dart
  /// final evaluator = Texpr();
  /// final result = evaluator.factorWithSteps('x^2 - 1');
  ///
  /// print('Result: ${result.result.toLatex()}'); // (x-1)(x+1)
  /// print(result.formatSteps());
  /// // Step 1 [Factorization] Difference of squares: a² - b² = (a - b)(a + b)
  /// //   x^{2}-1 → (x-1)(x+1)
  /// ```
  TracedResult<Expression> factorWithSteps(dynamic expression) {
    final expr =
        expression is String ? parse(expression) : expression as Expression;
    final engine = SymbolicEngine(maxRecursionDepth: maxRecursionDepth);
    return engine.factorWithSteps(expr);
  }
}
