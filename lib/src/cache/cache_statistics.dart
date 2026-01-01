/// Tracks cache performance metrics for monitoring and tuning.
///
/// Use this to understand cache effectiveness and adjust configuration.
///
/// Example:
/// ```dart
/// final evaluator = LatexMathEvaluator(
///   cacheConfig: CacheConfig.withStatistics,
/// );
///
/// // After some evaluations...
/// final stats = evaluator.cacheStatistics;
/// print('Hit rate: ${(stats.hitRate * 100).toStringAsFixed(1)}%');
/// print('Total accesses: ${stats.totalAccesses}');
/// ```
class CacheStatistics {
  int _hits = 0;
  int _misses = 0;
  int _evictions = 0;
  int _size = 0;

  /// Number of cache hits (successful lookups).
  int get hits => _hits;

  /// Number of cache misses (failed lookups requiring computation).
  int get misses => _misses;

  /// Number of entries evicted due to size limits.
  int get evictions => _evictions;

  /// Current number of entries in the cache.
  int get size => _size;

  /// Total number of cache accesses (hits + misses).
  int get totalAccesses => _hits + _misses;

  /// Cache hit rate as a value between 0.0 and 1.0.
  /// Returns 0.0 if no accesses have been made.
  double get hitRate {
    final total = totalAccesses;
    return total == 0 ? 0.0 : _hits / total;
  }

  /// Cache miss rate as a value between 0.0 and 1.0.
  double get missRate => 1.0 - hitRate;

  /// Records a cache hit.
  void recordHit() => _hits++;

  /// Records a cache miss.
  void recordMiss() => _misses++;

  /// Records an eviction event.
  void recordEviction() => _evictions++;

  /// Updates the current cache size.
  void updateSize(int newSize) => _size = newSize;

  /// Resets all statistics to zero.
  void reset() {
    _hits = 0;
    _misses = 0;
    _evictions = 0;
    _size = 0;
  }

  /// Merges statistics from another instance.
  void merge(CacheStatistics other) {
    _hits += other._hits;
    _misses += other._misses;
    _evictions += other._evictions;
  }

  /// Creates a snapshot copy of the current statistics.
  CacheStatistics snapshot() {
    return CacheStatistics()
      .._hits = _hits
      .._misses = _misses
      .._evictions = _evictions
      .._size = _size;
  }

  /// Converts statistics to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'hits': _hits,
        'misses': _misses,
        'evictions': _evictions,
        'size': _size,
        'totalAccesses': totalAccesses,
        'hitRate': hitRate,
      };

  @override
  String toString() =>
      'CacheStatistics(hits: $_hits, misses: $_misses, hitRate: ${(hitRate * 100).toStringAsFixed(1)}%, size: $_size)';
}

/// Combined statistics for all cache layers.
class MultiLayerCacheStatistics {
  /// Statistics for parsed expression cache (L1).
  final CacheStatistics parsedExpressions;

  /// Statistics for evaluation result cache (L2).
  final CacheStatistics evaluationResults;

  /// Statistics for differentiation cache (L3).
  final CacheStatistics differentiation;

  /// Statistics for sub-expression cache (L4).
  final CacheStatistics subExpressions;

  MultiLayerCacheStatistics({
    CacheStatistics? parsedExpressions,
    CacheStatistics? evaluationResults,
    CacheStatistics? differentiation,
    CacheStatistics? subExpressions,
  })  : parsedExpressions = parsedExpressions ?? CacheStatistics(),
        evaluationResults = evaluationResults ?? CacheStatistics(),
        differentiation = differentiation ?? CacheStatistics(),
        subExpressions = subExpressions ?? CacheStatistics();

  /// Total hits across all layers.
  int get totalHits =>
      parsedExpressions.hits +
      evaluationResults.hits +
      differentiation.hits +
      subExpressions.hits;

  /// Total misses across all layers.
  int get totalMisses =>
      parsedExpressions.misses +
      evaluationResults.misses +
      differentiation.misses +
      subExpressions.misses;

  /// Overall hit rate across all layers.
  double get overallHitRate {
    final total = totalHits + totalMisses;
    return total == 0 ? 0.0 : totalHits / total;
  }

  /// Resets all layer statistics.
  void reset() {
    parsedExpressions.reset();
    evaluationResults.reset();
    differentiation.reset();
    subExpressions.reset();
  }

  /// Converts all statistics to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'parsedExpressions': parsedExpressions.toJson(),
        'evaluationResults': evaluationResults.toJson(),
        'differentiation': differentiation.toJson(),
        'subExpressions': subExpressions.toJson(),
        'overallHitRate': overallHitRate,
      };

  @override
  String toString() => '''MultiLayerCacheStatistics(
  parsedExpressions: $parsedExpressions,
  evaluationResults: $evaluationResults,
  differentiation: $differentiation,
  subExpressions: $subExpressions,
  overallHitRate: ${(overallHitRate * 100).toStringAsFixed(1)}%
)''';
}
