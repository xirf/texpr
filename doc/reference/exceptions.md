# Exceptions and Error Taxonomy

This document provides a  specification of TeXpr's error model, including error classification, typed exceptions, and recovery strategies.

## Error Classification

TeXpr errors are classified into three distinct categories based on the processing stage where they occur:

```
┌─────────────────────────────────────────────────────────────────┐
│                        Input String                              │
└─────────────────────────┬───────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  TOKENIZER              │  TokenizerException                   │
│  (Lexical Analysis)     │  - Invalid characters                 │
│                         │  - Malformed numbers                  │
│                         │  - Unknown LaTeX commands             │
└─────────────────────────┬───────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  PARSER                 │  ParserException                      │
│  (Syntactic Analysis)   │  - Unbalanced delimiters              │
│                         │  - Missing arguments                  │
│                         │  - Unexpected tokens                  │
│                         │  - Recursion depth exceeded           │
└─────────────────────────┬───────────────────────────────────────┘
                          ▼
┌─────────────────────────────────────────────────────────────────┐
│  EVALUATOR              │  EvaluatorException                   │
│  (Semantic Analysis)    │  - Undefined variables                │
│                         │  - Division by zero                   │
│                         │  - Domain errors                      │
│                         │  - Type mismatches                    │
│                         │  - Resource limits                    │
└─────────────────────────┴───────────────────────────────────────┘
```

---

## Exception Hierarchy

```dart
sealed class TexprException implements Exception {
  String get message;
  int? get position;
  String? get expression;
  String? get suggestion;
}

class TokenizerException extends TexprException { ... }
class ParserException extends TexprException { ... }
class EvaluatorException extends TexprException { ... }
```

All exceptions are subclasses of the sealed `TexprException` base class, enabling exhaustive pattern matching in Dart 3.0+.

---

## Exception Properties

| Property     | Type      | Description                         |
| ------------ | --------- | ----------------------------------- |
| `message`    | `String`  | Human-readable error description    |
| `position`   | `int?`    | Character index in source (0-based) |
| `expression` | `String?` | Original expression string          |
| `suggestion` | `String?` | Actionable fix recommendation       |

---

## Lexical Errors (TokenizerException)

Lexical errors occur during tokenization when the input contains invalid character sequences.

### Error Codes

| Error             | Cause                              | Example           | Suggestion                 |
| ----------------- | ---------------------------------- | ----------------- | -------------------------- |
| Unknown command   | Unrecognized `\command`            | `\unknownfunc{x}` | "Did you mean '\sin'?"     |
| Invalid character | Non-mathematical character         | `@#$`             | "Remove invalid character" |
| Malformed number  | Multiple decimal points            | `1.2.3`           | "Invalid number format"    |
| Unterminated text | Missing closing brace in `\text{}` | `\text{hello`     | "Add closing brace"        |

### Example

```dart
try {
  texpr.parse(r'\sinn{x}');
} on TokenizerException catch (e) {
  print(e.message);     // "Unknown command: sinn"
  print(e.position);    // 0
  print(e.suggestion);  // "Did you mean 'sin'?"
}
```

---

## Syntactic Errors (ParserException)

Syntactic errors occur when the token sequence doesn't match the grammar rules.

### Error Codes

| Error                 | Cause                   | Example       | Suggestion                     |
| --------------------- | ----------------------- | ------------- | ------------------------------ |
| Unbalanced delimiters | Missing opening/closing | `(x + 1`      | "Expected ')'"                 |
| Missing argument      | Incomplete construct    | `\frac{1}`    | "Expected second argument"     |
| Unexpected token      | Grammar violation       | `+ + 1`       | "Unexpected operator"          |
| Recursion overflow    | Too deeply nested       | `((((...))))` | "Expression too deeply nested" |
| Empty expression      | No content              | ``            | "Expected expression"          |

### Example

