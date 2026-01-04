/// Tokenizer (lexer) for LaTeX math expressions.
library;

import 'dart:math' as math;

import 'exceptions.dart';
import 'extensions.dart';
import 'token.dart';
import 'tokenizer/command_registry.dart';
import 'tokenizer/command_normalizer.dart';

/// Maps Unicode mathematical symbols to their LaTeX equivalents.
///
/// This allows direct input of symbols like `√`, `π`, `∑`, `∫` without
/// requiring backslash commands.
const _unicodeToLatex = <String, String>{
  // Operators
  '√': r'\sqrt',
  '∑': r'\sum',
  '∫': r'\int',
  '∬': r'\iint',
  '∭': r'\iiint',
  '∮': r'\oint',
  '∂': r'\partial',
  '∇': r'\nabla',
  '±': r'\pm',
  '∓': r'\mp',
  '×': r'\times',
  '÷': r'\div',
  '·': r'\cdot',

  // Comparisons
  '≤': r'\leq',
  '≥': r'\geq',
  '≠': r'\neq',
  '≈': r'\approx',
  '∝': r'\propto',
  '≡': r'\equiv',

  // Set notation
  '∈': r'\in',
  '∉': r'\notin',
  '⊂': r'\subset',
  '⊃': r'\supset',
  '⊆': r'\subseteq',
  '⊇': r'\supseteq',
  '∪': r'\cup',
  '∩': r'\cap',
  '∅': r'\emptyset',

  // Greek letters (lowercase)
  'α': r'\alpha',
  'β': r'\beta',
  'γ': r'\gamma',
  'δ': r'\delta',
  'ε': r'\epsilon',
  'ζ': r'\zeta',
  'η': r'\eta',
  'θ': r'\theta',
  'ι': r'\iota',
  'κ': r'\kappa',
  'λ': r'\lambda',
  'μ': r'\mu',
  'ν': r'\nu',
  'ξ': r'\xi',
  'π': r'\pi',
  'ρ': r'\rho',
  'σ': r'\sigma',
  'τ': r'\tau',
  'υ': r'\upsilon',
  'φ': r'\phi',
  'χ': r'\chi',
  'ψ': r'\psi',
  'ω': r'\omega',

  // Greek letters (uppercase)
  'Γ': r'\Gamma',
  'Δ': r'\Delta',
  'Θ': r'\Theta',
  'Λ': r'\Lambda',
  'Ξ': r'\Xi',
  'Π': r'\Pi',
  'Σ': r'\Sigma',
  'Φ': r'\Phi',
  'Ψ': r'\Psi',
  'Ω': r'\Omega',

  // Special symbols
  '∞': r'\infty',
  '∀': r'\forall',
  '∃': r'\exists',
  '→': r'\to',
  '←': r'\leftarrow',
  '↔': r'\leftrightarrow',
  '⇒': r'\Rightarrow',
  '⇐': r'\Leftarrow',
  '⇔': r'\Leftrightarrow',
  '↦': r'\mapsto',
};

/// Functions that can be written without backslash (e.g., sin, cos, tan).
/// When followed by `(`, these are recognized as function calls.
const _knownFunctions = <String>{
  'sin',
  'cos',
  'tan',
  'cot',
  'sec',
  'csc',
  'arcsin',
  'arccos',
  'arctan',
  'sinh',
  'cosh',
  'tanh',
  'ln',
  'log',
  'exp',
  'sqrt',
  'abs',
};

/// Converts a LaTeX math string into a stream of tokens.
class Tokenizer {
  final String _source;
  final ExtensionRegistry? _extensions;
  final bool _allowImplicitMultiplication;
  int _position = 0;

  Tokenizer(String source,
      {ExtensionRegistry? extensions, bool allowImplicitMultiplication = true})
      : _source = _preprocessUnicode(source),
        _extensions = extensions,
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

  /// Preprocesses the input string by replacing Unicode symbols with LaTeX.
  ///
  /// This allows users to input mathematical expressions using Unicode symbols
  /// like `√`, `π`, `∑`, `∫` directly, which are converted to their LaTeX
  /// equivalents before tokenization.
  static String _preprocessUnicode(String input) {
    var result = input;
    for (final entry in _unicodeToLatex.entries) {
      if (result.contains(entry.key)) {
        result = result.replaceAll(entry.key, entry.value);
      }
    }
    return result;
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
            // Look ahead to check if this starts a known function name like sin(x)
            final funcMatch = _tryMatchUnprefixedFunction(startPos);
            if (funcMatch != null) {
              return funcMatch;
            }
            return Token(
                type: TokenType.variable, value: char, position: startPos);
          } else {
            final buffer = StringBuffer();
            buffer.write(char);
            while (!_isAtEnd && _isLetter(_current)) {
              buffer.write(_current);
              _position++;
            }
            final word = buffer.toString();
            // Check if this is a known function name without backslash
            if (_knownFunctions.contains(word.toLowerCase())) {
              return Token(
                  type: TokenType.function,
                  value: word.toLowerCase(),
                  position: startPos);
            }
            return Token(
                type: TokenType.variable, value: word, position: startPos);
          }
        }
        throw TokenizerException(
          'Unexpected character: $char',
          position: startPos,
          expression: _source,
          suggestion:
              'Remove this character or check if it should be part of a command',
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
        suggestion: 'Add a command after the backslash (e.g., \\sin, \\pi)',
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
      'Unknown command: \\$command',
      position: startPos,
      expression: _source,
      suggestion: 'Check if this is a valid command or function name',
    );
  }

  /// Tries to match a known function name without backslash (e.g., sin, cos).
  ///
  /// Only matches when the function name is followed by `(` to avoid
  /// misinterpreting variable names like `simple` or `sink`.
  /// Returns a function token if matched, null otherwise.
  Token? _tryMatchUnprefixedFunction(int startPos) {
    // We've already consumed the first letter, so _position is at startPos+1
    // and we already advanced past it. We need to look from startPos.

    // Reset to startPos to read the full potential function name
    final savedPos = _position;
    _position = startPos;

    // Read letters starting from startPos
    final buffer = StringBuffer();
    while (!_isAtEnd && _isLetter(_current)) {
      buffer.write(_current);
      _position++;
    }

    final word = buffer.toString().toLowerCase();

    // Skip whitespace after the word
    while (!_isAtEnd && _isWhitespace(_current)) {
      _position++;
    }

    // Check if it's a known function followed by '('
    if (_knownFunctions.contains(word) && !_isAtEnd && _current == '(') {
      // It's a function call like sin(x)
      return Token(
        type: TokenType.function,
        value: word,
        position: startPos,
      );
    }

    // Not a function call, restore position (only consumed first char)
    _position = savedPos;
    return null;
  }
}
