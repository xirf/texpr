/// Vector-specific functions.
library;

import '../ast.dart';
import '../exceptions.dart';
import '../vector.dart';

/// Handles the magnitude function for vectors (used internally).
///
/// This is not directly exposed as a LaTeX function, but can be used
/// by extensions if needed. The magnitude is typically accessed via
/// absolute value notation |v|.
double handleMagnitude(
  FunctionCall func,
  Map<String, double> variables,
  dynamic Function(Expression) evaluate,
) {
  final val = evaluate(func.argument);
  if (val is Vector) {
    return val.magnitude;
  }
  throw EvaluatorException(
    'magnitude requires a vector argument',
    suggestion: 'Use \\vec{...} to create a vector',
  );
}

/// Handles vector normalization (used internally).
///
/// This is not directly exposed as a LaTeX function since we use
/// \hat{v} notation instead.
Vector handleNormalize(
  FunctionCall func,
  Map<String, double> variables,
  dynamic Function(Expression) evaluate,
) {
  final val = evaluate(func.argument);
  if (val is Vector) {
    return val.normalize();
  }
  throw EvaluatorException(
    'normalize requires a vector argument',
    suggestion:
        'Use \\vec{...} to create a vector or \\hat{...} for unit vector',
  );
}
