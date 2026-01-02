/// Advanced benchmark suite using benchmark_harness for proper microbenchmarking.
///
/// Categories:
/// 1. Basic Algebra (baseline)
/// 2. Calculus (integrals, derivatives, limits)
/// 3. Matrix Operations
/// 4. Academic Paper Expressions (physics, statistics)
library;

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:texpr/texpr.dart';

// =============================================================================
// Benchmark Base Classes
// =============================================================================

/// Benchmark that measures parse + evaluate time (one-shot performance)
class ParseAndEvaluateBenchmark extends BenchmarkBase {
  final String latex;
  final Map<String, double> variables;
  late final Texpr evaluator;

  ParseAndEvaluateBenchmark(super.name, this.latex,
      [this.variables = const {}]);

  @override
  void setup() {
    // Use disabled cache to measure raw parsing + evaluation each time
    evaluator = Texpr(cacheConfig: CacheConfig.disabled);
  }

  @override
  void exercise() => run(); // Report per single run, not per 10

  @override
  void run() {
    evaluator.evaluate(latex, variables);
  }
}

/// Benchmark that measures only evaluation time (hot loop performance)
/// Parses once in setup, then evaluates repeatedly
class EvaluateOnlyBenchmark extends BenchmarkBase {
  final String latex;
  final Map<String, double> variables;
  late final Texpr evaluator;
  late final Expression parsed;

  EvaluateOnlyBenchmark(String name, this.latex, [this.variables = const {}])
      : super('$name.EvalOnly');

  @override
  void setup() {
    evaluator = Texpr(cacheConfig: CacheConfig.disabled);
    parsed = evaluator.parse(latex);
  }

  @override
  void exercise() => run();

  @override
  void run() {
    evaluator.evaluateParsed(parsed, variables);
  }
}

// =============================================================================
// Benchmark Definitions
// =============================================================================

void main() {
  print('=' * 70);
  print('Using benchmark_harness for reliable microbenchmarking');
  print('=' * 70);
  print('');

  // -------------------------------------------------------------------------
  // Category 1: Basic Algebra (baseline for comparison)
  // -------------------------------------------------------------------------
  print('--- Category 1: Basic Algebra ---');

  ParseAndEvaluateBenchmark(
    'Basic.SimpleArithmetic',
    r'1 + 2 + 3 + 4 + 5',
  ).report();

  ParseAndEvaluateBenchmark(
    'Basic.Multiplication',
    r'x * y * z',
    {'x': 2, 'y': 3, 'z': 4},
  ).report();

  ParseAndEvaluateBenchmark(
    'Basic.Trigonometry',
    r'\sin(x) + \cos(x)',
    {'x': 0.5},
  ).report();

  ParseAndEvaluateBenchmark(
    'Basic.PowerAndSqrt',
    r'\sqrt{x^2 + y^2}',
    {'x': 3, 'y': 4},
  ).report();

  print('');

  // -------------------------------------------------------------------------
  // Category 2: Calculus (from calculus_test.dart)
  // -------------------------------------------------------------------------
  print('--- Category 2: Calculus ---');

  ParseAndEvaluateBenchmark(
    'Calculus.DefiniteIntegral',
    r'\int_{0}^{1} x^2 dx',
  ).report();

  ParseAndEvaluateBenchmark(
    'Calculus.GaussianIntegral',
    r'\frac{1}{\sigma \sqrt{2\pi}} \int_{-\infty}^{\infty} e^{-\frac{1}{2}(\frac{x-\mu}{\sigma})^2} dx',
    {'sigma': 1.0, 'mu': 0.0},
  ).report();

  ParseAndEvaluateBenchmark(
    'Calculus.Derivative',
    r'\frac{d}{dx}(x^{10})',
    {'x': 2.0},
  ).report();

  ParseAndEvaluateBenchmark(
    'Calculus.LimitAtInfinity',
    r'\lim_{x \to \infty} \frac{2x+1}{x+3}',
  ).report();

  print('');

  // -------------------------------------------------------------------------
  // Category 3: Matrix Operations
  // -------------------------------------------------------------------------
  print('--- Category 3: Matrix Operations ---');

  ParseAndEvaluateBenchmark(
    'Matrix.2x2Parse',
    r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}',
  ).report();

  ParseAndEvaluateBenchmark(
    'Matrix.3x3Power',
    r'\begin{pmatrix} 0.8 & 0.1 & 0.1 \\ 0.2 & 0.7 & 0.1 \\ 0.3 & 0.3 & 0.4 \end{pmatrix} ^ 2',
  ).report();

  print('');

  // -------------------------------------------------------------------------
  // Category 4: Academic Paper Expressions (from v020_academic_paper_test.dart)
  // -------------------------------------------------------------------------
  print('--- Category 4: Academic Paper Expressions ---');

  ParseAndEvaluateBenchmark(
    'Academic.NormalDistribution',
    r'\frac{1}{\sigma \sqrt{2\pi}} e^{-\frac{1}{2}\left(\frac{x-\mu}{\sigma}\right)^2}',
    {'x': 0.0, 'mu': 0.0, 'sigma': 1.0},
  ).report();

  ParseAndEvaluateBenchmark(
    'Academic.LorentzFactor',
    r'\frac{1}{\sqrt{1 - \frac{v^2}{c^2}}}',
    {'v': 0.6, 'c': 1.0},
  ).report();

  ParseAndEvaluateBenchmark(
    'Academic.EulerPolyhedra',
    r'V - E + F',
    {'V': 8.0, 'E': 12.0, 'F': 6.0},
  ).report();

  ParseAndEvaluateBenchmark(
    'Academic.BeamDeflection',
    r'\frac{P L^3}{48 E I} * ( 3 \frac{x}{L} - 4 ( \frac{x}{L} )^3 )',
    {'P': 48.0, 'L': 1.0, 'E': 1.0, 'I': 1.0, 'x': 0.5},
  ).report();

  print('');

  // -------------------------------------------------------------------------
  // Category 5: Hot Loop Performance (parse once, evaluate many)
  // -------------------------------------------------------------------------
  print('--- Category 5: Hot Loop Performance (Eval-Only) ---');

  EvaluateOnlyBenchmark(
    'Basic.Trigonometry',
    r'\sin(x) + \cos(x)',
    {'x': 0.5},
  ).report();

  EvaluateOnlyBenchmark(
    'Calculus.Derivative',
    r'\frac{d}{dx}(x^{10})',
    {'x': 2.0},
  ).report();

  EvaluateOnlyBenchmark(
    'Academic.NormalDistribution',
    r'\frac{1}{\sigma \sqrt{2\pi}} e^{-\frac{1}{2}\left(\frac{x-\mu}{\sigma}\right)^2}',
    {'x': 0.0, 'mu': 0.0, 'sigma': 1.0},
  ).report();

  print('');
  print('=' * 70);
  print('BENCHMARK COMPLETE');
  print('=' * 70);
}
