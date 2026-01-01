/// Matrix evaluation logic.
library;

import '../../ast.dart';
import '../../exceptions.dart';
import '../../matrix.dart';

/// Handles evaluation of matrix expressions.
class MatrixEvaluator {
  /// Callback to evaluate arbitrary expressions.
  final dynamic Function(Expression, Map<String, double>) _evaluate;

  /// Creates a matrix evaluator with a callback for evaluating expressions.
  MatrixEvaluator(this._evaluate);

  /// Evaluates a matrix expression.
  ///
  /// Each cell is evaluated and must result in a number.
  Matrix evaluate(MatrixExpr matrix, Map<String, double> variables) {
    final rows = matrix.rows.map((row) {
      return row.map((cell) {
        final val = _evaluate(cell, variables);
        if (val is! double) {
          throw EvaluatorException(
            'Matrix elements must evaluate to numbers',
            suggestion: 'Ensure all matrix elements are numeric expressions',
          );
        }
        return val;
      }).toList();
    }).toList();
    return Matrix(rows);
  }
}
