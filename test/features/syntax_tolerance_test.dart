import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Tests for LaTeX syntax tolerance features.
///
/// These test the ability to parse common LaTeX variations without adjustment:
/// - Braceless fractions: `\frac12` to `\frac{1}{2}`
/// - Backslash-less functions: `sin(x)` to `\sin{x}`
/// - Implicit multiplication in exponents: `e^{ix}` (already works)
void main() {
  late LatexMathEvaluator evaluator;

  setUp(() {
    evaluator = LatexMathEvaluator();
  });

  group('Braceless Fractions', () {
    test(r'\frac12 = 0.5', () {
      final result = evaluator.evaluate(r'\frac12');
      expect(result.asNumeric(), equals(0.5));
    });

    test(r'\frac34 = 0.75', () {
      final result = evaluator.evaluate(r'\frac34');
      expect(result.asNumeric(), equals(0.75));
    });

    test(r'\frac1x with variable', () {
      final result = evaluator.evaluate(r'\frac1x', {'x': 4.0});
      expect(result.asNumeric(), equals(0.25));
    });

    test(r'\frac xy with two variables', () {
      // Note: space needed after \frac so tokenizer sees \frac as command
      final result = evaluator.evaluate(r'\frac xy', {'x': 6.0, 'y': 2.0});
      expect(result.asNumeric(), equals(3.0));
    });

    test(r'\frac12 + 1 = 1.5', () {
      final result = evaluator.evaluate(r'\frac12 + 1');
      expect(result.asNumeric(), equals(1.5));
    });

    test(r'ambiguous \frac123 throws clear error', () {
      expect(
        () => evaluator.evaluate(r'\frac123'),
        throwsA(isA<ParserException>().having(
          (e) => e.message,
          'message',
          contains('Ambiguous'),
        )),
      );
    });

    test(r'ambiguous \frac1234 throws clear error', () {
      expect(
        () => evaluator.evaluate(r'\frac1234'),
        throwsA(isA<ParserException>().having(
          (e) => e.suggestion,
          'suggestion',
          contains('braces'),
        )),
      );
    });

    test(r'mixed braced and braceless: \frac{12}3 works', () {
      final result = evaluator.evaluate(r'\frac{12}3');
      expect(result.asNumeric(), equals(4.0));
    });

    test(r'standard braced fraction still works', () {
      final result = evaluator.evaluate(r'\frac{1}{2}');
      expect(result.asNumeric(), equals(0.5));
    });
  });

  group('Backslash-less Functions', () {
    test('sin(x) without backslash', () {
      final result = evaluator.evaluate('sin(0)');
      expect(result.asNumeric(), equals(0.0));
    });

    test('cos(x) without backslash', () {
      final result = evaluator.evaluate('cos(0)');
      expect(result.asNumeric(), equals(1.0));
    });

    test('tan(x) without backslash', () {
      final result = evaluator.evaluate('tan(0)');
      expect(result.asNumeric(), closeTo(0.0, 1e-10));
    });

    test('ln(x) without backslash', () {
      final result = evaluator.evaluate('ln(1)');
      expect(result.asNumeric(), equals(0.0));
    });

    test('exp(x) without backslash', () {
      final result = evaluator.evaluate('exp(0)');
      expect(result.asNumeric(), equals(1.0));
    });

    test('sqrt(x) without backslash', () {
      final result = evaluator.evaluate('sqrt(4)');
      expect(result.asNumeric(), equals(2.0));
    });

    test('abs(x) without backslash', () {
      final result = evaluator.evaluate('abs(-5)');
      expect(result.asNumeric(), equals(5.0));
    });

    test('sin(x) with variable', () {
      final result = evaluator.evaluate(r'sin(x)', {'x': 0.0});
      expect(result.asNumeric(), equals(0.0));
    });

    test('combined expression: sin(x) + cos(x)', () {
      final result = evaluator.evaluate('sin(0) + cos(0)');
      expect(result.asNumeric(), equals(1.0));
    });

    test('sin still works as s*i*n without parentheses', () {
      // When not followed by (, it should still be implicit multiplication
      final result = evaluator.evaluate('sin', {'s': 2.0, 'i': 3.0, 'n': 4.0});
      expect(result.asNumeric(), equals(24.0));
    });

    test('variable named "sink" is not misinterpreted', () {
      // "sink" should remain as s*i*n*k, not a function
      final result =
          evaluator.evaluate('sink', {'s': 1.0, 'i': 2.0, 'n': 3.0, 'k': 4.0});
      expect(result.asNumeric(), equals(24.0));
    });
  });

  group('Implicit Multiplication in Exponents', () {
    test(r'e^{ix} with implicit multiplication', () {
      final result = evaluator.evaluate(r'e^{ix}', {'i': 2.0, 'x': 3.0});
      // e^(2*3) = e^6 ≈ 403.43
      expect(result.asNumeric(), closeTo(403.4287934927351, 1e-6));
    });

    test(r'2^{ab} with implicit multiplication', () {
      final result = evaluator.evaluate(r'2^{ab}', {'a': 2.0, 'b': 3.0});
      expect(result.asNumeric(), equals(64.0)); // 2^6 = 64
    });

    test(r'x^{yz} with implicit multiplication', () {
      final result =
          evaluator.evaluate(r'x^{yz}', {'x': 2.0, 'y': 1.0, 'z': 4.0});
      expect(result.asNumeric(), equals(16.0)); // 2^4 = 16
    });
  });

  group('Combined Features', () {
    test(r'\frac12 * sin(x)', () {
      final result = evaluator.evaluate(r'\frac12 * sin(0)');
      expect(result.asNumeric(), equals(0.0));
    });

    test(r'sin(x) + \frac12', () {
      final result = evaluator.evaluate(r'sin(0) + \frac12');
      expect(result.asNumeric(), equals(0.5));
    });

    test(r'2^{ab} + \frac12', () {
      final result =
          evaluator.evaluate(r'2^{ab} + \frac12', {'a': 1.0, 'b': 2.0});
      expect(result.asNumeric(), equals(4.5)); // 2^2 + 0.5 = 4.5
    });
  });
}
