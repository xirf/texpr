import 'dart:io';
import 'dart:convert';
import 'package:texpr/texpr.dart';

void main() async {
  print('================================================================');
  print('LATEX PARSING & EVALUATION BENCHMARK: DART vs PYTHON vs JS');
  print('================================================================');

  // Expression format: (Description, LaTeX, JS Math (null if skip), Variables)
  // Organized by category for cross-language comparison
  final expressions = [
    // -------------------------------------------------------------------------
    // Category 1: Basic Algebra (baseline)
    // -------------------------------------------------------------------------
    (
      'Basic: Simple Arithmetic',
      r'1 + 2 + 3 + 4 + 5',
      '1 + 2 + 3 + 4 + 5',
      <String, double>{}
    ),
    (
      'Basic: Multiplication',
      r'x * y * z',
      'x * y * z',
      <String, double>{'x': 2, 'y': 3, 'z': 4}
    ),
    (
      'Basic: Trigonometry',
      r'\sin(x) + \cos(x)',
      'sin(x) + cos(x)',
      <String, double>{'x': 0.5}
    ),
    (
      'Basic: Power & Sqrt',
      r'\sqrt{x^2 + y^2}',
      'sqrt(x^2 + y^2)',
      <String, double>{'x': 3, 'y': 4}
    ),

    // -------------------------------------------------------------------------
    // Category 2: Calculus (LaTeX-only for Python, skip JS)
    // -------------------------------------------------------------------------
    (
      'Calculus: Definite Integral',
      r'\int_{0}^{1} x^2 dx',
      null, // JS mathjs doesn't have integral syntax
      <String, double>{}
    ),

    // -------------------------------------------------------------------------
    // Category 3: Matrix Operations
    // -------------------------------------------------------------------------
    (
      'Matrix: 2x2 Parse',
      r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}',
      '[[1, 2], [3, 4]]',
      <String, double>{}
    ),
    (
      'Matrix: 3x3 Power',
      r'\begin{pmatrix} 0.8 & 0.1 & 0.1 \\ 0.2 & 0.7 & 0.1 \\ 0.3 & 0.3 & 0.4 \end{pmatrix} ^ 2',
      '[[0.8, 0.1, 0.1], [0.2, 0.7, 0.1], [0.3, 0.3, 0.4]] ^ 2',
      <String, double>{}
    ),

    // -------------------------------------------------------------------------
    // Category 4: Academic/Scientific (universal syntax)
    // -------------------------------------------------------------------------
    (
      'Academic: Normal Distribution PDF',
      r'\frac{1}{\sigma \sqrt{2\pi}} e^{-\frac{1}{2}\left(\frac{x-\mu}{\sigma}\right)^2}',
      '(1 / (sigma * sqrt(2 * pi))) * exp(-0.5 * ((x - mu) / sigma)^2)',
      <String, double>{'x': 0.0, 'mu': 0.0, 'sigma': 1.0}
    ),
    (
      'Academic: Lorentz Factor',
      r'\frac{1}{\sqrt{1 - \frac{v^2}{c^2}}}',
      '1 / sqrt(1 - (v^2 / c^2))',
      <String, double>{'v': 0.6, 'c': 1.0}
    ),
    (
      'Academic: Euler Polyhedra',
      r'V - E + F',
      'V - E + F',
      <String, double>{'V': 8.0, 'E': 12.0, 'F': 6.0}
    ),
    (
      'Academic: Beam Deflection',
      r'\frac{P L^3}{48 E I} * ( 3 \frac{x}{L} - 4 ( \frac{x}{L} )^3 )',
      '(P * L^3) / (48 * E_ * I_) * (3 * x / L - 4 * (x / L)^3)',
      <String, double>{'P': 48.0, 'L': 1.0, 'E': 1.0, 'I': 1.0, 'x': 0.5}
    ),

    // -------------------------------------------------------------------------
    // Category 5: Complex Expressions (stress test)
    // -------------------------------------------------------------------------
    (
      'Complex: Nested Functions',
      r'\sin(\cos(\tan(x)))',
      'sin(cos(tan(x)))',
      <String, double>{'x': 0.5}
    ),
    (
      'Complex: Polynomial',
      r'x^5 + 2x^4 - 3x^3 + 4x^2 - 5x + 6',
      'x^5 + 2*x^4 - 3*x^3 + 4*x^2 - 5*x + 6',
      <String, double>{'x': 2.0}
    ),
  ];

  final iterations = 1000;
  final pyIterations = 50;
  final jsIterations = 1000;

  // ---------------------------------------------------------
  // 1. DART BENCHMARK
  // ---------------------------------------------------------
  print('\nRunning DART Benchmarks (Uncached, $iterations iterations)...');

  // Disable ALL caches to measure raw parsing + evaluation speed every time
  // Note: parsedExpressionCacheSize: 0 alone only disables L1 (parse cache),
  // but L2 (evaluation result cache) was still active - that's what made
  // the integral appear faster than arithmetic (result was cached).
  final dartEvaluator = LatexMathEvaluator(cacheConfig: CacheConfig.disabled);
  final dartResults = <String, double>{};

  for (final (desc, latex, _, vars) in expressions) {
    // Warmup
    for (var i = 0; i < 100; i++) {
      dartEvaluator.evaluate(latex, vars);
    }

    final sw = Stopwatch()..start();
    for (var i = 0; i < iterations; i++) {
      dartEvaluator.evaluate(latex, vars);
    }
    sw.stop();

    final avgTimeUs = sw.elapsedMicroseconds / iterations;
    dartResults[desc] = avgTimeUs;
    print('  - $desc: ${avgTimeUs.toStringAsFixed(2)} µs/op');
  }

  // ---------------------------------------------------------
  // 2. PYTHON BENCHMARK
  // ---------------------------------------------------------
  print('\nRunning PYTHON (SymPy) Benchmarks ($pyIterations iterations)...');
  await _runPythonBenchmark(expressions, pyIterations);

  // ---------------------------------------------------------
  // 3. JS BENCHMARK
  // ---------------------------------------------------------
  print('\nRunning JS (mathjs) Benchmarks ($jsIterations iterations)...');
  await _runJsBenchmark(expressions, jsIterations);

  print('\n----------------------------------------------------------------');
  print('Summary (Avg µs/op)');
  print('----------------------------------------------------------------');
}

