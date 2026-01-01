import 'package:test/test.dart';
import 'package:texpr/src/cache/lfu_cache.dart';
import 'package:texpr/src/cache/cache_statistics.dart';

void main() {
  group('LfuCache', () {
    test('creates cache with specified maxSize', () {
      final cache = LfuCache<String, int>(maxSize: 5);
      expect(cache.maxSize, equals(5));
      expect(cache.length, equals(0));
      expect(cache.isEnabled, isTrue);
    });

    test('creates cache with negative maxSize (clamped to 0)', () {
      final cache = LfuCache<String, int>(maxSize: -10);
      expect(cache.maxSize, equals(0));
      expect(cache.isEnabled, isFalse);
    });

    test('creates cache with maxSize 0 (disabled)', () {
      final cache = LfuCache<String, int>(maxSize: 0);
      expect(cache.maxSize, equals(0));
      expect(cache.isEnabled, isFalse);
    });

    test('put and get values', () {
      final cache = LfuCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      expect(cache.get('a'), equals(1));
      expect(cache.get('b'), equals(2));
      expect(cache.get('c'), equals(3));
      expect(cache.length, equals(3));
    });

    test('get returns null for non-existent key', () {
      final cache = LfuCache<String, int>(maxSize: 3);
      expect(cache.get('nonexistent'), isNull);
    });

    test('containsKey returns correct results', () {
      final cache = LfuCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      expect(cache.containsKey('a'), isTrue);
      expect(cache.containsKey('b'), isFalse);
    });

    test('evicts least frequently used when exceeding maxSize', () {
      final cache = LfuCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      // Access 'a' and 'b' more frequently
      cache.get('a');
      cache.get('a');
      cache.get('b');

      // 'c' has lowest frequency (1), should be evicted
      cache.put('d', 4);

      expect(cache.get('c'), isNull);
      expect(cache.get('a'), equals(1));
      expect(cache.get('b'), equals(2));
      expect(cache.get('d'), equals(4));
    });

    test('get increases frequency', () {
      final cache = LfuCache<String, int>(maxSize: 2);

      cache.put('a', 1);
      cache.put('b', 2);

      // Access 'a' multiple times
      cache.get('a');
      cache.get('a');
      cache.get('a');

      // Add new item, should evict 'b' (lower frequency)
      cache.put('c', 3);

      expect(cache.get('a'), equals(1)); // Still present (high frequency)
      expect(cache.get('b'), isNull); // Evicted (low frequency)
      expect(cache.get('c'), equals(3));
    });

    test('put updates existing key and increases frequency', () {
      final cache = LfuCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      // Update 'a' to increase its frequency
      cache.put('a', 10);

      // Add new item, should evict 'b' or 'c' (lower frequency)
      cache.put('d', 4);

      expect(cache.get('a'), equals(10)); // Updated and not evicted
      expect(cache.length, equals(3));
    });

    test('clear removes all entries', () {
      final cache = LfuCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      expect(cache.length, equals(3));

      cache.clear();

      expect(cache.length, equals(0));
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), isNull);
      expect(cache.get('c'), isNull);
    });

    test('disabled cache ignores all puts', () {
      final cache = LfuCache<String, int>(maxSize: 0);

      cache.put('a', 1);
      cache.put('b', 2);

      expect(cache.length, equals(0));
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), isNull);
    });

    test('getOrPut returns cached value if exists', () {
      final cache = LfuCache<String, int>(maxSize: 3);
      cache.put('a', 1);

      var computeCalled = false;
      final result = cache.getOrPut('a', () {
        computeCalled = true;
        return 100;
      });

      expect(result, equals(1));
      expect(computeCalled, isFalse);
    });

    test('getOrPut computes and caches value if not exists', () {
      final cache = LfuCache<String, int>(maxSize: 3);

      var computeCalled = false;
      final result = cache.getOrPut('a', () {
        computeCalled = true;
        return 42;
      });

      expect(result, equals(42));
      expect(computeCalled, isTrue);
      expect(cache.get('a'), equals(42));
    });

    test('works with different key and value types', () {
      final cache = LfuCache<int, String>(maxSize: 3);

      cache.put(1, 'one');
      cache.put(2, 'two');
      cache.put(3, 'three');

      expect(cache.get(1), equals('one'));
      expect(cache.get(2), equals('two'));
      expect(cache.get(3), equals('three'));
    });

    test('records statistics when provided', () {
      final stats = CacheStatistics();
      final cache = LfuCache<String, int>(maxSize: 2, statistics: stats);

      cache.put('a', 1);
      cache.put('b', 2);
      expect(stats.size, equals(2));

      cache.get('a'); // Hit
      expect(stats.hits, equals(1));

      cache.get('nonexistent'); // Miss
      expect(stats.misses, equals(1));

      cache.put('c', 3); // Should evict
      expect(stats.evictions, equals(1));
    });

    test('changing maxSize triggers eviction', () {
      final cache = LfuCache<String, int>(maxSize: 5);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      cache.put('d', 4);
      cache.put('e', 5);

      expect(cache.length, equals(5));

      cache.maxSize = 3;

      expect(cache.maxSize, equals(3));
      expect(cache.length, equals(3));
    });
  });
}
