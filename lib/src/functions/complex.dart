import '../ast.dart';
import '../complex.dart';
import '../exceptions.dart';

dynamic handleRe(FunctionCall func, Map<String, double> variables,
    dynamic Function(Expression) evaluate) {
  if (func.args.length != 1) {
    throw EvaluatorException('Re() requires exactly 1 argument');
  }
  final val = evaluate(func.args[0]);
  if (val is Complex) return val.real;
  if (val is num) return val.toDouble();
  throw EvaluatorException('Re() argument must be a number or complex number');
}

dynamic handleIm(FunctionCall func, Map<String, double> variables,
    dynamic Function(Expression) evaluate) {
  if (func.args.length != 1) {
    throw EvaluatorException('Im() requires exactly 1 argument');
  }
  final val = evaluate(func.args[0]);
  if (val is Complex) return val.imaginary;
  if (val is num) return 0.0;
  throw EvaluatorException('Im() argument must be a number or complex number');
}

dynamic handleConjugate(FunctionCall func, Map<String, double> variables,
    dynamic Function(Expression) evaluate) {
  if (func.args.length != 1) {
    throw EvaluatorException('conjugate() requires exactly 1 argument');
  }
  final val = evaluate(func.args[0]);
  if (val is Complex) return val.conjugate;
  if (val is num) return Complex(val.toDouble());
  throw EvaluatorException(
      'conjugate() argument must be a number or complex number');
}
