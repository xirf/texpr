import 'package:texpr/texpr.dart';

void main() {
  final evaluator = LatexMathEvaluator();

  final tests = [
    (r'\sin{x}^2 + \cos{x}^2', 'sin²+cos² = 1'),
    (r'\int x^2 dx', '∫x² dx = x³/3'),
    (r'\frac{d}{dx}(x^3)', 'd/dx(x³) = 3x²'),
    (r'\sum_{i=1}^{10} i', 'Σi=1..10 = 55'),
    (r'\binom{10}{3}', 'C(10,3) = 120'),
  ];

  print('from sympy import *');
  print('x, i = symbols("x i")');
  print('');

  for (var idx = 0; idx < tests.length; idx++) {
    final (latex, desc) = tests[idx];
    final expr = evaluator.parse(latex);
    final sympy = expr.toSymPy();
    print('# $desc');
    print('expr_$idx = $sympy');
    print(
        'result = simplify(expr_$idx) if hasattr(expr_$idx, "simplify") else expr_$idx');
    print('print(f"Test $idx: {result}")');
    print('');
  }
}
