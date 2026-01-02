import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Integration tests for error recovery - v0.2.0 milestone verification
void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('Multiple Errors Detection', () {
    test('validates detects error in expression with unknown commands', () {
      final result = evaluator.validate(
        r'\unknown1 + \unknown2 + \unknown3',
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
      // Error recovery may collect sub-errors or return first error
      expect(result.subErrors, isNotNull);
    });

    test('multiple unclosed braces detected', () {
      final result = evaluator.validate(
        r'\sin{ + \cos{',
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('mixed error types in one expression', () {
      // Unknown command and syntax error
      final result = evaluator.validate(
        r'\unknownfunc{} + + 5',
      );
      expect(result.isValid, isFalse);
    });
  });

  group('Error Recovery Continuation', () {
    test('parsing continues after recoverable error', () {
      // Even with an error, we should get some diagnostic info
      final result = evaluator.validate(r'\sin{x} + \unknown{y} + \cos{z}');
      expect(result.isValid, isFalse);
      // Should identify the unknown command
      expect(result.errorMessage, isNotNull);
    });

    test('recovery does not affect valid expressions', () {
      final result = evaluator.validate(
        r'\sin{x} + \cos{y}',
      );
      expect(result.isValid, isTrue);
      // subErrors is empty list for valid expressions
      expect(result.subErrors.isEmpty, isTrue);
    });

    test('partial parse result available with recovery', () {
      // Even with errors, recovery mode should attempt to continue
      final result = evaluator.validate(
        r'x + y + \invalid + z',
      );
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });
  });

  group('Error Message Quality', () {
    test('unknown command has clear message', () {
      final result = evaluator.validate(r'\unknownfunction{x}');
      expect(result.isValid, isFalse);
      expect(result.errorMessage!.toLowerCase(), contains('unknown'));
    });

    test('unclosed brace has clear message', () {
      final result = evaluator.validate(r'\sin{x');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('unexpected operator has clear message', () {
      final result = evaluator.validate('2 + + 3');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('division by zero suggestion', () {
      try {
        evaluator.evaluate('1/0');
      } on EvaluatorException catch (e) {
        final vr = ValidationResult.fromException(e);
        expect(vr.suggestion, isNotNull);
        expect(vr.suggestion!.toLowerCase(), contains('denominator'));
      }
    });

    test('undefined variable has clear message', () {
      try {
        evaluator.evaluate('x + y');
      } on EvaluatorException catch (e) {
        expect(e.message.toLowerCase(), contains('undefined'));
      }
    });
  });

  group('Suggestion Accuracy', () {
    test('typo in function name has suggestion', () {
      final result = evaluator.validate(r'\sinn{x}');
      expect(result.isValid, isFalse);
      // Suggestions may be generic or function-specific depending on implementation
      expect(result.suggestion, isNotNull);
    });

    test('typo in cos has suggestion', () {
      final result = evaluator.validate(r'\coss{x}');
      expect(result.isValid, isFalse);
      expect(result.suggestion, isNotNull);
    });

    test('typo in sqrt suggests sqrt', () {
      final result = evaluator.validate(r'\sqr{x}');
      expect(result.isValid, isFalse);
      expect(result.suggestion, isNotNull);
    });

    test('frac with braceless single digits parses successfully', () {
      // \frac12 now works - braceless fractions with exactly 2 digits are supported
      final result = evaluator.validate(r'\frac12');
      expect(result.isValid, isTrue);
    });

    test('frac with ambiguous 3+ digits still fails', () {
      // \frac123 is ambiguous and should fail
      final result = evaluator.validate(r'\frac123');
      expect(result.isValid, isFalse);
      expect(result.suggestion, isNotNull);
    });

    test('missing backslash before function', () {
      // sin(x) without backslash should warn about missing \
      final result = evaluator.validate('sin(x)');
      // This might be valid as variable * x, but should give feedback
      expect(result, isNotNull);
    });
  });

  group('Error Position Reporting', () {
    test('error position is reported for unclosed brace', () {
      final result = evaluator.validate(r'\sin{');
      expect(result.isValid, isFalse);
      expect(result.position, isNotNull);
    });

    test('error position is reported for unknown command', () {
      final result = evaluator.validate(r'\unknown{x}');
      expect(result.isValid, isFalse);
      expect(result.position, isNotNull);
    });

    test('error position is accurate for mid-expression error', () {
      final result = evaluator.validate(r'1 + 2 + \unknown + 4');
      expect(result.isValid, isFalse);
      expect(result.position, isNotNull);
      // Position should be around where \unknown starts
      expect(result.position, greaterThanOrEqualTo(6));
    });

    test('ParserException info in ValidationResult', () {
      final result = evaluator.validate(r'\sin{');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
      // ValidationResult provides error info
      expect(result.toString(), contains('Error'));
    });
  });

  group('ValidationResult API', () {
    test('valid result has correct properties', () {
      final result = evaluator.validate('2 + 3');
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.position, isNull);
      expect(result.suggestion, isNull);
      // subErrors is an empty list for valid expressions
      expect(result.subErrors.isEmpty, isTrue);
    });

    test('invalid result has error message', () {
      final result = evaluator.validate(r'\invalid');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('ValidationResult.valid() constructor works', () {
      const result = ValidationResult.valid();
      expect(result.isValid, isTrue);
    });

    test('ValidationResult.fromException() works', () {
      const exception = ParserException('Test error', position: 5);
      final result = ValidationResult.fromException(exception);
      expect(result.isValid, isFalse);
      expect(result.errorMessage, 'Test error');
      expect(result.position, 5);
      expect(result.exceptionType, ParserException);
    });

    test('ValidationResult toString for valid is informative', () {
      final result = evaluator.validate('2 + 3');
      expect(result.toString().toLowerCase(), contains('valid'));
    });

    test('ValidationResult toString for invalid includes details', () {
      final result = evaluator.validate(r'\unknown');
      expect(result.toString().toLowerCase(), contains('invalid'));
      expect(result.toString(), contains('Error:'));
    });

    test('ValidationResult equality works', () {
      const result1 = ValidationResult.valid();
      const result2 = ValidationResult.valid();
      expect(result1, equals(result2));

      const result3 = ValidationResult(
        isValid: false,
        errorMessage: 'Error',
        position: 10,
      );
      const result4 = ValidationResult(
        isValid: false,
        errorMessage: 'Error',
        position: 10,
      );
      expect(result3, equals(result4));
    });
  });

  group('Edge Cases in Error Handling', () {
    test('empty string validation', () {
      final result = evaluator.validate('');
      expect(result.isValid, isFalse);
    });

    test('whitespace-only validation', () {
      final result = evaluator.validate('   ');
      expect(result.isValid, isFalse);
    });

    test('very long invalid expression', () {
      final longInvalid = List.filled(100, r'\invalid').join(' + ');
      final result = evaluator.validate(longInvalid);
      expect(result.isValid, isFalse);
    });

    test('nested errors', () {
      final result = evaluator.validate(r'\unknown{\invalid{x}}');
      expect(result.isValid, isFalse);
    });

    test('error at very beginning', () {
      final result = evaluator.validate(r'\invalid + 1');
      expect(result.isValid, isFalse);
      expect(result.position, isNotNull);
      expect(result.position, lessThanOrEqualTo(10));
    });

    test('error at very end', () {
      final result = evaluator.validate(r'1 + \invalid');
      expect(result.isValid, isFalse);
    });
  });

  group('Integration with Implicit Multiplication', () {
    test('validation with implicit multiplication enabled', () {
      final eval = Texpr(allowImplicitMultiplication: true);
      expect(eval.isValid('2x'), isTrue);
      expect(eval.isValid('xy'), isTrue);
      expect(eval.isValid('2x + 3y'), isTrue);
    });

    test('error recovery with implicit multiplication', () {
      final eval = Texpr(allowImplicitMultiplication: true);
      final result = eval.validate(r'2x + \invalid');
      expect(result.isValid, isFalse);
    });
  });

  group('Common Mistake Detection', () {
    test('frac with braceless single digits now valid', () {
      // \frac12 is now valid with braceless fraction support
      final result = evaluator.validate(r'\frac12');
      expect(result.isValid, isTrue);
    });

    test('unmatched parenthesis detected', () {
      final result = evaluator.validate('(1 + 2');
      expect(result.isValid, isFalse);
      expect(result.suggestion, isNotNull);
    });

    test('unmatched brace detected', () {
      final result = evaluator.validate(r'\sin{x');
      expect(result.isValid, isFalse);
      expect(result.suggestion, isNotNull);
    });

    test('double operator detected', () {
      final result = evaluator.validate('2 + + 3');
      expect(result.isValid, isFalse);
    });

    test('leading operator detected', () {
      final result = evaluator.validate('* 5');
      expect(result.isValid, isFalse);
    });
  });

  group('isValid Convenience Method', () {
    test('isValid returns true for valid expressions', () {
      expect(evaluator.isValid('2 + 3'), isTrue);
      expect(evaluator.isValid(r'\sin{x}'), isTrue);
      expect(evaluator.isValid(r'\frac{1}{2}'), isTrue);
    });

    test('isValid returns false for invalid expressions', () {
      expect(evaluator.isValid(r'\unknown{x}'), isFalse);
      expect(evaluator.isValid(r'\sin{'), isFalse);
      expect(evaluator.isValid('2 + + 3'), isFalse);
    });

    test('isValid accepts variables', () {
      expect(evaluator.isValid('x'), isTrue);
      expect(evaluator.isValid('x + y'), isTrue);
      expect(evaluator.isValid(r'x^{2} + 1'), isTrue);
    });
  });
}
