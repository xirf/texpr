import 'package:texpr/texpr.dart';

void main() {
  final evaluator = Texpr();
  try {
    evaluator.evaluate('1 + (2 > 1)');
    print('Failed: Should throw');
  } catch (e) {
    print('Passed: Threw $e');
  }
}
