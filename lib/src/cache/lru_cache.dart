import 'dart:collection';

import 'cache_statistics.dart';

/// A small, dependency-free LRU cache.
///
/// Uses [LinkedHashMap] iteration order as access order by removing and
/// reinserting on reads/writes.
///
/// Supports optional:
/// - Statistics tracking for monitoring cache performance
/// - Time-to-live (TTL) for automatic entry expiration
///
/// Example:
/// ```dart
/// final cache = LruCache<String, int>(maxSize: 100);
/// cache.put('answer', 42);
/// print(cache.get('answer')); // 42
///
/// // With statistics
/// final stats = CacheStatistics();
/// final trackedCache = LruCache<String, int>(maxSize: 100, statistics: stats);
/// print(stats.hitRate); // Track hit rate
/// ```
class LruCache<K, V> {
  final LinkedHashMap<K, _LruEntry<V>> _map = LinkedHashMap<K, _LruEntry<V>>();

  int _maxSize;

  /// Optional statistics collector.
  final CacheStatistics? statistics;

  /// Optional time-to-live for cache entries.
  final Duration? timeToLive;

  /// Creates an LRU cache with a maximum number of entries.
  ///
  /// If [maxSize] is 0, the cache is effectively disabled (all puts are ignored).
  /// If [timeToLive] is provided, entries expire after that duration.
  /// If [statistics] is provided, cache hits/misses are tracked.
  LruCache({
    required int maxSize,
    this.statistics,
    this.timeToLive,
  }) : _maxSize = maxSize < 0 ? 0 : maxSize;

  int get maxSize => _maxSize;

  set maxSize(int value) {
    _maxSize = value < 0 ? 0 : value;
    _evictIfNeeded();
  }

  int get length => _map.length;

  bool get isEnabled => _maxSize > 0;

  void clear() {
    _map.clear();
    statistics?.updateSize(0);
  }

  bool containsKey(K key) {
    final entry = _map[key];
    if (entry == null) return false;
    if (_isExpired(entry)) {
      _map.remove(key);
      statistics?.updateSize(_map.length);
      return false;
    }
    return true;
  }

  V? get(K key) {
    final entry = _map.remove(key);
    if (entry == null) {
      statistics?.recordMiss();
      return null;
    }

    // Check TTL
    if (_isExpired(entry)) {
      statistics?.recordMiss();
      statistics?.updateSize(_map.length);
      return null;
    }

    // Reinsert to mark as most recently used.
    _map[key] = entry;
    statistics?.recordHit();
    return entry.value;
  }

  void put(K key, V value) {
    if (!isEnabled) return;
    // Replace while marking MRU.
    _map.remove(key);
    _map[key] = _LruEntry(value, timeToLive != null ? DateTime.now() : null);
    _evictIfNeeded();
    statistics?.updateSize(_map.length);
  }

  /// Gets a value, or computes and caches it if not present.
  ///
  /// This is an atomic operation that avoids race conditions in the
  /// check-then-compute-then-store pattern.
  V getOrPut(K key, V Function() compute) {
    final existing = get(key);
    if (existing != null) return existing;

    final value = compute();
    put(key, value);
    return value;
  }

  /// Removes expired entries from the cache.
  ///
  /// This is called automatically during get/put operations,
  /// but can be called manually for proactive cleanup.
  void removeExpired() {
    if (timeToLive == null) return;

    final keysToRemove = <K>[];
    for (final entry in _map.entries) {
      if (_isExpired(entry.value)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _map.remove(key);
      statistics?.recordEviction();
    }

    statistics?.updateSize(_map.length);
  }

  bool _isExpired(_LruEntry<V> entry) {
    if (timeToLive == null || entry.createdAt == null) return false;
    return DateTime.now().difference(entry.createdAt!) > timeToLive!;
  }

  void _evictIfNeeded() {
    if (!isEnabled) {
      _map.clear();
      statistics?.updateSize(0);
      return;
    }
    while (_map.length > _maxSize) {
      _map.remove(_map.keys.first);
      statistics?.recordEviction();
    }
    statistics?.updateSize(_map.length);
  }
}

/// Internal entry for LRU cache with optional creation timestamp.
class _LruEntry<V> {
  final V value;
  final DateTime? createdAt;

  _LruEntry(this.value, this.createdAt);
}
