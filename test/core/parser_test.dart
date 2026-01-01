import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Parser', () {
    Expression parse(String input) {
      final tokens = Tokenizer(input).tokenize();
      return Parser(tokens).parse();
    }

    group('literals', () {
      test('parses number', () {
        final result = parse('42');
        expect(result, isA<NumberLiteral>());
        expect((result as NumberLiteral).value, 42.0);
      });

      test('parses variable', () {
        final result = parse('x');
        expect(result, isA<Variable>());
        expect((result as Variable).name, 'x');
      });
    });

    group('binary operations', () {
      test('parses addition', () {
        final result = parse('2 + 3');
        expect(result, isA<BinaryOp>());
        final op = result as BinaryOp;
        expect(op.operator, BinaryOperator.add);
        expect((op.left as NumberLiteral).value, 2.0);
        expect((op.right as NumberLiteral).value, 3.0);
      });

      test('parses subtraction', () {
        final result = parse('5 - 2');
        final op = result as BinaryOp;
        expect(op.operator, BinaryOperator.subtract);
      });

      test('parses multiplication', () {
        final result = parse(r'2 \times 3');
        final op = result as BinaryOp;
        expect(op.operator, BinaryOperator.multiply);
      });

      test('parses division', () {
        final result = parse(r'6 \div 2');
        final op = result as BinaryOp;
        expect(op.operator, BinaryOperator.divide);
      });

      test('parses power', () {
        final result = parse('x^2');
        final op = result as BinaryOp;
        expect(op.operator, BinaryOperator.power);
      });

      test('parses power with braces', () {
        final result = parse('x^{2}');
        final op = result as BinaryOp;
        expect(op.operator, BinaryOperator.power);
        expect((op.right as NumberLiteral).value, 2.0);
      });
    });

    group('precedence', () {
      test('multiply before add', () {
        // 2 + 3 * 4 should be 2 + (3 * 4)
        final result = parse(r'2 + 3 \times 4');
        expect(result, isA<BinaryOp>());
        final op = result as BinaryOp;
        expect(op.operator, BinaryOperator.add);
        expect((op.left as NumberLiteral).value, 2.0);
        expect((op.right as BinaryOp).operator, BinaryOperator.multiply);
      });

      test('power before multiply', () {
        // 2 * x^2 should be 2 * (x^2)
        final result = parse(r'2 \times x^{2}');
        final op = result as BinaryOp;
        expect(op.operator, BinaryOperator.multiply);
        expect((op.right as BinaryOp).operator, BinaryOperator.power);
      });
    });

    group('grouping', () {
      test('parses parentheses', () {
        // (2 + 3) * 4
        final result = parse(r'(2 + 3) \times 4');
        final op = result as BinaryOp;
        expect(op.operator, BinaryOperator.multiply);
        expect((op.left as BinaryOp).operator, BinaryOperator.add);
      });

      test('parses braces', () {
        final result = parse(r'{2 + 3} \times 4');
        final op = result as BinaryOp;
        expect(op.operator, BinaryOperator.multiply);
      });
    });

    group('unary', () {
      test('parses unary minus', () {
        final result = parse('-5');
        expect(result, isA<UnaryOp>());
        final op = result as UnaryOp;
        expect(op.operator, UnaryOperator.negate);
        expect((op.operand as NumberLiteral).value, 5.0);
      });

      test('parses double negative', () {
        final result = parse('--5');
        expect(result, isA<UnaryOp>());
        final op = result as UnaryOp;
        expect((op.operand as UnaryOp).operator, UnaryOperator.negate);
      });
    });

    group('errors', () {
      test('throws on unexpected token', () {
        expect(
          () => parse('2 +'),
          throwsA(isA<ParserException>()),
        );
      });
    });
  });
}
