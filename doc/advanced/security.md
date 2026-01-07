# Security

Security considerations for evaluating untrusted expressions.

## Resource Limits

TeXpr implements several limits to prevent denial of service.

### Recursion Depth

Prevents stack overflow from deeply nested expressions.

| Setting   | Default | Configurable                    |
| --------- | ------- | ------------------------------- |
| Max depth | 500     | `Texpr(maxRecursionDepth: ...)` |

### Iteration Limit

Prevents CPU pinning from large summations/products.

| Setting                      | Limit   |
| ---------------------------- | ------- |
| Max iterations per operation | 100,000 |

### Cache Size

Prevents memory exhaustion.

| Setting             | Default | Configurable                                  |
| ------------------- | ------- | --------------------------------------------- |
| Parse cache entries | 128     | `CacheConfig(parsedExpressionCacheSize: ...)` |
| Max cacheable input | 5KB     | `CacheConfig(maxCacheInputLength: ...)`       |

## Numeric Behavior

`Infinity` and `NaN` are valid IEEE-754 values, not security vulnerabilities. Handle them in your application:

```dart
final result = texpr.evaluateNumeric(r'1/0');  // double.infinity
if (result.isInfinite || result.isNaN) {
  // Handle appropriately
}
```

## Best Practices

1. **Limit recursion depth** — Lower to 100-200 for high-traffic applications
2. **Limit input length** — Reject expressions > 2,000-5,000 characters
3. **Catch exceptions** — Always wrap `evaluate()` in try-catch
4. **Handle infinity** — Check for `isInfinite` and `isNaN`

```dart
try {
  final result = texpr.evaluate(userInput);
  // Use result...
} on TexprException catch (e) {
  // Handle error
}
```

## Output Safety

- **JSON export** — Standard Dart map, safe for `jsonEncode`
- **MathML export** — Follow standard XSS prevention when embedding in HTML
