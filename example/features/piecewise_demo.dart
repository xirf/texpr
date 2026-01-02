import 'package:texpr/texpr.dart';

void main() {
  final evaluator = Texpr();

  print('=== Complex Piecewise Functions ===\n');

  // Test 1: Simple Huber loss (without subscripts in variable)
  print('Test 1: Huber Loss psi(r)');
  try {
    final huber = evaluator.parse(r'''
      \begin{cases}
        \frac{1}{2} r^{2} & |r| \leq \delta \\
        \delta (|r| - \frac{1}{2}\delta) & |r| > \delta
      \end{cases}
    ''');
    print('  Parsed: ${huber.runtimeType}');
    print('  LaTeX: ${huber.toLatex()}');

    // Evaluate at r=0.5, delta=1 (inside quadratic region)
    final result1 = evaluator.evaluateParsed(huber, {'r': 0.5, 'delta': 1.0});
    print('  At r=0.5, delta=1: ${result1.asNumeric()}');

    // Evaluate at r=2, delta=1 (linear region)
    final result2 = evaluator.evaluateParsed(huber, {'r': 2.0, 'delta': 1.0});
    print('  At r=2, delta=1: ${result2.asNumeric()}');
  } catch (e) {
    print('  Error: $e');
  }

  print('\n---\n');

  // Test 2: Hubble Law (simplified)
  print('Test 2: Hubble Law v(r)');
  try {
    final hubble = evaluator.parse(r'''
      \begin{cases}
        H_0 r & r \leq R_{crit} \\
        c \left( \frac{z^{2} - 1}{z^{2} + 1} \right) & r > R_{crit}
      \end{cases}
    ''');
    print('  Parsed: ${hubble.runtimeType}');
    print('  LaTeX: ${hubble.toLatex()}');

    // Evaluate at r=50, R_crit=100, H_0=70 (first case)
    final result1 = evaluator.evaluateParsed(hubble, {
      'r': 50.0,
      'R_crit': 100.0,
      'H_0': 70.0,
      'c': 300000.0,
      'z': 0.5,
    });
    print('  At r=50 (low): ${result1.asNumeric()}');
  } catch (e) {
    print('  Error: $e');
  }

  print('\n---\n');

  // Test 3: ReLU (should work perfectly)
  print('Test 3: ReLU Function');
  try {
    final relu = evaluator.parse(r'''
      \begin{cases}
        0 & x < 0 \\
        x & x \geq 0
      \end{cases}
    ''');
    print('  Parsed: ${relu.runtimeType}');

    print('  ReLU(-5) = ${evaluator.evaluateParsed(relu, {
          'x': -5.0
        }).asNumeric()}');
    print('  ReLU(0) = ${evaluator.evaluateParsed(relu, {
          'x': 0.0
        }).asNumeric()}');
    print('  ReLU(5) = ${evaluator.evaluateParsed(relu, {
          'x': 5.0
        }).asNumeric()}');

    // Differentiate
    final reluDeriv = evaluator.differentiate(relu, 'x');
    print('  ReLU\'(-5) = ${evaluator.evaluateParsed(reluDeriv, {
          'x': -5.0
        }).asNumeric()}');
    print('  ReLU\'(5) = ${evaluator.evaluateParsed(reluDeriv, {
          'x': 5.0
        }).asNumeric()}');
  } catch (e) {
    print('  Error: $e');
  }

  print('\n---\n');

  // Test 4: Check what characters/notations need support
  print('Test 4: Testing individual notation elements');

  // Test \mathcal
  print('  Testing \\mathcal{L}:');
  try {
    final cal = evaluator.parse(r'\mathcal{L}');
    print('    Parsed: ${cal.runtimeType}');
  } catch (e) {
    print('    Not supported: $e');
  }

  // Test \quad
  print('  Testing \\quad spacing:');
  try {
    final quad = evaluator.parse(r'x \quad y');
    print('    Parsed: ${quad.runtimeType}');
  } catch (e) {
    print('    Not supported: $e');
  }

  // Test subscript variables like R_{crit}
  print('  Testing R_{crit}:');
  try {
    final sub = evaluator.parse(r'R_{crit}');
    print('    Parsed: ${sub.runtimeType} = ${sub.toLatex()}');
    final result = evaluator.evaluateParsed(sub, {'R_crit': 50.0});
    print('    Evaluates as: ${result.asNumeric()}');
  } catch (e) {
    print('    Error: $e');
  }

  // Test H_0
  print('  Testing H_0:');
  try {
    final h0 = evaluator.parse(r'H_0');
    print('    Parsed: ${h0.runtimeType} = ${h0.toLatex()}');
    final result = evaluator.evaluateParsed(h0, {'H_0': 70.0});
    print('    Evaluates as: ${result.asNumeric()}');
  } catch (e) {
    print('    Error: $e');
  }

  print('\n=== Summary ===');
  print('The core \\begin{cases} parsing works!');
  print('Some notations that may need additional support:');
  print('  - \\mathcal{} font commands (for stylized L, etc.)');
  print('  - Subscript variables like R_{crit} are treated as multiplication');
  print('  - \\quad spacing is parsed but ignored in evaluation');
}
