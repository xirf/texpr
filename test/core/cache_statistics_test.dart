import 'package:test/test.dart';
import 'package:texpr/src/cache/cache_statistics.dart';

void main() {
  group('CacheStatistics', () {
    test('initializes with zero values', () {
      final stats = CacheStatistics();
      expect(stats.hits, equals(0));
      expect(stats.misses, equals(0));
      expect(stats.evictions, equals(0));
      expect(stats.size, equals(0));
      expect(stats.totalAccesses, equals(0));
      expect(stats.hitRate, equals(0.0));
    });

    test('recordHit increments hits', () {
      final stats = CacheStatistics();
      stats.recordHit();
      stats.recordHit();
      expect(stats.hits, equals(2));
    });

    test('recordMiss increments misses', () {
      final stats = CacheStatistics();
      stats.recordMiss();
      stats.recordMiss();
      stats.recordMiss();
      expect(stats.misses, equals(3));
    });

    test('recordEviction increments evictions', () {
      final stats = CacheStatistics();
      stats.recordEviction();
      expect(stats.evictions, equals(1));
    });

    test('updateSize sets current size', () {
      final stats = CacheStatistics();
      stats.updateSize(42);
      expect(stats.size, equals(42));
    });

    test('totalAccesses returns sum of hits and misses', () {
      final stats = CacheStatistics();
      stats.recordHit();
      stats.recordHit();
      stats.recordMiss();
      expect(stats.totalAccesses, equals(3));
    });

    test('hitRate calculates correctly', () {
      final stats = CacheStatistics();
      stats.recordHit();
      stats.recordHit();
      stats.recordHit();
      stats.recordMiss();
      expect(stats.hitRate, equals(0.75));
    });

    test('hitRate is 0 when no accesses', () {
      final stats = CacheStatistics();
      expect(stats.hitRate, equals(0.0));
    });

    test('missRate is complement of hitRate', () {
      final stats = CacheStatistics();
      stats.recordHit();
      stats.recordMiss();
      expect(stats.hitRate + stats.missRate, equals(1.0));
    });

    test('reset clears all values', () {
      final stats = CacheStatistics();
      stats.recordHit();
      stats.recordMiss();
      stats.recordEviction();
      stats.updateSize(10);

      stats.reset();

      expect(stats.hits, equals(0));
      expect(stats.misses, equals(0));
      expect(stats.evictions, equals(0));
      expect(stats.size, equals(0));
    });

    test('merge combines statistics', () {
      final stats1 = CacheStatistics();
      stats1.recordHit();
      stats1.recordHit();
      stats1.recordMiss();

      final stats2 = CacheStatistics();
      stats2.recordHit();
      stats2.recordMiss();
      stats2.recordMiss();

      stats1.merge(stats2);

      expect(stats1.hits, equals(3));
      expect(stats1.misses, equals(3));
    });

    test('snapshot creates independent copy', () {
      final stats = CacheStatistics();
      stats.recordHit();
      stats.recordMiss();

      final snapshot = stats.snapshot();

      stats.recordHit();
      stats.recordHit();

      expect(snapshot.hits, equals(1));
      expect(stats.hits, equals(3));
    });

    test('toJson returns correct structure', () {
      final stats = CacheStatistics();
      stats.recordHit();
      stats.recordMiss();
      stats.recordEviction();
      stats.updateSize(5);

      final json = stats.toJson();

      expect(json['hits'], equals(1));
      expect(json['misses'], equals(1));
      expect(json['evictions'], equals(1));
      expect(json['size'], equals(5));
      expect(json['totalAccesses'], equals(2));
      expect(json['hitRate'], equals(0.5));
    });

    test('toString returns readable format', () {
      final stats = CacheStatistics();
      stats.recordHit();
      stats.recordMiss();

      final str = stats.toString();

      expect(str, contains('hits: 1'));
      expect(str, contains('misses: 1'));
      expect(str, contains('hitRate: 50.0%'));
    });
  });

  group('MultiLayerCacheStatistics', () {
    test('initializes with empty statistics', () {
      final stats = MultiLayerCacheStatistics();
      expect(stats.parsedExpressions.hits, equals(0));
      expect(stats.evaluationResults.hits, equals(0));
      expect(stats.differentiation.hits, equals(0));
      expect(stats.subExpressions.hits, equals(0));
    });

    test('totalHits sums all layers', () {
      final stats = MultiLayerCacheStatistics();
      stats.parsedExpressions.recordHit();
      stats.parsedExpressions.recordHit();
      stats.evaluationResults.recordHit();
      stats.differentiation.recordHit();
      stats.subExpressions.recordHit();

      expect(stats.totalHits, equals(5));
    });

    test('totalMisses sums all layers', () {
      final stats = MultiLayerCacheStatistics();
      stats.parsedExpressions.recordMiss();
      stats.evaluationResults.recordMiss();
      stats.differentiation.recordMiss();

      expect(stats.totalMisses, equals(3));
    });

    test('overallHitRate calculates correctly', () {
      final stats = MultiLayerCacheStatistics();
      stats.parsedExpressions.recordHit();
      stats.parsedExpressions.recordHit();
      stats.evaluationResults.recordMiss();
      stats.differentiation.recordMiss();

      expect(stats.overallHitRate, equals(0.5));
    });

    test('overallHitRate is 0 when no accesses', () {
      final stats = MultiLayerCacheStatistics();
      expect(stats.overallHitRate, equals(0.0));
    });

    test('reset clears all layers', () {
      final stats = MultiLayerCacheStatistics();
      stats.parsedExpressions.recordHit();
      stats.evaluationResults.recordMiss();

      stats.reset();

      expect(stats.parsedExpressions.hits, equals(0));
      expect(stats.evaluationResults.misses, equals(0));
    });

    test('toJson returns correct structure', () {
      final stats = MultiLayerCacheStatistics();
      stats.parsedExpressions.recordHit();

      final json = stats.toJson();

      expect(json, containsPair('parsedExpressions', isA<Map>()));
      expect(json, containsPair('evaluationResults', isA<Map>()));
      expect(json, containsPair('differentiation', isA<Map>()));
      expect(json, containsPair('subExpressions', isA<Map>()));
      expect(json, containsPair('overallHitRate', isA<double>()));
    });
  });
}
