import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Real-Only Mode', () {
    late Texpr texprDefault;
    late Texpr texprRealOnly;

    setUp(() {
      texprDefault = Texpr(); // Default: complex numbers enabled
      texprRealOnly = Texpr(realOnly: true); // Real-only: NaN for complex
    });

    group('sqrt of negative numbers', () {
      test('default mode returns complex number', () {
        final result = texprDefault.evaluate(r'\sqrt{-1}');
        expect(result, isA<ComplexResult>());
        final value = (result as ComplexResult).value;
        expect(value.real, closeTo(0, 1e-10));
        expect(value.imaginary, closeTo(1, 1e-10));
      });

      test('real-only mode returns NaN', () {
        final result = texprRealOnly.evaluate(r'\sqrt{-1}');
        expect(result, isA<NumericResult>());
        expect((result as NumericResult).value.isNaN, isTrue);
      });

      test('sqrt of positive works in both modes', () {
        expect(texprDefault.evaluateNumeric(r'\sqrt{4}'), equals(2.0));
        expect(texprRealOnly.evaluateNumeric(r'\sqrt{4}'), equals(2.0));
      });

      test('sqrt of zero works in both modes', () {
        expect(texprDefault.evaluateNumeric(r'\sqrt{0}'), equals(0.0));
        expect(texprRealOnly.evaluateNumeric(r'\sqrt{0}'), equals(0.0));
      });
    });

    group('abs of sqrt of negative (the Desmos case)', () {
      test('default mode: |sqrt(π*x) - 2x| at x=-1 returns real magnitude', () {
        // sqrt(π * -1) = sqrt(-π) ≈ 1.77i
        // |1.77i - 2*(-1)| = |2 + 1.77i| = sqrt(4 + 3.14) ≈ 2.67
        final result =
            texprDefault.evaluate(r'|\sqrt{\pi x} - 2x|', {'x': -1.0});
        expect(result, isA<NumericResult>());
        final value = (result as NumericResult).value;
        expect(value, closeTo(2.67, 0.1));
      });

      test('real-only mode: |sqrt(π*x) - 2x| at x=-1 returns NaN', () {
        final result =
            texprRealOnly.evaluate(r'|\sqrt{\pi x} - 2x|', {'x': -1.0});
        expect(result, isA<NumericResult>());
        expect((result as NumericResult).value.isNaN, isTrue);
      });

      test('both modes work for positive x', () {
        // sqrt(π * 1) ≈ 1.77
        // |1.77 - 2*1| = |1.77 - 2| = 0.23
        final resultDefault =
            texprDefault.evaluate(r'|\sqrt{\pi x} - 2x|', {'x': 1.0});
        final resultRealOnly =
            texprRealOnly.evaluate(r'|\sqrt{\pi x} - 2x|', {'x': 1.0});

        expect(resultDefault, isA<NumericResult>());
        expect(resultRealOnly, isA<NumericResult>());

        final valueDefault = (resultDefault as NumericResult).value;
        final valueRealOnly = (resultRealOnly as NumericResult).value;

        expect(valueDefault, closeTo(0.23, 0.1));
        expect(valueRealOnly, closeTo(0.23, 0.1));
      });
    });

    group('ln of negative numbers', () {
      test('default mode returns complex number', () {
        final result = texprDefault.evaluate(r'\ln{-1}');
        expect(result, isA<ComplexResult>());
        final value = (result as ComplexResult).value;
        // ln(-1) = iπ
        expect(value.real, closeTo(0, 1e-10));
        expect(value.imaginary, closeTo(3.14159, 0.001));
      });

      test('real-only mode returns NaN', () {
        final result = texprRealOnly.evaluate(r'\ln{-1}');
        expect(result, isA<NumericResult>());
        expect((result as NumericResult).value.isNaN, isTrue);
      });

      test('ln of positive works in both modes', () {
        expect(texprDefault.evaluateNumeric(r'\ln{e}'), closeTo(1.0, 1e-10));
        expect(texprRealOnly.evaluateNumeric(r'\ln{e}'), closeTo(1.0, 1e-10));
      });
    });

    group('log of negative numbers', () {
      test('default mode returns complex number', () {
        final result = texprDefault.evaluate(r'\log{-10}');
        expect(result, isA<ComplexResult>());
      });

      test('real-only mode returns NaN', () {
        final result = texprRealOnly.evaluate(r'\log{-10}');
        expect(result, isA<NumericResult>());
        expect((result as NumericResult).value.isNaN, isTrue);
      });

      test('log of positive works in both modes', () {
        expect(texprDefault.evaluateNumeric(r'\log{100}'), closeTo(2.0, 1e-10));
        expect(
            texprRealOnly.evaluateNumeric(r'\log{100}'), closeTo(2.0, 1e-10));
      });
    });

    group('nth root of negative numbers', () {
      test('even root of negative: default returns complex', () {
        final result = texprDefault.evaluate(r'\sqrt[4]{-16}');
        expect(result, isA<ComplexResult>());
      });

      test('even root of negative: real-only returns NaN', () {
        final result = texprRealOnly.evaluate(r'\sqrt[4]{-16}');
        expect(result, isA<NumericResult>());
        expect((result as NumericResult).value.isNaN, isTrue);
      });

      test('odd root of negative works in both modes (real result)', () {
        // Cube root of -8 = -2 (real number)
        expect(texprDefault.evaluateNumeric(r'\sqrt[3]{-8}'),
            closeTo(-2.0, 1e-10));
        expect(texprRealOnly.evaluateNumeric(r'\sqrt[3]{-8}'),
            closeTo(-2.0, 1e-10));
      });
    });

    group('NaN propagates through operations', () {
      test('NaN + number = NaN', () {
        final result = texprRealOnly.evaluate(r'\sqrt{-1} + 5');
        expect(result, isA<NumericResult>());
        expect((result as NumericResult).value.isNaN, isTrue);
      });

      test('NaN * number = NaN', () {
        final result = texprRealOnly.evaluate(r'\sqrt{-1} \times 5');
        expect(result, isA<NumericResult>());
        expect((result as NumericResult).value.isNaN, isTrue);
      });

      test('function of NaN = NaN', () {
        final result = texprRealOnly.evaluate(r'\sin{\sqrt{-1}}');
        expect(result, isA<NumericResult>());
        expect((result as NumericResult).value.isNaN, isTrue);
      });
    });

    group('Evaluator class direct usage', () {
      test('realOnly parameter works on Evaluator', () {
        final evaluatorDefault = Evaluator();
        final evaluatorRealOnly = Evaluator(realOnly: true);

        final parser = Texpr();
        final expr = parser.parse(r'\sqrt{-1}');

        final resultDefault = evaluatorDefault.evaluate(expr);
        final resultRealOnly = evaluatorRealOnly.evaluate(expr);

        expect(resultDefault, isA<ComplexResult>());
        expect(resultRealOnly, isA<NumericResult>());
        expect((resultRealOnly as NumericResult).value.isNaN, isTrue);
      });
    });
  });
}
