/// Normalizes LaTeX commands to canonical forms.
library;

import '../token.dart';

/// Handles normalization of LaTeX commands to canonical forms.
///
/// This class provides a centralized location for handling:
/// - Command aliases (e.g., \arcsin -> asin)
/// - Special operator transformations (e.g., \times -> multiply)
/// - Command-specific token generation
class CommandNormalizer {
  /// Normalizes a LaTeX command and returns the appropriate token.
  ///
  /// Returns null if the command doesn't need special normalization.
  static Token? normalize(String command, int position) {
    switch (command) {
      // Multiplication operators
      case 'times':
      case 'cdot':
        return Token(
            type: TokenType.multiply, value: '\\$command', position: position);

      // Division operator
      case 'div':
        return Token(
            type: TokenType.divide, value: '\\div', position: position);

      // Normalize inverse trig aliases to canonical form
      case 'arcsin':
      case 'asin':
        return Token(
            type: TokenType.function, value: 'asin', position: position);

      case 'arccos':
      case 'acos':
        return Token(
            type: TokenType.function, value: 'acos', position: position);

      case 'arctan':
      case 'atan':
        return Token(
            type: TokenType.function, value: 'atan', position: position);

      case 'arccot':
        return Token(
            type: TokenType.function, value: 'acot', position: position);

      case 'arcsec':
        return Token(
            type: TokenType.function, value: 'asec', position: position);

      case 'arccsc':
        return Token(
            type: TokenType.function, value: 'acsc', position: position);

      default:
        return null;
    }
  }
}
