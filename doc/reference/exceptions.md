# Exceptions

Error handling in TeXpr.

## Exception Hierarchy

```
TexprException (sealed base class)
├── TokenizerException  — Invalid characters or tokens
├── ParserException     — Syntax errors
└── EvaluatorException  — Runtime errors
```

## Exception Properties

All exceptions include:

| Property     | Description            |
| ------------ | ---------------------- |
| `message`    | Error description      |
| `position`   | Index in source string |
| `expression` | Original expression    |
| `suggestion` | Tip to fix the error   |

## Handling Exceptions

```dart
try {
  texpr.evaluate(r'\log{0}');
} on EvaluatorException catch (e) {
  print('Math error: ${e.message}');
  print('At position: ${e.position}');
  print('Suggestion: ${e.suggestion}');
} on ParserException catch (e) {
  print('Syntax error: ${e.message}');
} on TokenizerException catch (e) {
  print('Invalid input: ${e.message}');
}
```

## Common Errors

| Error         | Exception          | Suggestion                    |
| ------------- | ------------------ | ----------------------------- |
| `\sin{`       | ParserException    | Missing closing brace         |
| `\sinn{x}`    | EvaluatorException | Did you mean 'sin'?           |
| `\log{0}`     | EvaluatorException | Domain error                  |
| `x / 0`       | EvaluatorException | Division by zero              |
| Undefined `x` | EvaluatorException | Provide a value for 'x'       |
| `\nabla{f}`   | EvaluatorException | Cannot evaluate symbolic grad |
| `A + B`       | EvaluatorException | Matrix dimensions must match  |

---

## ValidationResult

Returned by `texpr.validate()` for syntax checking without evaluation.

```dart
final result = texpr.validate(r'\frac{1}{');

if (!result.isValid) {
  print(result.errorMessage);   // Error description
  print(result.position);       // Error position
  print(result.suggestion);     // Fix suggestion
  print(result.exceptionType);  // ParserException
}
```

### Properties

| Property        | Description             |
| --------------- | ----------------------- |
| `isValid`       | `true` if valid         |
| `errorMessage`  | Error description       |
| `position`      | Error position          |
| `suggestion`    | Suggested fix           |
| `exceptionType` | Exception class         |
| `subErrors`     | Additional errors found |

### Multiple Error Detection

The validator attempts error recovery to find multiple issues:

```dart
final result = texpr.validate(r'2 + ) + }');

print(result.errorMessage);  // Primary error
for (final sub in result.subErrors) {
  print(sub.errorMessage);   // Additional errors
}
```
