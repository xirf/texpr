import 'package:texpr/texpr.dart';
import 'package:test/test.dart';
import 'dart:math' as math;

void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('Logarithm Edge Cases', () {
    test('ln(1) = 0', () {
      final result = evaluator.evaluate(r'\ln(1)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('ln(e) = 1', () {
      final result = evaluator.evaluate(r'\ln(e)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('ln(0) returns negative infinity', () {
      final result = evaluator.evaluate(r'\ln(0)');
      // ln(0) = -infinity (complex log of 0 has real part = -infinity)
      expect(result.isComplex, isTrue);
      final c = (result as ComplexResult).value;
      expect(c.real.isInfinite && c.real < 0, isTrue);
    });

    test('ln(negative) returns complex', () {
      final result = evaluator.evaluate(r'\ln(-1)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      // ln(-1) = i*π
      expect(c.real, closeTo(0, 1e-10));
      expect(c.imaginary, closeTo(math.pi, 1e-10));
    });

    test('ln(very large) produces finite result', () {
      final result = evaluator.evaluate(r'\ln(10^{100})');
      expect(result.asNumeric(), closeTo(100 * math.log(10), 1e-8));
    });

    test('ln(very small positive) produces large negative', () {
      final result = evaluator.evaluate(r'\ln(10^{-100})');
      expect(result.asNumeric(), closeTo(-100 * math.log(10), 1e-8));
    });

    test('ln(e^10) = 10', () {
      final result = evaluator.evaluate(r'\ln(e^{10})');
      expect(result.asNumeric(), closeTo(10, 1e-10));
    });
  });

  group('Log Base 10', () {
    test('log(1) = 0', () {
      final result = evaluator.evaluate(r'\log(1)');
      expect(result.asNumeric(), closeTo(0, 1e-10));
    });

    test('log(10) = 1', () {
      final result = evaluator.evaluate(r'\log(10)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('log(100) = 2', () {
      final result = evaluator.evaluate(r'\log(100)');
      expect(result.asNumeric(), closeTo(2, 1e-10));
    });

    test('log(1000) = 3', () {
      final result = evaluator.evaluate(r'\log(1000)');
      expect(result.asNumeric(), closeTo(3, 1e-10));
    });

    test('log(0.1) = -1', () {
      final result = evaluator.evaluate(r'\log(0.1)');
      expect(result.asNumeric(), closeTo(-1, 1e-10));
    });

    test('log(0.01) = -2', () {
      final result = evaluator.evaluate(r'\log(0.01)');
      expect(result.asNumeric(), closeTo(-2, 1e-10));
    });
  });

  group('Different Log Bases', () {
    test('log base 2 of 8 = 3', () {
      final result = evaluator.evaluate(r'\log_{2}(8)');
      expect(result.asNumeric(), closeTo(3, 1e-10));
    });

    test('log base 2 of 1024 = 10', () {
      final result = evaluator.evaluate(r'\log_{2}(1024)');
      expect(result.asNumeric(), closeTo(10, 1e-10));
    });

    test('log base 2 of 0.5 = -1', () {
      final result = evaluator.evaluate(r'\log_{2}(0.5)');
      expect(result.asNumeric(), closeTo(-1, 1e-10));
    });

    test('log base 3 of 27 = 3', () {
      final result = evaluator.evaluate(r'\log_{3}(27)');
      expect(result.asNumeric(), closeTo(3, 1e-10));
    });

    test('log base 5 of 125 = 3', () {
      final result = evaluator.evaluate(r'\log_{5}(125)');
      expect(result.asNumeric(), closeTo(3, 1e-10));
    });
  });

  group('Exponential Function', () {
    test('exp(0) = 1', () {
      final result = evaluator.evaluate(r'\exp(0)');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('exp(1) = e', () {
      final result = evaluator.evaluate(r'\exp(1)');
      expect(result.asNumeric(), closeTo(math.e, 1e-10));
    });

    test('exp(-1) = 1/e', () {
      final result = evaluator.evaluate(r'\exp(-1)');
      expect(result.asNumeric(), closeTo(1 / math.e, 1e-10));
    });

    test('exp(ln(5)) = 5', () {
      final result = evaluator.evaluate(r'\exp(\ln(5))');
      expect(result.asNumeric(), closeTo(5, 1e-10));
    });

    test('exp(2) = e²', () {
      final result = evaluator.evaluate(r'\exp(2)');
      expect(result.asNumeric(), closeTo(math.e * math.e, 1e-10));
    });
  });

  group('Exponential Overflow', () {
    test('exp(1000) overflows to infinity', () {
      final result = evaluator.evaluate(r'\exp(1000)');
      expect(result.asNumeric().isInfinite, isTrue);
    });

    test('exp(710) overflows to infinity', () {
      final result = evaluator.evaluate(r'\exp(710)');
      expect(result.asNumeric().isInfinite, isTrue);
    });

    test('exp(500) is very large', () {
      final result = evaluator.evaluate(r'\exp(500)');
      expect(result.asNumeric() > 1e200, isTrue);
    });
  });

  group('Exponential Underflow', () {
    test('exp(-1000) underflows to zero', () {
      final result = evaluator.evaluate(r'\exp(-1000)');
      expect(result.asNumeric(), equals(0));
    });

    test('exp(-750) underflows to zero', () {
      final result = evaluator.evaluate(r'\exp(-750)');
      expect(result.asNumeric(), equals(0));
    });

    test('exp(-100) is very small', () {
      final result = evaluator.evaluate(r'\exp(-100)');
      expect(result.asNumeric() < 1e-40, isTrue);
      expect(result.asNumeric() > 0, isTrue);
    });
  });

  group('Log-Exp Identities', () {
    test('e^(ln(x)) = x for x=10', () {
      final result = evaluator.evaluate(r'e^{\ln(10)}');
      expect(result.asNumeric(), closeTo(10, 1e-10));
    });

    test('ln(e^x) = x for x=5', () {
      final result = evaluator.evaluate(r'\ln(e^{5})');
      expect(result.asNumeric(), closeTo(5, 1e-10));
    });

    test('log(10^x) = x for x=3', () {
      final result = evaluator.evaluate(r'\log(10^{3})');
      expect(result.asNumeric(), closeTo(3, 1e-10));
    });

    test('10^(log(x)) = x for x=50', () {
      final result = evaluator.evaluate(r'10^{\log(50)}');
      expect(result.asNumeric(), closeTo(50, 1e-9));
    });

    test('ln(x*y) = ln(x) + ln(y)', () {
      final result1 = evaluator.evaluate(r'\ln(6)');
      final result2 = evaluator.evaluate(r'\ln(2) + \ln(3)');
      expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-10));
    });

    test('ln(x/y) = ln(x) - ln(y)', () {
      final result1 = evaluator.evaluate(r'\ln(0.5)');
      final result2 = evaluator.evaluate(r'\ln(1) - \ln(2)');
      expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-10));
    });

    test('ln(x^n) = n*ln(x)', () {
      final result1 = evaluator.evaluate(r'\ln(8)');
      final result2 = evaluator.evaluate(r'3 * \ln(2)');
      expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-10));
    });
  });

  group('Power vs Exponential', () {
    test('2^10 vs exp(10*ln(2))', () {
      final result1 = evaluator.evaluate(r'2^{10}');
      final result2 = evaluator.evaluate(r'\exp(10 * \ln(2))');
      expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-9));
    });

    test('e^x same as exp(x) for x=5', () {
      final result1 = evaluator.evaluate(r'e^{5}');
      final result2 = evaluator.evaluate(r'\exp(5)');
      expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-10));
    });

    test('10^x converts correctly', () {
      final result1 = evaluator.evaluate(r'10^{2.5}');
      final result2 = evaluator.evaluate(r'\exp(2.5 * \ln(10))');
      expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-9));
    });
  });

  group('Special Values', () {
    test('ln(sqrt(e)) = 0.5', () {
      final result = evaluator.evaluate(r'\ln(\sqrt{e})');
      expect(result.asNumeric(), closeTo(0.5, 1e-10));
    });

    test('exp(0.5) = sqrt(e)', () {
      final result = evaluator.evaluate(r'\exp(0.5)');
      expect(result.asNumeric(), closeTo(math.sqrt(math.e), 1e-10));
    });

    test('log(sqrt(10)) = 0.5', () {
      final result = evaluator.evaluate(r'\log(\sqrt{10})');
      expect(result.asNumeric(), closeTo(0.5, 1e-10));
    });

    test('ln(1/e) = -1', () {
      final result = evaluator.evaluate(r'\ln(1/e)');
      expect(result.asNumeric(), closeTo(-1, 1e-10));
    });
  });
}
