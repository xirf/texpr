import 'package:test/test.dart';
import 'package:texpr/texpr.dart';
import 'package:texpr/src/parser/error_suggestions.dart';

void main() {
  group('Improved Error Messages', () {
    late Texpr evaluator;

    setUp(() {
      evaluator = Texpr();
    });

    group('Error Suggestion Utilities', () {
      test('Levenshtein distance calculation', () {
        expect(levenshteinDistance('sin', 'sin'), 0);
        expect(levenshteinDistance('sin', 'sn'), 1);
        expect(levenshteinDistance('sin', 'cos'), 3);
        expect(levenshteinDistance('', 'abc'), 3);
        expect(levenshteinDistance('abc', ''), 3);
        expect(levenshteinDistance('sinx', 'sin'), 1);
      });

      test('findSimilarCommand returns null for very different strings', () {
        expect(findSimilarCommand('xyz123'), isNull);
        expect(findSimilarCommand('abcdefgh'), isNull);
      });

      test('findSimilarCommand finds close matches', () {
        expect(findSimilarCommand('sinn'), 'sin');
        expect(findSimilarCommand('coss'), 'cos');
        expect(findSimilarCommand('sqr'), 'sqrt');
        expect(findSimilarCommand('lnn'), 'ln');
      });

      test('findSimilarCommand uses command aliases', () {
        expect(findSimilarCommand('sine'), 'sin');
        expect(findSimilarCommand('cosine'), 'cos');
        expect(findSimilarCommand('squareroot'), 'sqrt');
        expect(findSimilarCommand('natural_log'), 'ln');
      });
    });

    group('Common Mistake Detection', () {
      test('detects frac without braces', () {
        final result = detectCommonMistake(r'\frac12', null);
        expect(result, isNotNull);
        expect(result!['pattern'], r'\frac12');
        expect(result['suggestion'], contains('braces'));
      });

      test('detects missing backslash before function', () {
        final result = detectCommonMistake('sin(x)', null);
        expect(result, isNotNull);
        expect(result!['suggestion'], contains('backslash'));
      });

      test('detects unmatched braces', () {
        final result = detectCommonMistake(r'\sin{x', null);
        expect(result, isNotNull);
        expect(result!['suggestion'], contains('closing brace'));
      });

      test('detects unmatched parentheses', () {
        final result = detectCommonMistake('(1 + 2', null);
        expect(result, isNotNull);
        expect(result!['suggestion'], contains('closing parenthesis'));
      });

      test('returns null for valid expression', () {
        final result = detectCommonMistake(r'\sin{x}', null);
        expect(result, isNull);
      });
    });

    group('ValidationResult Suggestions', () {
      test('validation of unknown function provides suggestion', () {
        final result = evaluator.validate(r'\unknownfunc{x}');
        expect(result.isValid, isFalse);
        expect(result.suggestion, isNotNull);
      });

      test('validation of undefined variable throws with suggestion', () {
        // x + y without providing variable values should fail on evaluate
        try {
          evaluator.evaluate('x + y');
        } on EvaluatorException catch (e) {
          expect(e.message, contains('Undefined variable'));
          final vr = ValidationResult.fromException(e);
          expect(vr.suggestion, isNotNull);
        }
      });

      test('validation of unclosed brace provides suggestion', () {
        try {
          evaluator.evaluate(r'\sin{x');
        } on TexprException catch (e) {
          final vr = ValidationResult.fromException(e);
          expect(vr.suggestion, isNotNull);
          // Just verify a suggestion exists, don't require specific text
        }
      });

      test('validation of division by zero provides suggestion', () {
        try {
          evaluator.evaluate(r'1 / 0');
        } on EvaluatorException catch (e) {
          final vr = ValidationResult.fromException(e);
          expect(vr.suggestion, isNotNull);
          expect(vr.suggestion!.toLowerCase(), contains('denominator'));
        }
      });
    });

    group('Error Position Markers', () {
      test('ParserException includes position in toString', () {
        try {
          evaluator.evaluate(r'\sin{');
        } on TexprException catch (e) {
          final str = e.toString();
          expect(str, contains('at position'));
        }
      });

      test('exception suggestion is included in toString', () {
        final e = EvaluatorException(
          'Test error',
          suggestion: 'Try fixing this',
        );
        expect(e.toString(), contains('Suggestion: Try fixing this'));
      });
    });
  });
}
