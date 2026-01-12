/// Built-in function registry.
///
/// Functions are organized into separate files by category:
/// - [logarithmic.dart] - ln, log
/// - [trigonometric.dart] - sin, cos, tan, sec, csc, cot, asin, acos, atan
/// - [hyperbolic.dart] - sinh, cosh, tanh, sech, csch, coth, asinh, acosh, atanh
/// - [rounding.dart] - ceil, floor, round
/// - [power.dart] - sqrt, exp
/// - [other.dart] - abs, sgn, factorial, fibonacci, min, max
library;

import '../ast.dart';
import '../exceptions.dart';

import 'logarithmic.dart' as log;
import 'trigonometric.dart' as trig;
import 'hyperbolic.dart' as hyper;
import 'rounding.dart' as round;
import 'power.dart' as pow;
import 'other.dart' as other;
import 'complex.dart' as complex;

/// Handler function type for evaluating a function call.
typedef FunctionHandler = dynamic Function(
  FunctionCall func,
  Map<String, double> variables,
  dynamic Function(Expression) evaluate,
);

/// Handler function type for functions that support real-only mode.
///
/// [realOnly] when true, operations that would produce complex numbers
/// (like sqrt of negative) should return NaN instead.
typedef RealOnlyAwareFunctionHandler = dynamic Function(
  FunctionCall func,
  Map<String, double> variables,
  dynamic Function(Expression) evaluate,
  bool realOnly,
);

/// Registry of built-in mathematical functions.
class FunctionRegistry {
  static final FunctionRegistry _instance = FunctionRegistry._();

  /// Singleton instance of the function registry.
  static FunctionRegistry get instance => _instance;

  final Map<String, FunctionHandler> _handlers = {};
  final Map<String, RealOnlyAwareFunctionHandler> _realOnlyAwareHandlers = {};

  FunctionRegistry._() {
    _registerBuiltins();
  }

  /// Creates a new registry (for testing or custom configurations).
  FunctionRegistry.custom();

  void _registerBuiltins() {
    // Helper to adapt double-returning handlers
    void reg(
        String name,
        double Function(
                FunctionCall, Map<String, double>, double Function(Expression))
            handler) {
      register(
          name,
          (f, v, e) => handler(f, v, (x) {
                final val = e(x);
                if (val is num) return val.toDouble();
                throw EvaluatorException('Expected number argument for $name');
              }));
    }

    // Logarithmic (dynamic - support complex, real-only aware)
    registerRealOnlyAware('ln', log.handleLn);
    registerRealOnlyAware('log', log.handleLog);

    // Trigonometric (dynamic - sin/cos/tan support complex)
    register('sin', trig.handleSin);
    register('cos', trig.handleCos);
    register('tan', trig.handleTan);
    register('sec', trig.handleSec);
    register('csc', trig.handleCsc);
    register('cot', trig.handleCot);
    register('asin', trig.handleAsin);
    register('acos', trig.handleAcos);
    register('atan', trig.handleAtan);

    // Hyperbolic (dynamic - sinh/cosh/tanh support complex)
    register('sinh', hyper.handleSinh);
    register('cosh', hyper.handleCosh);
    register('tanh', hyper.handleTanh);
    register('sech', hyper.handleSech);
    register('csch', hyper.handleCsch);
    register('coth', hyper.handleCoth);
    register('asinh', hyper.handleAsinh);
    register('acosh', hyper.handleAcosh);
    register('atanh', hyper.handleAtanh);

    // Power / Root (dynamic - support complex, real-only aware)
    registerRealOnlyAware('sqrt', pow.handleSqrt);
    register('exp', pow.handleExp);

    // Rounding
    reg('ceil', round.handleCeil);
    reg('floor', round.handleFloor);
    reg('round', round.handleRound);

    // Other
    register('abs', other.handleAbs);
    reg('sgn', other.handleSgn);
    reg('sign', other.handleSgn);
    reg('factorial', other.handleFactorial);
    reg('fibonacci', other.handleFibonacci);
    reg('min', other.handleMin);
    reg('max', other.handleMax);

    // Matrix functions (handle dynamic types directly)
    register('det', other.handleDet);
    register('trace', other.handleTrace);
    register('tr', other.handleTrace);

    // Combinatorics & Number Theory
    register('gcd', other.handleGcd);
    register('lcm', other.handleLcm);
    register('binom', other.handleBinom);

    // Complex functions
    register('Re', complex.handleRe);
    register('Im', complex.handleIm);
    register('conjugate', complex.handleConjugate);

    // Decoration functions (pass-through - display only)
    // These are for notation like \dot{x}, \ddot{x}, \bar{x}
    // and simply return the evaluated argument
    register('dot', (f, v, e) => e(f.argument));
    register('ddot', (f, v, e) => e(f.argument));
    register('bar', (f, v, e) => e(f.argument));
    register('overline', (f, v, e) => e(f.argument));
  }

  /// Registers a function handler.
  void register(String name, FunctionHandler handler) {
    _handlers[name] = handler;
  }

  /// Registers a real-only aware function handler.
  void registerRealOnlyAware(
      String name, RealOnlyAwareFunctionHandler handler) {
    _realOnlyAwareHandlers[name] = handler;
  }

  /// Checks if a function is registered.
  bool hasFunction(String name) =>
      _handlers.containsKey(name) || _realOnlyAwareHandlers.containsKey(name);

  /// Evaluates a function call.
  ///
  /// [realOnly] when true, functions like sqrt will return NaN for negative
  /// arguments instead of complex numbers. This is useful for graphing
  /// applications that expect Desmos-like behavior.
  ///
  /// Throws [EvaluatorException] if the function is not registered,
  /// with a did-you-mean suggestion if a similar function exists.
  dynamic evaluate(
    FunctionCall func,
    Map<String, double> variables,
    dynamic Function(Expression) evaluator, {
    bool realOnly = false,
  }) {
    // Check real-only aware handlers first
    final realOnlyHandler = _realOnlyAwareHandlers[func.name];
    if (realOnlyHandler != null) {
      return realOnlyHandler(func, variables, evaluator, realOnly);
    }

    // Fall back to standard handlers
    final handler = _handlers[func.name];
    if (handler != null) {
      return handler(func, variables, evaluator);
    }

    // Try to find a similar function name for did-you-mean suggestion
    final similar = _findSimilarFunction(func.name);
    throw EvaluatorException(
      'Unknown function: ${func.name}',
      suggestion: similar != null
          ? 'Did you mean "$similar"?'
          : 'Check that the function name is spelled correctly',
    );
  }

  /// Finds a similar function name using Levenshtein distance.
  String? _findSimilarFunction(String unknown) {
    final lower = unknown.toLowerCase();
    String? best;
    int bestDist = 3; // Max distance threshold

    final allNames = {..._handlers.keys, ..._realOnlyAwareHandlers.keys};
    for (final name in allNames) {
      final dist = _levenshtein(lower, name.toLowerCase());
      if (dist < bestDist) {
        bestDist = dist;
        best = name;
      }
    }
    return best;
  }

  /// Simple Levenshtein distance calculation.
  static int _levenshtein(String a, String b) {
    if (a == b) return 0;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;

    final dp = List.generate(a.length + 1, (_) => List.filled(b.length + 1, 0));
    for (int i = 0; i <= a.length; i++) {
      dp[i][0] = i;
    }
    for (int j = 0; j <= b.length; j++) {
      dp[0][j] = j;
    }

    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        dp[i][j] = [
          dp[i - 1][j] + 1,
          dp[i][j - 1] + 1,
          dp[i - 1][j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1),
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return dp[a.length][b.length];
  }
}
