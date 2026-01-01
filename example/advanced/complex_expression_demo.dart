import 'package:texpr/texpr.dart';

void main() {
  final evaluator = LatexMathEvaluator();

  print('=== Complex Expression Demo ===\n');

  final expr = r'\sin(\pi^3 x) \cdot \sqrt{\frac{e^2 - x^2}{2}} + \sqrt{|x|}';
  print('Expression: $expr\n');

  for (var x in [0.5, 1.0, 1.5, 2.0, 2.5]) {
    final result = evaluator.evaluate(expr, {'x': x});
    print('  x = $x => $result');
  }

  print('\n=== Fraction Examples ===\n');
  print('\\frac{1}{2} = ${evaluator.evaluate(r'\frac{1}{2}')}');
  print('\\frac{3 + 5}{4} = ${evaluator.evaluate(r'\frac{3 + 5}{4}')}');
  print('\\frac{\\pi}{2} = ${evaluator.evaluate(r'\frac{\pi}{2}')}');
  print('\\frac{e^2}{2} = ${evaluator.evaluate(r'\frac{e^2}{2}')}');

  print('\n=== Constant Examples ===\n');
  print('\\pi = ${evaluator.evaluate(r'\pi')}');
  print('\\tau = ${evaluator.evaluate(r'\tau')}');
  print('\\phi = ${evaluator.evaluate(r'\phi')}');
  print('2 \\pi = ${evaluator.evaluate(r'2 \pi')}');
  print('\\pi^2 = ${evaluator.evaluate(r'\pi^2')}');
}
