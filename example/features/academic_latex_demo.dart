import 'package:texpr/texpr.dart';

void main() {
  final evaluator = Texpr();

  print('=== Academic LaTeX Support Demo ===\n');
  print(
      'Copy-paste expressions from papers/notes without removing delimiter sizing commands!\n');

  print('Example 1: Square root with absolute value (common in analysis)');
  print(r'  Expression: \sqrt{\left|x+1\right|}');
  print('  With x = -2: ${evaluator.evaluate(r'\sqrt{\left|x+1\right|}', {
        'x': -2
      }).asNumeric()}');
  print('  With x = 0:  ${evaluator.evaluate(r'\sqrt{\left|x+1\right|}', {
        'x': 0
      }).asNumeric()}');
  print('  With x = 3:  ${evaluator.evaluate(r'\sqrt{\left|x+1\right|}', {
        'x': 3
      }).asNumeric()}');

  print('\nExample 2: Nested delimiters (common in calculus)');
  print(r'  Expression: \left(\left(\frac{x}{2}\right)^2 + 1\right)');
  print(
      '  With x = 4:  ${evaluator.evaluate(r'\left(\left(\frac{x}{2}\right)^2 + 1\right)', {
        'x': 4
      }).asNumeric()}');

  print('\nExample 3: Physics formula with delimiters');
  print(r'  Expression: \left(\frac{1}{2}\right) m v^2  (kinetic energy)');
  print(
      '  With m = 2, v = 3: ${evaluator.evaluate(r'\left(\frac{1}{2}\right) m v^2', {
        'm': 2,
        'v': 3
      }).asNumeric()}');

  print('\nExample 4: Escaped braces notation');
  print(r'  Expression: \left\{x^2 - 1\right\} * 2');
  print('  With x = 3:  ${evaluator.evaluate(r'\left\{x^2 - 1\right\} * 2', {
        'x': 3
      }).asNumeric()}');

  print('\nExample 5: Trigonometric expression from textbook');
  print(r'  Expression: \left|\sin{\left(x\right)}\right|');
  print(
      '  With x = 0:     ${evaluator.evaluate(r'\left|\sin{\left(x\right)}\right|', {
        'x': 0
      }).asNumeric()}');
  print(
      '  With x = π/2:   ${evaluator.evaluate(r'\left|\sin{\left(x\right)}\right|', {
        'x': 3.14159 / 2
      }).asNumeric()}');

  print('\nExample 6: Complex fraction (engineering notation)');
  print(r'  Expression: \frac{\left|x-2\right|}{\left(x+1\right)}');
  print(
      '  With x = 5:  ${evaluator.evaluate(r'\frac{\left|x-2\right|}{\left(x+1\right)}', {
        'x': 5
      }).asNumeric()}');
  print(
      '  With x = -5: ${evaluator.evaluate(r'\frac{\left|x-2\right|}{\left(x+1\right)}', {
        'x': -5
      }).asNumeric()}');

  print('\nExample 7: Manual sizing commands (also work)');
  final bigResult = evaluator.evaluate(r'\big(2+3\big) * 4').asNumeric();
  final bigResultBig = evaluator.evaluate(r'\Big(2+3\Big) * 4').asNumeric();
  final biggResult = evaluator.evaluate(r'\bigg(2+3\bigg) * 4').asNumeric();
  final biggResultBig = evaluator.evaluate(r'\Bigg(2+3\Bigg) * 4').asNumeric();

  print('  \\big(2+3\\big) * 4     = $bigResult');
  print('  \\Big(2+3\\Big) * 4     = $bigResultBig');
  print('  \\bigg(2+3\\bigg) * 4   = $biggResult');
  print('  \\Bigg(2+3\\Bigg) * 4   = $biggResultBig');

  print('\n✅ All delimiter sizing commands are silently ignored!');
  print('   You can paste directly from LaTeX documents without modification.');
}
