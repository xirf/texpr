import 'package:test/test.dart';
import 'package:texpr/src/ast.dart';
import 'package:texpr/src/exceptions.dart';
import 'package:texpr/src/symbolic/simplifier.dart';
import 'package:texpr/src/symbolic/rational_simplifier.dart';

void main() {
  group('Recursion Safety', () {
    test('Simplifier throws EvaluatorException on deep recursion', () {
      final simplifier = Simplifier();
      Expression expr = const NumberLiteral(1);

      // Create a deeply nested expression: 1 + (1 + (1 + ...))
      for (int i = 0; i < 1000; i++) {
        expr = BinaryOp(const NumberLiteral(1), BinaryOperator.add, expr);
      }

      expect(
        () => simplifier.simplify(expr),
        throwsA(isA<EvaluatorException>().having(
            (e) => e.message, 'message', contains('simplification depth'))),
      );
    });

    test('RationalSimplifier throws EvaluatorException on deep recursion', () {
      final simplifier = RationalSimplifier();
      Expression expr = const NumberLiteral(1);

      // Create a deeply nested expression: 1 + (1 + (1 + ...))
      for (int i = 0; i < 1000; i++) {
        expr = BinaryOp(const NumberLiteral(1), BinaryOperator.add, expr);
      }

      expect(
        () => simplifier.simplify(expr),
        throwsA(isA<EvaluatorException>().having((e) => e.message, 'message',
            contains('rational simplification depth'))),
      );
    });

    test('Simplifier allows reasonable depth', () {
      final simplifier = Simplifier();
      Expression expr = const NumberLiteral(1);

      // Depth of 50 should be fine
      for (int i = 0; i < 50; i++) {
        expr = BinaryOp(const NumberLiteral(1), BinaryOperator.add, expr);
      }

      // Should not throw
      final result = simplifier.simplify(expr);
      expect(result, isA<Expression>());
    }, timeout: const Timeout(Duration(seconds: 1)));
  });
}
