import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  test('Matrix evaluation', () {
    final evaluator = Texpr();
    // Simple 2x2 matrix
    // \begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}
    final matrix = '\\begin{matrix} 1 & 2 \\\\ 3 & 4 \\end{matrix}';

    final result = evaluator.evaluate(matrix).asMatrix();
    expect(result, isA<Matrix>());
    final m = result;
    expect(m.rows, 2);
    expect(m.cols, 2);
    expect(m.data[0][0], 1.0);
    expect(m.data[0][1], 2.0);
    expect(m.data[1][0], 3.0);
    expect(m.data[1][1], 4.0);
  });

  test('Matrix addition', () {
    final evaluator = Texpr();
    final expr =
        '\\begin{matrix} 1 & 2 \\\\ 3 & 4 \\end{matrix} + \\begin{matrix} 5 & 6 \\\\ 7 & 8 \\end{matrix}';
    final result = evaluator.evaluate(expr).asMatrix();
    expect(result, isA<Matrix>());
    final m = result;
    expect(m.data[0][0], 6.0);
    expect(m.data[0][1], 8.0);
    expect(m.data[1][0], 10.0);
    expect(m.data[1][1], 12.0);
  });

  test('Matrix multiplication', () {
    final evaluator = Texpr();
    // [1 2] * [5 6] = [1*5+2*7 1*6+2*8] = [19 22]
    // [3 4]   [7 8]   [3*5+4*7 3*6+4*8]   [43 50]
    final expr =
        '\\begin{matrix} 1 & 2 \\\\ 3 & 4 \\end{matrix} * \\begin{matrix} 5 & 6 \\\\ 7 & 8 \\end{matrix}';
    final result = evaluator.evaluate(expr).asMatrix();
    expect(result, isA<Matrix>());
    final m = result;
    expect(m.data[0][0], 19.0);
    expect(m.data[0][1], 22.0);
    expect(m.data[1][0], 43.0);
    expect(m.data[1][1], 50.0);
  });

  test('Matrix scalar multiplication', () {
    final evaluator = Texpr();
    final expr = '2 * \\begin{matrix} 1 & 2 \\\\ 3 & 4 \\end{matrix}';
    final result = evaluator.evaluate(expr).asMatrix();
    expect(result, isA<Matrix>());
    final m = result;
    expect(m.data[0][0], 2.0);
    expect(m.data[0][1], 4.0);
    expect(m.data[1][0], 6.0);
    expect(m.data[1][1], 8.0);
  });

  test('Large matrix determinant (4x4)', () {
    final evaluator = Texpr();
    // Create a 4x4 matrix with known determinant
    final expr =
        r'\det(\begin{matrix} 1 & 2 & 3 & 4 \\ 5 & 6 & 7 & 8 \\ 9 & 10 & 11 & 12 \\ 13 & 14 & 15 & 16 \end{matrix})';
    final result = evaluator.evaluate(expr).asNumeric();
    // This singular matrix should have determinant 0
    expect(result, equals(0.0));
  });

  test('Large matrix determinant (5x5)', () {
    final evaluator = Texpr();
    // Create a 5x5 identity-like matrix
    final expr =
        r'\det(\begin{matrix} 2 & 0 & 0 & 0 & 0 \\ 0 & 3 & 0 & 0 & 0 \\ 0 & 0 & 4 & 0 & 0 \\ 0 & 0 & 0 & 5 & 0 \\ 0 & 0 & 0 & 0 & 6 \end{matrix})';
    final result = evaluator.evaluate(expr).asNumeric();
    // Determinant of diagonal matrix is product of diagonal elements
    expect(result, equals(2.0 * 3 * 4 * 5 * 6)); // 720
  });

  test('Large matrix determinant (6x6) with non-zero pattern', () {
    final evaluator = Texpr();
    // Upper triangular matrix - det is product of diagonal
    final expr =
        r'\det(\begin{matrix} 1 & 2 & 3 & 4 & 5 & 6 \\ 0 & 1 & 2 & 3 & 4 & 5 \\ 0 & 0 & 1 & 2 & 3 & 4 \\ 0 & 0 & 0 & 1 & 2 & 3 \\ 0 & 0 & 0 & 0 & 1 & 2 \\ 0 & 0 & 0 & 0 & 0 & 1 \end{matrix})';
    final result = evaluator.evaluate(expr).asNumeric();
    // Upper triangular matrix: determinant is product of diagonal (all 1s)
    expect(result, equals(1.0));
  });

  test('Large matrix operations (10x10 identity)', () {
    // Test that we can handle reasonably large matrices
    final evaluator = Texpr();
    final identityRows = List.generate(10, (i) {
      final row = List.generate(10, (j) => i == j ? '1' : '0').join(' & ');
      return row;
    }).join(r' \\ ');

    final expr = '\\det(\\begin{matrix} $identityRows \\end{matrix})';
    final result = evaluator.evaluate(expr).asNumeric();
    // Determinant of identity matrix is 1
    expect(result, equals(1.0));
  });
}
