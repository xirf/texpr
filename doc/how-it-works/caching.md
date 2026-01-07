# Caching

TeXpr uses a multi-layer caching system to avoid redundant computation. Understanding how caching works helps you write performant code.

## Why Caching Matters

Parsing and evaluating expressions has overhead. For a simple expression like `sin(x)`:
- Tokenization: ~0.5µs
- Parsing: ~1µs  
- Evaluation: ~0.5µs

For a single evaluation, this is trivial. But for 10,000 evaluations (e.g., plotting a function), this adds up to **20ms** of overhead — noticeable in interactive applications.

With caching:
- First evaluation: ~2µs (full pipeline)
- Subsequent evaluations: ~0.5µs (evaluation only)

This is a **4x speedup** for repeated operations.

---

## The Four Cache Layers

TeXpr maintains four specialized caches, each targeting different redundancy patterns:

```
┌─────────────────────────────────────────────────────────────┐
│                      Cache Architecture                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  L1: Parsed Expression Cache                                 │
│  ┌─────────────────────┐                                    │
│  │ String → AST        │  Avoids re-parsing same expression │
│  └─────────────────────┘                                    │
│                                                             │
│  L2: Evaluation Result Cache                                 │
│  ┌─────────────────────────────┐                            │
│  │ (AST, Variables) → Result  │  Avoids re-evaluating same  │
│  └─────────────────────────────┘  inputs                    │
│                                                             │
│  L3: Differentiation Cache                                   │
│  ┌─────────────────────────────────┐                        │
│  │ (AST, Variable, Order) → AST   │  Avoids re-computing     │
│  └─────────────────────────────────┘  derivatives           │
│                                                             │
│  L4: Sub-expression Cache                                    │
│  ┌─────────────────────────────┐                            │
│  │ Node → Intermediate Result │  Avoids redundant           │
│  └─────────────────────────────┘  sub-tree evaluation       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### L1: Parsed Expression Cache

**What it stores**: String → AST mapping

**When it helps**: When you call `evaluate()` with the same expression multiple times:

```dart
// Both calls use the same parsed AST from L1
evaluator.evaluate(r'\sin{x}', {'x': 0});
evaluator.evaluate(r'\sin{x}', {'x': 1});
```

**Default size**: 128 entries

### L2: Evaluation Result Cache

**What it stores**: (AST + Variable values) → Result

**When it helps**: When you evaluate the same expression with the same variable values:

```dart
// Second call returns cached result instantly
evaluator.evaluate(r'\sin{x} + \cos{x}', {'x': 0.5});
evaluator.evaluate(r'\sin{x} + \cos{x}', {'x': 0.5});  // Cache hit!
```

**Caveat**: Only expensive operations (integrals, sums, large matrices) use L2 cache. Simple arithmetic is too fast to benefit from cache overhead.

**Default size**: 256 entries

### L3: Differentiation Cache

**What it stores**: (AST, variable name, order) → Derivative AST

**When it helps**: When you differentiate the same expression multiple times:

```dart
// Second call returns cached derivative
evaluator.differentiate(r'x^3', 'x');
evaluator.differentiate(r'x^3', 'x');  // Cache hit!
```

**Default size**: 128 entries

### L4: Sub-expression Cache

**What it stores**: Node → Intermediate result (during single evaluation)

**When it helps**: When an expression has repeated sub-trees:

```dart
// sin(x) appears twice — evaluated once, cached for second use
evaluator.evaluate(r'\sin{x} + 2 * \sin{x}', {'x': 1});
```

**Lifetime**: Single evaluation only (cleared between calls)

---

## Cache Configuration

Configure caching via `CacheConfig`:

```dart
// High-performance configuration
final evaluator = Texpr(
  cacheConfig: CacheConfig(
    parsedExpressionCacheSize: 512,    // L1
    evaluationResultCacheSize: 1024,   // L2
    differentiationCacheSize: 256,     // L3
    evictionPolicy: EvictionPolicy.lru, // Least Recently Used
    ttl: Duration(minutes: 30),         // Time-to-live
    collectStatistics: true,            // Enable stats
  ),
);
```

### Preset Configurations

```dart
// Optimized for repeated evaluation (plotting, animation)
CacheConfig.highPerformance

// With statistics collection enabled
CacheConfig.withStatistics

// Minimal memory footprint
CacheConfig.minimal

// No caching at all
CacheConfig.disabled
```

### Configuration Options

| Option                      | Default | Description                               |
| --------------------------- | ------- | ----------------------------------------- |
| `parsedExpressionCacheSize` | 128     | Max L1 entries                            |
| `evaluationResultCacheSize` | 256     | Max L2 entries                            |
| `differentiationCacheSize`  | 128     | Max L3 entries                            |
| `evictionPolicy`            | LRU     | How to evict entries                      |
| `ttl`                       | null    | Time-to-live (null = infinite)            |
| `maxCacheInputLength`       | 1000    | Skip caching expressions longer than this |
| `collectStatistics`         | false   | Track hit/miss rates                      |

---

## Eviction Policies

When a cache reaches capacity, entries must be evicted:

### LRU (Least Recently Used)
Evicts the entry that hasn't been accessed for the longest time. Good for most workloads.

### LFU (Least Frequently Used)
Evicts the entry with the fewest accesses. Better when some expressions are "hot" (frequently used).

```dart
CacheConfig(evictionPolicy: EvictionPolicy.lru)  // Default
CacheConfig(evictionPolicy: EvictionPolicy.lfu)
```

---

## Cache Statistics

Enable statistics to monitor cache effectiveness:

```dart
final evaluator = Texpr(
  cacheConfig: CacheConfig.withStatistics,
);