```dart
try {
  texpr.parse(r'\frac{1}');
} on ParserException catch (e) {
  print(e.message);     // "Expected second argument for \\frac"
  print(e.position);    // 8
  print(e.suggestion);  // "Usage: \\frac{numerator}{denominator}"
}
```

---

## Semantic Errors (EvaluatorException)

Semantic errors occur during evaluation when the expression is syntactically valid but mathematically problematic.

### Error Categories

#### Variable Errors

| Error               | Cause                | Example         | Suggestion                 |
| ------------------- | -------------------- | --------------- | -------------------------- |
| Undefined variable  | Missing binding      | `x + 1` (no x)  | "Provide a value for 'x'"  |
| Wrong variable type | Non-numeric variable | `{'x': 'text'}` | "Variable must be numeric" |

#### Domain Errors

| Error            | Cause                   | Example      | Suggestion                                       |
| ---------------- | ----------------------- | ------------ | ------------------------------------------------ |
| Division by zero | Zero denominator        | `1/0`        | "Denominator cannot be zero"                     |
| Log of zero      | `ln(0)`                 | `\ln{0}`     | "Logarithm undefined for zero"                   |
| Log of negative  | `ln(-x)` real mode      | `\ln{-1}`    | "Logarithm undefined for negative (use complex)" |
| Sqrt of negative | Real mode only          | `\sqrt{-1}`  | "Use complex number support"                     |
| Factorial domain | Negative or non-integer | `(-5)!`      | "Factorial requires non-negative integer"        |
| Asin/acos domain | Outside [-1, 1]         | `\arcsin{2}` | "Argument must be in [-1, 1]"                    |

#### Type Errors

| Error                     | Cause              | Example                | Suggestion                     |
| ------------------------- | ------------------ | ---------------------- | ------------------------------ |
| Matrix-scalar mismatch    | Incompatible types | `A + 5` (A is matrix)  | "Cannot add matrix and scalar" |
| Matrix dimension mismatch | Wrong dimensions   | `A * B` (incompatible) | "Matrix dimensions must match" |
| Non-numeric in calculus   | Variable in bounds | `\sum_{i=x}^{y}`       | "Bounds must be numeric"       |

#### Resource Limit Errors

| Error              | Cause            | Limit         | Suggestion                          |
| ------------------ | ---------------- | ------------- | ----------------------------------- |
| Recursion overflow | Deep nesting     | 500 (default) | "Increase maxRecursionDepth"        |
| Iteration overflow | Huge sum/product | 100,000       | "Reduce iteration bounds"           |
| Factorial overflow | Too large        | n > 170       | "Factorial(n) exceeds double range" |
| Fibonacci overflow | Too large        | n > 1476      | "Fibonacci(n) exceeds double range" |

### Example

```dart
try {
  texpr.evaluate(r'\sum_{i=1}^{999999999} i');
} on EvaluatorException catch (e) {
  print(e.message);     // "Iteration limit exceeded"
  print(e.suggestion);  // "Maximum 100,000 iterations allowed"
}
```

---

## Handling Exceptions

### Basic Pattern

```dart
try {
  final result = texpr.evaluate(expression, variables);
  // Use result...
} on TokenizerException catch (e) {
  // Invalid input: unknown commands, bad characters
  logError('Lexical error: ${e.message}');
} on ParserException catch (e) {
  // Syntax error: unbalanced braces, missing args
  logError('Syntax error at position ${e.position}: ${e.message}');
} on EvaluatorException catch (e) {
  // Runtime error: undefined vars, domain errors
  logError('Evaluation error: ${e.message}');
} on TexprException catch (e) {
  // Catch-all for any TeXpr error
  logError('Math error: ${e.message}');
}
```

### Exhaustive Matching (Dart 3.0+)

```dart
switch (error) {
  case TokenizerException(message: var msg, position: var pos):
    handleLexicalError(msg, pos);
  case ParserException(message: var msg, suggestion: var sug):
    handleSyntaxError(msg, sug);
  case EvaluatorException(message: var msg):
    handleRuntimeError(msg);
}
```

