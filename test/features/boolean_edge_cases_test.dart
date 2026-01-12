import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Boolean Edge Cases', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    group('Type Safety', () {
      test('throws when using boolean in arithmetic addition', () {
        expect(
          () => evaluator.evaluate('1 + (2 > 1)'),
          throwsA(isA<EvaluatorException>()),
        );
      });

      test('throws when using boolean in arithmetic multiplication', () {
        expect(
          () => evaluator.evaluate('5 * (x > 0)', {'x': 1}),
          throwsA(isA<EvaluatorException>()),
        );
      });

      test('throws when using boolean in function argument expecting number',
          () {
        expect(
          () => evaluator.evaluate(r'\sin(x > 0)', {'x': 1}),
          throwsA(isA<EvaluatorException>()),
        );
      });
    });

    group('Precedence Mixing', () {
      test('arithmetic binds tighter than comparison', () {
        // 1 + 1 > 0  =>  2 > 0  => true
        expect(evaluator.evaluate('1 + 1 > 0').asBoolean(), isTrue);

        // 2 * 3 = 6  =>  true
        expect(evaluator.evaluate('2 * 3 = 6').asBoolean(), isTrue);
      });

      test('comparison binds tighter than logic', () {
        // (2 > 1) \land (3 < 4)
        expect(evaluator.evaluate(r'2 > 1 \land 3 < 4').asBoolean(), isTrue);
      });

      test('mixed arithmetic comparison and logic', () {
        // (1 + 1 = 2) \lor (3 * 3 = 10) => true \lor false => true
        expect(evaluator.evaluate(r'1 + 1 = 2 \lor 3 * 3 = 10').asBoolean(),
            isTrue);
      });
    });

    group('Unary Negation', () {
      test('negates boolean expression correctly', () {
        expect(evaluator.evaluate(r'\neg(1 > 0)').asBoolean(), isFalse);
      });

      test('treats number as boolean in negation (truthy/falsy)', () {
        // \neg 1 -> \neg true -> false
        // This confirms that numbers are truthy in boolean context, even if booleans aren't numeric in arithmetic context.
        expect(evaluator.evaluate(r'\neg 1').asBoolean(), isFalse);
      });
    });
  });
}
