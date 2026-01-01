import 'package:texpr/texpr.dart';

void benchmarkEvaluate(
    {required LatexMathEvaluator evaluator,
    required String label,
    required String expression,
    required int iterations}) {
  final sw = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    evaluator.evaluate(expression, {'x': (i % 10).toDouble()});
  }
  sw.stop();
  print(
      '$label: ${sw.elapsedMilliseconds} ms; avg ${(sw.elapsedMilliseconds / iterations).toStringAsFixed(4)} ms/op');
}

void benchmarkFibonacci(
    {required LatexMathEvaluator evaluator,
    required int n,
    required int iterations}) {
  final actual = '\\fibonacci{$n}';
  print('Fibonacci benchmark (n=$n):');
  final sw = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    evaluator.evaluate(actual);
  }
  sw.stop();
  print(
      '  Ran $iterations iterations: ${sw.elapsedMilliseconds} ms; avg ${(sw.elapsedMilliseconds / iterations).toStringAsFixed(4)} ms/op');
}

void main(List<String> args) {
  print('Expression Cache Benchmark');

  final expr = r'x^{2} + 2x + 1';
  const iterations = 2000;

  // Use CacheConfig to properly control ALL cache layers
  // parsedExpressionCacheSize: 0 alone only disables L1 (parse cache)
  // but L2 (evaluation cache), L3 (differentiation cache), L4 (sub-expression cache)
  // would still be active with defaults!
  final withCache = LatexMathEvaluator(
    cacheConfig: CacheConfig.highPerformance,
  );
  final withoutCache = LatexMathEvaluator(
    cacheConfig: CacheConfig.disabled,
  );

  // Warmup
  print('Warming up JIT (light warmup)...');
  for (var i = 0; i < 100; i++) {
    withCache.evaluate(expr, {'x': i.toDouble()});
    withoutCache.evaluate(expr, {'x': i.toDouble()});
  }

  print(
      '\nBenchmark: repeated evaluate() calls (with and without parsed-expression caching)');
  benchmarkEvaluate(
      evaluator: withoutCache,
      label: 'Without cache',
      expression: expr,
      iterations: iterations);
  benchmarkEvaluate(
      evaluator: withCache,
      label: 'With cache',
      expression: expr,
      iterations: iterations);

  print(
      '\nBenchmark: parsed parse() + evaluateParsed (with cache) vs reparse on each evaluate');

  // For parse-once vs re-parse comparison, disable all caches
  // This measures: does parsing once help when caching is off?
  final evaluatorParseOnce = LatexMathEvaluator(
    cacheConfig: CacheConfig.disabled,
  );

  final parsed = evaluatorParseOnce.parse(expr);

  // time evaluating a parsed expression (no parse cost)
  final sw = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    evaluatorParseOnce.evaluateParsed(parsed, {'x': (i % 10).toDouble()});
  }
  sw.stop();
  print(
      'evaluateParsed (no parse every time): ${sw.elapsedMilliseconds} ms; avg ${(sw.elapsedMilliseconds / iterations).toStringAsFixed(4)} ms/op');

  // Now re-evaluate with parse each time
  final sw2 = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    evaluatorParseOnce.evaluate(expr, {'x': (i % 10).toDouble()});
  }
  sw2.stop();
  print(
      'evaluate (parse every time): ${sw2.elapsedMilliseconds} ms; avg ${(sw2.elapsedMilliseconds / iterations).toStringAsFixed(4)} ms/op');

  print('\nFibonacci memoization benchmark:');
  final fibEval = LatexMathEvaluator();
  final n = 40; // moderate index to show cost
  // first run (should compute and cache values upto n)
  benchmarkFibonacci(evaluator: fibEval, n: n, iterations: 5);
  // second run (values should be cached already)
  benchmarkFibonacci(evaluator: fibEval, n: n, iterations: 100);

  print('\nDone.');
}
