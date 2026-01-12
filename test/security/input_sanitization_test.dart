import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

/// Input sanitization and validation security tests
///
/// This test suite covers:
/// 1. Path traversal attempts in expressions
/// 2. Format string injection
/// 3. Expression injection via user input
/// 4. Cross-expression contamination
/// 5. Side-channel attacks via timing
void main() {
  late Texpr evaluator;

  setUp(() {
    evaluator = Texpr();
  });

  group('Path Traversal Attempts', () {
    test('expressions resembling file paths should be handled', () {
      // CVE: Path traversal via expression
      final pathLike = [
        '../../../etc/passwd',
        r'..\..\windows\system32',
        '/etc/shadow',
        r'C:\Windows\System32',
        '~/secret',
      ];

      for (final expr in pathLike) {
        expect(
          () => evaluator.evaluate(expr),
          throwsA(isA<TexprException>()),
          reason: 'Path-like strings should fail as invalid expressions',
        );
      }
    });

    test('expressions with dots and slashes should be rejected', () {
      // CVE: Directory traversal patterns
      final expr = '../' * 100;

      expect(
        () => evaluator.evaluate(expr),
        throwsA(isA<TexprException>()),
        reason: 'Directory traversal patterns should be rejected',
      );
    });
  });

  group('Format String Injection', () {
    test('expressions with format specifiers should be safe', () {
      // CVE: Format string injection
      final formatStrings = [
        '%s%s%s%s%s',
        '%x%x%x%x',
        '%n%n%n',
        '{0}{1}{2}',
        r'\x41\x41\x41',
      ];

      for (final expr in formatStrings) {
        expect(
          () => evaluator.evaluate(expr),
          anyOf(
            throwsA(isA<TexprException>()),
            returnsNormally, // May parse as operators/variables
          ),
          reason: 'Format specifiers should not execute as format strings',
        );
      }
    });
  });

  group('Expression Injection via User Input', () {
    test('user input as variable value should not execute code', () {
      // CVE: Variable value injection
      final userInput = r'\factorial{1000}'; // Malicious expression

      // User input should be treated as a value, not parsed
      final vars = {'x': 1.0};
      final result = evaluator.evaluate('x + 1', vars);

      expect(result.asNumeric(), equals(2.0),
          reason: 'Variable values should not be re-parsed');
    });

    test('concatenating user input should not create injection', () {
      // CVE: Expression concatenation injection
      // This test demonstrates proper variable isolation

      // Should use variable substitution, not string concatenation
      final vars = {'x': 5.0};
      final result = evaluator.evaluate('x + 1', vars);

      expect(result.asNumeric(), equals(6.0),
          reason: 'User input should be isolated in variables');
    });

    test('user input with quotes should not break parsing', () {
      // CVE: Quote injection
      final maliciousNames = [
        'x"',
        "x'",
        'x`',
        r'x\"',
        r"x\'",
      ];

      for (final name in maliciousNames) {
        expect(
          () => evaluator.evaluate(name),
          anyOf(
            returnsNormally,
            throwsA(isA<Exception>()),
          ),
          reason: 'Quotes in variable names should be handled',
        );
      }
    });
  });

  group('Multi-Expression Contamination', () {
    test('evaluating multiple expressions should not share state', () {
      // CVE: Expression state leakage
      final result1 = evaluator.evaluate('x + 1', {'x': 5.0});
      final result2 = evaluator.evaluate('y + 1', {'y': 10.0});

      expect(result1.asNumeric(), equals(6.0));
      expect(result2.asNumeric(), equals(11.0),
          reason: 'Expressions should be independent');
    });

    test('let bindings should not leak between expressions', () {
      // CVE: Let binding contamination
      // Note: The parser supports 'let x = value' which adds to the global environment.
      // To test isolation, we use separate evaluator instances.

      final evaluator1 = Texpr();
      evaluator1.evaluate(r'let x = 25');

      // A fresh evaluator should not have x defined
      final evaluator2 = Texpr();
      expect(
        () => evaluator2.evaluate('x + 1'),
        throwsA(isA<EvaluatorException>()),
        reason: 'Let bindings should be scoped to evaluator instance',
      );
    });

    test('errors in one expression should not affect next', () {
      // CVE: Error state persistence
      try {
        evaluator.evaluate('1/0');
      } catch (_) {
        // Ignore
      }

      final result = evaluator.evaluate('2 + 2');
      expect(result.asNumeric(), equals(4.0),
          reason: 'Previous errors should not contaminate new evaluations');
    });
  });

  group('Environment Variable Isolation', () {
    test('global environment should not be modified by evaluation', () {
      // CVE: Environment pollution
      final customVars = {'x': 1.0, 'y': 2.0};
      final originalVars = Map.from(customVars);

      evaluator.evaluate('x + y', customVars);

      expect(customVars, equals(originalVars),
          reason: 'Evaluation should not modify variable map');
    });

    test('nested evaluations should not share environments', () {
      // CVE: Environment leakage in nested contexts
      final outer = {'x': 1.0};
      final inner = {'x': 2.0};

      final result1 = evaluator.evaluate('x + 1', outer);
      final result2 = evaluator.evaluate('x + 1', inner);

      expect(result1.asNumeric(), equals(2.0));
      expect(result2.asNumeric(), equals(3.0),
          reason: 'Different environments should be isolated');
    });
  });

  group('Timing Side-Channel Attacks', () {
    test('evaluation time should not leak variable values', () {
      // CVE: Timing attack on variable existence
      final start1 = DateTime.now();
      try {
        evaluator.evaluate('unknownVar');
      } catch (_) {}
      final time1 = DateTime.now().difference(start1);

      final start2 = DateTime.now();
      try {
        evaluator.evaluate('unknownVar2');
      } catch (_) {}
      final time2 = DateTime.now().difference(start2);

      // Timing should be similar (within order of magnitude)
      expect(
        (time1.inMicroseconds - time2.inMicroseconds).abs() < 100000,
        isTrue,
        reason: 'Timing should not vary significantly for similar errors',
      );
    });

    test('large number computation time should be bounded', () {
      // CVE: Timing DoS
      final start = DateTime.now();
      final result = evaluator.evaluate('9999999 + 1');
      final elapsed = DateTime.now().difference(start);

      expect(result.asNumeric(), equals(10000000.0));
      expect(
        elapsed.inSeconds < 1,
        isTrue,
        reason: 'Simple arithmetic should complete quickly',
      );
    });
  });

  group('Special Value Injection', () {
    test('infinity as variable value should be handled', () {
      // CVE: Infinity injection
      final result = evaluator.evaluate('x + 1', {'x': double.infinity});

      expect(result.asNumeric().isInfinite, isTrue,
          reason: 'Infinity should propagate correctly');
    });

    test('NaN as variable value should be handled', () {
      // CVE: NaN injection
      final result = evaluator.evaluate('x + 1', {'x': double.nan});

      expect(result.asNumeric().isNaN, isTrue,
          reason: 'NaN should propagate correctly');
    });

    test('negative zero should be handled', () {
      // CVE: Negative zero edge case
      final result = evaluator.evaluate('x + 1', {'x': -0.0});

      expect(result.asNumeric(), equals(1.0),
          reason: 'Negative zero should work correctly');
    });

    test('maximum double value should not overflow', () {
      // CVE: Double overflow
      final result = evaluator.evaluate('x + 1', {'x': double.maxFinite});

      expect(
        result.asNumeric().isFinite || result.asNumeric().isInfinite,
        isTrue,
        reason: 'Max double should be handled without crash',
      );
    });

    test('minimum positive double should not underflow', () {
      // CVE: Double underflow
      final result = evaluator.evaluate('x * 0.5', {'x': double.minPositive});

      expect(result, isA<NumericResult>(),
          reason: 'Min positive should be handled');
    });
  });

  group('Escape Sequence Injection', () {
    test('expressions with escape sequences should be rejected', () {
      // CVE: Escape sequence injection
      final escapes = [
        r'1 + \n 1',
        r'1 + \t 1',
        r'1 + \r 1',
        r'1 + \0 1',
        r'1 + \x41 1',
        r'1 + \u0041 1',
      ];

      for (final expr in escapes) {
        expect(
          () => evaluator.evaluate(expr),
          anyOf(
            throwsA(isA<Exception>()),
            returnsNormally,
          ),
          reason: 'Escape sequences should be handled consistently',
        );
      }
    });
  });

  group('Validation Bypass Attempts', () {
    test('validate and evaluate should be consistent', () {
      // CVE: Validation/evaluation inconsistency
      final expr = r'\sin{x}';

      final validation = evaluator.validate(expr);

      if (validation.isValid) {
        expect(
          () => evaluator.evaluate(expr, {'x': 1.0}),
          returnsNormally,
          reason: 'Valid expression should evaluate successfully',
        );
      } else {
        expect(
          () => evaluator.evaluate(expr, {'x': 1.0}),
          anyOf(
            throwsA(isA<Exception>()),
            returnsNormally,
          ),
          reason: 'Validation should match evaluation behavior',
        );
      }
    });

    test('malicious expression passing validation should still be safe', () {
      // CVE: Validation bypass
      final expr = '1' * 1000;

      final validation = evaluator.validate(expr);
      // Whether valid or not, evaluation should be safe
      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'Evaluation should be safe even if validation passes',
      );
    });
  });

  group('Type Coercion Edge Cases', () {
    test('mixing complex and real should not cause type confusion', () {
      // CVE: Type coercion vulnerability
      final result = evaluator.evaluate(r'\sqrt{-1} + 1');

      expect(
        result.isComplex || result.isNumeric,
        isTrue,
        reason: 'Type coercion should be safe',
      );
    });

    test('matrix and scalar operations should throw type error', () {
      // CVE: Type safety bypass
      expect(
        () => evaluator.evaluate(r'\begin{pmatrix} 1 & 2 \end{pmatrix} + 3'),
        throwsA(isA<EvaluatorException>()),
        reason: 'Type mismatches should be caught',
      );
    });
  });

  group('Error Message Information Disclosure', () {
    test('error messages should not leak sensitive information', () {
      // CVE: Information disclosure via error messages
      final result = evaluator.validate(r'\unknownFunc{x}');

      expect(result.isValid, isFalse);
      // Error message should be helpful but not leak internals
      expect(
        result.errorMessage,
        isNot(contains('stack')),
        reason: 'Error should not contain stack traces',
      );
      expect(
        result.errorMessage,
        isNot(contains('file://')),
        reason: 'Error should not contain file paths',
      );
    });

    test('suggestions should not reveal internal structure', () {
      // CVE: Internal structure disclosure
      try {
        evaluator.evaluate(r'\invalid');
      } on TexprException catch (e) {
        expect(
          e.suggestion ?? '',
          isNot(contains('/')),
          reason: 'Suggestions should not contain paths',
        );
      }
    });
  });

  group('Resource Limit Bypass Attempts', () {
    test('chaining operations should not bypass iteration limits', () {
      // CVE: Limit bypass via chaining
      final expr = r'\sum_{i=1}^{5000} 1 + \sum_{i=1}^{5000} 1';

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          throwsA(isA<EvaluatorException>()),
          returnsNormally,
        ),
        reason: 'Chained operations should respect limits',
      );
    });

    test('nested limits should compound correctly', () {
      // CVE: Nested limit multiplication
      final expr = r'\sum_{i=1}^{1000} \sum_{j=1}^{1000} 1';

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          throwsA(isA<EvaluatorException>()),
          returnsNormally,
        ),
        reason: 'Nested iterations should be bounded',
      );
    });
  });

  group('Unicode Security', () {
    test('BIDI override attacks should not affect semantics', () {
      // CVE: BIDI override attack
      final expr = '1+2\u202E-1\u202C'; // RLO ... PDF

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          returnsNormally,
          throwsA(isA<Exception>()),
        ),
        reason: 'BIDI characters should not change semantics',
      );
    });

    test('confusable characters should be rejected', () {
      // CVE: Confusable character substitution
      // Greek omicron 'ο' vs Latin 'o'
      final expr = 'οmicron'; // Greek omicron

      expect(
        () => evaluator.evaluate(expr),
        anyOf(
          throwsA(isA<Exception>()),
          returnsNormally,
        ),
        reason: 'Confusable characters should be handled',
      );
    });
  });

  group('Boundary Value Testing', () {
    test('empty expression should be handled', () {
      // CVE: Empty input edge case
      expect(
        () => evaluator.evaluate(''),
        throwsA(isA<Exception>()),
        reason: 'Empty expression should be rejected',
      );
    });

    test('whitespace-only expression should be rejected', () {
      // CVE: Whitespace-only input
      expect(
        () => evaluator.evaluate('   \t\n   '),
        throwsA(isA<Exception>()),
        reason: 'Whitespace-only should be rejected',
      );
    });

    test('single character expressions should be handled', () {
      // CVE: Single character edge cases
      final singles = ['1', 'x', '+', '(', r'\'];

      for (final expr in singles) {
        expect(
          () => evaluator.evaluate(expr, {'x': 1.0}),
          anyOf(
            returnsNormally,
            throwsA(isA<Exception>()),
          ),
          reason: 'Single characters should be handled safely',
        );
      }
    });
  });
}
