import 'package:texpr/texpr.dart';

void main() {
  final e = LatexMathEvaluator();

  print('--- Vector Demo ---\n');

  // 1) Create a vector.
  print('1) Create a vector');
  final v = e.evaluate(r'\vec{1, 2, 3}').asVector();
  print(r"Expression: \vec{1, 2, 3}");
  print('Dimension: ${v.dimension}');
  print('Components: ${v.components}\n');

  // 2) Unit vector (normalization).
  print('2) Unit vector');
  final u = e.evaluate(r'\hat{3, 4}').asVector();
  print(r"Expression: \hat{3, 4}");
  print('Components: ${u.components}');
  print('Magnitude: ${u.magnitude}\n');

  // 3) Magnitude uses |v|.
  print('3) Magnitude');
  final mag = e.evaluate(r'|\vec{3, 4}|').asNumeric();
  print(r"Expression: |\vec{3, 4}| (vector length)");
  print('Result: $mag\n');

  // 4) Dot product.
  print('4) Dot product');
  final dot1 = e.evaluate(r'\vec{1, 2, 3} \cdot \vec{4, 5, 6}').asNumeric();
  final dot2 = e.evaluate(r'\vec{1, 2, 3} * \vec{4, 5, 6}').asNumeric();
  final dot3 = e.evaluate(r'\vec{1, 2, 3}\vec{4, 5, 6}').asNumeric();
  print(r"Expression: \vec{1, 2, 3} \cdot \vec{4, 5, 6}");
  print('Result: $dot1');
  print(r"Expression: \vec{1, 2, 3} * \vec{4, 5, 6} (same meaning)");
  print('Result: $dot2');
  print(r"Expression: \vec{1, 2, 3}\vec{4, 5, 6} (implicit multiplication)");
  print('Result: $dot3\n');

  // 5) Cross product (3D only).
  print('5) Cross product');
  final cross = e.evaluate(r'\vec{1, 0, 0} \times \vec{0, 1, 0}').asVector();
  print(r"Expression: \vec{1, 0, 0} \times \vec{0, 1, 0}");
  print('Result: ${cross.components}\n');

  // 6) Scalar multiplication and division.
  print('6) Scaling');
  final scaled = e.evaluate(r'2 * \vec{1, 2, 3}').asVector();
  final divided = e.evaluate(r'\vec{6, 9, 12} / 3').asVector();
  print(r"Expression: 2 * \vec{1, 2, 3}");
  print('Result: ${scaled.components}');
  print(r"Expression: \vec{6, 9, 12} / 3");
  print('Result: ${divided.components}\n');

  // 7) A common mistake: spaces are not commas.
  print('7) Common mistake');
  final notTwoD = e.evaluate(r'\vec{1 2}').asVector();
  print(r"Expression: \vec{1 2}");
  print('Parsed as a 1D vector: ${notTwoD.components}\n');

  // 8) Errors are explicit.
  print('8) Errors');
  try {
    e.evaluate(r'\vec{1, 2} + \vec{3, 4, 5}');
  } catch (err) {
    print('Dimension mismatch: $err');
  }

  try {
    e.evaluate(r'\hat{0, 0}');
  } catch (err) {
    print('Cannot normalize zero: $err');
  }
}
