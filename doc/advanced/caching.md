# Caching

Performance optimization for repeated evaluations.

## Parse Once, Evaluate Many

For repeated evaluations (plotting, animations), parse the expression once:

```dart
final texpr = Texpr();
final ast = texpr.parse(r'\sin{x} + \cos{x}');

for (var x = 0.0; x < 100; x += 0.01) {
  texpr.evaluateParsed(ast, {'x': x});
}
```

### Performance Comparison

| Method             | Overhead | Use Case            |
| ------------------ | -------- | ------------------- |
| `evaluate()`       | High     | One-off evaluations |
| `evaluateParsed()` | Low      | Loops, animations   |

## Cache Configuration

```dart
final texpr = Texpr(
  cacheConfig: CacheConfig(
    parsedExpressionCacheSize: 256,
    evaluationResultCacheSize: 512,
  ),
);
```

### Options

| Option                      | Default | Description                    |
| --------------------------- | ------- | ------------------------------ |
| `parsedExpressionCacheSize` | 128     | Max cached ASTs                |
| `evaluationResultCacheSize` | 256     | Max cached results             |
| `maxCacheInputLength`       | 5120    | Max expression length to cache |

### Presets

```dart
// High performance for graphing
final texpr = Texpr(cacheConfig: CacheConfig.highPerformance);
```

## Cache Management

```dart
// Clear parsed expression cache
texpr.clearParsedExpressionCache();
```

Clear the cache when:
- Memory is constrained
- Extensions change dynamically
- Expression set changes completely
