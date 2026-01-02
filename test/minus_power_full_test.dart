import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  final evaluator = Texpr();

  test('isValid should accept expression with unary minus and power', () {
    expect(evaluator.isValid(r'-(x-1)^{2}+4'), isTrue);
  });

  test('evaluate numeric matches expected value', () {
    final value = evaluator.evaluateNumeric(r'-(x-1)^{2}+4', {'x': 2});
    expect(value, equals(3.0));
  });

  test('differentiate yields expected derivative and numeric value', () {
    final derivative = evaluator.differentiate(r'-(x-1)^{2}+4', 'x');
    // derivative should be -2*(x-1)
    final derivVal = evaluator.evaluateParsed(derivative, {'x': 2}).asNumeric();
    expect(derivVal, equals(-2.0));
  });

  test('simplify and expand produce consistent numeric result', () {
    final parsed = evaluator.parse(r'-(x-1)^{2}+4');
    final simplified = Simplifier().simplify(parsed);

    final originalVal = evaluator.evaluateParsed(parsed, {'x': 3}).asNumeric();
    final simplifiedVal =
        evaluator.evaluateParsed(simplified, {'x': 3}).asNumeric();
    expect(originalVal, equals(simplifiedVal));
  });
}
