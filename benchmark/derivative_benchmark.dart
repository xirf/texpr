import 'package:texpr/texpr.dart';

void benchmarkDerivativeEvaluation({
  required Texpr evaluator,
  required String label,
  required String expressionWithFrac, // \frac{d}{dx}(...) style string
  required Expression parsedExpression,
  required Expression symbolicDerivative,
  required int iterations,
}) {
  // Warmup small (avoid problematic values like x==1 where denominator is zero)
  for (var i = 0; i < 20; i++) {
    var xVal = (i % 10).toDouble();
    if (expressionWithFrac.contains('x - 1')) {
      xVal = 2 + (i % 10).toDouble();
    }
    try {
      evaluator.evaluate(expressionWithFrac, {'x': xVal});
    } catch (_) {}
    try {
      evaluator.evaluateParsed(symbolicDerivative, {'x': xVal});
    } catch (_) {}
  }

  final sw1 = Stopwatch()..start();
  var inlineErrors = 0;
  for (var i = 0; i < iterations; i++) {
    var xVal = (i % 100).toDouble() / 10.0 + 0.5; // avoid integer roots
    if (expressionWithFrac.contains('x - 1')) {
      xVal = (i % 100).toDouble() / 10.0 + 2.5; // avoid x == 1
    }
    try {
      evaluator.evaluate(expressionWithFrac, {'x': xVal});
    } catch (e) {
      inlineErrors++;
    }
  }
  sw1.stop();

  final sw2 = Stopwatch()..start();
  var symbolicErrors = 0;
  for (var i = 0; i < iterations; i++) {
    var xVal = (i % 100).toDouble() / 10.0 + 0.5; // avoid integer roots
    if (expressionWithFrac.contains('x - 1')) {
      xVal = (i % 100).toDouble() / 10.0 + 2.5; // avoid x == 1
    }
    try {
      evaluator.evaluateParsed(symbolicDerivative, {'x': xVal});
    } catch (e) {
      symbolicErrors++;
    }
  }
  sw2.stop();

  final sw3 = Stopwatch()..start();
  var parseEvalErrors = 0;
  for (var i = 0; i < iterations; i++) {
    // Re-parse expression and then differentiate & evaluate per iteration to measure cost
    var xVal = (i % 100).toDouble() / 10.0 + 0.5; // avoid integer roots
    if (expressionWithFrac.contains('x - 1')) {
      xVal = (i % 100).toDouble() / 10.0 + 2.5; // avoid x == 1
    }
    final parsed = evaluator.parse(expressionWithFrac);
    try {
      evaluator.evaluateParsed(parsed, {'x': xVal});
    } catch (e) {
      parseEvalErrors++;
    }
  }
  sw3.stop();

  if (inlineErrors > 0 || symbolicErrors > 0 || parseEvalErrors > 0) {
    print(
        'Note: There were evaluation errors - inline:$inlineErrors symbolic:$symbolicErrors parse-eval:$parseEvalErrors');
  }

  final avgInlineMs = sw1.elapsedMicroseconds / iterations / 1000.0;
  final avgSymbolicMs = sw2.elapsedMicroseconds / iterations / 1000.0;
  final avgParseAndEvalMs = sw3.elapsedMicroseconds / iterations / 1000.0;

  print('--- $label ---');
  print(
      'Inline \\frac evaluation (evaluate): ${sw1.elapsedMilliseconds} ms; avg ${avgInlineMs.toStringAsFixed(4)} ms/op');
  print(
      'Symbolic derivative evaluation (evaluateParsed): ${sw2.elapsedMilliseconds} ms; avg ${avgSymbolicMs.toStringAsFixed(4)} ms/op');
  print(
      'Parse+eval per op (worst-case): ${sw3.elapsedMilliseconds} ms; avg ${avgParseAndEvalMs.toStringAsFixed(4)} ms/op');
  print('');
}

void benchmarkDifferentiateCost({
  required Texpr evaluator,
  required String expressionString,
  required Expression parsedExpression,
  required int iterations,
}) {
  // Measure the time to call differentiate() repeatedly
  final sw = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    evaluator.differentiate(parsedExpression, 'x');
  }
  sw.stop();

  final avgMs = sw.elapsedMicroseconds / iterations / 1000.0;
  print(
      'Differentiate() cost for $expressionString: ${sw.elapsedMilliseconds} ms total; avg ${avgMs.toStringAsFixed(4)} ms/op');
}

String _repeat(String s, int n) => List.filled(n, s).join(' + ');

void main(List<String> args) {
  // Use caching intentionally for this benchmark - we're comparing
  // inline derivative evaluation vs pre-computed symbolic derivatives,
  // not measuring cache overhead
  final evaluator = Texpr(
    cacheConfig: CacheConfig.highPerformance,
  );
  print('Derivative Benchmarks');
  print('=' * 60);

  const iterations = 2000;

  final expressions = <String, String>{
    'Polynomial x^10': r'\frac{d}{dx}(x^{10})',
    'Polynomial x^20': r'\frac{d}{dx}(x^{20})',
    'Trigonometric composite': r'\frac{d}{dx}(\sin{x^{2}})',
    'Rational function': r'\frac{d}{dx}(\frac{x^{5} + 2x^{3} - x + 7}{x - 1})',
    'x^x': r'\frac{d}{dx}(x^{x})',
    'Long polynomial': '\\frac{d}{dx}(${_repeat(r'x^{2}', 20)})',
  };

  for (final entry in expressions.entries) {
    final label = entry.key;
    final inlineExpr = entry.value;

    // Parse the raw base expression (without the \frac call) for differentiate() when needed
    // Extract inner expression by removing '\\frac{d}{dx}(' prefix and trailing ')'
    final innerStart = inlineExpr.indexOf('(');
    final innerEnd = inlineExpr.lastIndexOf(')');
    final inner = inlineExpr.substring(innerStart + 1, innerEnd);

    // Parse once and differentiate
    final parsed = evaluator.parse(inner);
    final derivative = evaluator.differentiate(parsed, 'x');

    // Benchmark evaluate vs evaluateParsed
    benchmarkDerivativeEvaluation(
      evaluator: evaluator,
      label: label,
      expressionWithFrac: inlineExpr,
      parsedExpression: parsed,
      symbolicDerivative: derivative,
      iterations: iterations,
    );

    // Measure differentiation cost separately
    benchmarkDifferentiateCost(
      evaluator: evaluator,
      expressionString: inner,
      parsedExpression: parsed,
      iterations: 100,
    );
  }

  print('Done.');
}
