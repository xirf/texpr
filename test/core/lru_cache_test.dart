import 'package:test/test.dart';
import 'package:texpr/src/cache/lru_cache.dart';

void main() {
  group('LruCache', () {
    test('creates cache with specified maxSize', () {
      final cache = LruCache<String, int>(maxSize: 5);
      expect(cache.maxSize, equals(5));
      expect(cache.length, equals(0));
      expect(cache.isEnabled, isTrue);
    });

    test('creates cache with negative maxSize (clamped to 0)', () {
      final cache = LruCache<String, int>(maxSize: -10);
      expect(cache.maxSize, equals(0));
      expect(cache.isEnabled, isFalse);
    });

    test('creates cache with maxSize 0 (disabled)', () {
      final cache = LruCache<String, int>(maxSize: 0);
      expect(cache.maxSize, equals(0));
      expect(cache.isEnabled, isFalse);
    });

    test('put and get values', () {
      final cache = LruCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      expect(cache.get('a'), equals(1));
      expect(cache.get('b'), equals(2));
      expect(cache.get('c'), equals(3));
      expect(cache.length, equals(3));
    });

    test('get returns null for non-existent key', () {
      final cache = LruCache<String, int>(maxSize: 3);
      expect(cache.get('nonexistent'), isNull);
    });

    test('containsKey returns correct results', () {
      final cache = LruCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      expect(cache.containsKey('a'), isTrue);
      expect(cache.containsKey('b'), isFalse);
    });

    test('evicts least recently used when exceeding maxSize', () {
      final cache = LruCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      cache.put('d', 4); // Should evict 'a'

      expect(cache.get('a'), isNull);
      expect(cache.get('b'), equals(2));
      expect(cache.get('c'), equals(3));
      expect(cache.get('d'), equals(4));
      expect(cache.length, equals(3));
    });

    test('get updates access order (makes item most recently used)', () {
      final cache = LruCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      // Access 'a' to make it most recently used
      cache.get('a');

      // Add new item, should evict 'b' (least recently used)
      cache.put('d', 4);

      expect(cache.get('a'), equals(1));
      expect(cache.get('b'), isNull);
      expect(cache.get('c'), equals(3));
      expect(cache.get('d'), equals(4));
    });

    test('put updates existing key and marks as most recently used', () {
      final cache = LruCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);

      // Update 'a' to make it most recently used
      cache.put('a', 10);

      // Add new item, should evict 'b' (least recently used)
      cache.put('d', 4);

      expect(cache.get('a'), equals(10));
      expect(cache.get('b'), isNull);
      expect(cache.get('c'), equals(3));
      expect(cache.get('d'), equals(4));
    });

    test('clear removes all entries', () {
      final cache = LruCache<String, int>(maxSize: 3);

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
      final cache = LruCache<String, int>(maxSize: 0);

      cache.put('a', 1);
      cache.put('b', 2);

      expect(cache.length, equals(0));
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), isNull);
    });

    test('changing maxSize triggers eviction', () {
      final cache = LruCache<String, int>(maxSize: 5);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      cache.put('d', 4);
      cache.put('e', 5);

      expect(cache.length, equals(5));

      // Reduce maxSize
      cache.maxSize = 3;

      expect(cache.maxSize, equals(3));
      expect(cache.length, equals(3));

      // 'a' and 'b' should be evicted (least recently used)
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), isNull);
      expect(cache.get('c'), equals(3));
      expect(cache.get('d'), equals(4));
      expect(cache.get('e'), equals(5));
    });

    test('setting maxSize to negative value clamps to 0', () {
      final cache = LruCache<String, int>(maxSize: 5);

      cache.put('a', 1);
      cache.put('b', 2);

      expect(cache.length, equals(2));

      cache.maxSize = -10;

      expect(cache.maxSize, equals(0));
      expect(cache.isEnabled, isFalse);
      expect(cache.length, equals(0)); // All entries cleared
    });

    test('setting maxSize to 0 disables cache and clears entries', () {
      final cache = LruCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);

      expect(cache.length, equals(2));
      expect(cache.isEnabled, isTrue);

      cache.maxSize = 0;

      expect(cache.maxSize, equals(0));
      expect(cache.isEnabled, isFalse);
      expect(cache.length, equals(0));
    });

    test('increasing maxSize allows more entries', () {
      final cache = LruCache<String, int>(maxSize: 2);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3); // Should evict 'a'

      expect(cache.get('a'), isNull);
      expect(cache.length, equals(2));

      cache.maxSize = 5;

      cache.put('d', 4);
      cache.put('e', 5);
      cache.put('f', 6);

      expect(cache.length, equals(5));
      expect(cache.get('b'), equals(2));
      expect(cache.get('c'), equals(3));
      expect(cache.get('d'), equals(4));
      expect(cache.get('e'), equals(5));
      expect(cache.get('f'), equals(6));
    });

    test('works with different key and value types', () {
      final cache = LruCache<int, String>(maxSize: 3);

      cache.put(1, 'one');
      cache.put(2, 'two');
      cache.put(3, 'three');

      expect(cache.get(1), equals('one'));
      expect(cache.get(2), equals('two'));
      expect(cache.get(3), equals('three'));
    });

    test('handles complex value types', () {
      final cache = LruCache<String, List<int>>(maxSize: 2);

      cache.put('a', [1, 2, 3]);
      cache.put('b', [4, 5, 6]);

      expect(cache.get('a'), equals([1, 2, 3]));
      expect(cache.get('b'), equals([4, 5, 6]));
    });

    test('multiple evictions when adding single item', () {
      final cache = LruCache<String, int>(maxSize: 3);

      cache.put('a', 1);
      cache.put('b', 2);
      cache.put('c', 3);
      cache.put('d', 4);
      cache.put('e', 5);

      // Should only have the last 3 entries
      expect(cache.length, equals(3));
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), isNull);
      expect(cache.get('c'), equals(3));
      expect(cache.get('d'), equals(4));
      expect(cache.get('e'), equals(5));
    });

    test('setting maxSize to 1 works correctly', () {
      final cache = LruCache<String, int>(maxSize: 1);

      cache.put('a', 1);
      expect(cache.get('a'), equals(1));
      expect(cache.length, equals(1));

      cache.put('b', 2);
      expect(cache.get('a'), isNull);
      expect(cache.get('b'), equals(2));
      expect(cache.length, equals(1));
    });
  });
}
