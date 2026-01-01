import 'package:test/test.dart';
import 'package:texpr/src/visitors/evaluation_visitor.dart';
import 'package:texpr/src/ast/basic.dart';
import 'package:texpr/src/ast/operations.dart';

void main() {
  group('EvaluationVisitor', () {
    late EvaluationVisitor visitor;
    const emptyVars = <String, double>{};

    setUp(() {
      visitor = EvaluationVisitor();
    });

    test('evaluates number literal', () {
      final expr = NumberLiteral(42);
      final result = expr.accept(visitor, emptyVars);

      expect(result, equals(42.0));
    });

    test('evaluates variable with context', () {
      final expr = Variable('x');
      final result = expr.accept(visitor, {'x': 5.0});

      expect(result, equals(5.0));
    });

    test('evaluates pi constant', () {
      final expr = Variable('pi');
      final result = expr.accept(visitor, emptyVars);

      expect(result, closeTo(3.14159, 0.00001));
    });

    test('evaluates addition', () {
      final expr =
          BinaryOp(NumberLiteral(3), BinaryOperator.add, NumberLiteral(4));
      final result = expr.accept(visitor, emptyVars);

      expect(result, equals(7.0));
    });

    test('evaluates subtraction', () {
      final expr = BinaryOp(
          NumberLiteral(10), BinaryOperator.subtract, NumberLiteral(3));
      final result = expr.accept(visitor, emptyVars);

      expect(result, equals(7.0));
    });

    test('evaluates multiplication', () {
      final expr =
          BinaryOp(NumberLiteral(6), BinaryOperator.multiply, NumberLiteral(7));
      final result = expr.accept(visitor, emptyVars);

      expect(result, equals(42.0));
    });

    test('evaluates division', () {
      final expr =
          BinaryOp(NumberLiteral(15), BinaryOperator.divide, NumberLiteral(3));
      final result = expr.accept(visitor, emptyVars);

      expect(result, equals(5.0));
    });

    test('evaluates power', () {
      final expr =
          BinaryOp(NumberLiteral(2), BinaryOperator.power, NumberLiteral(3));
      final result = expr.accept(visitor, emptyVars);

      expect(result, equals(8.0));
    });

    test('evaluates unary minus', () {
      final expr = UnaryOp(UnaryOperator.negate, NumberLiteral(42));
      final result = expr.accept(visitor, emptyVars);

      expect(result, equals(-42.0));
    });

    test('evaluates complex expression: (x + 2) * 3', () {
      final expr = BinaryOp(
        BinaryOp(Variable('x'), BinaryOperator.add, NumberLiteral(2)),
        BinaryOperator.multiply,
        NumberLiteral(3),
      );
      final result = expr.accept(visitor, {'x': 5.0});

      expect(result, equals(21.0)); // (5 + 2) * 3 = 21
    });

    test('evaluates nested expression: 2^3 + 4', () {
      final expr = BinaryOp(
        BinaryOp(NumberLiteral(2), BinaryOperator.power, NumberLiteral(3)),
        BinaryOperator.add,
        NumberLiteral(4),
      );
      final result = expr.accept(visitor, emptyVars);

      expect(result, equals(12.0)); // 8 + 4 = 12
    });

    test('throws on division by zero', () {
      final expr =
          BinaryOp(NumberLiteral(5), BinaryOperator.divide, NumberLiteral(0));

      expect(
        () => expr.accept(visitor, null),
        throwsA(isA<Exception>()),
      );
    });

    test('throws on undefined variable', () {
      final expr = Variable('undefined');

      expect(
        () => expr.accept(visitor, null),
        throwsA(isA<Exception>()),
      );
    });
  });
}
