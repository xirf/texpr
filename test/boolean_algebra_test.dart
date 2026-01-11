import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Boolean Algebra', () {
    final evaluator = Texpr();

    group('Basic Operators', () {
      test('AND operator - \\land', () {
        // true AND true = true
        final result1 = evaluator.evaluate(r'(1 > 0) \land (2 > 1)');
        expect(result1.isBoolean, isTrue);
        expect(result1.asBoolean(), isTrue);

        // true AND false = false
        final result2 = evaluator.evaluate(r'(1 > 0) \land (0 > 1)');
        expect(result2.asBoolean(), isFalse);

        // false AND true = false
        final result3 = evaluator.evaluate(r'(0 > 1) \land (1 > 0)');
        expect(result3.asBoolean(), isFalse);

        // false AND false = false
        final result4 = evaluator.evaluate(r'(0 > 1) \land (0 > 2)');
        expect(result4.asBoolean(), isFalse);
      });

      test('AND operator - \\wedge alias', () {
        final result = evaluator.evaluate(r'(1 > 0) \wedge (2 > 1)');
        expect(result.asBoolean(), isTrue);
      });

      test('OR operator - \\lor', () {
        // true OR true = true
        expect(evaluator.evaluate(r'(1 > 0) \lor (2 > 1)').asBoolean(), isTrue);

        // true OR false = true
        expect(evaluator.evaluate(r'(1 > 0) \lor (0 > 1)').asBoolean(), isTrue);

        // false OR true = true
        expect(evaluator.evaluate(r'(0 > 1) \lor (1 > 0)').asBoolean(), isTrue);

        // false OR false = false
        expect(
            evaluator.evaluate(r'(0 > 1) \lor (0 > 2)').asBoolean(), isFalse);
      });

      test('OR operator - \\vee alias', () {
        expect(evaluator.evaluate(r'(0 > 1) \vee (1 > 0)').asBoolean(), isTrue);
      });

      test('NOT operator - \\neg', () {
        // NOT true = false
        expect(evaluator.evaluate(r'\neg(1 > 0)').asBoolean(), isFalse);

        // NOT false = true
        expect(evaluator.evaluate(r'\neg(0 > 1)').asBoolean(), isTrue);
      });

      test('NOT operator - \\lnot alias', () {
        expect(evaluator.evaluate(r'\lnot(1 > 0)').asBoolean(), isFalse);
      });

      test('XOR operator - \\oplus', () {
        // true XOR true = false
        expect(
            evaluator.evaluate(r'(1 > 0) \oplus (2 > 1)').asBoolean(), isFalse);

        // true XOR false = true
        expect(
            evaluator.evaluate(r'(1 > 0) \oplus (0 > 1)').asBoolean(), isTrue);

        // false XOR true = true
        expect(
            evaluator.evaluate(r'(0 > 1) \oplus (1 > 0)').asBoolean(), isTrue);

        // false XOR false = false
        expect(
            evaluator.evaluate(r'(0 > 1) \oplus (0 > 2)').asBoolean(), isFalse);
      });

      test('Implication operator - \\Rightarrow', () {
        // true => true = true
        expect(evaluator.evaluate(r'(1 > 0) \Rightarrow (2 > 1)').asBoolean(),
            isTrue);

        // true => false = false
        expect(evaluator.evaluate(r'(1 > 0) \Rightarrow (0 > 1)').asBoolean(),
            isFalse);

        // false => true = true
        expect(evaluator.evaluate(r'(0 > 1) \Rightarrow (1 > 0)').asBoolean(),
            isTrue);

        // false => false = true
        expect(evaluator.evaluate(r'(0 > 1) \Rightarrow (0 > 2)').asBoolean(),
            isTrue);
      });

      test('Implication operator - \\implies alias', () {
        expect(evaluator.evaluate(r'(0 > 1) \implies (1 > 0)').asBoolean(),
            isTrue);
      });

      test('Biconditional operator - \\Leftrightarrow', () {
        // true <=> true = true
        expect(
            evaluator.evaluate(r'(1 > 0) \Leftrightarrow (2 > 1)').asBoolean(),
            isTrue);

        // true <=> false = false
        expect(
            evaluator.evaluate(r'(1 > 0) \Leftrightarrow (0 > 1)').asBoolean(),
            isFalse);

        // false <=> true = false
        expect(
            evaluator.evaluate(r'(0 > 1) \Leftrightarrow (1 > 0)').asBoolean(),
            isFalse);

        // false <=> false = true
        expect(
            evaluator.evaluate(r'(0 > 1) \Leftrightarrow (0 > 2)').asBoolean(),
            isTrue);
      });

      test('Biconditional operator - \\iff alias', () {
        expect(evaluator.evaluate(r'(1 > 0) \iff (2 > 1)').asBoolean(), isTrue);
      });
    });

    group('Operator Precedence', () {
      test('NOT binds tighter than AND', () {
        // ¬false ∧ true = true ∧ true = true
        expect(evaluator.evaluate(r'\neg(0 > 1) \land (1 > 0)').asBoolean(),
            isTrue);
      });

      test('AND binds tighter than OR', () {
        // false ∨ (true ∧ true) = false ∨ true = true
        expect(
            evaluator
                .evaluate(r'(0 > 1) \lor (1 > 0) \land (2 > 1)')
                .asBoolean(),
            isTrue);

        // (true ∧ false) ∨ true = false ∨ true = true
        expect(
            evaluator
                .evaluate(r'(1 > 0) \land (0 > 1) \lor (2 > 1)')
                .asBoolean(),
            isTrue);
      });

      test('OR binds tighter than implication', () {
        // true ⇒ (false ∨ true) = true ⇒ true = true
        expect(
            evaluator
                .evaluate(r'(1 > 0) \Rightarrow (0 > 1) \lor (2 > 1)')
                .asBoolean(),
            isTrue);
      });
    });

    group('Complex Expressions', () {
      test('De Morgan law: ¬(A ∧ B) = ¬A ∨ ¬B', () {
        // Both should be false when A=true, B=true
        final left =
            evaluator.evaluate(r'\neg((1 > 0) \land (2 > 1))').asBoolean();
        final right =
            evaluator.evaluate(r'\neg(1 > 0) \lor \neg(2 > 1)').asBoolean();
        expect(left, right);
      });

      test('De Morgan law: ¬(A ∨ B) = ¬A ∧ ¬B', () {
        // Both should be true when A=false, B=false
        final left =
            evaluator.evaluate(r'\neg((0 > 1) \lor (0 > 2))').asBoolean();
        final right =
            evaluator.evaluate(r'\neg(0 > 1) \land \neg(0 > 2)').asBoolean();
        expect(left, right);
      });

      test('XOR as exclusive disjunction: A ⊕ B = (A ∨ B) ∧ ¬(A ∧ B)', () {
        final left = evaluator.evaluate(r'(1 > 0) \oplus (0 > 1)').asBoolean();
        final right = evaluator
            .evaluate(
                r'((1 > 0) \lor (0 > 1)) \land \neg((1 > 0) \land (0 > 1))')
            .asBoolean();
        expect(left, right);
      });

      test('Implication as disjunction: A ⇒ B = ¬A ∨ B', () {
        final left =
            evaluator.evaluate(r'(1 > 0) \Rightarrow (0 > 1)').asBoolean();
        final right =
            evaluator.evaluate(r'\neg(1 > 0) \lor (0 > 1)').asBoolean();
        expect(left, right);
      });

      test('Nested boolean with variables', () {
        // (x > 0) ∧ (x < 10) for x = 5 should be true
        expect(
          evaluator.evaluate(r'(x > 0) \land (x < 10)', {'x': 5.0}).asBoolean(),
          isTrue,
        );

        // (x > 0) ∧ (x < 10) for x = -1 should be false
        expect(
          evaluator
              .evaluate(r'(x > 0) \land (x < 10)', {'x': -1.0}).asBoolean(),
          isFalse,
        );
      });
    });

    group('AST Generation', () {
      test('BooleanBinaryExpr is created for AND', () {
        final expr = evaluator.parse(r'(1 > 0) \land (2 > 1)');
        expect(expr, isA<BooleanBinaryExpr>());
        expect((expr as BooleanBinaryExpr).operator, BooleanOperator.and);
      });

      test('BooleanUnaryExpr is created for NOT', () {
        final expr = evaluator.parse(r'\neg(1 > 0)');
        expect(expr, isA<BooleanUnaryExpr>());
      });
    });

    group('Result Type', () {
      test('Boolean expressions return BooleanResult', () {
        final result = evaluator.evaluate(r'(1 > 0) \land (2 > 1)');
        expect(result, isA<BooleanResult>());
        expect(result.isBoolean, isTrue);
      });

      test('NOT expression returns BooleanResult', () {
        final result = evaluator.evaluate(r'\neg(1 > 0)');
        expect(result, isA<BooleanResult>());
      });
    });
  });
}
