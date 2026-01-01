import 'dart:math' as math;
import 'package:texpr/texpr.dart';

void main() {
  // Disable all caches to measure actual computation time
  // Without this, L2 evaluation cache returns cached matrix results
  final evaluator = LatexMathEvaluator(cacheConfig: CacheConfig.disabled);

  print('Matrix Performance Benchmarks');
  print('=' * 60);

  // Benchmark determinant calculation for various matrix sizes
  for (final size in [3, 4, 5, 6, 8, 10]) {
    benchmarkDeterminant(evaluator, size);
  }

  print('\n');
  print('Matrix Operations Benchmarks');
  print('=' * 60);

  // Benchmark matrix multiplication
  for (final size in [3, 5, 10, 20]) {
    benchmarkMultiplication(evaluator, size);
  }
}

void benchmarkDeterminant(LatexMathEvaluator evaluator, int size) {
  // Create a random matrix
  final random = math.Random(42); // Fixed seed for reproducibility
  final matrixStr = _createRandomMatrix(size, random);

  final expr = '\\det($matrixStr)';

  // Warm up
  for (var i = 0; i < 5; i++) {
    evaluator.evaluate(expr);
  }

  // Benchmark
  const iterations = 100;
  final stopwatch = Stopwatch()..start();

  for (var i = 0; i < iterations; i++) {
    evaluator.evaluate(expr);
  }

  stopwatch.stop();
  final avgTimeMs = stopwatch.elapsedMicroseconds / iterations / 1000;

  print('${size}x$size determinant: ${avgTimeMs.toStringAsFixed(2)} ms/op');
}

void benchmarkMultiplication(LatexMathEvaluator evaluator, int size) {
  final random = math.Random(42);
  final matrix1 = _createRandomMatrix(size, random);
  final matrix2 = _createRandomMatrix(size, random);

  final expr = '$matrix1 * $matrix2';

  // Warm up
  for (var i = 0; i < 5; i++) {
    evaluator.evaluate(expr);
  }

  // Benchmark
  const iterations = 50;
  final stopwatch = Stopwatch()..start();

  for (var i = 0; i < iterations; i++) {
    evaluator.evaluate(expr);
  }

  stopwatch.stop();
  final avgTimeMs = stopwatch.elapsedMicroseconds / iterations / 1000;

  print('${size}x$size multiplication: ${avgTimeMs.toStringAsFixed(2)} ms/op');
}

String _createRandomMatrix(int size, math.Random random) {
  final rows = <String>[];
  for (var i = 0; i < size; i++) {
    final row = List.generate(
      size,
      (_) => (random.nextDouble() * 10).toStringAsFixed(1),
    ).join(' & ');
    rows.add(row);
  }
  return '\\begin{matrix} ${rows.join(r' \\ ')} \\end{matrix}';
}
