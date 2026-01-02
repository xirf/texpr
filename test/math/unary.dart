import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  test('Evaluate -(1+2)', () {
    final evaluator = Texpr();
    final result = evaluator.evaluateNumeric('-(1+2)');
    expect(result, closeTo(-3.0, 0.0001));
  });

  test('Evaluate - (1+2) with space', () {
    final evaluator = Texpr();
    final result = evaluator.evaluateNumeric('- (1+2)');
    expect(result, closeTo(-3.0, 0.0001));
  });

  test("Evaluate -x^2+4 where x=3", () {
    final evaluator = Texpr();
    final result = evaluator.evaluateNumeric('-x^2+4', {'x': 3});
    expect(result, closeTo(-5.0, 0.0001));
  });
  test("Evaluate -(x+1)^2 where x=3", () {
    final evaluator = Texpr();
    final result = evaluator.evaluateNumeric('-(x+1)^2', {'x': 3});
    expect(result, closeTo(-16.0, 0.0001));
  });
}
