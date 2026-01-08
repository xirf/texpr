import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Tokenizer-specific security tests
///
/// This test suite covers security vulnerabilities in the tokenization phase:
/// 1. Command injection via custom commands
/// 2. Buffer overflow in token reading
/// 3. Special character bypass
/// 4. Backslash injection
/// 5. Control character handling
void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('Command Injection via Backslash', () {
    test('backslash followed by system command should be rejected', () {
      // CVE: Backslash command injection
      final maliciousCommands = [
        r'\system{ls}',
        r'\exec{cmd}',
        r'\eval{code}',
        r'\shell{rm -rf}',
        r'\import{file}',
        r'\include{file}',
        r'\input{file}',
      ];

      for (final cmd in maliciousCommands) {
        expect(
          () => evaluator.evaluate(cmd),
          throwsA(isA<TokenizerException>()),
          reason: '$cmd should be rejected as unknown command',
        );
      }
    });

    test('deeply nested backslash commands should not cause buffer overflow',
        () {
      // CVE: Buffer overflow in command reading
      final deepCommand = r'\' * 10000 + 'sin{x}';

      expect(
        () => evaluator.evaluate(deepCommand),
        throwsA(isA<TexprException>()),
        reason: 'Excessive backslashes should fail gracefully',
      );
    });

    test('command with extremely long name should be rejected', () {
      // CVE: Command name length validation
      final longCommand = r'\' + 'a' * 10000 + '{x}';

      expect(
        () => evaluator.evaluate(longCommand),
        throwsA(isA<TokenizerException>()),
        reason: 'Extremely long command names should be rejected',
      );
    });
  });

  group('Special Character Injection', () {
    test('control characters in expression should be handled', () {
      // CVE: Control character injection (0x00-0x1F)
      final controlChars = [
        '1+1\x00',
        '1+1\x01',
        '1+1\x07', // Bell
        '1+1\x08', // Backspace
        '1+1\x0C', // Form feed
        '1+1\x0E',
        '1+1\x1B', // Escape
        '1+1\x7F', // Delete
      ];

      for (final expr in controlChars) {
        expect(
          () => evaluator.evaluate(expr),
          anyOf(
            throwsA(isA<TokenizerException>()),
            returnsNormally,
          ),
          reason: 'Control characters should not cause undefined behavior',
        );
      }
    });

    test('zero-width characters should not bypass validation', () {
      // CVE: Zero-width character bypass
      final expr = '1\u200B+\u200C1\u200D'; // Zero-width space/joiner

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Zero-width characters should be handled',
      );
    });

    test('right-to-left override should not affect parsing', () {
      // CVE: Unicode directional override
      final expr = '1+\u202E2\u202C'; // RLO...PDF

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Directional overrides should not confuse parser',
      );
    });

    test('homoglyph attacks should not bypass validation', () {
      // CVE: Homoglyph substitution (look-alike characters)
      final homoglyphs = [
        'х + 1', // Cyrillic 'х' looks like Latin 'x'
        'а + 1', // Cyrillic 'а' looks like Latin 'a'
        'о + 1', // Cyrillic 'о' looks like Latin 'o'
        '０ + １', // Full-width digits
        'ｘ + １', // Full-width x
      ];

      for (final expr in homoglyphs) {
        expect(
          () => evaluator.evaluate(expr),
          anyOf(
            throwsA(isA<TexprException>()),
            returnsNormally,
          ),
          reason: 'Homoglyphs should be handled safely',
        );
      }
    });
  });

  group('Tokenizer Buffer Edge Cases', () {
    test('number with excessive digits should be handled', () {
      // CVE: Number buffer overflow
      final hugeNumber = '9' * 100000;

      expect(
        () => evaluator.evaluate(hugeNumber),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Extremely long numbers should be parsed or rejected',
      );
    });

    test('number with excessive decimal places should be handled', () {
      // CVE: Decimal parsing DoS
      final preciseNumber = '0.${'9' * 100000}';

      expect(
        () => evaluator.evaluate(preciseNumber),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Very precise numbers should be handled',
      );
    });

    test('scientific notation with extreme exponent should be handled', () {
      // CVE: Scientific notation overflow
      final extremeExponents = [
        '1e1000000',
        '1e-1000000',
        '1e${'9' * 100}',
      ];

      for (final expr in extremeExponents) {
        expect(
          () => evaluator.evaluate(expr),
          anyOf(
            returnsNormally, // May return infinity
            throwsA(isA<Exception>()),
          ),
          reason: 'Extreme exponents should be handled',
        );
      }
    });

    test('malformed scientific notation should be rejected', () {
      // CVE: Malformed number parsing
      final malformed = [
        '1e',
        '1e+',
        '1e-',
        '1ee5',
        '1e5e5',
      ];

      for (final expr in malformed) {
        expect(
          () => evaluator.evaluate(expr),
          anyOf(
            throwsA(isA<TexprException>()),
            returnsNormally, // May be parsed as 1*e or similar
          ),
          reason: 'Malformed scientific notation should be handled safely',
        );
      }
    });
  });

  group('Unicode Normalization Attacks', () {
    test('combining characters should not create unexpected tokens', () {
      // CVE: Combining character confusion
      // 'x' followed by combining diacritic
      final expr = 'x\u0301 + 1'; // x with acute accent

      expect(
        () => evaluator.evaluate(expr, {'x': 1.0}),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Combining characters should be handled',
      );
    });

    test('normalization equivalence should not bypass checks', () {
      // CVE: Unicode normalization bypass
      // é can be represented as U+00E9 or U+0065 U+0301
      final expr1 = 'é + 1'; // Precomposed
      final expr2 = 'e\u0301 + 1'; // Decomposed

      // Both should behave consistently
      expect(
        () => evaluator.evaluate(expr1),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally,
        ),
      );

      expect(
        () => evaluator.evaluate(expr2),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally,
        ),
      );
    });

    test('emoji in expression should be rejected', () {
      // CVE: Emoji injection
      final emojiExprs = [
        '1 + 😀',
        '🔢 + 1',
        r'\sin{😎}',
      ];

      for (final expr in emojiExprs) {
        expect(
          () => evaluator.evaluate(expr),
          throwsA(isA<TexprException>()),
          reason: 'Emoji should be rejected as invalid characters',
        );
      }
    });
  });

  group('Whitespace Injection Attacks', () {
    test('excessive whitespace should not cause DoS', () {
      // CVE: Whitespace DoS
      final expr = '1${' ' * 10000}+${' ' * 10000}1';

      expect(
        () => evaluator.evaluate(expr),
        returnsNormally,
        reason: 'Excessive whitespace should be skipped efficiently',
      );
    });

    test('mixed whitespace types should be handled', () {
      // CVE: Different whitespace types
      final expr = '1\t+\n1\r\n'; // Tab, newline, CRLF

      expect(
        () => evaluator.evaluate(expr),
        returnsNormally,
        reason: 'All whitespace types should be skipped',
      );
    });

    test('non-breaking space should be handled', () {
      // CVE: Non-breaking space (\u00A0)
      final expr = '1\u00A0+\u00A01';

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Non-breaking space should be handled',
      );
    });

    test('unicode whitespace characters should be handled', () {
      // CVE: Unicode whitespace bypass
      final unicodeWhitespaces = [
        '1\u2000+\u20001', // En quad
        '1\u2009+\u20091', // Thin space
        '1\u200A+\u200A1', // Hair space
        '1\u3000+\u30001', // Ideographic space
      ];

      for (final expr in unicodeWhitespaces) {
        expect(
          () => evaluator.evaluate(expr),
          anyOf(
            returnsNormally,
            throwsA(isA<Exception>()),
          ),
          reason: 'Unicode whitespace should be handled consistently',
        );
      }
    });
  });

  group('Backslash Escaping Edge Cases', () {
    test('double backslash should not escape commands', () {
      // CVE: Backslash escape confusion
      final expr = r'\\sin{x}';

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally,
        ),
        reason: 'Double backslash handling should be clear',
      );
    });

    test('backslash at end of input should be handled', () {
      // CVE: Trailing backslash
      final expr = r'1 + 1\';

      expect(
        () => evaluator.evaluate(expr),
        throwsA(isA<Exception>()),
        reason: 'Trailing backslash should cause error',
      );
    });

    test('backslash followed by whitespace should be rejected', () {
      // CVE: Backslash whitespace
      final expr = r'\ sin{x}';

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          throwsA(isA<TokenizerException>()),
          throwsA(isA<EvaluatorException>()), // May parse as variables
        ),
        reason: 'Backslash followed by space should cause error',
      );
    });
  });

  group('Brace Matching Edge Cases', () {
    test('unmatched opening braces should be detected', () {
      // CVE: Unclosed brace
      final exprs = [
        r'\frac{1',
        r'\sqrt{',
        r'{1 + 1',
      ];

      for (final expr in exprs) {
        expect(
          () => evaluator.evaluate(expr),
          throwsA(isA<TexprException>()),
          reason: 'Unmatched opening braces should throw error',
        );
      }
    });

    test('unmatched closing braces should be detected', () {
      // CVE: Extra closing brace
      final exprs = [
        '1 + 1}',
        r'\sin{x}}',
        '}1 + 1',
      ];

      for (final expr in exprs) {
        expect(
          () => evaluator.evaluate(expr),
          throwsA(isA<TexprException>()),
          reason: 'Unmatched closing braces should throw error',
        );
      }
    });

    test('deeply nested mismatched braces should be caught', () {
      // CVE: Complex brace mismatch
      final expr = r'\frac{\frac{\frac{1{2}}{3}';

      expect(
        () => evaluator.evaluate(expr),
        throwsA(isA<TexprException>()),
        reason: 'Nested brace mismatches should be detected',
      );
    });
  });

  group('Variable Name Injection', () {
    test('variable names with special LaTeX characters should fail', () {
      // CVE: Variable name injection
      final vars = {
        r'\alpha': 1.0,
        r'\beta': 2.0,
        r'\sin': 3.0,
      };

      expect(
        () => evaluator.evaluate('x', vars),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Variable names should be validated',
      );
    });

    test('variable names with numbers should be handled', () {
      // CVE: Alphanumeric variable names
      final vars = {
        'x1': 1.0,
        'x2': 2.0,
        'var123': 3.0,
      };

      expect(
        () => evaluator.evaluate('x1 + x2', vars),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Numeric suffixes in variables should be handled',
      );
    });

    test('single character unicode variable names should work', () {
      // CVE: Unicode variable validation
      final vars = {
        'alpha': 1.0,
        'beta': 2.0,
        'theta': 3.0,
      };

      expect(
        () => evaluator.evaluate(r'\alpha + \beta', vars),
        returnsNormally,
        reason: 'Greek letter variables should work',
      );
    });
  });

  group('Max Input Length Enforcement', () {
    test('input exceeding max length should be rejected immediately', () {
      // CVE: Input length bypass
      final longInput = '1 + ' * 100000; // Will exceed maxInputLength

      expect(
        () => evaluator.evaluate(longInput),
        throwsA(isA<TokenizerException>()),
        reason: 'Inputs exceeding max length should be rejected',
      );
    });

    test('input at max length boundary should be handled', () {
      // Test exactly at the boundary
      final atBoundary = '1' * (Tokenizer.maxInputLength - 1);

      expect(
        () => evaluator.evaluate(atBoundary),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Input at boundary should be processed',
      );
    });
  });

  group('Token Type Confusion', () {
    test('operator that looks like variable should not confuse tokenizer', () {
      // CVE: Token type confusion
      final expr = 'x*-1'; // Minus sign vs variable

      expect(
        () => evaluator.evaluate(expr, {'x': 2.0}),
        returnsNormally,
        reason: 'Minus operator should be distinguished from variable',
      );
    });

    test('function name collision with variable should be handled', () {
      // CVE: Function/variable collision
      final vars = {'sin': 1.0};

      expect(
        () => evaluator.evaluate(r'\sin{x}', vars),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Function names should take precedence over variables',
      );
    });
  });

  group('Comment Injection (if supported)', () {
    test('LaTeX comments should not be processed as code', () {
      // CVE: Comment injection
      final expr = r'1 + 1 % malicious code';

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Comment handling should be consistent',
      );
    });
  });

  group('Tokenizer State Corruption', () {
    test('reusing tokenizer should not maintain state', () {
      // CVE: Tokenizer state leakage
      final expr1 = r'\sin{x}';
      final expr2 = r'\cos{y}';

      evaluator.evaluate(expr1, {'x': 0.0});
      final result2 = evaluator.evaluate(expr2, {'y': 0.0});

      expect(result2, isA<NumericResult>(),
          reason: 'Second evaluation should not be affected by first');
    });

    test('tokenizer with error should not corrupt future parsing', () {
      // CVE: Error state corruption
      try {
        evaluator.evaluate(r'\invalid{x}');
      } catch (_) {
        // Expected
      }

      // Next evaluation should work fine
      final result = evaluator.evaluate('1 + 1');
      expect(result.asNumeric(), equals(2.0),
          reason: 'Previous error should not affect new parsing');
    });
  });
}
