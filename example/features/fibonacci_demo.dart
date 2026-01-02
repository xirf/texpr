import 'package:texpr/texpr.dart';

void main() {
  final evaluator = Texpr();
  print('fibonacci(0) = ${evaluator.evaluateNumeric(r"\fibonacci{0}")}');
  print('fibonacci(1) = ${evaluator.evaluateNumeric(r"\fibonacci{1}")}');
  print('fibonacci(12) = ${evaluator.evaluateNumeric(r"\fibonacci{12}")}');
  print('factorial(6) = ${evaluator.evaluateNumeric(r"\factorial{6}")}');
}
