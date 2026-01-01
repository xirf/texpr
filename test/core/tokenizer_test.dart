import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('Tokenizer', () {
    group('numbers', () {
      test('tokenizes integer', () {
        final tokens = Tokenizer('42').tokenize();
        expect(tokens.length, 2); // number + eof
        expect(tokens[0].type, TokenType.number);
        expect(tokens[0].value, '42');
      });

      test('tokenizes decimal', () {
        final tokens = Tokenizer('3.14').tokenize();
        expect(tokens[0].type, TokenType.number);
        expect(tokens[0].value, '3.14');
      });

      test('tokenizes multiple numbers', () {
        final tokens = Tokenizer('12 34').tokenize();
        expect(tokens[0].value, '12');
        expect(tokens[1].value, '34');
      });
    });

    group('operators', () {
      test('tokenizes basic operators', () {
        final tokens = Tokenizer('+ - * /').tokenize();
        expect(tokens[0].type, TokenType.plus);
        expect(tokens[1].type, TokenType.minus);
        expect(tokens[2].type, TokenType.multiply);
        expect(tokens[3].type, TokenType.divide);
      });

      test('tokenizes power operator', () {
        final tokens = Tokenizer('^').tokenize();
        expect(tokens[0].type, TokenType.power);
      });

      test('tokenizes LaTeX times', () {
        final tokens = Tokenizer(r'\times').tokenize();
        expect(tokens[0].type, TokenType.multiply);
      });

      test('tokenizes LaTeX cdot', () {
        final tokens = Tokenizer(r'\cdot').tokenize();
        expect(tokens[0].type, TokenType.multiply);
      });

      test('tokenizes LaTeX div', () {
        final tokens = Tokenizer(r'\div').tokenize();
        expect(tokens[0].type, TokenType.divide);
      });
    });

    group('variables', () {
      test('tokenizes single letter variable', () {
        final tokens = Tokenizer('x').tokenize();
        expect(tokens[0].type, TokenType.variable);
        expect(tokens[0].value, 'x');
      });

      test('tokenizes uppercase variable', () {
        final tokens = Tokenizer('X').tokenize();
        expect(tokens[0].type, TokenType.variable);
        expect(tokens[0].value, 'X');
      });
    });

    group('parentheses and braces', () {
      test('tokenizes parentheses', () {
        final tokens = Tokenizer('()').tokenize();
        expect(tokens[0].type, TokenType.lparen);
        expect(tokens[0].value, '(');
        expect(tokens[1].type, TokenType.rparen);
        expect(tokens[1].value, ')');
      });

      test('tokenizes braces', () {
        final tokens = Tokenizer('{}').tokenize();
        expect(tokens[0].type, TokenType.lparen);
        expect(tokens[0].value, '{');
        expect(tokens[1].type, TokenType.rparen);
        expect(tokens[1].value, '}');
      });
    });

    group('whitespace', () {
      test('skips whitespace', () {
        final tokens = Tokenizer('  2  +  3  ').tokenize();
        expect(tokens.length, 4); // 2, +, 3, eof
      });
    });

    group('errors', () {
      test('throws on unknown LaTex command', () {
        expect(
          () => Tokenizer(r'\unknown').tokenize(),
          throwsA(isA<TokenizerException>()),
        );
      });

      test('throws on unexpected character', () {
        expect(
          () => Tokenizer('@').tokenize(),
          throwsA(isA<TokenizerException>()),
        );
      });
    });

    group('complex expressions', () {
      test('tokenizes full expression', () {
        final tokens = Tokenizer(r'2 + x \times 3').tokenize();
        expect(tokens.length, 6); // 2, +, x, \times, 3, eof
        expect(tokens[0].type, TokenType.number);
        expect(tokens[1].type, TokenType.plus);
        expect(tokens[2].type, TokenType.variable);
        expect(tokens[3].type, TokenType.multiply);
        expect(tokens[4].type, TokenType.number);
      });
    });
  });
}
