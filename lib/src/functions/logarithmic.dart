/// Logarithmic function handlers with complex number support.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../complex.dart';
import '../exceptions.dart';
import '../interval.dart';

/// Natural logarithm: \ln{x} - supports complex and interval arguments
dynamic handleLn(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.log();
  if (arg is Interval) return arg.log();
  if (arg is num) {
    if (arg <= 0) {
      // Return complex result for non-positive real numbers
      return Complex(arg.toDouble()).log();
    }
    return math.log(arg.toDouble());
  }
  throw EvaluatorException(
      'ln requires a numeric, complex or interval argument');
}

/// Logarithm: \log{x} or \log_{base}{x} - supports complex and interval
dynamic handleLog(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);

  if (func.base != null) {
    final base = evaluate(func.base!);

    // Evaluate ln(base)
    dynamic logBase;
    if (base is num) {
      if (base <= 0 || base == 1) {
        throw EvaluatorException('Invalid logarithm base');
      }
      logBase = math.log(base.toDouble());
    } else if (base is Interval) {
      // Base interval should probably not contain 1 or <= 0
      // But let Interval.log() and division handle errors
      logBase = base.log();
      // If base contains 1, logBase contains 0, division will throw.
    } else if (base is Complex) {
      logBase = base.log();
    } else {
      throw EvaluatorException('Invalid logarithm base type');
    }

    if (arg is Complex) {
      // if base is Interval/num -> Complex / Interval?
      // Complex / num ok.
      // Complex / Interval -> Interval must be converted to Complex? or Error?
      // Generally mixing Complex and Interval is hard.
      // If logBase is Interval (real), treat as Complex(real, 0)? Or treat Interval as constant?
      // For now, if types mismatch in a way that BinaryEvaluator doesn't support, we throw.
      // But here we use /, which calls binary op.
      // result = ln(arg) / logBase.
      // Complex.log() returns Complex.
      // Complex / Interval is not supported in BinaryEvaluator/IntervalStrategy unless handle there.
      // Actually IntervalStrategy handles Interval op num.
      // ComplexStrategy handles Complex op num/Complex.
      // Complex / Interval is undefined.
      // We should try to cast Interval to something or throw.
      if (logBase is Interval) {
        throw EvaluatorException(
            'Complex log with Interval base not supported');
      }

      return arg.log() / logBase; // Complex / num or Complex / Complex
    }

    if (arg is Interval) {
      // ln(Interval) / logBase
      final lnArg = arg.log();
      // Interval / Interval -> ok
      // Interval / num -> ok
      // Interval / Complex -> throw
      if (logBase is Complex) {
        throw EvaluatorException(
            'Interval log with Complex base not supported');
      }

      if (logBase is num) return lnArg / logBase;
      if (logBase is Interval) return lnArg / logBase;
    }

    if (arg is num) {
      if (arg <= 0) {
        final lnArg = Complex(arg.toDouble()).log();
        if (logBase is Complex || logBase is num) {
          return lnArg / logBase;
        }
        // logBase is Interval
        throw EvaluatorException(
            'Complex log with Interval base not supported');
      }

      final lnArg = math.log(arg.toDouble());
      if (logBase is num) return lnArg / logBase;
      if (logBase is Complex) return Complex(lnArg) / logBase;
      if (logBase is Interval) {
        // num / Interval -> supported
        return Interval.point(lnArg) / logBase;
      }
    }
    throw EvaluatorException(
        'log requires a numeric, complex or interval argument');
  }

  // log base 10
  if (arg is Complex) {
    return arg.log() / math.ln10;
  }
  if (arg is Interval) {
    return arg.log() / math.ln10;
  }
  if (arg is num) {
    if (arg <= 0) {
      return Complex(arg.toDouble()).log() / math.ln10;
    }
    return math.log(arg.toDouble()) / math.ln10;
  }
  throw EvaluatorException(
      'log requires a numeric, complex or interval argument');
}
