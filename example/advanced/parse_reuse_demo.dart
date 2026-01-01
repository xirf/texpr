import 'package:texpr/texpr.dart';

void main() {
  print('=== Parse Once, Evaluate Multiple Times Demo ===\n');

  final evaluator = LatexMathEvaluator();

  // Example 1: Quadratic equation
  print('1. Quadratic Equation: x^2 + 2x + 1');
  final quadratic = evaluator.parse(r'x^{2} + 2x + 1');

  print('   x = 1: ${evaluator.evaluateParsed(quadratic, {'x': 1})}');
  print('   x = 5: ${evaluator.evaluateParsed(quadratic, {'x': 5})}');
  print('');

  // Example 2: Multi-variable expression
  print('2. Multi-variable: 2x + 3y - z');
  final multiVar = evaluator.parse(r'2x + 3y - z');

  print('   x=1, y=2, z=3: ${evaluator.evaluateParsed(multiVar, {
        'x': 1,
        'y': 2,
        'z': 3
      })}');
  print('');

  // Example 3: Trigonometric function
  print(r'3. Trigonometric: \sin{x} + \cos{x}');
  final trig = evaluator.parse(r'\sin{x} + \cos{x}');

  print('   x = 0: ${evaluator.evaluateParsed(trig, {'x': 0})}');
  print('   x = π/4: ${evaluator.evaluateParsed(trig, {'x': 3.14159 / 4})}');
  print('   x = π/2: ${evaluator.evaluateParsed(trig, {'x': 3.14159 / 2})}');
  print('');

  // Example 4: Complex expression with fractions
  print(r'4. Fraction: \frac{a}{b} + \frac{c}{d}');
  final fraction = evaluator.parse(r'\frac{a}{b} + \frac{c}{d}');

  print('   a=1, b=2, c=1, d=4: ${evaluator.evaluateParsed(fraction, {
        'a': 1,
        'b': 2,
        'c': 1,
        'd': 4
      })}');

  print('');

  // Example 5: Performance comparison
  print('5. Performance Test (1000 evaluations)');
  final testExpr = r'x^{3} + 2x^{2} - 5x + 3';

  final stopwatch1 = Stopwatch()..start();
  for (int i = 0; i < 1000; i++) {
    evaluator.evaluate(testExpr, {'x': i.toDouble()});
  }
  stopwatch1.stop();
  print('   Parse+Evaluate each time: ${stopwatch1.elapsedMilliseconds}ms');

  final stopwatch2 = Stopwatch()..start();
  final parsed = evaluator.parse(testExpr);
  for (int i = 0; i < 1000; i++) {
    evaluator.evaluateParsed(parsed, {'x': i.toDouble()});
  }
  stopwatch2.stop();
  print('   Parse once, reuse: ${stopwatch2.elapsedMilliseconds}ms');
  print(
      '   Speedup: ${(stopwatch1.elapsedMilliseconds / stopwatch2.elapsedMilliseconds).toStringAsFixed(2)}x');
}
