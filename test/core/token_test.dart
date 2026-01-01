// ignore_for_file: unrelated_type_equality_checks

import 'package:test/test.dart';
import 'package:texpr/src/token.dart';

void main() {
  group('TokenType', () {
    test('all token types are defined', () {
      expect(TokenType.values.length, greaterThan(0));

      // Verify some key types exist
      expect(TokenType.values.contains(TokenType.number), isTrue);
      expect(TokenType.values.contains(TokenType.variable), isTrue);
      expect(TokenType.values.contains(TokenType.plus), isTrue);
      expect(TokenType.values.contains(TokenType.minus), isTrue);
      expect(TokenType.values.contains(TokenType.multiply), isTrue);
      expect(TokenType.values.contains(TokenType.divide), isTrue);
      expect(TokenType.values.contains(TokenType.power), isTrue);
      expect(TokenType.values.contains(TokenType.lparen), isTrue);
      expect(TokenType.values.contains(TokenType.rparen), isTrue);
      expect(TokenType.values.contains(TokenType.function), isTrue);
      expect(TokenType.values.contains(TokenType.eof), isTrue);
    });
  });

  group('Token', () {
    test('creates a token with all properties', () {
      final token = Token(
        type: TokenType.number,
        value: '42',
        position: 5,
      );

      expect(token.type, equals(TokenType.number));
      expect(token.value, equals('42'));
      expect(token.position, equals(5));
    });

    test('toString returns correct format', () {
      final token = Token(
        type: TokenType.plus,
        value: '+',
        position: 10,
      );

      final str = token.toString();
      expect(str, contains('Token'));
      expect(str, contains('plus'));
      expect(str, contains('+'));
      expect(str, contains('10'));
    });

    test('equality works correctly for identical tokens', () {
      final token1 = Token(
        type: TokenType.variable,
        value: 'x',
        position: 0,
      );
      final token2 = Token(
        type: TokenType.variable,
        value: 'x',
        position: 0,
      );

      expect(token1, equals(token2));
      expect(token1 == token1, isTrue); // identical
    });

    test('equality ignores position', () {
      final token1 = Token(
        type: TokenType.variable,
        value: 'x',
        position: 0,
      );
      final token2 = Token(
        type: TokenType.variable,
        value: 'x',
        position: 10,
      );

      expect(token1, equals(token2));
    });

    test('equality fails for different types', () {
      final token1 = Token(
        type: TokenType.number,
        value: '5',
        position: 0,
      );
      final token2 = Token(
        type: TokenType.variable,
        value: '5',
        position: 0,
      );

      expect(token1, isNot(equals(token2)));
    });

    test('equality fails for different values', () {
      final token1 = Token(
        type: TokenType.variable,
        value: 'x',
        position: 0,
      );
      final token2 = Token(
        type: TokenType.variable,
        value: 'y',
        position: 0,
      );

      expect(token1, isNot(equals(token2)));
    });

    test('equality with different object type returns false', () {
      final token = Token(
        type: TokenType.number,
        value: '5',
        position: 0,
      );

      expect(token == 'not a token', isFalse);
      expect(token == 5, isFalse);
    });

    test('hashCode is consistent for equal tokens', () {
      final token1 = Token(
        type: TokenType.multiply,
        value: '*',
        position: 5,
      );
      final token2 = Token(
        type: TokenType.multiply,
        value: '*',
        position: 15,
      );

      expect(token1.hashCode, equals(token2.hashCode));
    });

    test('hashCode is different for different tokens', () {
      final token1 = Token(
        type: TokenType.plus,
        value: '+',
        position: 0,
      );
      final token2 = Token(
        type: TokenType.minus,
        value: '-',
        position: 0,
      );

      expect(token1.hashCode, isNot(equals(token2.hashCode)));
    });

    test('works with all token types', () {
      for (final type in TokenType.values) {
        final token = Token(
          type: type,
          value: 'test',
          position: 0,
        );

        expect(token.type, equals(type));
      }
    });
  });
}
