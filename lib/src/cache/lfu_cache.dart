import 'dart:collection';

import 'cache_statistics.dart';

/// A Least Frequently Used (LFU) cache.
///
/// Evicts entries that are accessed less frequently when the cache is full.
/// This is better than LRU for patterns where some expressions are accessed
/// much more often than others (hot spots).
///
/// Example:
/// ```dart
/// final cache = LfuCache<String, int>(maxSize: 3);
/// cache.put('a', 1);
/// cache.put('b', 2);
/// cache.put('c', 3);
///
/// // Access 'a' multiple times
/// cache.get('a');
/// cache.get('a');
///
/// // Adding 'd' will evict 'b' or 'c' (lowest frequency), not 'a'
/// cache.put('d', 4);
/// ```
class LfuCache<K, V> {
  final LinkedHashMap<K, _LfuEntry<V>> _map = LinkedHashMap<K, _LfuEntry<V>>();
  final SplayTreeMap<int, LinkedHashSet<K>> _frequencyBuckets =
      SplayTreeMap<int, LinkedHashSet<K>>();

  int _maxSize;
  int _minFrequency = 0;

  /// Optional statistics collector.
  final CacheStatistics? statistics;

  /// Creates an LFU cache with a maximum number of entries.
  ///
  /// If [maxSize] is 0, the cache is effectively disabled.
  LfuCache({required int maxSize, this.statistics})
      : _maxSize = maxSize < 0 ? 0 : maxSize;

  /// Current maximum size of the cache.
  int get maxSize => _maxSize;

  /// Sets a new maximum size, evicting entries if necessary.
  set maxSize(int value) {
    _maxSize = value < 0 ? 0 : value;
    _trimToSize();
  }

  /// Current number of entries in the cache.
  int get length => _map.length;

  /// Whether the cache is enabled (maxSize > 0).
  bool get isEnabled => _maxSize > 0;

  /// Clears all entries from the cache.
  void clear() {
    _map.clear();
    _frequencyBuckets.clear();
    _minFrequency = 0;
    statistics?.updateSize(0);
  }

  /// Checks if the cache contains the given key.
  bool containsKey(K key) => _map.containsKey(key);

  /// Gets a value from the cache, or null if not found.
  ///
  /// Accessing a value increases its frequency count.
  V? get(K key) {
    final entry = _map[key];
    if (entry == null) {
      statistics?.recordMiss();
      return null;
    }
    statistics?.recordHit();
    _incrementFrequency(key, entry);
    return entry.value;
  }

  /// Stores a value in the cache.
  ///
  /// If the cache is full, evicts the least frequently used entry.
  void put(K key, V value) {
    if (!isEnabled) return;

    final existing = _map[key];
    if (existing != null) {
      // Update existing entry
      existing.value = value;
      _incrementFrequency(key, existing);
      return;
    }

    // Evict if at capacity (before adding new entry)
    if (_map.length >= _maxSize) {
      _evictLeastFrequent();
    }

    // New entry
    final entry = _LfuEntry<V>(value, 1);
    _map[key] = entry;
    _addToFrequencyBucket(key, 1);
    _minFrequency = 1;

    statistics?.updateSize(_map.length);
  }

  /// Gets a value, or computes and caches it if not present.
  V getOrPut(K key, V Function() compute) {
    final existing = get(key);
    if (existing != null) return existing;

    final value = compute();
    put(key, value);
    return value;
  }

  void _incrementFrequency(K key, _LfuEntry<V> entry) {
    final oldFreq = entry.frequency;
    final newFreq = oldFreq + 1;
    entry.frequency = newFreq;

    // Remove from old frequency bucket
    _removeFromFrequencyBucket(key, oldFreq);

    // Add to new frequency bucket
    _addToFrequencyBucket(key, newFreq);

    // Update min frequency if needed
    if (_minFrequency == oldFreq &&
        _frequencyBuckets[oldFreq]?.isEmpty != false) {
      _minFrequency = newFreq;
    }
  }

  void _addToFrequencyBucket(K key, int frequency) {
    _frequencyBuckets.putIfAbsent(frequency, () => LinkedHashSet<K>()).add(key);
  }

  void _removeFromFrequencyBucket(K key, int frequency) {
    final bucket = _frequencyBuckets[frequency];
    if (bucket != null) {
      bucket.remove(key);
      if (bucket.isEmpty) {
        _frequencyBuckets.remove(frequency);
      }
    }
  }

  /// Trims cache to maxSize when maxSize is reduced.
  void _trimToSize() {
    if (!isEnabled) {
      _map.clear();
      _frequencyBuckets.clear();
      return;
    }

    while (_map.length > _maxSize) {
      _evictLeastFrequent();
    }
  }

  void _evictLeastFrequent() {
    if (_map.isEmpty) return;

    final bucket = _frequencyBuckets[_minFrequency];
    if (bucket == null || bucket.isEmpty) {
      // Find next non-empty bucket
      for (final entry in _frequencyBuckets.entries) {
        if (entry.value.isNotEmpty) {
          _minFrequency = entry.key;
          _evictFromBucket(entry.value);
          return;
        }
      }
      return;
    }

    _evictFromBucket(bucket);
  }

  void _evictFromBucket(LinkedHashSet<K> bucket) {
    final keyToEvict = bucket.first;
    bucket.remove(keyToEvict);
    _map.remove(keyToEvict);

    if (bucket.isEmpty) {
      _frequencyBuckets.remove(_minFrequency);
    }

    statistics?.recordEviction();
    statistics?.updateSize(_map.length);
  }
}

/// Internal entry for LFU cache tracking value and frequency.
class _LfuEntry<V> {
  V value;
  int frequency;

  _LfuEntry(this.value, this.frequency);
}
