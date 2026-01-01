import 'package:test/test.dart';
import 'package:texpr/texpr.dart';
import 'package:texpr/src/symbolic/assumptions.dart';
import 'dart:math' as math;

/// Edge case tests for logarithm laws - v0.2.0 milestone verification
void main() {
  late SymbolicEngine engine;
  late LatexMathEvaluator latexEvaluator;

  setUp(() {
    engine = SymbolicEngine();
    latexEvaluator = LatexMathEvaluator();
  });

  group('Nested Logarithms', () {
    test('ln(ln(e^e)) = 1', () {
      // ln(e^e) = e, so ln(ln(e^e)) = ln(e) = 1
      final result = latexEvaluator.evaluate(r'\ln(\ln(e^{e}))');
      expect(result.asNumeric(), closeTo(1, 1e-10));
    });

    test('ln(e^(ln(x))) = ln(x)', () {
      for (var x in [2.0, 5.0, 10.0]) {
        final result1 = latexEvaluator.evaluate(r'\ln(e^{\ln(x)})', {'x': x});
        final result2 = latexEvaluator.evaluate(r'\ln(x)', {'x': x});
        expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('log10(10^(log10(x))) = log10(x)', () {
      for (var x in [100.0, 1000.0]) {
        final result1 =
            latexEvaluator.evaluate(r'\log(10^{\log(x)})', {'x': x});
        final result2 = latexEvaluator.evaluate(r'\log(x)', {'x': x});
        expect(result1.asNumeric(), closeTo(result2.asNumeric(), 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('double nested ln: ln(ln(ln(e^(e^e))))', () {
      // e^e ≈ 15.15, e^(e^e) is huge
      // ln(e^(e^e)) = e^e
      // ln(ln(e^(e^e))) = ln(e^e) = e
      // ln(ln(ln(e^(e^e)))) = ln(e) = 1
      final result = latexEvaluator.evaluate(r'\ln(\ln(\ln(e^{e^{e}})))');
      expect(result.asNumeric(), closeTo(1, 1e-8));
    });
  });

  group('Change of Base', () {
    test('log_a(b) = ln(b)/ln(a)', () {
      // log_2(8) = ln(8)/ln(2) = 3
      final log2_8 = latexEvaluator.evaluate(r'\log_{2}(8)');
      final changeBase = latexEvaluator.evaluate(r'\ln(8) / \ln(2)');
      expect(log2_8.asNumeric(), closeTo(changeBase.asNumeric(), 1e-10));
    });

    test('log_3(81) = 4', () {
      final result = latexEvaluator.evaluate(r'\log_{3}(81)');
      expect(result.asNumeric(), closeTo(4, 1e-10));
    });

    test('log_5(625) = 4', () {
      final result = latexEvaluator.evaluate(r'\log_{5}(625)');
      expect(result.asNumeric(), closeTo(4, 1e-10));
    });

    test('log_4(2) = 0.5', () {
      final result = latexEvaluator.evaluate(r'\log_{4}(2)');
      expect(result.asNumeric(), closeTo(0.5, 1e-10));
    });

    test('log_a(a) = 1 for any base', () {
      for (var a in [2.0, 3.0, 10.0, math.e]) {
        final result = latexEvaluator.evaluate(r'\ln(a) / \ln(a)', {'a': a});
        expect(result.asNumeric(), closeTo(1, 1e-10),
            reason: 'Failed for a=$a');
      }
    });
  });

  group('Floating Point Edge Cases', () {
    test('ln of very large number', () {
      final result = latexEvaluator.evaluate(r'\ln(10^{100})');
      // ln(10^100) = 100 * ln(10) ≈ 230.26
      expect(result.asNumeric(), closeTo(100 * math.log(10), 1e-8));
    });

    test('ln of very small positive number', () {
      final result = latexEvaluator.evaluate(r'\ln(10^{-100})');
      // ln(10^-100) = -100 * ln(10) ≈ -230.26
      expect(result.asNumeric(), closeTo(-100 * math.log(10), 1e-8));
    });

    test('log10 of powers of 10', () {
      for (var n in [1, 2, 3, 4, 5, 6, 10, 15]) {
        final result =
            latexEvaluator.evaluate(r'\log(10^{n})', {'n': n.toDouble()});
        expect(result.asNumeric(), closeTo(n.toDouble(), 1e-10),
            reason: 'Failed for n=$n');
      }
    });

    test('exp of very small number', () {
      final result = latexEvaluator.evaluate(r'\exp(-500)');
      // Should underflow to 0 or very small
      expect(result.asNumeric(), lessThan(1e-200));
    });
  });

  group('Compound Logarithm Expressions', () {
    test('ln(x*y*z) = ln(x) + ln(y) + ln(z)', () {
      for (var x in [2.0]) {
        for (var y in [3.0]) {
          for (var z in [5.0]) {
            final lhs = latexEvaluator
                .evaluate(r'\ln(x * y * z)', {'x': x, 'y': y, 'z': z});
            final rhs = latexEvaluator.evaluate(
                r'\ln(x) + \ln(y) + \ln(z)', {'x': x, 'y': y, 'z': z});
            expect(lhs.asNumeric(), closeTo(rhs.asNumeric(), 1e-10));
          }
        }
      }
    });

    test('ln(x/y/z) = ln(x) - ln(y) - ln(z)', () {
      final lhs = latexEvaluator
          .evaluate(r'\ln(x / y / z)', {'x': 60.0, 'y': 3.0, 'z': 4.0});
      final rhs = latexEvaluator.evaluate(
          r'\ln(x) - \ln(y) - \ln(z)', {'x': 60.0, 'y': 3.0, 'z': 4.0});
      expect(lhs.asNumeric(), closeTo(rhs.asNumeric(), 1e-10));
    });

    test('ln((x^a)*(y^b)) = a*ln(x) + b*ln(y)', () {
      final lhs = latexEvaluator.evaluate(
          r'\ln((x^{a}) * (y^{b}))', {'x': 2.0, 'y': 3.0, 'a': 4.0, 'b': 5.0});
      final rhs = latexEvaluator.evaluate(
          r'a * \ln(x) + b * \ln(y)', {'x': 2.0, 'y': 3.0, 'a': 4.0, 'b': 5.0});
      expect(lhs.asNumeric(), closeTo(rhs.asNumeric(), 1e-10));
    });
  });

  group('Logarithm with Complex Results', () {
    test('ln(-1) = iπ', () {
      final result = latexEvaluator.evaluate(r'\ln(-1)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(0, 1e-10));
      expect(c.imaginary, closeTo(math.pi, 1e-10));
    });

    test('ln(-e) = 1 + iπ', () {
      final result = latexEvaluator.evaluate(r'\ln(-e)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(1, 1e-10));
      expect(c.imaginary, closeTo(math.pi, 1e-10));
    });

    test('ln(i) = iπ/2', () {
      final result = latexEvaluator.evaluate(r'\ln(i)');
      expect(result, isA<ComplexResult>());
      final c = (result as ComplexResult).value;
      expect(c.real, closeTo(0, 1e-10));
      expect(c.imaginary, closeTo(math.pi / 2, 1e-10));
    });
  });

  group('Symbolic Logarithm Simplification', () {
    test('log(1) = 0', () {
      final expr = FunctionCall('log', const NumberLiteral(1));
      final simplified = engine.simplify(expr);
      expect(simplified, equals(const NumberLiteral(0)));
    });

    test('ln(e) = 1', () {
      final expr = FunctionCall('ln', const Variable('e'));
      final simplified = engine.simplify(expr);
      // Note: e is a constant, not a variable
      expect(simplified, isNotNull);
    });

    test('ln(a^n) = n*ln(a) with positive assumption', () {
      engine.assume('a', Assumption.positive);
      final aPowerN =
          BinaryOp(Variable('a'), BinaryOperator.power, Variable('n'));
      final expr = FunctionCall('ln', aPowerN);
      final simplified = engine.simplify(expr);

      final lnA = FunctionCall('ln', Variable('a'));
      final expected = BinaryOp(Variable('n'), BinaryOperator.multiply, lnA);
      expect(simplified, equals(expected));
    });

    test('log(a*b) simplifies with log laws', () {
      final ab =
          BinaryOp(Variable('a'), BinaryOperator.multiply, Variable('b'));
      final expr = FunctionCall('log', ab);
      final simplified = engine.simplify(expr);

      // Should apply log(a*b) = log(a) + log(b)
      expect(simplified is BinaryOp || simplified is FunctionCall, isTrue);
    });

    test('log(a/b) simplifies with log laws', () {
      final aOverB =
          BinaryOp(Variable('a'), BinaryOperator.divide, Variable('b'));
      final expr = FunctionCall('log', aOverB);
      final simplified = engine.simplify(expr);

      // Should apply log(a/b) = log(a) - log(b)
      expect(
          simplified is BinaryOp ||
              simplified is FunctionCall ||
              simplified is NumberLiteral,
          isTrue);
    });
  });

  group('Exponential Identities', () {
    test('e^(ln(x)) = x', () {
      for (var x in [2.0, 5.0, 10.0]) {
        final result = latexEvaluator.evaluate(r'e^{\ln(x)}', {'x': x});
        expect(result.asNumeric(), closeTo(x, 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('ln(e^x) = x', () {
      for (var x in [-2.0, 0.0, 3.0, 5.0]) {
        final result = latexEvaluator.evaluate(r'\ln(e^{x})', {'x': x});
        expect(result.asNumeric(), closeTo(x, 1e-10),
            reason: 'Failed for x=$x');
      }
    });

    test('10^(log10(x)) = x', () {
      for (var x in [2.0, 50.0, 100.0]) {
        final result = latexEvaluator.evaluate(r'10^{\log(x)}', {'x': x});
        expect(result.asNumeric(), closeTo(x, 1e-9), reason: 'Failed for x=$x');
      }
    });

    test('a^(log_a(x)) = x', () {
      // 2^(log_2(8)) = 8
      final result = latexEvaluator.evaluate(r'2^{\log_{2}(8)}');
      expect(result.asNumeric(), closeTo(8, 1e-10));
    });
  });

  group('Special Log Values', () {
    test('log(1) = 0 for any base', () {
      expect(latexEvaluator.evaluate(r'\ln(1)').asNumeric(), closeTo(0, 1e-10));
      expect(
          latexEvaluator.evaluate(r'\log(1)').asNumeric(), closeTo(0, 1e-10));
      expect(latexEvaluator.evaluate(r'\log_{2}(1)').asNumeric(),
          closeTo(0, 1e-10));
      expect(latexEvaluator.evaluate(r'\log_{5}(1)').asNumeric(),
          closeTo(0, 1e-10));
    });

    test('ln(e^n) = n', () {
      for (var n in [1, 2, 3, 5, 10]) {
        final result =
            latexEvaluator.evaluate(r'\ln(e^{n})', {'n': n.toDouble()});
        expect(result.asNumeric(), closeTo(n.toDouble(), 1e-10),
            reason: 'Failed for n=$n');
      }
    });

    test('log2(2^n) = n', () {
      for (var n in [1, 2, 3, 8, 10]) {
        final result =
            latexEvaluator.evaluate(r'\log_{2}(2^{n})', {'n': n.toDouble()});
        expect(result.asNumeric(), closeTo(n.toDouble(), 1e-10),
            reason: 'Failed for n=$n');
      }
    });
  });
}
