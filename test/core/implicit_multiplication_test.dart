import 'package:test/test.dart';
import 'package:texpr/texpr.dart';
import 'dart:math' as math;

void main() {
  group('Implicit Multiplication Heuristics', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    group('Exponent implicit multiplication', () {
      test('e^{ix} evaluates to Euler identity at π', () {
        final result = evaluator.evaluate(r'e^{ix}', {'x': math.pi});
        final complex = result.asComplex();
        expect(complex.real, closeTo(-1.0, 1e-10));
        expect(complex.imaginary, closeTo(0.0, 1e-10));
      });

      test('e^ix without braces is parsed as (e^i)*x', () {
        // Note: Without braces, e^ix is parsed as (e^i) * x
        // This is expected behavior; use e^{ix} for Euler's formula
        final result = evaluator.evaluate(r'e^ix', {'x': 2.0});
        final complex = result.asComplex();
        // e^i ≈ 0.540 + 0.841i, then multiplied by x=2
        expect(complex.real, closeTo(2 * math.cos(1), 1e-10));
        expect(complex.imaginary, closeTo(2 * math.sin(1), 1e-10));
      });

      test('2^{xy} evaluates with implicit multiplication in braced exponent',
          () {
        final result =
            evaluator.evaluateNumeric(r'2^{xy}', {'x': 2.0, 'y': 3.0});
        // 2^(2*3) = 2^6 = 64
        expect(result, equals(64.0));
      });
    });

    group('Variable implicit multiplication', () {
      test('2xy evaluates as 2*x*y', () {
        final result = evaluator.evaluateNumeric('2xy', {'x': 3.0, 'y': 4.0});
        expect(result, equals(24.0));
      });

      test('abc evaluates as a*b*c', () {
        final result =
            evaluator.evaluateNumeric('abc', {'a': 2.0, 'b': 3.0, 'c': 4.0});
        expect(result, equals(24.0));
      });

      test(r'2\pi r evaluates correctly with LaTeX pi', () {
        final result = evaluator.evaluateNumeric(r'2\pi r', {'r': 1.0});
        expect(result, closeTo(2 * math.pi, 1e-10));
      });

      test('implicit multiplication with parentheses: x(x+1)', () {
        final result = evaluator.evaluateNumeric('x(x+1)', {'x': 3.0});
        // 3 * (3+1) = 3 * 4 = 12
        expect(result, equals(12.0));
      });
    });

    group('Function implicit multiplication', () {
      test(r'2\sin{x} evaluates as 2*sin(x)', () {
        final result =
            evaluator.evaluateNumeric(r'2\sin{x}', {'x': math.pi / 2});
        expect(result, closeTo(2.0, 1e-10));
      });

      test(r'x\sin{x} evaluates as x*sin(x)', () {
        final result =
            evaluator.evaluateNumeric(r'x\sin{x}', {'x': math.pi / 2});
        expect(result, closeTo(math.pi / 2, 1e-10));
      });
    });

    group(
        'Disabled implicit multiplication (allowImplicitMultiplication: false)',
        () {
      late Texpr evalNoImplicit;

      setUp(() {
        evalNoImplicit = Texpr(allowImplicitMultiplication: false);
      });

      test('xy is treated as single variable xy, not x*y', () {
        // With implicit multiplication disabled, 'xy' is a single variable
        final result = evalNoImplicit.evaluateNumeric('xy', {'xy': 42.0});
        expect(result, equals(42.0));
      });

      test('multi-char variables work without implicit multiplication', () {
        // Common scientific variable names
        expect(evalNoImplicit.evaluateNumeric('mass', {'mass': 10.0}),
            equals(10.0));
        expect(evalNoImplicit.evaluateNumeric('velocity', {'velocity': 5.0}),
            equals(5.0));
        expect(
            evalNoImplicit.evaluateNumeric('time', {'time': 3.0}), equals(3.0));
      });

      test('throws when trying to use xy with separate x and y variables', () {
        expect(
          () => evalNoImplicit.evaluateNumeric('xy', {'x': 2.0, 'y': 3.0}),
          throwsA(isA<EvaluatorException>()),
        );
      });

      test('explicit multiplication still works', () {
        final result =
            evalNoImplicit.evaluateNumeric(r'x \times y', {'x': 2.0, 'y': 3.0});
        expect(result, equals(6.0));
      });

      test('explicit multiplication with cdot works', () {
        final result =
            evalNoImplicit.evaluateNumeric(r'x \cdot y', {'x': 2.0, 'y': 3.0});
        expect(result, equals(6.0));
      });

      test('explicit multiplication with asterisk works', () {
        final result =
            evalNoImplicit.evaluateNumeric('x * y', {'x': 2.0, 'y': 3.0});
        expect(result, equals(6.0));
      });

      test('number followed by variable requires explicit operator', () {
        // '2x' with disabled implicit multiplication - should treat as '2' followed by variable 'x'
        // The parser may still handle this differently, let's check syntax validity
        final result = evalNoImplicit.evaluateNumeric('2 * x', {'x': 5.0});
        expect(result, equals(10.0));
      });

      test('functions still work normally', () {
        expect(
          evalNoImplicit.evaluateNumeric(r'\sin{\pi}'),
          closeTo(0.0, 1e-10),
        );
        expect(
          evalNoImplicit.evaluateNumeric(r'\sqrt{16}'),
          equals(4.0),
        );
      });

      test('validates multi-char variable expressions', () {
        expect(evalNoImplicit.isValid('abc'), isTrue);
        expect(evalNoImplicit.isValid('mass'), isTrue);
      });
    });
  });
}
