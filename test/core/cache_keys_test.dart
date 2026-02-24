import 'package:test/test.dart';
import 'package:texpr/src/ast.dart';
import 'package:texpr/src/cache/cache_keys.dart';

void main() {
  group('EvaluationCacheKey structural normalization', () {
    final expr = BinaryOp(
      const NumberLiteral(1),
      BinaryOperator.add,
      const NumberLiteral(2),
    );

    test('treats +0.0 and -0.0 as the same key', () {
      final key1 = EvaluationCacheKey(expr, {'x': 0.0});
      final key2 = EvaluationCacheKey(expr, {'x': -0.0});

      expect(key1, equals(key2));
      expect(key1.hashCode, equals(key2.hashCode));
    });

    test('treats NaN values as equivalent for key matching', () {
      final key1 = EvaluationCacheKey(expr, {'x': double.nan});
      final key2 = EvaluationCacheKey(expr, {'x': double.nan});

      expect(key1, equals(key2));
      expect(key1.hashCode, equals(key2.hashCode));
    });

    test('uses variable values in structural equality', () {
      final key1 = EvaluationCacheKey(expr, {'x': 1.0});
      final key2 = EvaluationCacheKey(expr, {'x': 2.0});

      expect(key1 == key2, isFalse);
    });

    test('is stable across variable insertion order', () {
      final key1 = EvaluationCacheKey(expr, {'x': 1.0, 'y': -0.0});
      final key2 = EvaluationCacheKey(expr, {'y': 0.0, 'x': 1.0});

      expect(key1, equals(key2));
      expect(key1.hashCode, equals(key2.hashCode));
    });

    test('identity and structural keys are not considered equal', () {
      final vars = {'x': 1.0};
      final identityKey = EvaluationCacheKey.identity(expr, vars);
      final structuralKey = EvaluationCacheKey(expr, vars);

      expect(identityKey == structuralKey, isFalse);
    });
  });
}