---

## ValidationResult

For validation without throwing exceptions, use `texpr.validate()`:

```dart
final result = texpr.validate(r'\frac{1}{');

if (!result.isValid) {
  print(result.errorMessage);   // "Expected closing brace"
  print(result.position);       // 9
  print(result.suggestion);     // "Add '}' to close \\frac"
  print(result.exceptionType);  // ParserException
}
```

### Properties

| Property        | Type                    | Description                          |
| --------------- | ----------------------- | ------------------------------------ |
| `isValid`       | `bool`                  | `true` if expression is valid        |
| `errorMessage`  | `String?`               | Primary error description            |
| `position`      | `int?`                  | Error position in source             |
| `suggestion`    | `String?`               | Recommended fix                      |
| `exceptionType` | `Type?`                 | Exception class that would be thrown |
| `subErrors`     | `List<ValidationError>` | Additional errors found              |

### Multiple Error Detection

The validator attempts recovery to find multiple issues:

```dart
final result = texpr.validate(r'2 + ) + \unknownfunc{x}');

print(result.errorMessage);  // Primary error
for (final sub in result.subErrors) {
  print('${sub.position}: ${sub.errorMessage}');
}
// Output:
// 4: Unexpected ')'
// 8: Unknown command 'unknownfunc'
```

---

## Error Recovery Strategies

### User Input Handling

```dart
String sanitizeAndEvaluate(String input) {
  // 1. Validate first
  final validation = texpr.validate(input);
  if (!validation.isValid) {
    return 'Error: ${validation.suggestion ?? validation.errorMessage}';
  }

  // 2. Evaluate with timeout protection
  try {
    final result = texpr.evaluate(input, context);
    
    // 3. Check for special values
    if (result.isNumeric) {
      final value = result.asNumeric();
      if (value.isNaN) return 'Error: Result is undefined';
      if (value.isInfinite) return 'Error: Result is infinite';
      return value.toString();
    }
    
    return result.toString();
  } on TexprException catch (e) {
    return 'Error: ${e.suggestion ?? e.message}';
  }
}
```

### Graceful Degradation

```dart
double evaluateOrDefault(String expr, double defaultValue) {
  try {
    return texpr.evaluate(expr).asNumeric();
  } on TexprException {
    return defaultValue;
  }
}
```

---

## Error Message Quality

TeXpr provides actionable suggestions for common errors:

| Error Pattern      | Message                          | Suggestion                    |
| ------------------ | -------------------------------- | ----------------------------- |
| `\sin{x`           | "Expected closing brace"         | "Add '}' after the argument"  |
| `\sni{x}`          | "Unknown command: sni"           | "Did you mean 'sin'?"         |
| `x + `             | "Unexpected end of expression"   | "Add right-hand operand"      |
| `\log{0}`          | "Logarithm of zero is undefined" | "Ensure argument is positive" |
| `A + B` (matrices) | "Matrix dimensions must match"   | "A is 2×2, B is 3×3"          |

---

## API Stability

| Aspect                | Stability Guarantee             |
| --------------------- | ------------------------------- |
| Exception types       | Stable within major versions    |
| `message` text        | May change (not API)            |
| `position` accuracy   | Best effort, may be approximate |
| `suggestion` presence | Not guaranteed                  |
| New exception types   | May be added in minor versions  |

---

## Summary

| Stage        | Exception            | Examples                             |
| ------------ | -------------------- | ------------------------------------ |
| Tokenization | `TokenizerException` | Unknown commands, invalid chars      |
| Parsing      | `ParserException`    | Syntax errors, unbalanced delimiters |
| Evaluation   | `EvaluatorException` | Domain errors, undefined variables   |

Always wrap `evaluate()` calls in try-catch and handle all three exception types appropriately for robust applications.
