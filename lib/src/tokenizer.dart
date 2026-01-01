/// Tokenizer (lexer) for LaTeX math expressions.
library;

import 'dart:math' as math;

import 'exceptions.dart';
import 'extensions.dart';
import 'token.dart';
import 'tokenizer/command_registry.dart';
import 'tokenizer/command_normalizer.dart';

/// Converts a LaTeX math string into a stream of tokens.
class Tokenizer {
  final String _source;
  final ExtensionRegistry? _extensions;
  final bool _allowImplicitMultiplication;
  int _position = 0;

  Tokenizer(this._source,
      {ExtensionRegistry? extensions, bool allowImplicitMultiplication = true})
      : _extensions = extensions,
        _allowImplicitMultiplication = allowImplicitMultiplication {
    if (_source.length > maxInputLength) {
      throw TokenizerException(
        'Input exceeds maximum allowed length: ${_source.length} (max $maxInputLength)',
        position: 0,
        expression: '${_source.substring(0, math.min(_source.length, 100))}...',
        suggestion:
            'Reduce the size of your LaTeX expression to under $maxInputLength characters',
      );
    }
  }

  /// Maximum allowed length for input string.
  static const int maxInputLength = 100000;

  /// Returns all tokens from the source string.
  List<Token> tokenize() {
    final tokens = <Token>[];

    while (!_isAtEnd) {
      _skipWhitespace();
      if (_isAtEnd) break;

      final token = _nextToken();
      if (token != null && token.type != TokenType.spacing) {
        tokens.add(token);
      }
    }

    tokens.add(Token(type: TokenType.eof, value: '', position: _position));
    return tokens;
  }

  bool get _isAtEnd => _position >= _source.length;

  String get _current => _source[_position];

  String? get _peek =>
      _position + 1 < _source.length ? _source[_position + 1] : null;

  void _skipWhitespace() {
    while (!_isAtEnd && _isWhitespace(_current)) {
      _position++;
    }
  }

  bool _isWhitespace(String char) =>
      char == ' ' || char == '\t' || char == '\n' || char == '\r';

  bool _isDigit(String char) =>
      char.codeUnitAt(0) >= 48 && char.codeUnitAt(0) <= 57;

  bool _isLetter(String char) {
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || (code >= 97 && code <= 122);
  }

  Token? _nextToken() {
    final startPos = _position;
    final char = _current;

    // Numbers
    if (_isDigit(char)) {
      return _readNumber();
    }

    // LaTeX commands
    if (char == '\\') {
      return _readLatexCommand();
    }

    // Single character tokens
    _position++;

    switch (char) {
      case '+':
        return Token(type: TokenType.plus, value: '+', position: startPos);
      case '-':
        return Token(type: TokenType.minus, value: '-', position: startPos);
      case '*':
        return Token(type: TokenType.multiply, value: '*', position: startPos);
      case '/':
        return Token(type: TokenType.divide, value: '/', position: startPos);
      case '^':
        return Token(type: TokenType.power, value: '^', position: startPos);
      case '_':
        return Token(
            type: TokenType.underscore, value: '_', position: startPos);
      case '=':
        return Token(type: TokenType.equals, value: '=', position: startPos);
      case '<':
        if (!_isAtEnd && _current == '=') {
          _position++;
          return Token(
              type: TokenType.lessEqual, value: '<=', position: startPos);
        }
        return Token(type: TokenType.less, value: '<', position: startPos);
      case '>':
        if (!_isAtEnd && _current == '=') {
          _position++;
          return Token(
              type: TokenType.greaterEqual, value: '>=', position: startPos);
        }
        return Token(type: TokenType.greater, value: '>', position: startPos);
      case '(':
      case '{':
        return Token(type: TokenType.lparen, value: char, position: startPos);
      case ')':
      case '}':
        return Token(type: TokenType.rparen, value: char, position: startPos);
      case '[':
        return Token(type: TokenType.lbracket, value: '[', position: startPos);
      case ']':
        return Token(type: TokenType.rbracket, value: ']', position: startPos);
      case ',':
        return Token(type: TokenType.comma, value: ',', position: startPos);
      case '|':
        return Token(type: TokenType.pipe, value: '|', position: startPos);
      case '&':
        return Token(type: TokenType.ampersand, value: '&', position: startPos);
      default:
        if (_isLetter(char)) {
          if (_allowImplicitMultiplication) {
            return Token(
                type: TokenType.variable, value: char, position: startPos);
          } else {
            final buffer = StringBuffer();
            buffer.write(char);
            while (!_isAtEnd && _isLetter(_current)) {
              buffer.write(_current);
              _position++;
            }
            return Token(
                type: TokenType.variable,
                value: buffer.toString(),
                position: startPos);
          }
        }
        throw TokenizerException(
          'Unexpected character: $char',
          position: startPos,
          expression: _source,
          suggestion:
              'Remove this character or check if it should be part of a LaTeX command',
        );
    }
  }

  Token _readNumber() {
    final startPos = _position;
    final buffer = StringBuffer();

    // Integer part
    while (!_isAtEnd && _isDigit(_current)) {
      buffer.write(_current);
      _position++;
    }

    // Decimal part
    if (!_isAtEnd && _current == '.' && _peek != null && _isDigit(_peek!)) {
      buffer.write(_current);
      _position++;

      while (!_isAtEnd && _isDigit(_current)) {
        buffer.write(_current);
        _position++;
      }
    }

    final valueStr = buffer.toString();
    return Token(
        type: TokenType.number,
        value: valueStr,
        position: startPos,
        numberValue: double.parse(valueStr));
  }

  Token? _readLatexCommand() {
    final startPos = _position;
    _position++; // Skip the backslash

    if (_isAtEnd) {
      throw TokenizerException(
        'Unexpected end after backslash',
        position: startPos,
        expression: _source,
        suggestion:
            'Add a LaTeX command after the backslash (e.g., \\sin, \\pi)',
      );
    }

    // Handle double backslash \\
    if (_current == '\\') {
      _position++;
      return Token(
          type: TokenType.backslash, value: '\\\\', position: startPos);
    }

    // Handle escaped braces \{ and \} - treat as regular braces
    if (_current == '{') {
      _position++;
      return Token(type: TokenType.lparen, value: '{', position: startPos);
    }
    if (_current == '}') {
      _position++;
      return Token(type: TokenType.rparen, value: '}', position: startPos);
    }

    // Handle punctuation spacing commands (\, \; \: \! \ )
    if (const [',', ';', ':', '!', ' '].contains(_current)) {
      final value = _current;
      _position++;
      return Token(type: TokenType.spacing, value: value, position: startPos);
    }

    final buffer = StringBuffer();
    while (!_isAtEnd && _isLetter(_current)) {
      buffer.write(_current);
      _position++;
    }

    final command = buffer.toString();

    // Try command normalization first
    final normalizedToken = CommandNormalizer.normalize(command, startPos);
    if (normalizedToken != null) {
      return normalizedToken;
    }

    // Check command registry
    final tokenType = LatexCommandRegistry.instance.getTokenType(command);
    if (tokenType != null) {
      if (tokenType == TokenType.ignored) {
        return null; // Skip delimiter sizing commands
      }
      return Token(type: tokenType, value: command, position: startPos);
    }

    // Try extension registry
    if (_extensions != null) {
      final token = _extensions!.tryTokenize(command, startPos);
      if (token != null) {
        return token;
      }
    }

    throw TokenizerException(
      'Unknown LaTeX command: \\$command',
      position: startPos,
      expression: _source,
      suggestion: 'Check if this is a valid LaTeX command or function name',
    );
  }
}
