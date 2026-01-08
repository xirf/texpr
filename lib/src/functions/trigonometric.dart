/// Trigonometric function handlers with complex number support.
library;

import 'dart:math' as math;

import '../ast.dart';
import '../complex.dart';
import '../exceptions.dart';
import '../interval.dart';

/// Sine: \sin{x} - supports real, complex, and interval arguments
dynamic handleSin(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.sin();
  if (arg is Interval) return arg.sin();
  if (arg is num) return math.sin(arg.toDouble());
  throw EvaluatorException(
      'sin requires a numeric, complex or interval argument');
}

/// Cosine: \cos{x} - supports real, complex, and interval arguments
dynamic handleCos(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.cos();
  if (arg is Interval) return arg.cos();
  if (arg is num) return math.cos(arg.toDouble());
  throw EvaluatorException(
      'cos requires a numeric, complex or interval argument');
}

/// Tangent: \tan{x} - supports real, complex, and interval arguments
dynamic handleTan(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) return arg.tan();
  if (arg is Interval) return arg.tan();
  if (arg is num) return math.tan(arg.toDouble());
  throw EvaluatorException(
      'tan requires a numeric, complex or interval argument');
}

/// Arcsine: \asin{x}
dynamic handleAsin(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Interval) return arg.asin();
  if (arg is num) {
    if (arg < -1 || arg > 1) {
      throw EvaluatorException('asin argument must be between -1 and 1');
    }
    return math.asin(arg.toDouble());
  }
  throw EvaluatorException('asin requires a numeric or interval argument');
}

/// Arccosine: \acos{x}
dynamic handleAcos(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Interval) return arg.acos();
  if (arg is num) {
    if (arg < -1 || arg > 1) {
      throw EvaluatorException('acos argument must be between -1 and 1');
    }
    return math.acos(arg.toDouble());
  }
  throw EvaluatorException('acos requires a numeric or interval argument');
}

/// Arctangent: \atan{x}
dynamic handleAtan(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Interval) return arg.atan();
  if (arg is num) return math.atan(arg.toDouble());
  throw EvaluatorException('atan requires a numeric or interval argument');
}

/// Secant: \sec{x} = 1/cos(x)
dynamic handleSec(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) {
    final cosVal = arg.cos();
    return cosVal.reciprocal;
  }
  if (arg is Interval) {
    return arg.cos().reciprocal;
  }
  if (arg is num) {
    final cosVal = math.cos(arg.toDouble());
    if (cosVal == 0) {
      throw EvaluatorException('sec is undefined at this point (cos = 0)');
    }
    return 1.0 / cosVal;
  }
  throw EvaluatorException(
      'sec requires a numeric, complex or interval argument');
}

/// Cosecant: \csc{x} = 1/sin(x)
dynamic handleCsc(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) {
    final sinVal = arg.sin();
    return sinVal.reciprocal;
  }
  if (arg is Interval) {
    return arg.sin().reciprocal;
  }
  if (arg is num) {
    final sinVal = math.sin(arg.toDouble());
    if (sinVal == 0) {
      throw EvaluatorException('csc is undefined at this point (sin = 0)');
    }
    return 1.0 / sinVal;
  }
  throw EvaluatorException(
      'csc requires a numeric, complex or interval argument');
}

/// Cotangent: \cot{x} = cos(x)/sin(x)
dynamic handleCot(FunctionCall func, Map<String, double> vars,
    dynamic Function(Expression) evaluate) {
  final arg = evaluate(func.argument);
  if (arg is Complex) {
    final tanVal = arg.tan();
    return tanVal.reciprocal;
  }
  if (arg is Interval) {
    return arg.tan().reciprocal;
  }
  if (arg is num) {
    final sinVal = math.sin(arg.toDouble());
    if (sinVal == 0) {
      throw EvaluatorException('cot is undefined at this point (sin = 0)');
    }
    return math.cos(arg.toDouble()) / sinVal;
  }
  throw EvaluatorException(
      'cot requires a numeric, complex or interval argument');
}
