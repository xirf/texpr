/// Benchmark comparing texpr (LaTeX) vs math_expressions (text).
///
/// Uses benchmark_harness for proper statistical benchmarking.
/// Both are Dart libraries - this is the most fair apples-to-apples comparison
/// since it removes language runtime differences.
// ignore_for_file: deprecated_member_use

library;

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:texpr/texpr.dart';
import 'package:math_expressions/math_expressions.dart' as me;

// =============================================================================
// Benchmark Classes
// =============================================================================

/// Benchmark for texpr (parse + evaluate)
class LatexBenchmark extends BenchmarkBase {
  final String latex;
  final Map<String, double> variables;
  late final LatexMathEvaluator evaluator;

  LatexBenchmark(String name, this.latex, [this.variables = const {}])
      : super('LaTeX.$name');

  @override
  void setup() {
    evaluator = LatexMathEvaluator(cacheConfig: CacheConfig.disabled);
  }

  @override
  void exercise() => run();

  @override
  void run() {
    evaluator.evaluate(latex, variables);
  }
}

/// Benchmark for texpr (evaluate only, pre-parsed)
class LatexEvalOnlyBenchmark extends BenchmarkBase {
  final String latex;
  final Map<String, double> variables;
  late final LatexMathEvaluator evaluator;
  late final Expression parsed;

  LatexEvalOnlyBenchmark(String name, this.latex, [this.variables = const {}])
      : super('LaTeX.$name.EvalOnly');

  @override
  void setup() {
    evaluator = LatexMathEvaluator(cacheConfig: CacheConfig.disabled);
    parsed = evaluator.parse(latex);
  }

  @override
  void exercise() => run();

  @override
  void run() {
    evaluator.evaluateParsed(parsed, variables);
  }
}

/// Benchmark for math_expressions (parse + evaluate)
class MathExprBenchmark extends BenchmarkBase {
  final String text;
  final Map<String, double> variables;
  late final me.Parser parser;
  late final me.ContextModel cm;

  MathExprBenchmark(String name, this.text, [this.variables = const {}])
      : super('MathExpr.$name');

  @override
  void setup() {
    parser = me.Parser();
    cm = me.ContextModel();
    for (final entry in variables.entries) {
      cm.bindVariable(me.Variable(entry.key), me.Number(entry.value));
    }
  }

  @override
  void exercise() => run();

  @override
  void run() {
    final expr = parser.parse(text);
    expr.evaluate(me.EvaluationType.REAL, cm);
  }
}

/// Benchmark for math_expressions (evaluate only, pre-parsed)
class MathExprEvalOnlyBenchmark extends BenchmarkBase {
  final String text;
  final Map<String, double> variables;
  late final me.Parser parser;
  late final me.ContextModel cm;
  late final me.Expression parsed;

  MathExprEvalOnlyBenchmark(String name, this.text, [this.variables = const {}])
      : super('MathExpr.$name.EvalOnly');

  @override
  void setup() {
    parser = me.Parser();
    cm = me.ContextModel();
    for (final entry in variables.entries) {
      cm.bindVariable(me.Variable(entry.key), me.Number(entry.value));
    }
    parsed = parser.parse(text);
  }

  @override
  void exercise() => run();

  @override
  void run() {
    parsed.evaluate(me.EvaluationType.REAL, cm);
  }
}

// =============================================================================
// Main
// =============================================================================

void main() {
  print('=' * 70);
  print('DART LIBRARY COMPARISON: texpr vs math_expressions');
  print('Using benchmark_harness for reliable microbenchmarking');
  print('=' * 70);
  print('');
  print('texpr: Parses LaTeX (\\sin{x}, \\frac{a}{b})');
  print('math_expressions:     Parses text (sin(x), a/b)');
  print('');

  // Expression pairs: (name, latex, text, variables)
  final expressions = [
    (
      'SimpleArithmetic',
      r'1 + 2 + 3 + 4 + 5',
      '1 + 2 + 3 + 4 + 5',
      <String, double>{}
    ),
    (
      'Multiplication',
      r'x * y * z',
      'x * y * z',
      {'x': 2.0, 'y': 3.0, 'z': 4.0}
    ),
    ('Trigonometry', r'\sin(x) + \cos(x)', 'sin(x) + cos(x)', {'x': 0.5}),
    (
      'PowerAndSqrt',
      r'\sqrt{x^2 + y^2}',
      'sqrt(x^2 + y^2)',
      {'x': 3.0, 'y': 4.0}
    ),
    (
      'Polynomial',
      r'x^3 + 2*x^2 - 5*x + 7',
      'x^3 + 2*x^2 - 5*x + 7',
      {'x': 2.0}
    ),
    ('NestedFunctions', r'\sin(\cos(x))', 'sin(cos(x))', {'x': 1.0}),
    // Note: math_expressions doesn't support 'pi' or 'exp' as functions
    // Using simpler alternatives for fair comparison:
    (
      'ComplexTrig',
      r'\sin(x) * \cos(y) + \tan(z)',
      'sin(x) * cos(y) + tan(z)',
      {'x': 1.0, 'y': 2.0, 'z': 0.5}
    ),
    (
      'LongPolynomial',
      r'x^5 + 2*x^4 - 3*x^3 + 4*x^2 - 5*x + 6',
      'x^5 + 2*x^4 - 3*x^3 + 4*x^2 - 5*x + 6',
      {'x': 2.0}
    ),
  ];

  // -------------------------------------------------------------------------
  // Parse + Evaluate (One-Shot)
  // -------------------------------------------------------------------------
  print('--- Parse + Evaluate (One-Shot) ---');
  print('');

  for (final (name, latex, text, vars) in expressions) {
    LatexBenchmark(name, latex, vars).report();
    MathExprBenchmark(name, text, vars).report();
    print('');
  }

  // -------------------------------------------------------------------------
  // Evaluate Only (Hot Loop)
  // -------------------------------------------------------------------------
  print('--- Evaluate Only (Hot Loop, Pre-Parsed) ---');
  print('');

  for (final (name, latex, text, vars) in expressions) {
    LatexEvalOnlyBenchmark(name, latex, vars).report();
    MathExprEvalOnlyBenchmark(name, text, vars).report();
    print('');
  }

  print('=' * 70);
  print('COMPLETE');
  print('=' * 70);
}
