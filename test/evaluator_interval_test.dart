import 'package:test/test.dart';
import 'package:texpr/texpr.dart';
import 'dart:math' as math;

void main() {
  group('Evaluator with Interval', () {
    late Texpr texpr;

    setUp(() {
      texpr = Texpr();
    });

    test('Variable substitution', () {
      final result = texpr.evaluate('x', {'x': Interval(1, 2)});
      expect(result, isA<IntervalResult>());
      expect((result as IntervalResult).interval, Interval(1, 2));
    });

    test('Binary operations (Interval + Number)', () {
      // x + 1 => [1,2] + 1 => [2,3]
      var result = texpr.evaluate('x + 1', {'x': Interval(1, 2)});
      expect((result as IntervalResult).interval, Interval(2, 3));

      // 1 + x => [2,3]
      result = texpr.evaluate('1 + x', {'x': Interval(1, 2)});
      expect((result as IntervalResult).interval, Interval(2, 3));
    });

    test('Binary operations (Interval * Interval)', () {
      // x * x => [1, 2] * [1, 2] => [1, 4]
      final result =
          texpr.evaluate('x * y', {'x': Interval(1, 2), 'y': Interval(1, 2)});
      expect((result as IntervalResult).interval, Interval(1, 4));
    });

    test('Binary operations (Division)', () {
      // x / 2 => [1, 2] / 2 => [0.5, 1]
      final result = texpr.evaluate('x / 2', {'x': Interval(1, 2)});
      expect((result as IntervalResult).interval, Interval(0.5, 1.0));
    });

    test('Power function (x^2)', () {
      // x^2, x=[1,2] => [1,4]
      final result = texpr.evaluate('x^2', {'x': Interval(1, 2)});
      expect((result as IntervalResult).interval, Interval(1, 4));

      // x^3 => [1, 8]
      final result3 = texpr.evaluate('x^3', {'x': Interval(1, 2)});
      expect((result3 as IntervalResult).interval, Interval(1, 8));
    });

    test('Sqrt function', () {
      // sqrt([4, 9]) => [2, 3]
      final result = texpr.evaluate('sqrt(x)', {'x': Interval(4, 9)});
      expect((result as IntervalResult).interval, Interval(2, 3));
    });

    test('Trigonometric functions (sin)', () {
      // sin([0, pi]) => [0, 1]
      final result = texpr.evaluate('sin(x)', {'x': Interval(0, math.pi)});
      final interval = (result as IntervalResult).interval;
      expect(interval.lower, closeTo(0, 1e-10));
      expect(interval.upper, closeTo(1, 1e-10));
    });

    test('Inverse trigonometric functions (asin)', () {
      // asin([0, 0.5]) => [0, pi/6]
      final result = texpr.evaluate('asin(x)', {'x': Interval(0, 0.5)});
      final interval = (result as IntervalResult).interval;
      expect(interval.lower, 0.0);
      expect(interval.upper, closeTo(math.pi / 6, 1e-10));
    });

    test('Logarithm (ln)', () {
      // ln([e, e^2]) => [1, 2]
      final e = math.e;
      final result = texpr.evaluate('ln(x)', {'x': Interval(e, e * e)});
      final interval = (result as IntervalResult).interval;
      expect(interval.lower, closeTo(1, 1e-10));
      expect(interval.upper, closeTo(2, 1e-10));
    });

    test('Logarithm (log base 10)', () {
      // log([10, 100]) => [1, 2]
      final result = texpr.evaluate('log(x)', {'x': Interval(10, 100)});
      final interval = (result as IntervalResult).interval;
      expect(interval.lower, closeTo(1, 1e-10));
      expect(interval.upper, closeTo(2, 1e-10));
    });

    test('Exponential (exp)', () {
      // exp([0, 1]) => [1, e]
      final result = texpr.evaluate('exp(x)', {'x': Interval(0, 1)});
      final interval = (result as IntervalResult).interval;
      expect(interval.lower, 1.0);
      expect(interval.upper, closeTo(math.e, 1e-10));
    });

    test('Absolute value (abs)', () {
      // abs([-2, 1]) => [0, 2]
      final result = texpr.evaluate('abs(x)', {'x': Interval(-2, 1)});
      expect((result as IntervalResult).interval, Interval(0, 2));
    });

    group('Interval Notation Parsing', () {
      test('Literal interval', () {
        final result = texpr.evaluate('[1, 2]');
        expect((result as IntervalResult).interval, Interval(1, 2));
      });

      test('Interval expression', () {
        // [1+1, 2*2] => [2, 4]
        final result = texpr.evaluate('[1+1, 2*2]');
        expect((result as IntervalResult).interval, Interval(2, 4));
      });

      test('Variable in interval', () {
        // [x, x+1] with x=1 => [1, 2]
        final result = texpr.evaluate('[x, x+1]', {'x': 1});
        expect((result as IntervalResult).interval, Interval(1, 2));
      });

      test('Interval arithmetic with notation', () {
        // [1, 2] + [3, 4] => [4, 6]
        final result = texpr.evaluate('[1, 2] + [3, 4]');
        expect((result as IntervalResult).interval, Interval(4, 6));
      });

      test('Mixed operations', () {
        // [1, 2] * 2 => [2, 4]
        final result = texpr.evaluate('[1, 2] * 2');
        expect((result as IntervalResult).interval, Interval(2, 4));
      });

      test('Nested intervals (Invalid logic but valid parse)', () {
        // [ [1,2], [3,4] ] -> Interval of intervals?
        // Our evaluator enforces numeric bounds for now.
        // Expect error during evaluation?
        expect(() => texpr.evaluate('[[1, 2], [3, 4]]'),
            throwsA(isA<EvaluatorException>()));
        // Or EvaluatorException? asNumeric() throws StateError.
      });
    });
  });
}
