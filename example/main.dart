// TeXpr - Example Usage
//
// Run with: dart run example/main.dart

import 'package:texpr/texpr.dart';
import 'dart:math' as math;

void main() {
  final evaluator = Texpr();

  print('=== Basic Arithmetic ===');
  print('2 + 3 * 4 = ${evaluator.evaluateNumeric(r"2 + 3 \times 4")}');

  print('\n=== Variables ===');
  print(
      'x² + 1 where x=3: ${evaluator.evaluateNumeric(r"x^{2} + 1", {"x": 3})}');
  print('a * b where a=5, b=7: ${evaluator.evaluateNumeric(r"a \times b", {
        "a": 5,
        "b": 7
      })}');

  print('\n=== Logarithms ===');
  print('ln(e) = ${evaluator.evaluateNumeric(r"\ln{2.71828}")}');
  print('log10(100) = ${evaluator.evaluateNumeric(r"\log{100}")}');
  print('log2(8) = ${evaluator.evaluateNumeric(r"\log_{2}{8}")}');

  print('\n=== Other Functions ===');
  print('√16 = ${evaluator.evaluateNumeric(r"\sqrt{16}")}');
  print('|−5| = ${evaluator.evaluateNumeric(r"\abs{-5}")}');
  print('5! = ${evaluator.evaluateNumeric(r"\factorial{5}")}');
  print('⌈1.2⌉ = ${evaluator.evaluateNumeric(r"\ceil{1.2}")}');
  print('⌊1.8⌋ = ${evaluator.evaluateNumeric(r"\floor{1.8}")}');

  print('\n=== Constants ===');
  print('e = ${evaluator.evaluateNumeric("e")}');
  print('pi = ${evaluator.evaluateNumeric(r"\pi")}');
  print('\n=== Summation ===');
  print('∑(i=1 to 5) i = ${evaluator.evaluateNumeric(r"\sum_{i=1}^{5} i")}');
  print(
      '∑(i=1 to 3) i² = ${evaluator.evaluateNumeric(r"\sum_{i=1}^{3} i^{2}")}');

  print('\n=== Product ===');
  print(
      '∏(i=1 to 5) i = 5! = ${evaluator.evaluateNumeric(r"\prod_{i=1}^{5} i")}');
  print(
      '∏(i=1 to 3) 2 = 2³ = ${evaluator.evaluateNumeric(r"\prod_{i=1}^{3} 2")}');

  print('\n=== Advanced Physics & Calculus ===');
  final qmExpr = r'\int_{0}^{\pi} \hbar \sin{x} dx';
  print('QM Integral: $qmExpr');
  final qmResult = evaluator.evaluate(qmExpr);
  print('  Result: $qmResult');

  print('\n=== Custom Extensions ===');
  customExtensionExample();

  print('\n=== Fibonacci (memoized) ===');
  fibonacciExample();

  print('\n=== Parsed Expression Cache ===');
  cachingExample();
}

void customExtensionExample() {
  // Create extension registry
  final registry = ExtensionRegistry();

  // Register cube root command: \cbrt
  registry.registerCommand(
      'cbrt',
      (cmd, pos) =>
          Token(type: TokenType.function, value: 'cbrt', position: pos));

  // Register cube root evaluator
  registry.registerEvaluator((expr, vars, evaluate) {
    if (expr is FunctionCall && expr.name == 'cbrt') {
      final arg = evaluate(expr.argument);
      return math.pow(arg, 1 / 3).toDouble();
    }
    return null;
  });

  // Use with extensions
  final evaluator = Texpr(extensions: registry);
  print('∛27 = ${evaluator.evaluate(r"\cbrt{27}")}');
  print('∛8 = ${evaluator.evaluate(r"\cbrt{8}")}');
}

void fibonacciExample() {
  final evaluator = Texpr();
  print('fibonacci(0) = ${evaluator.evaluateNumeric(r"\fibonacci{0}")}');
  print('fibonacci(1) = ${evaluator.evaluateNumeric(r"\fibonacci{1}")}');
  print('fibonacci(10) = ${evaluator.evaluateNumeric(r"\fibonacci{10}")}');
}

void cachingExample() {
  // Show parsed expression cache usage and performance advantage.
  final evaluator = Texpr(parsedExpressionCacheSize: 32);
  final expression = r'x^{2} + 2x + 1';

  final parsed = evaluator.parse(expression);
  print('Parsed AST reused: ${identical(parsed, evaluator.parse(expression))}');
  print('Evaluate (x=2): ${evaluator.evaluateParsed(parsed, {
        'x': 2
      }).asNumeric()}');
  // Clear cache demonstration
  evaluator.clearParsedExpressionCache();
  print('Cache cleared.');
}
