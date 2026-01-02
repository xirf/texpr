import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Square Root with Optional Parameter', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    group('Cube roots (n=3)', () {
      test('evaluates \\sqrt[3]{8}', () {
        final result = evaluator.evaluate(r'\sqrt[3]{8}');
        expect(result.asNumeric(), closeTo(2.0, 1e-10));
      });

      test('evaluates \\sqrt[3]{27}', () {
        final result = evaluator.evaluate(r'\sqrt[3]{27}');
        expect(result.asNumeric(), closeTo(3.0, 1e-10));
      });

      test('evaluates \\sqrt[3]{-8} (odd root)', () {
        final result = evaluator.evaluate(r'\sqrt[3]{-8}');
        expect(result.asNumeric(), closeTo(-2.0, 1e-10));
      });

      test('evaluates \\sqrt[3]{-27}', () {
        final result = evaluator.evaluate(r'\sqrt[3]{-27}');
        expect(result.asNumeric(), closeTo(-3.0, 1e-10));
      });
    });

    group('4th roots', () {
      test('evaluates \\sqrt[4]{16}', () {
        final result = evaluator.evaluate(r'\sqrt[4]{16}');
        expect(result.asNumeric(), closeTo(2.0, 1e-10));
      });

      test('evaluates \\sqrt[4]{81}', () {
        final result = evaluator.evaluate(r'\sqrt[4]{81}');
        expect(result.asNumeric(), closeTo(3.0, 1e-10));
      });

      test('returns complex for \\sqrt[4]{-16} (even root of negative)', () {
        final result = evaluator.evaluate(r'\sqrt[4]{-16}');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        // 4th root of -16 = 2*(cos(π/4) + i*sin(π/4)) ≈ 1.41 + 1.41i
        expect(c.abs, closeTo(2.0, 1e-10));
      });
    });

    group('Other nth roots', () {
      test('evaluates \\sqrt[5]{32}', () {
        final result = evaluator.evaluate(r'\sqrt[5]{32}');
        expect(result.asNumeric(), closeTo(2.0, 1e-10));
      });

      test('evaluates \\sqrt[2]{16} (explicitly 2nd root)', () {
        final result = evaluator.evaluate(r'\sqrt[2]{16}');
        expect(result.asNumeric(), closeTo(4.0, 1e-10));
      });

      test('evaluates \\sqrt[10]{1024}', () {
        final result = evaluator.evaluate(r'\sqrt[10]{1024}');
        expect(result.asNumeric(), closeTo(2.0, 1e-10));
      });
    });

    group('With variables', () {
      test('evaluates \\sqrt[3]{x} with x=8', () {
        final result = evaluator.evaluate(r'\sqrt[3]{x}', {'x': 8.0});
        expect(result.asNumeric(), closeTo(2.0, 1e-10));
      });

      test('evaluates \\sqrt[n]{x} with n=3, x=27', () {
        final result =
            evaluator.evaluate(r'\sqrt[n]{x}', {'n': 3.0, 'x': 27.0});
        expect(result.asNumeric(), closeTo(3.0, 1e-10));
      });

      test('evaluates \\sqrt[n]{x} with n=4, x=16', () {
        final result =
            evaluator.evaluate(r'\sqrt[n]{x}', {'n': 4.0, 'x': 16.0});
        expect(result.asNumeric(), closeTo(2.0, 1e-10));
      });
    });

    group('Complex expressions', () {
      test('evaluates \\sqrt[3]{2^3}', () {
        final result = evaluator.evaluate(r'\sqrt[3]{2^3}');
        expect(result.asNumeric(), closeTo(2.0, 1e-10));
      });

      test('evaluates 2\\sqrt[3]{8}', () {
        final result = evaluator.evaluate(r'2\sqrt[3]{8}');
        expect(result.asNumeric(), closeTo(4.0, 1e-10));
      });

      test('evaluates \\sqrt[3]{x+y} with variables', () {
        final result =
            evaluator.evaluate(r'\sqrt[3]{x+y}', {'x': 4.0, 'y': 4.0});
        expect(result.asNumeric(), closeTo(2.0, 1e-10));
      });

      test('evaluates nested roots \\sqrt[3]{\\sqrt{64}}', () {
        final result = evaluator.evaluate(r'\sqrt[3]{\sqrt{64}}');
        expect(result.asNumeric(), closeTo(2.0, 1e-10));
      });
    });

    group('Error cases', () {
      test('returns complex for \\sqrt[2]{-4} (even root of negative)', () {
        final result = evaluator.evaluate(r'\sqrt[2]{-4}');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.imaginary, closeTo(2.0, 1e-10));
      });

      test('throws on \\sqrt[0]{8} (0th root)', () {
        expect(
          () => evaluator.evaluate(r'\sqrt[0]{8}'),
          throwsA(isA<EvaluatorException>()),
        );
      });

      test('returns complex for \\sqrt[6]{-64} (even root of negative)', () {
        final result = evaluator.evaluate(r'\sqrt[6]{-64}');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.abs, closeTo(2.0, 1e-10));
      });
    });

    group('Backwards compatibility', () {
      test('\\sqrt{16} still works (square root)', () {
        final result = evaluator.evaluate(r'\sqrt{16}');
        expect(result.asNumeric(), closeTo(4.0, 1e-10));
      });

      test('\\sqrt{25} still works', () {
        final result = evaluator.evaluate(r'\sqrt{25}');
        expect(result.asNumeric(), closeTo(5.0, 1e-10));
      });

      test('\\sqrt{x} with variable still works', () {
        final result = evaluator.evaluate(r'\sqrt{x}', {'x': 9.0});
        expect(result.asNumeric(), closeTo(3.0, 1e-10));
      });

      test('returns complex for \\sqrt{-1} (imaginary unit)', () {
        final result = evaluator.evaluate(r'\sqrt{-1}');
        expect(result, isA<ComplexResult>());
        final c = (result as ComplexResult).value;
        expect(c.imaginary, closeTo(1.0, 1e-10));
      });
    });
  });
}
