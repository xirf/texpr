# Core API

## Texpr

The `Texpr` class is the primary interface for using the library. It handles tokenizing, parsing, and evaluating LaTeX math expressions.

### Constructors

- `Texpr({ExtensionRegistry? extensions, bool allowImplicitMultiplication = true, CacheConfig? cacheConfig, int maxRecursionDepth = 500})`
  - Creates a new evaluator instance.
  - `extensions`: Optional registry for custom commands and functions.
  - `allowImplicitMultiplication`: If true, `xy` is treated as `x * y`.
  - `cacheConfig`: Advanced cache configuration (size, eviction policy, TTL).
  - `maxRecursionDepth`: Maximum recursion depth for parsing and evaluation (default: 500).

### Methods

#### `evaluate`

```dart
EvaluationResult evaluate(String expression, [Map<String, double> variables = const {}])
```

Parses and evaluates a LaTeX string. Returns an `EvaluationResult`.

#### `evaluateParsed`

```dart
EvaluationResult evaluateParsed(Expression ast, [Map<String, double> variables = const {}])
```

Evaluates a pre-parsed AST. Useful for performance when evaluating the same expression multiple times with different variables.

#### `parse`

```dart
Expression parse(String expression)
```

Parses a string into an AST `Expression` without evaluating. Cached if caching is enabled.

#### `evaluateNumeric`

```dart
double evaluateNumeric(String expression, [Map<String, double> variables = const {}])
```

Evaluates the expression and returns a `double` directly. Throws `StateError` if the result is not a real number.

#### `evaluateMatrix`

```dart
Matrix evaluateMatrix(String expression, [Map<String, double> variables = const {}])
```

Evaluates the expression and returns a `Matrix` directly. Throws `StateError` if the result is not a matrix.

#### `validate`

```dart
ValidationResult validate(String expression)
```

Checks if an expression is providing detailed error information if invalid.

#### `isValid`

```dart
bool isValid(String expression)
```

Returns `true` if the expression is syntactically valid, `false` otherwise.

#### `differentiate`

```dart
Expression differentiate(dynamic expression, String variable, {int order = 1})
```

Computes the symbolic derivative of an expression. `expression` can be a String or an AST Expression.

#### `integrate`

```dart
Expression integrate(dynamic expression, String variable)
```

Computes the symbolic antiderivative (indefinite integral) of an expression. `expression` can be a String or an AST Expression.

#### `clearParsedExpressionCache`

```dart
void clearParsedExpressionCache()
```

Clears the internal parsed expression (L1) cache.

#### `clearAllCaches`

```dart
void clearAllCaches()
```

Clears all internal caches (L1-L4).

#### `warmUpCache`

```dart
void warmUpCache(List<String> expressions)
```

Warms up the cache with a list of common expressions to pre-populate it before time-critical operations.

---

## EvaluationResult

Sealed base class for all evaluation results. It enables type-safe handling of results using pattern matching.

### Subclasses

- `NumericResult(double value)`: Wraps a `double`.
- `ComplexResult(Complex value)`: Wraps a `Complex` number.
- `MatrixResult(Matrix matrix)`: Wraps a `Matrix`.
- `VectorResult(Vector vector)`: Wraps a `Vector`.

### Common Methods

- `asNumeric()`: Returns `double` or throws if not numeric/real.
- `asComplex()`: Returns `Complex` or throws if not scalar/complex.
- `asMatrix()`: Returns `Matrix` or throws.
- `asVector()`: Returns `Vector` or throws.
- `isNaN`: Checks if the result contains any NaN values.
- `isNumeric`, `isComplex`, `isMatrix`, `isVector`: Type check properties.

### Usage Example

```dart
final result = evaluator.evaluate('2 + 3');
switch (result) {
  case NumericResult(:final value):
    print('Number: $value');
  case ComplexResult(:final value):
    print('Complex: $value');
  case MatrixResult(:final matrix):
    print('Matrix: $matrix');
  // Handle other cases...
}
```
