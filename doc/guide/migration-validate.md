# Migration Guide: `isValid()` / `validate()` Deprecation

`Texpr.isValid()` and `Texpr.validate()` are deprecated and will be removed in `1.0.0`.

Use `parse()` with `try/catch` instead.

## Why this change?

- Single parsing entry point reduces API surface.
- Parse exceptions already provide structured diagnostics (`message`, `position`, `suggestion`).
- Encourages a single error-handling model across parsing and evaluation.

## Migration Patterns

### 1) Replace `isValid()`

Before:

```dart
final ok = texpr.isValid(input);
if (!ok) {
  return;
}
```

After:

```dart
try {
  texpr.parse(input);
  // valid
} on TexprException {
  // invalid
}
```

### 2) Replace `validate()` with rich error handling

Before:

```dart
final result = texpr.validate(input);
if (!result.isValid) {
  print(result.errorMessage);
  print(result.position);
  print(result.suggestion);
}
```

After:

```dart
try {
  texpr.parse(input);
} on TexprException catch (e) {
  print(e.message);
  print(e.position);
  print(e.suggestion);
}
```

### 3) Keep parse result for reuse

```dart
Expression ast;
try {
  ast = texpr.parse(input);
} on TexprException catch (e) {
  // report validation-style diagnostics
  rethrow;
}

final value = texpr.evaluateParsed(ast, {'x': 2.0});
```

## Timeline

- **Now (0.1.x):** methods are available but deprecated.
- **1.0.0:** methods are removed.
