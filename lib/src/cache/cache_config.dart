/// Configuration for the caching system.
///
/// Provides fine-grained control over cache behavior including:
/// - Size limits for each cache layer
/// - Eviction policies (LRU, LFU)
/// - Optional TTL for cache entries
/// - Statistics collection
///
/// Example:
/// ```dart
/// final config = CacheConfig(
///   parsedExpressionCacheSize: 256,
///   evaluationResultCacheSize: 512,
///   evictionPolicy: EvictionPolicy.lru,
///   collectStatistics: true,
/// );
/// final evaluator = Texpr(cacheConfig: config);
/// ```
class CacheConfig {
  /// Maximum entries in parsed expression cache (L1).
  /// Set to 0 to disable.
  final int parsedExpressionCacheSize;

  /// Maximum entries in evaluation result cache (L2).
  /// Set to 0 to disable.
  final int evaluationResultCacheSize;

  /// Maximum entries in differentiation cache (L3).
  /// Set to 0 to disable.
  final int differentiationCacheSize;

  /// Maximum entries in sub-expression cache (L4).
  /// Set to 0 to disable.
  final int subExpressionCacheSize;

  /// Maximum input string length eligible for L1 caching.
  /// Expressions longer than this are parsed normally but not cached.
  /// This prevents memory exhaustion from caching large ASTs.
  /// Set to 0 to disable length-based filtering.
  final int maxCacheInputLength;

  /// Eviction policy for all caches.
  final EvictionPolicy evictionPolicy;

  /// Optional TTL for cache entries.
  /// If null, entries never expire based on time.
  final Duration? timeToLive;

  /// Enable/disable cache statistics collection.
  /// When enabled, hit rates and other metrics are tracked.
  final bool collectStatistics;

  /// Creates a cache configuration.
  ///
  /// All sizes default to reasonable values. Set a size to 0 to disable
  /// that cache layer.
  const CacheConfig({
    this.parsedExpressionCacheSize = 128,
    this.evaluationResultCacheSize = 256,
    this.differentiationCacheSize = 64,
    this.subExpressionCacheSize = 512,
    this.maxCacheInputLength = 5120, // 5KB default
    this.evictionPolicy = EvictionPolicy.lru,
    this.timeToLive,
    this.collectStatistics = false,
  });

  /// A configuration with caching disabled.
  static const CacheConfig disabled = CacheConfig(
    parsedExpressionCacheSize: 0,
    evaluationResultCacheSize: 0,
    differentiationCacheSize: 0,
    subExpressionCacheSize: 0,
    maxCacheInputLength: 0,
    collectStatistics: false,
  );

  /// A configuration optimized for high-frequency evaluation (like graphing).
  static const CacheConfig highPerformance = CacheConfig(
    parsedExpressionCacheSize: 512,
    evaluationResultCacheSize: 2048,
    differentiationCacheSize: 256,
    subExpressionCacheSize: 1024,
    collectStatistics: false,
  );

  /// A configuration with statistics enabled for debugging/tuning.
  static const CacheConfig withStatistics = CacheConfig(
    parsedExpressionCacheSize: 128,
    evaluationResultCacheSize: 256,
    differentiationCacheSize: 64,
    subExpressionCacheSize: 512,
    collectStatistics: true,
  );

  /// Creates a copy with modified values.
  CacheConfig copyWith({
    int? parsedExpressionCacheSize,
    int? evaluationResultCacheSize,
    int? differentiationCacheSize,
    int? subExpressionCacheSize,
    int? maxCacheInputLength,
    EvictionPolicy? evictionPolicy,
    Duration? timeToLive,
    bool? collectStatistics,
  }) {
    return CacheConfig(
      parsedExpressionCacheSize:
          parsedExpressionCacheSize ?? this.parsedExpressionCacheSize,
      evaluationResultCacheSize:
          evaluationResultCacheSize ?? this.evaluationResultCacheSize,
      differentiationCacheSize:
          differentiationCacheSize ?? this.differentiationCacheSize,
      subExpressionCacheSize:
          subExpressionCacheSize ?? this.subExpressionCacheSize,
      maxCacheInputLength: maxCacheInputLength ?? this.maxCacheInputLength,
      evictionPolicy: evictionPolicy ?? this.evictionPolicy,
      timeToLive: timeToLive ?? this.timeToLive,
      collectStatistics: collectStatistics ?? this.collectStatistics,
    );
  }
}

/// Eviction policy for cache entries when the cache is full.
enum EvictionPolicy {
  /// Least Recently Used - evicts entries that haven't been accessed recently.
  /// Good for general-purpose caching.
  lru,

  /// Least Frequently Used - evicts entries that are accessed least often.
  /// Better for hot-spot patterns where some expressions are used much more.
  lfu,
}
