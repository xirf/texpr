import 'package:texpr/texpr.dart';

void main() {
  final expressions = [
    r'x^2 + 2x + 1',
    r'\frac{d}{dx}(x^3 + 2x^2 - 5x + 7)',
    r'\int_0^1 x^2 dx',
    r'\sum_{i=1}^{10} i^2',
    r'\sin(x) + \cos(x) + \tan(x)',
    r'\frac{x^2 + 1}{x - 1}',
    r'\sqrt{x^2 + y^2}',
    r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}',
    r'e^{x^2} + \ln(x)',
    r'\lim_{x \to 0} \frac{\sin(x)}{x}',
  ];

  print('Parser Performance Benchmark');
  print('=' * 60);
  print('Testing ${expressions.length} expressions...\n');

  final stopwatch = Stopwatch()..start();
  const iterations = 10000;

  for (var i = 0; i < iterations; i++) {
    for (final expr in expressions) {
      try {
        final evaluator = LatexMathEvaluator();
        evaluator.parse(expr);
      } catch (e) {
        // Ignore evaluation errors, we're testing parsing
      }
    }
  }

  stopwatch.stop();
  final totalExpressions = iterations * expressions.length;
  final avgTimePerExpression = stopwatch.elapsedMicroseconds / totalExpressions;

  print('Results:');
  print('-' * 60);
  print('Total expressions parsed: $totalExpressions');
  print('Total time: ${stopwatch.elapsedMilliseconds}ms');
  print(
      'Average time per expression: ${avgTimePerExpression.toStringAsFixed(2)}μs');
  print(
      'Expressions per second: ${(1000000 / avgTimePerExpression).toStringAsFixed(0)}');
  print('\nOptimizations applied:');
  print('  ✓ Non-allocating match1() for single tokens');
  print('  ✓ Token caching with matchToken()');
  print('  ✓ Pre-parsed numeric values');
  print('  ✓ Interned string constants');
  print('  ✓ Pre-sized variable arrays');
  print('  ✓ Selective recursion guards');
  print('  ✓ Inline pragmas on hot paths');
}
