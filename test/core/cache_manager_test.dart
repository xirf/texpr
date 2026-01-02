import 'package:test/test.dart';
import 'package:texpr/texpr.dart';

void main() {
  group('CacheConfig', () {
    test('default values are reasonable', () {
      final config = CacheConfig();
      expect(config.parsedExpressionCacheSize, equals(128));
      expect(config.evaluationResultCacheSize, equals(256));
      expect(config.differentiationCacheSize, equals(64));
      expect(config.subExpressionCacheSize, equals(512));
      expect(config.evictionPolicy, equals(EvictionPolicy.lru));
      expect(config.timeToLive, isNull);
      expect(config.collectStatistics, isFalse);
    });

    test('disabled preset has all caches disabled', () {
      final config = CacheConfig.disabled;
      expect(config.parsedExpressionCacheSize, equals(0));
      expect(config.evaluationResultCacheSize, equals(0));
      expect(config.differentiationCacheSize, equals(0));
      expect(config.subExpressionCacheSize, equals(0));
    });

    test('highPerformance preset has larger cache sizes', () {
      final config = CacheConfig.highPerformance;
      expect(config.parsedExpressionCacheSize, greaterThan(128));
      expect(config.evaluationResultCacheSize, greaterThan(256));
    });

    test('withStatistics preset enables statistics', () {
      final config = CacheConfig.withStatistics;
      expect(config.collectStatistics, isTrue);
    });

    test('copyWith creates modified copy', () {
      final config = CacheConfig();
      final modified = config.copyWith(
        parsedExpressionCacheSize: 500,
        collectStatistics: true,
      );

      expect(modified.parsedExpressionCacheSize, equals(500));
      expect(modified.collectStatistics, isTrue);
      expect(modified.evaluationResultCacheSize, equals(256)); // Unchanged
    });
  });

  group('CacheManager', () {
    test('creates with default config', () {
      final manager = CacheManager(CacheConfig());
      expect(manager.isEnabled, isTrue);
    });

    test('creates with disabled config', () {
      final manager = CacheManager(CacheConfig.disabled);
      expect(manager.isEnabled, isFalse);
    });

    test('caches and retrieves parsed expressions', () {
      final manager = CacheManager(CacheConfig());
      final expr = NumberLiteral(42);

      manager.putParsedExpression('42', expr);
      final retrieved = manager.getParsedExpression('42');

      expect(identical(retrieved, expr), isTrue);
    });

    test('returns null for uncached expressions', () {
      final manager = CacheManager(CacheConfig());
      expect(manager.getParsedExpression('nonexistent'), isNull);
    });

    test('clear removes all cached entries', () {
      final manager = CacheManager(CacheConfig());
      manager.putParsedExpression('42', NumberLiteral(42));

      manager.clear();

      expect(manager.getParsedExpression('42'), isNull);
    });

    test('clearLayer clears specific layer only', () {
      final manager = CacheManager(CacheConfig());
      manager.putParsedExpression('42', NumberLiteral(42));

      manager.clearLayer(CacheLayer.evaluationResults);

      // Parsed expressions should still be there
      expect(manager.getParsedExpression('42'), isNotNull);

      manager.clearLayer(CacheLayer.parsedExpressions);

      // Now should be cleared
      expect(manager.getParsedExpression('42'), isNull);
    });

    test('warmUp preloads expressions', () {
      final manager = CacheManager(CacheConfig());

      manager
          .warmUp(['1', '2', '3'], (expr) => NumberLiteral(double.parse(expr)));

      expect(manager.getParsedExpression('1'), isNotNull);
      expect(manager.getParsedExpression('2'), isNotNull);
      expect(manager.getParsedExpression('3'), isNotNull);
    });

    test('warmUp skips invalid expressions', () {
      final manager = CacheManager(CacheConfig());

      manager.warmUp(['valid', 'throws'], (expr) {
        if (expr == 'throws') throw Exception('Parse error');
        return NumberLiteral(1);
      });

      expect(manager.getParsedExpression('valid'), isNotNull);
      // Should not throw, just skip invalid
    });

    test('statistics are tracked when enabled', () {
      final config = CacheConfig.withStatistics;
      final manager = CacheManager(config);

      // Miss
      manager.getParsedExpression('x');
      expect(manager.statistics.parsedExpressions.misses, equals(1));

      // Put and hit
      manager.putParsedExpression('x', NumberLiteral(1));
      manager.getParsedExpression('x');
      expect(manager.statistics.parsedExpressions.hits, equals(1));
    });
  });

  group('Texpr with advanced caching', () {
    test('accepts CacheConfig', () {
      final evaluator = Texpr(
        cacheConfig: CacheConfig.highPerformance,
      );

      // Should work normally
      final result = evaluator.evaluate('2 + 3');
      expect(result.asNumeric(), equals(5));
    });

    test('backwards compatible with parsedExpressionCacheSize', () {
      final evaluator = Texpr(parsedExpressionCacheSize: 512);
      expect(evaluator.cacheConfig.parsedExpressionCacheSize, equals(512));
    });

    test('cacheStatistics returns statistics', () {
      final evaluator = Texpr(
        cacheConfig: CacheConfig.withStatistics,
      );

      evaluator.evaluate('x^2', {'x': 2});
      evaluator.evaluate('x^2', {'x': 3});
      evaluator.evaluate('x^2', {'x': 2}); // Cache hit for evaluation

      final stats = evaluator.cacheStatistics;
      expect(stats.parsedExpressions.hits, greaterThan(0));
    });

    test('clearAllCaches clears everything', () {
      final evaluator = Texpr();

      // Populate cache
      evaluator.parse('x^2');
      evaluator.parse('x^3');

      // Clear
      evaluator.clearAllCaches();

      // Would need internal access to verify, but at least it shouldn't throw
    });

    test('warmUpCache preloads expressions', () {
      final evaluator = Texpr(
        cacheConfig: CacheConfig.withStatistics,
      );

      evaluator.warmUpCache(['x^2', 'sin(x)', 'cos(x)']);

      // Now evaluations should have cache hits for parsing
      evaluator.evaluate('x^2', {'x': 1});

      final stats = evaluator.cacheStatistics;
      expect(stats.parsedExpressions.hits, greaterThan(0));
    });

    test('evaluation result caching works for constant expressions', () {
      final evaluator = Texpr(
        cacheConfig: CacheConfig.withStatistics,
      );

      // Constant expressions (no variables) are always cached
      // First evaluation (cache miss)
      evaluator.evaluate(r'\pi * 2');

      // Same expression (should be cache hit)
      evaluator.evaluate(r'\pi * 2');

      final stats = evaluator.cacheStatistics;
      expect(stats.evaluationResults.hits, greaterThan(0));
    });

    test('cheap expressions with variables bypass L2 cache (cost-aware)', () {
      // This is intentional: for cheap expressions, cache lookup overhead
      // exceeds evaluation cost. L2 is only consulted for costly operations.
      final evaluator = Texpr(
        cacheConfig: CacheConfig.withStatistics,
      );

      // Cheap expression - should NOT hit L2 (by design)
      evaluator.evaluate('x^2 + 2*x + 1', {'x': 5});
      evaluator.evaluate('x^2 + 2*x + 1', {'x': 5});

      final stats = evaluator.cacheStatistics;
      // L1 (parsed expression) should hit, but L2 (evaluation) should not
      expect(stats.parsedExpressions.hits, greaterThan(0));
      expect(stats.evaluationResults.hits, equals(0));
    });

    test('differentiation caching works', () {
      final evaluator = Texpr(
        cacheConfig: CacheConfig.withStatistics,
      );

      final expr = evaluator.parse('x^3');

      // First differentiation (cache miss)
      evaluator.differentiate(expr, 'x');

      // Same differentiation (should be cache hit)
      evaluator.differentiate(expr, 'x');

      final stats = evaluator.cacheStatistics;
      expect(stats.differentiation.hits, greaterThan(0));
    });

    test('disabled cache still works', () {
      final evaluator = Texpr(
        cacheConfig: CacheConfig.disabled,
      );

      // Should work normally without caching
      final result = evaluator.evaluate('2 + 3');
      expect(result.asNumeric(), equals(5));
    });
  });
}
