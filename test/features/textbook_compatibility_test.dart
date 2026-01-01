import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Tests for textbook LaTeX compatibility features.
/// These tests verify that copy-paste from textbooks works correctly.
void main() {
  group('Textbook LaTeX Compatibility', () {
    late LatexMathEvaluator evaluator;

    setUp(() {
      evaluator = LatexMathEvaluator();
    });

    group('Function Power Notation', () {
      test(r'\sin^2{\theta} parses correctly', () {
        final result = evaluator.parse(r'\sin^2{\theta}');
        expect(result, isA<BinaryOp>());
        expect(result.toLatex(), contains('sin'));
      });

      test(r'\sin^2{\theta} + \cos^2{\theta} parses correctly', () {
        final result = evaluator.parse(r'\sin^2{\theta} + \cos^2{\theta}');
        expect(result, isA<BinaryOp>());
      });

      test(r'\tan^3{x} parses correctly', () {
        final result = evaluator.parse(r'\tan^3{x}');
        expect(result, isA<BinaryOp>());
      });

      test(r'\sin^{-1}{x} parses correctly (inverse notation)', () {
        final result = evaluator.parse(r'\sin^{-1}{x}');
        expect(result, isA<BinaryOp>());
      });

      test('evaluates sin^2(pi/4) = 0.5', () {
        final result = evaluator.evaluate(r'\sin^2{\frac{\pi}{4}}');
        expect(result.asNumeric(), closeTo(0.5, 1e-10));
      });
    });

    group('Multi-argument Function Notation', () {
      test('f(x,y) parses as function call', () {
        final result = evaluator.parse(r'f(x,y)');
        expect(result, isA<FunctionCall>());
      });

      test('g(a,b,c) parses as function call with 3 args', () {
        final result = evaluator.parse(r'g(a,b,c)');
        expect(result, isA<FunctionCall>());
      });

      test(r'\iint_{D} f(x,y) dx dy parses correctly', () {
        final result = evaluator.parse(r'\iint_{D} f(x,y) dx dy');
        expect(result, isA<MultiIntegralExpr>());
      });

      test(r'\iiint_{V} h(x,y,z) dx dy dz parses correctly', () {
        final result = evaluator.parse(r'\iiint_{V} h(x,y,z) dx dy dz');
        expect(result, isA<MultiIntegralExpr>());
      });
    });

    group('Implicit Multiplication Preserved', () {
      test('x(x+1) is implicit multiplication, not function call', () {
        // x(x+1) = x * (x+1) = 2 * 3 = 6 when x=2
        final result = evaluator.evaluate('x(x+1)', {'x': 2});
        expect(result.asNumeric(), equals(6.0));
      });

      test('2(3+1) is implicit multiplication', () {
        final result = evaluator.evaluate('2(3+1)');
        expect(result.asNumeric(), equals(8.0));
      });

      test('a(b) is implicit multiplication', () {
        final result = evaluator.evaluate('a(b)', {'a': 3, 'b': 4});
        expect(result.asNumeric(), equals(12.0));
      });
    });

    group('Real Textbook Examples', () {
      test('Pythagorean identity: sin^2 + cos^2 = 1', () {
        final result = evaluator
            .evaluate(r'\sin^2{\frac{\pi}{3}} + \cos^2{\frac{\pi}{3}}');
        expect(result.asNumeric(), closeTo(1.0, 1e-10));
      });

      test('Double integral with function notation', () {
        final result = evaluator.parse(r'\iint_{R} f(x,y) dx dy');
        expect(result, isA<MultiIntegralExpr>());
      });

      test('Mixed expression with function powers', () {
        final result = evaluator.parse(r'\int \sin^2{x} dx');
        expect(result, isA<IntegralExpr>());
      });
    });
  });
}
