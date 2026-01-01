/// Rounding function handlers.
library;

import '../ast.dart';

/// Ceiling: \ceil{x}
double handleCeil(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  return evaluate(func.argument).ceilToDouble();
}

/// Floor: \floor{x}
double handleFloor(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  return evaluate(func.argument).floorToDouble();
}

/// Round: \round{x}
double handleRound(FunctionCall func, Map<String, double> vars,
    double Function(Expression) evaluate) {
  return evaluate(func.argument).roundToDouble();
}
