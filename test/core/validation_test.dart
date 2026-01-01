import 'package:texpr/texpr.dart';
import 'package:test/test.dart';

void main() {
  late LatexMathEvaluator evaluator;

  setUp(() {
    evaluator = LatexMathEvaluator();
  });

  group('isValid()', () {
    test('returns true for valid expressions', () {
      expect(evaluator.isValid('2 + 3'), isTrue);
      expect(evaluator.isValid(r'2 \times 3'), isTrue);
      expect(evaluator.isValid(r'\sin{0}'), isTrue);
      expect(evaluator.isValid(r'\frac{1}{2}'), isTrue);
      expect(evaluator.isValid(r'x^{2} + 1'), isTrue);
    });

    test('returns true for expressions with variables', () {
      expect(evaluator.isValid('x'), isTrue);
      expect(evaluator.isValid('x + y'), isTrue);
      expect(evaluator.isValid(r'\sin{x}'), isTrue);
      expect(evaluator.isValid(r'x^{2} + 2x + 1'), isTrue);
    });

    test('returns true for complex valid expressions', () {
      expect(evaluator.isValid(r'\log_{2}{8}'), isTrue);
      expect(evaluator.isValid(r'\sum_{i=1}^{5} i'), isTrue);
      expect(evaluator.isValid(r'\lim_{x \to 0} x'), isTrue);
      expect(evaluator.isValid(r'\int_{0}^{1} x dx'), isTrue);
      expect(evaluator.isValid(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}'),
          isTrue);
    });

    test('returns false for unclosed braces', () {
      expect(evaluator.isValid(r'\sin{'), isFalse);
      expect(evaluator.isValid(r'\frac{1}{2'), isFalse);
      expect(evaluator.isValid(r'x^{2'), isFalse);
    });

    test('returns false for unclosed parentheses', () {
      expect(evaluator.isValid('(2 + 3'), isFalse);
      expect(evaluator.isValid('2 + 3)'), isFalse);
    });

    test('returns false for unknown commands', () {
      expect(evaluator.isValid(r'\unknown{5}'), isFalse);
      expect(evaluator.isValid(r'\notafunction{x}'), isFalse);
    });

    test('returns false for invalid syntax', () {
      expect(evaluator.isValid('2 + + 3'), isFalse);
      expect(evaluator.isValid('* 5'), isFalse);
      expect(evaluator.isValid(r'\frac{}'), isFalse);
    });

    test('returns false for unexpected characters', () {
      expect(evaluator.isValid('2 @ 3'), isFalse);
      expect(evaluator.isValid('x # y'), isFalse);
    });
  });

  group('validate()', () {
    test('returns valid result for correct expressions', () {
      final result = evaluator.validate('2 + 3');
      expect(result.isValid, isTrue);
      expect(result.errorMessage, isNull);
      expect(result.position, isNull);
      expect(result.suggestion, isNull);
    });

    test('returns valid result for expressions with variables', () {
      final result = evaluator.validate(r'x^{2} + 1');
      expect(result.isValid, isTrue);
    });

    test('provides error message for unclosed braces', () {
      final result = evaluator.validate(r'\sin{');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage, contains('Expected'));
      expect(result.suggestion, isNotNull);
    });

    test('provides error message for unknown commands', () {
      final result = evaluator.validate(r'\unknown{5}');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
      expect(result.suggestion, contains('command'));
    });

    test('provides position information when available', () {
      final result = evaluator.validate(r'\unknown{5}');
      expect(result.isValid, isFalse);
      expect(result.position, isNotNull);
    });

    test('provides suggestion for common errors', () {
      // Unclosed braces - results in "Expected expression"
      var result = evaluator.validate(r'\sin{');
      expect(result.suggestion, isNotNull);
      expect(result.suggestion!.toLowerCase(), contains('syntax'));

      // Unknown command
      result = evaluator.validate(r'\unknown{5}');
      expect(result.suggestion, isNotNull);
      expect(result.suggestion!.toLowerCase(), contains('command'));
    });

    test('includes exception type in result', () {
      final result = evaluator.validate(r'\sin{');
      expect(result.isValid, isFalse);
      expect(result.exceptionType, isNotNull);
    });

    test('toString() provides readable output for valid result', () {
      final result = evaluator.validate('2 + 3');
      expect(result.toString(), contains('valid'));
    });

    test('toString() provides detailed output for invalid result', () {
      final result = evaluator.validate(r'\sin{');
      final str = result.toString();
      expect(str, contains('invalid'));
      expect(str, contains('Error:'));
      expect(str, contains('Suggestion:'));
    });

    test('validates complex expressions correctly', () {
      expect(evaluator.validate(r'\sum_{i=1}^{10} i^{2}').isValid, isTrue);
      expect(evaluator.validate(r'\lim_{x \to 0} \frac{\sin{x}}{x}').isValid,
          isTrue);
      expect(
          evaluator
              .validate(r'\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}')
              .isValid,
          isTrue);
    });

    test('catches malformed matrix syntax', () {
      final result = evaluator.validate(r'\begin{matrix} 1 & 2');
      expect(result.isValid, isFalse);
      expect(result.errorMessage, isNotNull);
    });

    test('validates function calls with subscripts', () {
      expect(evaluator.validate(r'\log_{10}{100}').isValid, isTrue);
      expect(evaluator.validate(r'\log_{2}{8}').isValid, isTrue);
    });

    test('validates nested functions', () {
      expect(evaluator.validate(r'\sin{\cos{\tan{0}}}').isValid, isTrue);
      expect(evaluator.validate(r'\sqrt{\frac{1}{2}}').isValid, isTrue);
    });

    test('empty expression is invalid', () {
      final result = evaluator.validate('');
      expect(result.isValid, isFalse);
    });

    test('whitespace-only expression is invalid', () {
      final result = evaluator.validate('   ');
      expect(result.isValid, isFalse);
    });
  });

  group('ValidationResult', () {
    test('equality works correctly', () {
      const result1 = ValidationResult.valid();
      const result2 = ValidationResult.valid();
      expect(result1, equals(result2));

      const result3 = ValidationResult(
        isValid: false,
        errorMessage: 'Test error',
        position: 5,
      );
      const result4 = ValidationResult(
        isValid: false,
        errorMessage: 'Test error',
        position: 5,
      );
      expect(result3, equals(result4));
    });

    test('hashCode works correctly', () {
      const result1 = ValidationResult.valid();
      const result2 = ValidationResult.valid();
      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('fromException creates correct result', () {
      const exception = ParserException('Test error', position: 10);
      final result = ValidationResult.fromException(exception);

      expect(result.isValid, isFalse);
      expect(result.errorMessage, equals('Test error'));
      expect(result.position, equals(10));
      expect(result.exceptionType, equals(ParserException));
    });
  });

  group('Validation with implicit multiplication', () {
    test('validates with implicit multiplication enabled', () {
      final evalWithImplicit =
          LatexMathEvaluator(allowImplicitMultiplication: true);
      expect(evalWithImplicit.isValid('2x'), isTrue);
      expect(evalWithImplicit.isValid('3xy'), isTrue);
    });

    test('validates with implicit multiplication disabled', () {
      final evalNoImplicit =
          LatexMathEvaluator(allowImplicitMultiplication: false);
      // With implicit multiplication disabled, '2x' requires explicit operator
      // The tokenizer will treat '2x' as invalid without implicit multiplication
      expect(evalNoImplicit.isValid(r'2 \times x'), isTrue);
      expect(evalNoImplicit.isValid(r'2 \cdot x'), isTrue);
    });
  });
}
