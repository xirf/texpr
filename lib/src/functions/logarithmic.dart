/// Logarithmic function handlers with complex number support.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../complex.dart';
import '../exceptions.dart';

/// Natural logarithm: \ln{x} - supports complex arguments
dynamic handleLn(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.log();
  if (arg is num) {
    if (arg <= 0) {
      // Return complex result for non-positive real numbers
      return Complex(arg.toDouble()).log();
    }
    return math.log(arg.toDouble());
  }
  throw EvaluatorException('ln requires a numeric or complex argument');
}

/// Logarithm: \log{x} or \log_{base}{x} - supports complex arguments
dynamic handleLog(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);

  if (func.base != null) {
    final base = evaluate(func.base!);
    if (base is! num || base <= 0 || base == 1) {
      throw EvaluatorException('Invalid logarithm base');
    }
    final logBase = math.log(base.toDouble());

    if (arg is Complex) {
      final logArg = arg.log();
      return logArg / logBase;
    }
    if (arg is num) {
      if (arg <= 0) {
        return Complex(arg.toDouble()).log() / logBase;
      }
      return math.log(arg.toDouble()) / logBase;
    }
    throw EvaluatorException('log requires a numeric or complex argument');
  }

  // log base 10
  if (arg is Complex) {
    return arg.log() / math.ln10;
  }
  if (arg is num) {
    if (arg <= 0) {
      return Complex(arg.toDouble()).log() / math.ln10;
    }
    return math.log(arg.toDouble()) / math.ln10;
  }
  throw EvaluatorException('log requires a numeric or complex argument');
}
