import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  group('Advanced Matrix Operations', () {
    final evaluator = LatexMathEvaluator();

    test('Matrix Transpose', () {
      // A = [[1, 2], [3, 4]]
      // A^T = [[1, 3], [2, 4]]
      final result = evaluator
          .evaluate(r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}^T')
          .asMatrix();
      expect(result, isA<Matrix>());
      final matrix = result;
      expect(matrix.rows, 2);
      expect(matrix.cols, 2);
      expect(matrix[0][0], 1.0);
      expect(matrix[0][1], 3.0);
      expect(matrix[1][0], 2.0);
      expect(matrix[1][1], 4.0);
    });

    test('Matrix Determinant (Function)', () {
      // det([[1, 2], [3, 4]]) = 1*4 - 2*3 = 4 - 6 = -2
      final result = evaluator
          .evaluate(r'\det(\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix})')
          .asNumeric();
      expect(result, -2.0);
    });

    test('Matrix Inverse', () {
      // A = [[4, 7], [2, 6]]
      // det(A) = 24 - 14 = 10
      // A^-1 = 1/10 * [[6, -7], [-2, 4]] = [[0.6, -0.7], [-0.2, 0.4]]
      final result = evaluator
          .evaluate(r'\begin{pmatrix} 4 & 7 \\ 2 & 6 \end{pmatrix}^{-1}')
          .asMatrix();
      expect(result, isA<Matrix>());
      final matrix = result;
      expect(matrix[0][0], closeTo(0.6, 1e-9));
      expect(matrix[0][1], closeTo(-0.7, 1e-9));
      expect(matrix[1][0], closeTo(-0.2, 1e-9));
      expect(matrix[1][1], closeTo(0.4, 1e-9));
    });
  });

  group('Numerical Integration', () {
    final evaluator = LatexMathEvaluator();

    test('Integral of x dx', () {
      // \int_0^1 x dx = [x^2/2]_0^1 = 0.5
      final result = evaluator.evaluate(r'\int_{0}^{1} x dx').asNumeric();
      expect(result, closeTo(0.5, 1e-3));
    });

    test('Integral of x^2 dx', () {
      // \int_0^3 x^2 dx = [x^3/3]_0^3 = 9
      final result = evaluator.evaluate(r'\int_{0}^{3} x^2 dx').asNumeric();
      expect(result, closeTo(9.0, 1e-3));
    });

    test('Integral with function call', () {
      // \int_0^\pi \sin(x) dx = [-\cos(x)]_0^\pi = -(-1) - (-1) = 2
      final result =
          evaluator.evaluate(r'\int_{0}^{\pi} \sin(x) dx').asNumeric();
      expect(result, closeTo(2.0, 1e-3));
    });

    test('Integral with explicit multiplication', () {
      // \int_0^1 2*x dx = 1
      final result = evaluator.evaluate(r'\int_{0}^{1} 2*x dx').asNumeric();
      expect(result, closeTo(1.0, 1e-3));
    });
  });
}
