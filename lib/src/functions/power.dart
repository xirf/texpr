/// Power and root function handlers with complex number support.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../complex.dart';
import '../exceptions.dart';

/// Square root or nth root: \sqrt{x} or \sqrt[n]{x} - supports complex
dynamic handleSqrt(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);

  // Check for nth root via optional parameter
  if (func.optionalParam != null) {
    final n = evaluate(func.optionalParam!);
    if (n is! num) {
      throw EvaluatorException('Root index must be a number');
    }
    if (n == 0) {
      throw EvaluatorException('Cannot compute 0th root');
    }

    if (arg is Complex) {
      return arg.pow(1 / n.toDouble());
    }
    if (arg is num) {
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
    throw EvaluatorException('sqrt requires a numeric or complex argument');
  }

  // Default: square root
  if (arg is Complex) return arg.sqrt();
  if (arg is num) {
    if (arg < 0) {
      // Return complex result for negative numbers
      return Complex(arg.toDouble()).sqrt();
    }
    return math.sqrt(arg.toDouble());
  }
  throw EvaluatorException('sqrt requires a numeric or complex argument');
}

/// Exponential: \exp{x} - supports complex arguments
dynamic handleExp(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.exp();
  if (arg is num) return math.exp(arg.toDouble());
  throw EvaluatorException('exp requires a numeric or complex argument');
}
