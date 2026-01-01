import 'package:texpr/texpr.dart';

void main() {
  final evaluator = LatexMathEvaluator();

  print('=== Symbolic Differentiation Demo ===\n');

  // Basic derivatives
  print('--- Basic Derivatives ---');
  print('d/dx(5) = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(5)')}');
  print(
      'd/dx(x) evaluated at x=5 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(x)', {
        'x': 5
      })}');
  print(
      'd/dx(3x) evaluated at x=2 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(3x)', {
        'x': 2
      })}');
  print('');

  // Power rule
  print('--- Power Rule ---');
  print(
      'd/dx(x^2) at x=3 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(x^{2})', {
        'x': 3
      })}');
  print(
      'd/dx(x^3) at x=2 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(x^{3})', {
        'x': 2
      })}');
  print(
      'd/dx(x^{-1}) at x=2 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(x^{-1})', {
        'x': 2
      })}');
  print('');

  // Sum and difference rules
  print('--- Sum and Difference Rules ---');
  print(
      'd/dx(x^2 + x) at x=3 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(x^{2} + x)', {
        'x': 3
      })}');
  print(
      'd/dx(x^3 - x) at x=2 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(x^{3} - x)', {
        'x': 2
      })}');
  print('');

  // Product rule
  print('--- Product Rule ---');
  print(
      'd/dx(x * x^2) at x=2 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(x \cdot x^{2})', {
        'x': 2
      })}');
  print(
      'd/dx((x+1)(x-1)) at x=3 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}((x+1)(x-1))', {
        'x': 3
      })}');
  print('');

  // Quotient rule
  print('--- Quotient Rule ---');
  print(
      'd/dx(1/x) at x=2 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(\frac{1}{x})', {
        'x': 2
      })}');
  print(
      'd/dx(x/(x+1)) at x=2 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(\frac{x}{x+1})', {
        'x': 2
      })}');
  print('');

  // Chain rule
  print('--- Chain Rule ---');
  print(
      'd/dx((x^2)^3) at x=1 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}((x^{2})^{3})', {
        'x': 1
      })}');
  print(
      'd/dx(sin(x^2)) at x=0 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(\sin{x^{2}})', {
        'x': 0
      })}');
  print('');

  // Trigonometric functions
  print('--- Trigonometric Functions ---');
  print(
      'd/dx(sin(x)) at x=0 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(\sin{x})', {
        'x': 0
      })}');
  print(
      'd/dx(cos(x)) at x=0 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(\cos{x})', {
        'x': 0
      })}');
  print(
      'd/dx(tan(x)) at x=0 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(\tan{x})', {
        'x': 0
      })}');
  print('');

  // Exponential and logarithmic
  print('--- Exponential and Logarithmic ---');
  print(
      'd/dx(e^x) at x=1 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(e^{x})', {
        'x': 1
      })}');
  print(
      'd/dx(ln(x)) at x=e = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(\ln{x})', {
        'x': 2.718281828
      })}');
  print(
      'd/dx(2^x) at x=1 = ${evaluator.evaluateNumeric(r'\frac{d}{dx}(2^{x})', {
        'x': 1
      })}');
  print('');

  // Higher order derivatives
  print('--- Higher Order Derivatives ---');
  print(
      'd²/dx²(x^3) at x=2 = ${evaluator.evaluateNumeric(r'\frac{d^{2}}{dx^{2}}(x^{3})', {
        'x': 2
      })}');
  print(
      'd³/dx³(x^4) at x=2 = ${evaluator.evaluateNumeric(r'\frac{d^{3}}{dx^{3}}(x^{4})', {
        'x': 2
      })}');
  print(
      'd²/dx²(sin(x)) at x=0 = ${evaluator.evaluateNumeric(r'\frac{d^{2}}{dx^{2}}(\sin{x})', {
        'x': 0
      })}');
  print('');

  // Using the API to get symbolic derivatives
  print('--- Symbolic Derivatives (API) ---');

  // Parse the expression
  final expr1 = evaluator.parse(r'x^{2} + 3x + 1');

  // Get the symbolic derivative using the public API
  final derivative1 = evaluator.differentiate(expr1, 'x');
  print('Derivative of x² + 3x + 1: $derivative1');

  // Evaluate at a specific point
  final result1 = evaluator.evaluateParsed(derivative1, {'x': 2});
  print('Evaluated at x=2: ${result1.asNumeric()}');
  print('');

  // Second derivative example
  final expr2 = evaluator.parse(r'x^{3}');
  final firstDerivative = evaluator.differentiate(expr2, 'x');
  final secondDerivative = evaluator.differentiate(firstDerivative, 'x');
  print('f(x) = x³');
  print('f\'(x) = $firstDerivative');
  print('f\'\'(x) = $secondDerivative');
  print('f\'\'(2) = ${evaluator.evaluateParsed(secondDerivative, {
        'x': 2
      }).asNumeric()}');
  print('');

  // Complex example
  print('--- Complex Example ---');
  final complexExpr = r'\frac{d}{dx}(\frac{x^{2} + 1}{x - 1})';
  print('Expression: d/dx((x² + 1)/(x - 1))');
  print('At x=3: ${evaluator.evaluateNumeric(complexExpr, {'x': 3})}');
  print('At x=5: ${evaluator.evaluateNumeric(complexExpr, {'x': 5})}');
  print('');

  // x^x derivative (uses logarithmic differentiation internally)
  print('--- Special: x^x ---');
  final xxDerivative = r'\frac{d}{dx}(x^{x})';
  print('d/dx(x^x) at x=2 = ${evaluator.evaluateNumeric(xxDerivative, {
        'x': 2
      })}');
  print('d/dx(x^x) at x=3 = ${evaluator.evaluateNumeric(xxDerivative, {
        'x': 3
      })}');
}
