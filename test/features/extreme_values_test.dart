import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  late LatexMathEvaluator evaluator;

  setUp(() {
    evaluator = LatexMathEvaluator();
  });

  group('Very Large Numbers', () {
    test('handles 1e100', () {
      final result = evaluator.evaluate('10^{100}');
      expect(result.asNumeric(), equals(1e100));
    });

    test('handles near MAX_DOUBLE (1e308)', () {
      final result = evaluator.evaluate('10^{308}');
      expect(result.asNumeric(), equals(1e308));
    });

    test('addition with very large numbers', () {
      final result = evaluator.evaluate('10^{100} + 2 * 10^{100}');
      expect(result.asNumeric(), closeTo(3e100, 1e90));
    });

    test('multiplication with very large numbers', () {
      final result = evaluator.evaluate('10^{50} * 10^{50}');
      expect(result.asNumeric(), closeTo(1e100, 1e90));
    });

    test('large number subtraction', () {
      final result = evaluator.evaluate('10^{100} - 9 * 10^{99}');
      expect(result.asNumeric(), closeTo(1e99, 1e89));
    });

    test('powers of large numbers', () {
      final result = evaluator.evaluate('10^{100}');
      expect(result.asNumeric(), equals(1e100));
    });

    test('large number in expression', () {
      final result = evaluator.evaluate('(10^{50})^2');
      expect(result.asNumeric(), closeTo(1e100, 1e90));
    });
  });

  group('Very Small Numbers', () {
    test('handles 1e-100', () {
      final result = evaluator.evaluate('10^{-100}');
      expect(result.asNumeric(), equals(1e-100));
    });

    test('handles near MIN_DOUBLE (1e-308)', () {
      final result = evaluator.evaluate('10^{-308}');
      expect(result.asNumeric(), equals(1e-308));
    });

    test('addition with very small numbers', () {
      final result = evaluator.evaluate('10^{-100} + 2 * 10^{-100}');
      expect(result.asNumeric(), closeTo(3e-100, 1e-110));
    });

    test('multiplication of small numbers', () {
      final result = evaluator.evaluate('10^{-50} * 10^{-50}');
      expect(result.asNumeric(), equals(1e-100));
    });

    test('division creating small number', () {
      final result = evaluator.evaluate('1 / 10^{100}');
      expect(result.asNumeric(), equals(1e-100));
    });

    test('small number power', () {
      final result = evaluator.evaluate('10^{-100}');
      expect(result.asNumeric(), equals(1e-100));
    });
  });

  group('Numbers Near Zero', () {
    test('handles 1e-15', () {
      final result = evaluator.evaluate('10^{-15}');
      expect(result.asNumeric(), equals(1e-15));
    });

    test('handles 1e-20', () {
      final result = evaluator.evaluate('10^{-20}');
      expect(result.asNumeric(), equals(1e-20));
    });

    test('near-zero addition', () {
      final result = evaluator.evaluate('10^{-15} + 10^{-15}');
      expect(result.asNumeric(), closeTo(2e-15, 1e-25));
    });

    test('near-zero subtraction to exact zero', () {
      final result = evaluator.evaluate('10^{-15} - 10^{-15}');
      expect(result.asNumeric(), closeTo(0, 1e-25));
    });

    test('multiplication by near-zero', () {
      final result = evaluator.evaluate('1000 * 10^{-15}');
      expect(result.asNumeric(), closeTo(1e-12, 1e-22));
    });
  });

  group('Infinity Handling', () {
    test('evaluates infinity constant', () {
      final result = evaluator.evaluate(r'\infty');
      expect(result.asNumeric().isInfinite, isTrue);
      expect(result.asNumeric() > 0, isTrue);
    });

    test('division by zero throws exception', () {
      expect(
        () => evaluator.evaluate('1 / 0'),
        throwsA(isA<EvaluatorException>()),
      );
    });

    test('negative division by zero throws exception', () {
      expect(
        () => evaluator.evaluate('-1 / 0'),
        throwsA(isA<EvaluatorException>()),
      );
    });

    test('infinity in arithmetic', () {
      final result = evaluator.evaluate(r'\infty + 1');
      expect(result.asNumeric().isInfinite, isTrue);
    });

    test('infinity multiplication', () {
      final result = evaluator.evaluate(r'2 * \infty');
      expect(result.asNumeric().isInfinite, isTrue);
    });

    test('infinity divided by number', () {
      final result = evaluator.evaluate(r'\infty / 2');
      expect(result.asNumeric().isInfinite, isTrue);
    });

    test('log of infinity', () {
      final result = evaluator.evaluate(r'\ln(\infty)');
      expect(result.asNumeric().isInfinite, isTrue);
    });
  });

  group('NaN Handling', () {
    test('0/0 throws exception', () {
      expect(
        () => evaluator.evaluate('0 / 0'),
        throwsA(isA<EvaluatorException>()),
      );
    });

    test('infinity - infinity produces NaN', () {
      final result = evaluator.evaluate(r'\infty - \infty');
      expect(result.asNumeric().isNaN, isTrue);
    });

    test('0 * infinity produces NaN', () {
      final result = evaluator.evaluate(r'0 * \infty');
      expect(result.asNumeric().isNaN, isTrue);
    });

    test('sqrt of negative returns complex', () {
      final result = evaluator.evaluate(r'\sqrt{-1}');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.imaginary, closeTo(1.0, 1e-10));
    });

    test('log of negative returns complex', () {
      final result = evaluator.evaluate(r'\ln(-1)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      // ln(-1) = i*pi
      expect(c.real, closeTo(0.0, 1e-10));
      expect(c.imaginary, closeTo(3.14159265, 1e-5));
    });
  });

  group('Overflow Scenarios', () {
    test('exp of very large number overflows to infinity', () {
      final result = evaluator.evaluate(r'\exp(1000)');
      expect(result.asNumeric().isInfinite, isTrue);
    });

    test('large power overflows', () {
      final result = evaluator.evaluate('10^{400}');
      expect(result.asNumeric().isInfinite, isTrue);
    });
  });

  group('Underflow Scenarios', () {
    test('exp of very negative number underflows to zero', () {
      final result = evaluator.evaluate(r'\exp(-1000)');
      expect(result.asNumeric(), equals(0));
    });

    test('very small power approaches zero', () {
      final result = evaluator.evaluate('(10^{-50})^{10}');
      expect(result.asNumeric(), equals(0));
    });

    test('division with extreme values approaches zero', () {
      final result = evaluator.evaluate('10^{-150} / 10^{150}');
      expect(result.asNumeric(), closeTo(0, 1e-299));
    });
  });

  group('Mixed Extreme Operations', () {
    test('large plus small preserves large', () {
      final result = evaluator.evaluate('10^{100} + 1');
      expect(result.asNumeric(), equals(1e100));
    });

    test('large minus small preserves large', () {
      final result = evaluator.evaluate('10^{100} - 1');
      expect(result.asNumeric(), equals(1e100));
    });

    test('multiplication of extreme opposites', () {
      final result = evaluator.evaluate('10^{200} * 10^{-200}');
      expect(result.asNumeric(), equals(1.0));
    });

    test('division normalizing extremes', () {
      final result = evaluator.evaluate('10^{150} / 10^{150}');
      expect(result.asNumeric(), equals(1.0));
    });

    test('alternating extreme operations', () {
      final result = evaluator.evaluate('(10^{50} * 10^{50}) / 10^{100}');
      expect(result.asNumeric(), closeTo(1.0, 1e-10));
    });
  });
}
