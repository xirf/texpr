import 'package:texpr/texpr.dart';

void main() {
  final evaluator = Texpr();

  print('=== Absolute Value Demo ===\n');

  print('Example 1: Basic absolute values');
  print('  |-5| = ${evaluator.evaluate(r'|-5|')}');
  print('  |5| = ${evaluator.evaluate(r'|5|')}');
  print('  |0| = ${evaluator.evaluate(r'|0|')}');
  print('  |-3.14| = ${evaluator.evaluate(r'|-3.14|')}');

  print('\nExample 2: Absolute value with expressions');
  print('  |2 - 5| = ${evaluator.evaluate(r'|2 - 5|')}');
  print('  |x^2 - 4| with x=1 = ${evaluator.evaluate(r'|x^2 - 4|', {'x': 1})}');
  print('  |x^2 - 4| with x=3 = ${evaluator.evaluate(r'|x^2 - 4|', {'x': 3})}');

  print('\nExample 3: Using \\abs{} notation');
  print('  \\abs{-7} = ${evaluator.evaluate(r'\abs{-7}')}');
  print(
      '  \\abs{x} with x=-10 = ${evaluator.evaluate(r'\abs{x}', {'x': -10})}');

  print('\nExample 4: Nested absolute values');
  print('  ||x|| with x=-5 = ${evaluator.evaluate(r'||x||', {'x': -5})}');
  print('  ||-3|| = ${evaluator.evaluate(r'||-3||')}');

  print('\nExample 5: Absolute value in complex expressions');
  print('  2 * |x - 3| with x=1 = ${evaluator.evaluate(r'2 * |x - 3|', {
        'x': 1
      })}');
  print('  |sin(x)| with x=0 = ${evaluator.evaluate(r'|\sin{x}|', {'x': 0})}');
  print('  |sin(x)| with x=π = ${evaluator.evaluate(r'|\sin{x}|', {
        'x': 3.14159
      })}');

  print('\nExample 6: Distance formula using absolute value');
  print('  |b - a| with a=3, b=7 = ${evaluator.evaluate(r'|b - a|', {
        'a': 3,
        'b': 7
      })}');
  print('  |b - a| with a=7, b=3 = ${evaluator.evaluate(r'|b - a|', {
        'a': 7,
        'b': 3
      })}');
}
