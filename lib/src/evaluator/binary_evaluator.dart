import '../ast.dart';
import '../exceptions.dart';
import '../matrix.dart';
import 'strategies/binary_operation_strategy.dart';
import 'strategies/number_number_strategy.dart';
import 'strategies/complex_strategy.dart';
import 'strategies/matrix_strategy.dart';
import 'strategies/vector_strategy.dart';
import 'strategies/interval_strategy.dart';

/// Handles evaluation of binary operations using the strategy pattern.
///
/// This evaluator delegates to specific strategies based on operand types,
/// making it easy to add new type combinations and operations.
class BinaryEvaluator {
  final List<BinaryOperationStrategy> _strategies = [
    // Order matters: more specific strategies first
    MatrixStrategy(),
    VectorStrategy(),
    ComplexStrategy(),
    IntervalStrategy(),
    NumberNumberStrategy(),
  ];

  /// Evaluates a binary operation between two expressions.
  ///
  /// Supports operations on numbers, complex numbers, matrices, and vectors.
  /// Special handling for matrix transpose (M^T), inverse (M^{-1}),
  /// and vector cross product.
  ///
  /// [rightValue] may be null for special cases like M^T where the right
  /// expression is not evaluated.
  dynamic evaluate(
    dynamic leftValue,
    BinaryOperator operator,
    dynamic rightValue,
    Expression expr,
  ) {
    // Special handling for Matrix Transpose: M^T
    if (leftValue is Matrix &&
        operator == BinaryOperator.power &&
        expr is BinaryOp &&
        expr.right is Variable &&
        (expr.right as Variable).name == 'T') {
      return leftValue.transpose();
    }

    // Get source token for vector operations
    final sourceToken = expr is BinaryOp ? expr.sourceToken : null;

    // Find appropriate strategy
    for (final strategy in _strategies) {
      if (strategy.canHandle(leftValue, rightValue)) {
        // Special handling for VectorStrategy to pass sourceToken
        if (strategy is VectorStrategy) {
          return strategy.evaluate(
            leftValue,
            operator,
            rightValue,
            sourceToken: sourceToken,
          );
        }
        return strategy.evaluate(leftValue, operator, rightValue);
      }
    }

    throw EvaluatorException(
      'Type mismatch in binary operation',
      suggestion:
          'Ensure both operands are compatible types (numbers, complex numbers, matrices, or vectors)',
    );
  }
}
