import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Integration test for MathML export verification.
///
/// This test:
/// 1. Parses LaTeX expressions using the Dart library
/// 2. Exports to MathML
/// 3. Saves test data to a JSON file
/// 4. A Python script validates the MathML XML structure
void main() {
  late LatexMathEvaluator evaluator;

  setUp(() {
    evaluator = LatexMathEvaluator();
  });

  group('MathML Integration Export', () {
    test('exports test cases for Python validation', () {
      final testCases = <Map<String, dynamic>>[];

      // Basic expressions
      _addCase(
        testCases,
        evaluator,
        latex: r'42',
        description: 'Number literal',
        expectedElements: ['mn'],
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'x',
        description: 'Variable',
        expectedElements: ['mi'],
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\alpha',
        description: 'Greek letter',
        expectedElements: ['mi'],
        expectedContent: 'α',
      );

      // Binary operations
      _addCase(
        testCases,
        evaluator,
        latex: r'2 + 3',
        description: 'Addition',
        expectedElements: ['mn', 'mo', 'mrow'],
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\frac{a}{b}',
        description: 'Fraction',
        expectedElements: ['mfrac'],
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'x^{2}',
        description: 'Superscript',
        expectedElements: ['msup'],
      );

      // Functions
      _addCase(
        testCases,
        evaluator,
        latex: r'\sin{x}',
        description: 'Sine function',
        expectedElements: ['mi', 'mrow'],
        expectedContent: 'sin',
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\sqrt{x}',
        description: 'Square root',
        expectedElements: ['msqrt'],
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\sqrt[3]{x}',
        description: 'Cube root',
        expectedElements: ['mroot'],
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\log_{2}{x}',
        description: 'Logarithm with base',
        expectedElements: ['msub', 'mi'],
        expectedContent: 'log',
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'|x|',
        description: 'Absolute value',
        expectedElements: ['mo', 'mrow'],
        expectedContent: '|',
      );

      // Calculus
      _addCase(
        testCases,
        evaluator,
        latex: r'\sum_{i=1}^{10} i',
        description: 'Summation',
        expectedElements: ['munderover', 'mo'],
        expectedContent: '∑',
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\prod_{i=1}^{5} i',
        description: 'Product',
        expectedElements: ['munderover', 'mo'],
        expectedContent: '∏',
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\int_{0}^{1} x dx',
        description: 'Definite integral',
        expectedElements: ['msubsup', 'mo'],
        expectedContent: '∫',
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\lim_{x \to 0} x',
        description: 'Limit',
        expectedElements: ['munder', 'mo'],
        expectedContent: 'lim',
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'\binom{n}{k}',
        description: 'Binomial coefficient',
        expectedElements: ['mfrac', 'mo'],
      );

      // Comparisons
      _addCase(
        testCases,
        evaluator,
        latex: r'x < 5',
        description: 'Less than',
        expectedElements: ['mo', 'mrow'],
        expectedContent: '<',
      );

      _addCase(
        testCases,
        evaluator,
        latex: r'x \leq 5',
        description: 'Less or equal',
        expectedElements: ['mo'],
        expectedContent: '≤',
      );

      // Matrix
      _addCase(
        testCases,
        evaluator,
        latex: r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}',
        description: 'Matrix',
        expectedElements: ['mtable', 'mtr', 'mtd'],
      );

      // Complex expression
      _addCase(
        testCases,
        evaluator,
        latex: r'\frac{-b + \sqrt{b^{2} - 4ac}}{2a}',
        description: 'Quadratic formula',
        expectedElements: ['mfrac', 'msqrt', 'msup', 'mrow'],
      );

      // Write to JSON file for Python to validate
      final outputPath = 'test/integration/mathml/test_cases.json';
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
  LatexMathEvaluator evaluator, {
  required String latex,
  required String description,
  required List<String> expectedElements,
  String? expectedContent,
}) {
  try {
    final expr = evaluator.parse(latex);
    final mathml = expr.toMathML();
    final mathmlNoWrapper = expr.toMathML(includeWrapper: false);

    cases.add({
      'description': description,
      'latex': latex,
      'mathml': mathml,
      'mathml_content': mathmlNoWrapper,
      'expected_elements': expectedElements,
      if (expectedContent != null) 'expected_content': expectedContent,
    });
  } catch (e) {
    cases.add({
      'description': description,
      'latex': latex,
      'error': e.toString(),
    });
  }
}
