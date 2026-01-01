import 'expression.dart';
import 'visitor.dart';

/// A matrix expression.
class MatrixExpr extends Expression {
  final List<List<Expression>> rows;

  const MatrixExpr(this.rows);

  @override
  String toString() => 'MatrixExpr($rows)';

  @override
  String toLatex() {
    final rowsLatex = rows.map((row) {
      return row.map((expr) => expr.toLatex()).join(' & ');
    }).join(' \\\\ ');
    return '\\begin{bmatrix}$rowsLatex\\end{bmatrix}';
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitMatrixExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MatrixExpr &&
          runtimeType == other.runtimeType &&
          _rowsEquals(rows, other.rows);

  @override
  int get hashCode => Object.hashAll(rows.expand((row) => row));

  static bool _rowsEquals(List<List<Expression>> a, List<List<Expression>> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (!_listEquals(a[i], b[i])) return false;
    }
    return true;
  }

  static bool _listEquals(List<Expression> a, List<Expression> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// A vector expression created via \vec{...} or \hat{...}.
class VectorExpr extends Expression {
  final List<Expression> components;
  final bool isUnitVector;

  const VectorExpr(this.components, {this.isUnitVector = false});

  @override
  String toString() =>
      isUnitVector ? 'UnitVector($components)' : 'VectorExpr($components)';

  @override
  String toLatex() {
    final componentsLatex = components.map((c) => c.toLatex()).join(',');
    if (isUnitVector) {
      return '\\hat{$componentsLatex}';
    }
    return '\\vec{$componentsLatex}';
  }

  @override
  R accept<R, C>(ExpressionVisitor<R, C> visitor, C? context) {
    return visitor.visitVectorExpr(this, context);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorExpr &&
          runtimeType == other.runtimeType &&
          isUnitVector == other.isUnitVector &&
          _listEquals(components, other.components);

  @override
  int get hashCode => Object.hashAll(components) ^ isUnitVector.hashCode;

  static bool _listEquals(List<Expression> a, List<Expression> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
