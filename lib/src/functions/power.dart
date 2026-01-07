/// Power and root function handlers with complex number support.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../complex.dart';
import '../exceptions.dart';
import '../interval.dart';

/// Square root or nth root: \sqrt{x} or \sqrt[n]{x} - supports complex and interval
dynamic handleSqrt(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);

  // Check for nth root via optional parameter
  if (func.optionalParam != null) {
    final n = evaluate(func.optionalParam!);
    if (n is! num && n is! Interval) {
      throw EvaluatorException('Root index must be a number or interval');
    }

    // n can be num or Interval
    if (n is num && n == 0) {
      throw EvaluatorException('Cannot compute 0th root');
    }

    if (arg is Complex) {
      if (n is num) return arg.pow(1 / n.toDouble());
      // Complex ^ (1/Interval)? Not supported easily.
      throw EvaluatorException(
          'Complex base with interval root index not supported');
    }

    if (arg is Interval) {
      // x^(1/n) = exp(ln(x)/n)
      try {
        final logArg = arg.log();
        if (n is num) {
          return (logArg / n).exp();
        } else if (n is Interval) {
          return (logArg / n).exp();
        }
      } catch (e) {
        // log might throw if arg <= 0.
        if (arg.lower < 0) {
          // For intervals including negative numbers, even roots are problematic in Real Interval Arithmetic.
          // We typically throw or return Empty if undefined.
          // Interval.sqrt throws.
          throw EvaluatorException(
              'Root of interval with negative values requires complex intervals');
        }
        rethrow;
      }
    }

    if (arg is num) {
      if (n is num) {
        if (arg < 0 && n % 2 == 0) {
          // Even root of negative: return complex
          return Complex(arg.toDouble()).pow(1 / n.toDouble());
        }
        if (arg < 0 && n % 2 == 1) {
          // Odd root of negative: -(-x)^(1/n)
          return -math.pow(-arg.toDouble(), 1 / n.toDouble());
        }
        return math.pow(arg.toDouble(), 1 / n.toDouble());
      }
      // arg is num, n is Interval
      // a^(1/N) = exp(ln(a)/N)
      if (arg <= 0)
        throw EvaluatorException(
            'Root base must be positive for interval index');
      return (Interval.point(arg.toDouble()).log() / n).exp();
    }
    throw EvaluatorException(
        'sqrt requires a numeric, complex or interval argument');
  }

  // Default: square root
  if (arg is Complex) return arg.sqrt();
  if (arg is Interval) return arg.sqrt();
  if (arg is num) {
    if (arg < 0) {
      // Return complex result for negative numbers
      return Complex(arg.toDouble()).sqrt();
    }
    return math.sqrt(arg.toDouble());
  }
  throw EvaluatorException(
      'sqrt requires a numeric, complex or interval argument');
}

/// Exponential: \exp{x} - supports complex and interval arguments
dynamic handleExp(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.exp();
  if (arg is Interval) return arg.exp();
  if (arg is num) return math.exp(arg.toDouble());
  throw EvaluatorException(
      'exp requires a numeric, complex or interval argument');
}
