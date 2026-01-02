import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('Deeply Nested Expressions', () {
    test('nested parentheses (10 levels)', () {
      final result = evaluator.evaluate('((((((((((1))))))))))');
      expect(result.asNumeric(), equals(1));
    });

    test('nested parentheses with operations (15 levels)', () {
      final result = evaluator.evaluate('(((((((((((((((1+1)))))))))))))))');
      expect(result.asNumeric(), equals(2));
    });

    test('nested brackets (10 levels)', () {
      final result = evaluator.evaluate(r'{{{{{{{{{{5}}}}}}}}}}');
      expect(result.asNumeric(), equals(5));
    });

    test('nested powers', () {
      final result = evaluator.evaluate(r'2^{2^{2^{2}}}');
      expect(result.asNumeric(), equals(65536));
    });

    test('nested square roots', () {
      final result = evaluator.evaluate(r'\sqrt{\sqrt{\sqrt{256}}}');
      expect(result.asNumeric(), equals(2));
    });

    test('deeply nested functions', () {
      final result = evaluator.evaluate(r'\sin(\cos(\tan(0)))');
      expect(result.asNumeric(), closeTo(0.8414709848, 1e-9));
    });

    test('nested absolute values', () {
      final result = evaluator.evaluate(r'|||-5|||');
      expect(result.asNumeric(), equals(5));
    });

    test('nested summations', () {
      final result =
          evaluator.evaluate(r'\sum_{i=1}^{2} \sum_{j=1}^{2} (i * j)');
      expect(result.asNumeric(), equals(9)); // (1*1 + 1*2) + (2*1 + 2*2) = 9
    });
  });

  group('Long Expressions', () {
    test('long addition chain (50 terms)', () {
      final expr = List.generate(50, (i) => '1').join('+');
      final result = evaluator.evaluate(expr);
      expect(result.asNumeric(), equals(50));
    });

    test('long multiplication chain (10 terms)', () {
      final expr = List.generate(10, (i) => '2').join('*');
      final result = evaluator.evaluate(expr);
      expect(result.asNumeric(), equals(1024)); // 2^10
    });

    test('alternating operations (30 terms)', () {
      final expr = List.generate(15, (i) => '10 - 5').join(' + ');
      final result = evaluator.evaluate(expr);
      expect(result.asNumeric(), equals(75)); // 15 * 5
    });

    test('complex polynomial (20 terms)', () {
      final terms = [for (var i = 0; i < 20; i++) 'x^{$i}'];
      final expr = terms.join(' + ');
      final result = evaluator.evaluate(expr, {'x': 1});
      expect(result.asNumeric(), equals(20));
    });
  });

  group('All Operator Precedence Combinations', () {
    test('addition and multiplication', () {
      final result = evaluator.evaluate('2 + 3 * 4');
      expect(result.asNumeric(), equals(14));
    });

    test('subtraction and division', () {
      final result = evaluator.evaluate('10 - 8 / 2');
      expect(result.asNumeric(), equals(6));
    });

    test('power and multiplication', () {
      final result = evaluator.evaluate('2 * 3^{2}');
      expect(result.asNumeric(), equals(18));
    });

    test('power and addition', () {
      final result = evaluator.evaluate('2^{3} + 1');
      expect(result.asNumeric(), equals(9));
    });

    test('all four operations', () {
      final result = evaluator.evaluate('10 + 5 * 2 - 8 / 4');
      expect(result.asNumeric(), equals(18));
    });

    test('powers, multiplication, and addition', () {
      final result = evaluator.evaluate('2^{3} * 4 + 5');
      expect(result.asNumeric(), equals(37));
    });

    test('complex precedence chain', () {
      final result = evaluator.evaluate('1 + 2 * 3^{2} - 4 / 2');
      expect(result.asNumeric(), equals(17));
    });

    test('parentheses override precedence', () {
      final result = evaluator.evaluate('(2 + 3) * 4');
      expect(result.asNumeric(), equals(20));
    });

    test('nested precedence overrides', () {
      final result = evaluator.evaluate('((2 + 3) * (4 - 1))^{2}');
      expect(result.asNumeric(), equals(225));
    });
  });

  group('Complex Delimiter Nesting', () {
    test('mixed parentheses and braces', () {
      final result = evaluator.evaluate(r'(2 + {3 * 4})');
      expect(result.asNumeric(), equals(14));
    });

    test('fraction with nested operations', () {
      final result = evaluator.evaluate(r'\frac{(2+3)*(4+5)}{(1+2)}');
      expect(result.asNumeric(), equals(15));
    });

    test('nested absolute values with operations', () {
      final result = evaluator.evaluate(r'|(2 * |-3| + 4)|');
      expect(result.asNumeric(), equals(10));
    });

    test('matrix with nested expressions', () {
      final result = evaluator
          .evaluate(r'\begin{bmatrix} 2+3 & 4*5 \\ 6/2 & 7-1 \end{bmatrix}');
      expect(result.isMatrix, isTrue);
      final mat = result.asMatrix();
      expect(mat[0][0], equals(5));
      expect(mat[0][1], equals(20));
      expect(mat[1][0], equals(3));
      expect(mat[1][1], equals(6));
    });
  });

  group('Edge Case Delimiters', () {
    test('empty parentheses not allowed', () {
      expect(
        () => evaluator.evaluate('()'),
        throwsA(isA<ParserException>()),
      );
    });

    test('unmatched opening parenthesis', () {
      expect(
        () => evaluator.evaluate('(1 + 2'),
        throwsA(isA<ParserException>()),
      );
    });

    test('unmatched closing parenthesis', () {
      expect(
        () => evaluator.evaluate('1 + 2)'),
        throwsA(isA<ParserException>()),
      );
    });

    test('nested mismatched delimiters', () {
      expect(
        () => evaluator.evaluate('(1 + {2 * 3)'),
        throwsA(isA<ParserException>()),
      );
    });
  });

  group('Special Characters and Edge Cases', () {
    test('expression with only whitespace fails', () {
      expect(
        () => evaluator.evaluate('   '),
        throwsA(isA<Exception>()),
      );
    });

    test('multiple operators in sequence fail', () {
      expect(
        () => evaluator.evaluate('1 ++ 2'),
        throwsA(isA<Exception>()),
      );
    });

    test('operator at start fails', () {
      expect(
        () => evaluator.evaluate('+ 5'),
        throwsA(isA<Exception>()),
      );
    });

    test('operator at end fails', () {
      expect(
        () => evaluator.evaluate('5 +'),
        throwsA(isA<ParserException>()),
      );
    });

    test('unicode Greek letters work', () {
      final result = evaluator.evaluate(r'\pi');
      expect(result.asNumeric(), closeTo(3.14159265359, 1e-10));
    });
  });

  group('Malformed Expressions', () {
    test('missing operand after operator', () {
      expect(
        () => evaluator.evaluate('2 * '),
        throwsA(isA<ParserException>()),
      );
    });

    test('unclosed function call', () {
      expect(
        () => evaluator.evaluate(r'\sin(1'),
        throwsA(isA<ParserException>()),
      );
    });

    test('missing function argument', () {
      expect(
        () => evaluator.evaluate(r'\sin()'),
        throwsA(isA<Exception>()),
      );
    });

    test('incomplete fraction', () {
      expect(
        () => evaluator.evaluate(r'\frac{1}'),
        throwsA(isA<ParserException>()),
      );
    });

    test('incomplete power', () {
      expect(
        () => evaluator.evaluate('2^'),
        throwsA(isA<ParserException>()),
      );
    });
  });
}
