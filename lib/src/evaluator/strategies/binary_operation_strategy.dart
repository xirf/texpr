/// Strategy pattern for binary operations.
library;

import 'package:texpr/texpr.dart';

/// Base interface for binary operation strategies.
///
/// Each strategy handles operations for a specific combination of types
/// (e.g., number-number, matrix-matrix, complex-complex).
abstract class BinaryOperationStrategy {
  /// Checks if this strategy can handle the given operand types.
  bool canHandle(dynamic left, dynamic right);

  /// Evaluates the binary operation.
  dynamic evaluate(
    dynamic left,
    BinaryOperator operator,
    dynamic right,
  );
}