// ... perform many evaluations ...

final stats = evaluator.cacheStatistics;
print('Overall hit rate: ${(stats.overallHitRate * 100).toFixed(1)}%');
print('L1 (parsed): ${stats.parsedExpressions.hits} hits, ${stats.parsedExpressions.misses} misses');
print('L2 (results): ${stats.evaluationResults.hits} hits, ${stats.evaluationResults.misses} misses');
```

A high hit rate (>80%) indicates caching is working well. A low hit rate suggests:
- Expressions aren't being repeated
- Variable values are always different
- Cache is too small for your workload

---

## Manual Cache Control

### Clearing Caches

```dart
// Clear only L1 (parsed expressions)
evaluator.clearParsedExpressionCache();

// Clear all caches
evaluator.clearAllCaches();
```

### Warming Up

Pre-populate the cache before time-critical operations:

```dart
// Before entering a tight loop
evaluator.warmUpCache([
  r'\sin{x}',
  r'\cos{x}',
  r'\sin{x}^2 + \cos{x}^2',
]);

// Now these expressions are pre-parsed
for (var x = 0.0; x < 100; x += 0.01) {
  evaluator.evaluate(r'\sin{x}', {'x': x});
}
```

---

## Best Practices

### 1. Use `evaluateParsed()` for Loops

The most effective optimization: parse once, evaluate many times.

```dart
// ✓ Good: Parse once
final ast = evaluator.parse(r'\sin{x} + \cos{x}');
for (var x = 0.0; x < 100; x += 0.01) {
  evaluator.evaluateParsed(ast, {'x': x});
}

// ✗ Less efficient: Relies on L1 cache
for (var x = 0.0; x < 100; x += 0.01) {
  evaluator.evaluate(r'\sin{x} + \cos{x}', {'x': x});
}
```

### 2. Reuse Variable Maps

Creating new Map objects for each evaluation bypasses L2 cache:

```dart
// ✓ Good: Reuse map
final vars = {'x': 0.0};
for (var i = 0; i < 1000; i++) {
  vars['x'] = i.toDouble();
  evaluator.evaluateParsed(ast, vars);
}

// ✗ Bad: New map each iteration
for (var i = 0; i < 1000; i++) {
  evaluator.evaluateParsed(ast, {'x': i.toDouble()});  // Always new Map
}
```

### 3. Size Caches for Your Workload

If you're evaluating 50 different expressions, a cache size of 128 is fine. If you're evaluating 500, increase it:

```dart
CacheConfig(parsedExpressionCacheSize: 512)
```

### 4. Use TTL for Long-Running Apps

In long-running applications, stale cache entries can consume memory:

```dart
CacheConfig(ttl: Duration(hours: 1))  // Expire after 1 hour
```

---

## When Caching Doesn't Help

Caching has overhead (~0.5µs per lookup). For very simple expressions, this overhead can exceed the saved computation:

- `2 + 3` — Evaluation is faster than cache lookup
- `x` — Just a variable lookup

L2 cache is smart about this: it only caches "costly" operations like integrals, sums, and large matrices.

---

## Thread Safety Warning

::: warning
TeXpr caches are **not thread-safe**. Each thread/isolate should have its own `Texpr` instance.
:::

```dart
// ✗ Don't share across isolates
final sharedEvaluator = Texpr();
Isolate.spawn((_) => sharedEvaluator.evaluate(...));  // Race condition!

// ✓ Create per-isolate
Isolate.spawn((_) {
  final localEvaluator = Texpr();
  localEvaluator.evaluate(...);
});
```

---

## Performance Benchmarks

Typical performance on modern hardware:

| Scenario                      | Without Caching | With Caching | Speedup |
| ----------------------------- | --------------- | ------------ | ------- |
| Simple expression, 10k evals  | 20ms            | 6ms          | 3.3x    |
| Complex expression, 10k evals | 50ms            | 8ms          | 6.2x    |
| Integral, 100 evals           | 150ms           | 15ms         | 10x     |
| Same variables, 10k evals     | 20ms            | 5ms          | 4x      |

Measured on MacBook Air M1. Actual performance depends on expression complexity and hardware.

---

## Summary

The caching system:
1. Uses four layers targeting different redundancy patterns
2. Is configurable (size, eviction policy, TTL)
3. Provides statistics for monitoring
4. Works best with explicit `parse()` + `evaluateParsed()` pattern
5. Is not thread-safe — use one instance per thread/isolate

For most applications, default settings work well. Tune cache sizes if you're evaluating many different expressions or need to minimize memory usage.
