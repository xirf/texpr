import 'package:texpr/texpr.dart';
import 'package:test/test.dart';
import 'dart:math' as math;

void main() {
  group('Implicit Multiplication Reproduction', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    test('2x + 1 with x=2', () {
      final result = evaluator.evaluate("2x + 1", {'x': 2}).asNumeric();
      expect(result, 5.0);
    });

    test('3\\sin{x} with x=pi/2', () {
      final result =
          evaluator.evaluate("3\\sin{x}", {'x': math.pi / 2}).asNumeric();
      expect(result, 3.0);
    });

    test('(x+1)(x-1) with x=3', () {
      final result = evaluator.evaluate("(x+1)(x-1)", {'x': 3}).asNumeric();
      expect(result, 8.0);
    });
  });
}
