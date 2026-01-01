/// Other miscellaneous function handlers.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../exceptions.dart';

import '../matrix.dart';

final List<double?> _factorialCache = List<double?>.filled(171, null);

final List<double> _fibonacciCache = <double>[0.0, 1.0];

/// Absolute value: \abs{x}
double handleAbs(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  return evaluate(func.argument).abs();
}

/// Sign function: \sgn{x}
double handleSgn(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final x = evaluate(func.argument);
  if (x > 0) return 1.0;
  if (x < 0) return -1.0;
  return 0.0;
}

/// Factorial: \factorial{n}
double handleFactorial(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final n = evaluate(func.argument).toInt();
  if (n < 0) {
    throw EvaluatorException('Factorial of negative number');
  }
  if (n > 170) {
    throw EvaluatorException('Factorial overflow');
  }
  final cached = _factorialCache[n];
  if (cached != null) return cached;
  double result = 1;
  for (int i = 2; i <= n; i++) {
    result *= i;
  }
  _factorialCache[n] = result;
  return result;
}

/// Fibonacci: \fibonacci{n}
///
/// Uses 0-indexed definition: fibonacci(0) = 0, fibonacci(1) = 1.
double handleFibonacci(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  final n = evaluate(func.argument).toInt();
  if (n < 0) {
    throw EvaluatorException('Fibonacci of negative number');
  }
  if (n >= 1477) {
    // fib(1477) overflows double to Infinity.
    throw EvaluatorException('Fibonacci overflow');
  }

  if (n < _fibonacciCache.length) {
    return _fibonacciCache[n];
  }

  // Double check cache size even though limited by n < 1477
  if (_fibonacciCache.length > 2000) {
    _fibonacciCache.clear();
    _fibonacciCache.addAll([0.0, 1.0]);
  }

  for (int i = _fibonacciCache.length; i <= n; i++) {
    final next = _fibonacciCache[i - 1] + _fibonacciCache[i - 2];
    if (!next.isFinite) {
      throw EvaluatorException('Fibonacci overflow');
    }
    _fibonacciCache.add(next);
  }
  return _fibonacciCache[n];
}

/// Minimum: \min_{a}{b}
double handleMin(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  if (func.base == null) {
    throw EvaluatorException('min requires two arguments: \\min_{a}{b}');
  }
  return math.min(evaluate(func.base!), evaluate(func.argument));
}

/// Maximum: \max_{a}{b}
double handleMax(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  if (func.base == null) {
    throw EvaluatorException('max requires two arguments: \\max_{a}{b}');
  }
  return math.max(evaluate(func.base!), evaluate(func.argument));
}

/// Determinant: \det{M}
double handleDet(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is! Matrix) {
    throw EvaluatorException('Argument to det must be a matrix');
  }
  return arg.determinant();
}

/// Trace: \trace{M}
double handleTrace(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is! Matrix) {
    throw EvaluatorException('Argument to trace must be a matrix');
  }
  return arg.trace();
}

/// GCD: \gcd(a, b)
double handleGcd(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  if (func.args.length != 2) {
    throw EvaluatorException('gcd requires two arguments');
  }
  final a = (evaluate(func.args[0]) as double).round();
  final b = (evaluate(func.args[1]) as double).round();
  return _gcd(a, b).toDouble();
}

int _gcd(int a, int b) {
  return b == 0 ? a : _gcd(b, a % b);
}

/// LCM: \lcm(a, b)
double handleLcm(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  if (func.args.length != 2) {
    throw EvaluatorException('lcm requires two arguments');
  }
  final a = (evaluate(func.args[0]) as double).round();
  final b = (evaluate(func.args[1]) as double).round();
  if (a == 0 || b == 0) return 0;
  return ((a * b).abs() / _gcd(a, b)).toDouble();
}

/// Binomial Coefficient: \binom{n}{k}
double handleBinom(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  if (func.args.length != 2) {
    throw EvaluatorException('binom requires two arguments');
  }
  final n = (evaluate(func.args[0]) as double).round();
  final k = (evaluate(func.args[1]) as double).round();

  if (k < 0 || k > n) return 0;
  if (k == 0 || k == n) return 1;
  if (k > n / 2) {
    return handleBinom(
        FunctionCall.multivar('binom',
            [NumberLiteral(n.toDouble()), NumberLiteral((n - k).toDouble())]),
        vars,
        evaluate);
  }

  double res = 1;
  for (int i = 1; i <= k; i++) {
    res = res * (n - i + 1) / i;
  }
  return res;
}
