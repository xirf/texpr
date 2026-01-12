// TeXpr - Quick Demo
// Try it: https://zapp.run/github/xirf/texpr

import 'package:texpr/texpr.dart';

void main() {
  final texpr = Texpr();

  // Basic arithmetic
  print('2 + 3 × 4 = ${texpr.evaluateNumeric(r"2 + 3 \times 4")}');
  print('10 ÷ 2 = ${texpr.evaluateNumeric(r"\frac{10}{2}")}');

  // Functions
  print('sin(π) = ${texpr.evaluateNumeric(r"\sin{\pi}")}');
  print('√16 = ${texpr.evaluateNumeric(r"\sqrt{16}")}');
  print('log₂(8) = ${texpr.evaluateNumeric(r"\log_{2}{8}")}');

  // Variables
  print('x² + 1 (x=3) = ${texpr.evaluateNumeric(r"x^2 + 1", {"x": 3})}');

  // Summation
  print('Σ(i=1..5) i = ${texpr.evaluateNumeric(r"\sum_{i=1}^{5} i")}');

  // Calculus - differentiation
  final derivative = texpr.differentiate(r'x^3', 'x');
  print("d/dx(x³) = ${derivative.toLatex()}");

  // User-defined functions
  texpr.evaluate(r'f(x) = x^2 + 1');
  print('f(4) = ${texpr.evaluateNumeric("f(4)")}');
}
