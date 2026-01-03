import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  group('Fibonacci function', () {
    test('basic values', () {
      final evaluator = Texpr();

      expect(evaluator.evaluateNumeric(r'\fibonacci{0}'), 0.0);
      expect(evaluator.evaluateNumeric(r'\fibonacci{1}'), 1.0);
      expect(evaluator.evaluateNumeric(r'\fibonacci{2}'), 1.0);
      expect(evaluator.evaluateNumeric(r'\fibonacci{3}'), 2.0);
      expect(evaluator.evaluateNumeric(r'\fibonacci{10}'), 55.0);
    });

    test('negative input throws', () {
      final evaluator = Texpr();
      expect(() => evaluator.evaluateNumeric(r'\fibonacci{-1}'),
          throwsA(isA<TexprException>()));
    });
  });
}
