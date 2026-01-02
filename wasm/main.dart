import 'package:texpr/texpr.dart';

/// Entry point for WASM compilation demo.
///
/// This file demonstrates the texpr library running in WebAssembly.
/// Compile with: dart compile wasm wasm/main.dart -o wasm/build/main.wasm
void main() {
  print('=== texpr WASM Demo ===\n');

  final evaluator = Texpr();

  // Basic arithmetic
  _evaluate(evaluator, '2 + 3 \\times 4');

  // Variables
  _evaluateWithVars(evaluator, 'x^{2} + 1', {'x': 3});
  _evaluateWithVars(evaluator, 'x^{2} + 2x + 1', {'x': 5});

  // Functions
  _evaluate(evaluator, '\\sin{0}');
  _evaluate(evaluator, '\\cos{0}');
  _evaluate(evaluator, '\\sqrt{16}');

  // Logarithms
  _evaluate(evaluator, '\\log_{2}{8}');
  _evaluate(evaluator, '\\ln{e}');

  // Fractions
  _evaluate(evaluator, '\\frac{1}{2} + \\frac{1}{4}');

  print('\n=== Demo Complete ===');
}

void _evaluate(Texpr evaluator, String expression) {
  try {
    final result = evaluator.evaluateNumeric(expression);
    print('$expression = $result');
  } catch (e) {
    print('$expression -> Error: $e');
  }
}

void _evaluateWithVars(
    Texpr evaluator, String expression, Map<String, double> vars) {
  try {
    final result = evaluator.evaluateNumeric(expression, vars);
    final varsStr = vars.entries.map((e) => '${e.key}=${e.value}').join(', ');
    print('$expression ($varsStr) = $result');
  } catch (e) {
    print('$expression -> Error: $e');
  }
}