Future<void> _runPythonBenchmark(
    List<dynamic> expressions, int iterations) async {
  final pyScript = StringBuffer();
  pyScript.writeln('import time, json, gc');
  pyScript.writeln('from sympy import Symbol, symbols');
  pyScript.writeln('from sympy.parsing.latex import parse_latex');
  pyScript.writeln('expressions = [');
  for (final (desc, latex, _, vars) in expressions) {
    if (desc == 'Matrix') continue;
    final varStr = vars.isNotEmpty ? jsonEncode(vars) : '{}';
    final escapedLatex = latex.replaceAll(r'\', r'\\');
    pyScript.writeln('    ("$desc", "$escapedLatex", $varStr),');
  }
  pyScript.writeln(']');
  pyScript.writeln('iterations = $iterations');
  pyScript.writeln('x, y, z = symbols("x y z")');

  // Warmup
  pyScript.writeln('for _, l, _ in expressions:');
  pyScript.writeln('    try: parse_latex(l)');
  pyScript.writeln('    except: pass');

  // Loop
  pyScript.writeln('for desc, latex, vars in expressions:');
  pyScript.writeln('    gc.collect(); gc.disable()');
  pyScript.writeln('    start = time.perf_counter_ns()');
  pyScript.writeln('    for _ in range(iterations):');
  pyScript.writeln('        expr = parse_latex(latex)');
  pyScript.writeln('        if vars: expr.evalf(subs=vars)');
  pyScript.writeln('        else: expr.evalf()');
  pyScript.writeln('    end = time.perf_counter_ns()');
  pyScript.writeln('    gc.enable()');
  pyScript.writeln(
      '    print(f"  - {desc}: {(end-start)/iterations/1000.0:.2f} µs/op")');

  final pyFile = File('benchmark/comparison/benchmark_script.py');
  await pyFile.writeAsString(pyScript.toString());

  final process = await Process.start('bash', [
    '-c',
    'source benchmark/comparison/.venv/bin/activate && python3 benchmark/comparison/benchmark_script.py'
  ]);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  await process.exitCode;
}

Future<void> _runJsBenchmark(List<dynamic> expressions, int iterations) async {
  final jsScript = StringBuffer();
  jsScript.writeln('const math = require("mathjs");');
  jsScript.writeln('const expressions = [');
  for (final (desc, _, jsMath, vars) in expressions) {
    if (jsMath == null) continue;
    final varStr = vars.isNotEmpty ? jsonEncode(vars) : '{}';
    jsScript.writeln('    {desc: "$desc", expr: "$jsMath", vars: $varStr},');
  }
  jsScript.writeln('];');
  jsScript.writeln('const iterations = $iterations;');

  // Warmup
  jsScript.writeln('expressions.forEach(item => {');
  jsScript
      .writeln('    try { math.evaluate(item.expr, item.vars); } catch(e){}');
  jsScript.writeln('});');

  // Loop
  jsScript.writeln('expressions.forEach(item => {');
  jsScript.writeln('    const start = process.hrtime.bigint();');
  jsScript.writeln('    for(let i=0; i<iterations; i++) {');
  jsScript.writeln('        math.evaluate(item.expr, item.vars);');
  jsScript.writeln('    }');
  jsScript.writeln('    const end = process.hrtime.bigint();');
  jsScript
      .writeln('    const avgUs = Number(end - start) / iterations / 1000.0;');
  jsScript.writeln(
      '    console.log(`  - ${r"${item.desc}"}: ${r"${avgUs.toFixed(2)}"} µs/op`);');
  jsScript.writeln('});');

  final jsFile = File('benchmark/comparison/js/benchmark.js');
  await jsFile.writeAsString(jsScript.toString());

  final process = await Process.start(
      'bash', ['-c', 'cd benchmark/comparison/js && node benchmark.js']);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);
  await process.exitCode;
}

String jsonEncode(Object? object) => const JsonEncoder().convert(object);
