import 'package:test/test.dart';
import 'package:texpr/src/ast.dart';
import 'package:texpr/src/symbolic/normalizer.dart';

void main() {
  group('ExpressionNormalizer', () {
    late ExpressionNormalizer normalizer;

    setUp(() {
      normalizer = ExpressionNormalizer();
    });

    test('reorders addition: x + 1 -> 1 + x', () {
      final expr = BinaryOp(
        Variable('x'),
        BinaryOperator.add,
        NumberLiteral(1),
      );
      final normalized = normalizer.normalize(expr);
      expect(normalized, isA<BinaryOp>());
      final op = normalized as BinaryOp;
      expect(op.left, isA<NumberLiteral>());
      expect((op.left as NumberLiteral).value, 1);
      expect(op.right, isA<Variable>());
      expect((op.right as Variable).name, 'x');
    });

    test('reorders multiplication: y * x -> x * y', () {
      final expr = BinaryOp(
        Variable('y'),
        BinaryOperator.multiply,
        Variable('x'),
      );
      final normalized = normalizer.normalize(expr);
      expect(normalized, isA<BinaryOp>());
      final op = normalized as BinaryOp;
      expect(op.left, isA<Variable>());
      expect((op.left as Variable).name, 'x');
      expect(op.right, isA<Variable>());
      expect((op.right as Variable).name, 'y');
    });

    test('flattens associativity: (a + b) + c -> a + (b + c)', () {
      final a = Variable('a');
      final b = Variable('b');
      final c = Variable('c');

      // (a + b) + c
      final expr = BinaryOp(
        BinaryOp(a, BinaryOperator.add, b),
        BinaryOperator.add,
        c,
      );

      final normalized = normalizer.normalize(expr);

      // Expect a + (b + c)
      expect(normalized, isA<BinaryOp>());
      final root = normalized as BinaryOp;
      expect(root.left, a);
      expect(root.right, isA<BinaryOp>());
      final right = root.right as BinaryOp;
      expect(right.left, b);
      expect(right.right, c);
    });

    test('normalizes complex expression: (y + x) + 2 -> 2 + (x + y)', () {
      // (y + x) + 2
      // 1. (y+x) -> (x+y) [canonical order in inner op]
      // 2. Canonical order treats sub-expr as "larger" than scalar 2?
      //    Usually scalars come first.

      // (y + x) is "Op", 2 is "Literal". 2 should be left.
      // So result should be 2 + (x + y).

      final expr = BinaryOp(
        BinaryOp(Variable('y'), BinaryOperator.add, Variable('x')),
        BinaryOperator.add,
        NumberLiteral(2),
      );

      final normalized = normalizer.normalize(expr);

      expect(normalized, isA<BinaryOp>());
      final root = normalized as BinaryOp;

      // Verify 2 is on left
      expect(root.left, isA<NumberLiteral>());
      expect((root.left as NumberLiteral).value, 2);

      // Verify right is (x + y)
      expect(root.right, isA<BinaryOp>());
      final right = root.right as BinaryOp;
      expect(right.left, isA<Variable>());
      expect((right.left as Variable).name, 'x');
      expect(right.right, isA<Variable>());
      expect((right.right as Variable).name, 'y');
    });
  });
}
