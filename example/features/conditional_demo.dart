import 'package:texpr/texpr.dart';

void main() {
  final evaluator = Texpr();

  print('=== Conditional Expressions Demo ===\n');

  // Example 1: Curly brace notation f(x) = x^2 - 2 {-1 < x < 2}
  print('Example 1: f(x) = x^2 - 2 {-1 < x < 2}');
  for (var x in [-2.0, -0.5, 0.0, 1.0, 3.0]) {
    final result = evaluator.evaluate('f(x)=x^{2}-2{-1<x<2}', {'x': x});
    print(
        '  x = $x => ${result.isNaN ? "undefined (condition not met)" : result}');
  }

  print('\nExample 2: x^2 - 2, -1 < x < 2 (comma notation)');
  for (var x in [-2.0, -0.5, 0.0, 1.0, 3.0]) {
    final result = evaluator.evaluate('x^2-2, -1 < x < 2', {'x': x});
    print(
        '  x = $x => ${result.isNaN ? "undefined (condition not met)" : result}');
  }

  print('\nExample 3: sqrt(x), x >= 0');
  for (var x in [-1.0, 0.0, 4.0, 9.0]) {
    final result = evaluator.evaluate('\\sqrt{x}, x >= 0', {'x': x});
    print(
        '  x = $x => ${result.isNaN ? "undefined (condition not met)" : result}');
  }

  print('\nExample 4: Standalone chained comparison: 0 <= x <= 10');
  for (var x in [-1.0, 0.0, 5.0, 10.0, 15.0]) {
    final result = evaluator.evaluate('0 <= x <= 10', {'x': x});
    print(
        '  x = $x => ${result.isNumeric ? (result.asNumeric() == 1.0 ? "true" : "false") : "false"}');
  }
}
