import 'dart:math' as math;
import 'package:test/test.dart';
import 'package:texpr/src/interval.dart';
import 'package:texpr/src/evaluation_result.dart'; // For IntervalResult

void main() {
  group('Interval', () {
    test('creation and properties', () {
      final i = Interval(1, 3);
      expect(i.lower, 1);
      expect(i.upper, 3);
      expect(i.width, 2);
      expect(i.midpoint, 2);
      expect(i.radius, 1);
      expect(i.isEmpty, false);
      expect(i.isPoint, false);
      expect(i.containsZero, false);
      expect(i.toString(), '[1.0, 3.0]');
    });

    test('point interval', () {
      final p = Interval.point(5);
      expect(p.lower, 5);
      expect(p.upper, 5);
      expect(p.isPoint, true);
      expect(p.width, 0);
      expect(p.contains(5), true);
    });

    test('containsZero', () {
      expect(Interval(-1, 1).containsZero, true);
      expect(Interval(0, 1).containsZero, true);
      expect(Interval(-1, 0).containsZero, true);
      expect(Interval(1, 2).containsZero, false);
      expect(Interval(-2, -1).containsZero, false);
    });

    test('addition', () {
      final a = Interval(1, 2);
      final b = Interval(3, 4);
      final sum = a + b;
      expect(sum, Interval(4, 6));
      expect(a + 5, Interval(6, 7));
    });

    test('subtraction', () {
      final a = Interval(1, 2);
      final b = Interval(3, 4);
      // [1,2] - [3,4] = [1-4, 2-3] = [-3, -1]
      final diff = a - b;
      expect(diff, Interval(-3, -1));
      expect(a - 1, Interval(0, 1));
    });

    test('multiplication', () {
      final a = Interval(-2, 1);
      final b = Interval(3, 4);
      // [-2,1] * [3,4]
      // -2*3=-6, -2*4=-8, 1*3=3, 1*4=4
      // min=-8, max=4
      expect(a * b, Interval(-8, 4));

      expect(Interval(2, 3) * 2, Interval(4, 6));
      expect(Interval(2, 3) * -1, Interval(-3, -2));
    });

    test('division', () {
      final a = Interval(10, 20);
      final b = Interval(2, 5);
      // [10,20] * [1/5, 1/2] = [2, 10]
      expect(a / b, Interval(2, 10));

      expect(() => a / Interval(-1, 1), throwsArgumentError);
      expect(a / 2, Interval(5, 10));
    });

    test('reciprocal', () {
      expect(Interval(2, 4).reciprocal, Interval(0.25, 0.5));
      expect(() => Interval(-1, 1).reciprocal, throwsArgumentError);
    });

    test('abs', () {
      expect(Interval(2, 3).abs(), Interval(2, 3));
      expect(Interval(-3, -2).abs(), Interval(2, 3));
      expect(Interval(-2, 3).abs(), Interval(0, 3));
    });

    test('square', () {
      expect(Interval(2, 3).square(), Interval(4, 9));
      expect(Interval(-3, -2).square(), Interval(4, 9));
      expect(Interval(-2, 3).square(), Interval(0, 9));
    });

    test('pow', () {
      expect(Interval(2, 3).pow(2), Interval(4, 9));
      expect(Interval(2, 3).pow(3), Interval(8, 27));
      expect(Interval(-2, 2).pow(2), Interval(0, 4));
      expect(Interval(2, 3).pow(0), Interval.point(1));
    });

    test('transcendental functions', () {
      final i = Interval(0, 1);
      final exp = i.exp();
      expect(exp.lower, closeTo(1.0, 1e-10));
      expect(exp.upper, closeTo(2.718281828, 1e-9));

      final j = Interval(1, 2.718281828);
      final log = j.log();
      expect(log.lower, closeTo(0.0, 1e-10));
      expect(log.upper, closeTo(1.0, 1e-7));
    });

    test('trigonometric functions', () {
      // sin([0, pi]) = [0, 1]
      expect(Interval(0, math.pi).sin().lower, closeTo(0.0, 1e-10));
      expect(Interval(0, math.pi).sin().upper, closeTo(1.0, 1e-10));

      // sin([0, 2pi]) = [-1, 1]
      expect(Interval(0, 2 * math.pi).sin().lower, closeTo(-1.0, 1e-10));
      expect(Interval(0, 2 * math.pi).sin().upper, closeTo(1.0, 1e-10));

      // cos([0, pi]) = [-1, 1]
      expect(Interval(0, math.pi).cos().lower, closeTo(-1.0, 1e-10));
      expect(Interval(0, math.pi).cos().upper, closeTo(1.0, 1e-10));

      // tan([-pi/4, pi/4]) = [-1, 1]
      expect(Interval(-math.pi / 4, math.pi / 4).tan().lower,
          closeTo(-1.0, 1e-10));
      expect(
          Interval(-math.pi / 4, math.pi / 4).tan().upper, closeTo(1.0, 1e-10));
    });

    test('inverse trigonometric functions', () {
      // asin([-1, 1]) = [-pi/2, pi/2]
      final asin = Interval(-1, 1).asin();
      expect(asin.lower, closeTo(-math.pi / 2, 1e-10));
      expect(asin.upper, closeTo(math.pi / 2, 1e-10));

      // acos([-1, 1]) = [0, pi] (monotonic decreasing, so acos(1) is lower, acos(-1) is upper)
      // acos(1) = 0, acos(-1) = pi
      final acos = Interval(-1, 1).acos();
      expect(acos.lower, closeTo(0, 1e-10));
      expect(acos.upper, closeTo(math.pi, 1e-10));

      expect(Interval(0, 1).atan().lower, 0);
      expect(Interval(0, 1).atan().upper, closeTo(math.pi / 4, 1e-10));
    });

    test('hyperbolic functions', () {
      expect(Interval(0, 1).sinh().lower, 0);
      expect(Interval(0, 1).cosh().lower, 1);
      expect(Interval(0, 1).tanh().lower, 0);
    });

    test('IntervalResult', () {
      final res = IntervalResult(Interval(1, 2));
      expect(res.isInterval, true);
      expect(res.asInterval(), Interval(1, 2));
      expect(res.asNumeric(), 1.5); // midpoint
      expect(() => res.asComplex(), throwsStateError);
      expect(res.isNaN, false);
    });
  });
}
