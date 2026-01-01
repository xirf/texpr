import 'package:texpr/texpr.dart';

void main() async {
  print('================================================================');
  print('CACHING MODES COMPARISON');
  print('================================================================');

  final expressions = [
    ('Simple Arithmetic', r'1 + 2 + 3 + 4 + 5', <String, double>{}),
    ('Multiplication', r'x * y * z', <String, double>{'x': 2, 'y': 3, 'z': 4}),
    ('Trigonometry', r'\sin(x) + \cos(x)', <String, double>{'x': 0.5}),
    ('Power & Sqrt', r'\sqrt{x^2 + y^2}', <String, double>{'x': 3, 'y': 4}),
    (
      'Matrix 2x2',
      r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}',
      <String, double>{}
    ),
  ];

  const iterations = 1000;

  // ---------------------------------------------------------
  // 1. NO CACHE - measure raw parse + evaluate time
  // ---------------------------------------------------------
  print('\n--- Mode 1: No Cache (CacheConfig.disabled) ---');
  print('Measures: Full parse + evaluate on every call\n');

  final uncached = LatexMathEvaluator(cacheConfig: CacheConfig.disabled);

  for (final (desc, latex, vars) in expressions) {
    // Warmup
    for (var i = 0; i < 100; i++) {
      uncached.evaluate(latex, vars);
    }

    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      uncached.evaluate(latex, vars);
    }
    sw.stop();
    print(
        '  $desc: ${(sw.elapsedMicroseconds / iterations).toStringAsFixed(2)} µs/op');
  }

  // ---------------------------------------------------------
  // 2. WITH CACHE - default configuration
  // ---------------------------------------------------------
  print('\n--- Mode 2: With Cache (default) ---');
  print('Measures: Cached parse + cached evaluate results\n');

  final cached = LatexMathEvaluator(); // Default caching enabled

  for (final (desc, latex, vars) in expressions) {
    // Warmup (also primes the cache)
    for (var i = 0; i < 100; i++) {
      cached.evaluate(latex, vars);
    }

    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      cached.evaluate(latex, vars);
    }
    sw.stop();
    print(
        '  $desc: ${(sw.elapsedMicroseconds / iterations).toStringAsFixed(2)} µs/op');
  }

  // ---------------------------------------------------------
  // 3. PARSE ONCE + evaluateParsed - optimal for hot loops
  // ---------------------------------------------------------
  print('\n--- Mode 3: Parse Once + evaluateParsed() ---');
  print('Measures: Pre-parsed AST, evaluate only (no cache lookup overhead)\n');

  final parseOnce = LatexMathEvaluator(cacheConfig: CacheConfig.disabled);

  for (final (desc, latex, vars) in expressions) {
    final ast = parseOnce.parse(latex);

    // Warmup
    for (var i = 0; i < 100; i++) {
      parseOnce.evaluateParsed(ast, vars);
    }

    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      parseOnce.evaluateParsed(ast, vars);
    }
    sw.stop();
    print(
        '  $desc: ${(sw.elapsedMicroseconds / iterations).toStringAsFixed(2)} µs/op');
  }

  print('\n================================================================');
  print('SUMMARY');
  print('================================================================');
  print(
      'Mode 1 (No Cache): Best for one-off evaluations or unique expressions');
  print('Mode 2 (Cached):   Best for repeated evaluation of same expressions');
  print(
      'Mode 3 (Parse Once): Best for hot loops with same expression, varying variables');
}
