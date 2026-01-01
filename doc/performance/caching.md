# Caching and Performance

This page explains the caching system for parsed expressions, evaluation results, and other cached computations.

## Multi-Layer Cache Architecture

The evaluator uses a 4-layer caching system for improved performance:

| Layer | Name               | Key                    | Value          | Use Case                             |
| ----- | ------------------ | ---------------------- | -------------- | ------------------------------------ |
| L1    | Parsed Expressions | LaTeX string           | AST            | Avoid re-parsing same expressions    |
| L2    | Evaluation Results | AST + Variables        | Result         | Avoid re-evaluating with same inputs |
| L3    | Differentiation    | AST + Variable + Order | Derivative AST | Cache symbolic derivatives           |
| L4    | Sub-expressions    | Expression hash        | Numeric result | Cache shared sub-computations        |

### Cost-Aware L2 Caching

L2 evaluation cache is **only consulted for computationally expensive operations**:
- Integrals (Simpson's rule: ~10,000 iterations)
- Summations and products with bounds
- Limits
- Large matrices (>4 rows)
- Constant expressions (no variables)

For cheap expressions like `x^2 + 1`, the overhead of cache key creation would exceed evaluation time, so L2 is bypassed entirely.

### Identity-Based Keys

L2 uses **identity-based cache keys** for performance. This means cache hits occur when the **same Map instance** is reused:

```dart
final vars = {'x': 5.0};

// These are cache hits (same vars instance)
evaluator.evaluateParsed(ast, vars);
evaluator.evaluateParsed(ast, vars);

// This is a cache miss (new Map instance)
evaluator.evaluateParsed(ast, {'x': 5.0});
```

> [!IMPORTANT]
> **AST Immutability Invariant:** Identity-based caching requires ASTs to be immutable after parsing. All Expression nodes are frozen once constructed. Do not modify AST fields after creation.

## Cache Configuration

### Default Configuration

```dart
// Default: default cache sizes, LRU eviction, no statistics
final evaluator = LatexMathEvaluator();
```

### Custom Configuration

```dart
final config = CacheConfig(
  parsedExpressionCacheSize: 256,   // L1 size
  evaluationResultCacheSize: 512,   // L2 size
  differentiationCacheSize: 128,    // L3 size
  subExpressionCacheSize: 1024,     // L4 size
  evictionPolicy: EvictionPolicy.lru,
  timeToLive: Duration(minutes: 30), // Optional TTL
  collectStatistics: true,           // Enable stats
);

final evaluator = LatexMathEvaluator(cacheConfig: config);
```

### Preset Configurations

```dart
// Disable all caching
final noCache = LatexMathEvaluator(cacheConfig: CacheConfig.disabled);

// High-performance for graphing/animations
final graphing = LatexMathEvaluator(cacheConfig: CacheConfig.highPerformance);

// With statistics for debugging
final withStats = LatexMathEvaluator(cacheConfig: CacheConfig.withStatistics);
```

## Eviction Policies

### LRU (Least Recently Used)

- Default policy
- Evicts entries that haven't been accessed recently
- Good for general-purpose caching

### LFU (Least Frequently Used)

- Evicts entries accessed least often
- Better for hot-spot patterns where some expressions are used much more
- Useful for computation-heavy expressions that are reused

```dart
final config = CacheConfig(
  evictionPolicy: EvictionPolicy.lfu,
);
```

## Cache Statistics

Monitor cache performance for tuning:

```dart
final evaluator = LatexMathEvaluator(
  cacheConfig: CacheConfig.withStatistics,
);

// Perform many evaluations...
for (var i = 0; i < 1000; i++) {
  evaluator.evaluate('x^2 + 2*x + 1', {'x': i.toDouble()});
}

final stats = evaluator.cacheStatistics;
print('Overall hit rate: ${(stats.overallHitRate * 100).toStringAsFixed(1)}%');
print('Parsed expression hits: ${stats.parsedExpressions.hits}');
print('Evaluation result hits: ${stats.evaluationResults.hits}');

// Layer-by-layer analysis
print(stats.parsedExpressions);  // Hit/miss for parsing
print(stats.evaluationResults);   // Hit/miss for evaluation
print(stats.differentiation);     // Hit/miss for differentiation
```

## Cache Warming

Preload frequently-used expressions:

```dart
final evaluator = LatexMathEvaluator();

// Warm up cache with common expressions
evaluator.warmUpCache([
  'x^2',
  'sin(x)',
  'cos(x)',
  'e^x',
  'ln(x)',
  'x^2 + y^2',
]);

// Subsequent evaluations will have L1 cache hits
evaluator.evaluate('sin(x)', {'x': 0}); // Cache hit!
```

## Cache Invalidation

### Clear Specific Layer

```dart
// Clear only parsed expression cache (when extensions change)
evaluator.clearParsedExpressionCache();
```

### Clear All Caches

```dart
// Clear everything
evaluator.clearAllCaches();
```

### TTL-Based Invalidation

```dart
final config = CacheConfig(
  timeToLive: Duration(minutes: 10), // Entries expire after 10 minutes
);
```

## Memoized Math Functions

Several functions use internal memoization independent of the cache system:

- `\factorial{n}` caches results up to n=170
- `\fibonacci{n}` caches computed values dynamically

## Best Practices

1. **For Graphing Applications**: Use `CacheConfig.highPerformance` with larger L2 cache
2. **For One-Shot Calculations**: Default config or disabled cache
3. **For Long-Running Apps**: Consider TTL to prevent memory growth
4. **For Debugging Performance**: Enable statistics with `CacheConfig.withStatistics`
5. **After Changing Extensions**: Call `clearParsedExpressionCache()` to avoid stale parses

## Running the Benchmarks

```bash
dart run benchmark/expression_cache_benchmark.dart
```

Sample output with caching enabled:

```
Benchmark: repeated evaluate() calls (with and without parsed-expression caching)
Without cache: 19 ms; avg 0.0095 ms/op
With cache: 5 ms; avg 0.0025 ms/op

Benchmark: parsed parse() + evaluateParsed (with cache) vs reparse on each evaluate
evaluateParsed (no parse every time): 3 ms; avg 0.0015 ms/op
evaluate (parse every time): 7 ms; avg 0.0035 ms/op
```

## Performance Tips

1. **Parse Once, Evaluate Many**: For expressions evaluated with different variables, use `parse()` + `evaluateParsed()`
2. **Enable L2 Cache**: When evaluating the same expression with the same variables repeatedly
3. **Use LFU for Hot Spots**: If some expressions are accessed much more than others
4. **Monitor Hit Rates**: Use statistics to tune cache sizes for your use case
5. **Tune Cache Sizes**: Larger caches = more memory but better hit rates
