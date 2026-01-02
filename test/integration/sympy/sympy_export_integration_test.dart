import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Integration test for SymPy export verification.
///
/// This test:
/// 1. Parses LaTeX expressions using the Dart library
/// 2. Evaluates them with the Dart evaluator
/// 3. Exports to SymPy code
/// 4. Saves test data to a JSON file
/// 5. A Python script reads this and verifies with SymPy
void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('SymPy Integration Export', () {
    test('exports test cases for Python verification', () {
      final testCases = <Map<String, dynamic>>[];

      // Basic arithmetic
      _addCase(
        testCases,
        evaluator,
        latex: r'2 + 3',
        description: 'Addition',
        variables: {},
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'10 - 4',
        description: 'Subtraction',
        variables: {},
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'6 \times 7',
        description: 'Multiplication',
        variables: {},
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\frac{20}{4}',
        description: 'Division',
        variables: {},
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'2^{10}',
        description: 'Power',
        variables: {},
      );

      // Trigonometry
      _addCase(
        testCases,
        evaluator,
        latex: r'\sin{0}',
        description: 'Sine of 0',
        variables: {},
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\cos{0}',
        description: 'Cosine of 0',
        variables: {},
      );

      // Functions
      _addCase(
        testCases,
        evaluator,
        latex: r'\sqrt{16}',
        description: 'Square root',
        variables: {},
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\sqrt[3]{27}',
        description: 'Cube root',
        variables: {},
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\ln{e}',
        description: 'Natural log of e',
        variables: {},
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'|{-5}|',
        description: 'Absolute value',
        variables: {},
      );

      // Variable expressions
      _addCase(
        testCases,
        evaluator,
        latex: r'x^2 + 2x + 1',
        description: 'Quadratic at x=3',
        variables: {'x': 3.0},
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\sin{x}^2 + \cos{x}^2',
        description: 'Pythagorean identity',
        variables: {'x': 1.0},
      );

      // Calculus (symbolic - compare string output)
      _addSymbolicCase(
        testCases,
        evaluator,
        latex: r'\int x^2 dx',
        description: 'Integral of x^2',
        expectedSympy: 'x**3/3',
      );

      _addSymbolicCase(
        testCases,
        evaluator,
        latex: r'\frac{d}{dx}(x^3)',
        description: 'Derivative of x^3',
        expectedSympy: '3*x**2',
      );

      // Combinatorics
      _addCase(
        testCases,
        evaluator,
        latex: r'\binom{10}{3}',
        description: 'Binomial coefficient',
        variables: {},
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\factorial{5}',
        description: 'Factorial of 5',
        variables: {},
      );

      // Constants
      _addCase(
        testCases,
        evaluator,
        latex: r'e^{0}',
        description: 'e to the 0',
        variables: {},
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\pi',
        description: 'Pi constant',
        variables: {},
        tolerance: 1e-10,
      );

      // Complex nested expressions
      _addCase(
        testCases,
        evaluator,
        latex: r'\frac{1}{\sqrt{2\pi}} e^{-\frac{x^2}{2}}',
        description: 'Standard normal PDF at x=0',
        variables: {'x': 0.0},
        tolerance: 1e-6,
      );

      // Write to JSON file for Python to read
      final outputPath = 'test/integration/sympy/test_cases.json';
      final jsonOutput = const JsonEncoder.withIndent('  ').convert({
        'generated_at': DateTime.now().toIso8601String(),
        'test_cases': testCases,
      });

      File(outputPath).writeAsStringSync(jsonOutput);
      print('Exported ${testCases.length} test cases to $outputPath');

      expect(testCases.length, greaterThan(10));
    });
  });
}

void _addCase(
  List<Map<String, dynamic>> cases,
  Texpr evaluator, {
  required String latex,
  required String description,
  required Map<String, double> variables,
  double tolerance = 1e-10,
}) {
  try {
    final expr = evaluator.parse(latex);
    final sympy = expr.toSymPy();
    final dartResult = evaluator.evaluate(latex, variables);

    cases.add({
      'type': 'numeric',
      'description': description,
      'latex': latex,
      'sympy_code': sympy,
      'variables': variables,
      'dart_result': dartResult.asNumeric(),
      'tolerance': tolerance,
    });
  } catch (e) {
    cases.add({
      'type': 'error',
      'description': description,
      'latex': latex,
      'error': e.toString(),
    });
  }
}

void _addSymbolicCase(
  List<Map<String, dynamic>> cases,
  Texpr evaluator, {
  required String latex,
  required String description,
  required String expectedSympy,
}) {
  try {
    final expr = evaluator.parse(latex);
    final sympy = expr.toSymPy();

    cases.add({
      'type': 'symbolic',
      'description': description,
      'latex': latex,
      'sympy_code': sympy,
      'expected_sympy_result': expectedSympy,
    });
  } catch (e) {
    cases.add({
      'type': 'error',
      'description': description,
      'latex': latex,
      'error': e.toString(),
    });
  }
}
