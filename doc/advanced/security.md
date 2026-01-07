# Security

Security considerations for evaluating untrusted mathematical expressions. TeXpr takes security seriously and implements multiple layers of protection against denial-of-service and resource exhaustion attacks.

## Threat Model

When accepting user-supplied expressions, consider these attack vectors:

| Threat                | Attack Vector              | TeXpr Defense         |
| --------------------- | -------------------------- | --------------------- |
| **Stack Overflow**    | Deeply nested expressions  | Recursion depth limit |
| **CPU Exhaustion**    | Large iteration counts     | Iteration limits      |
| **Memory Exhaustion** | Unbounded cache growth     | Cache size limits     |
| **Integer Overflow**  | Large factorial/fibonacci  | Explicit bounds       |
| **ReDoS**             | Malicious regex patterns   | No regex in hot paths |
| **Infinite Loops**    | Non-terminating evaluation | Bounded iterations    |

---

## Resource Limits

### Recursion Depth

Prevents stack overflow from deeply nested expressions like `((((...))))` or `a^b^c^d^...`.

| Setting   | Default | Configurable                    |
| --------- | ------- | ------------------------------- |
| Max depth | 500     | `Texpr(maxRecursionDepth: ...)` |

```dart
// Default: 500 levels of nesting
final evaluator = Texpr();

// Reduced for high-traffic applications
final restricted = Texpr(maxRecursionDepth: 100);

// Increased for complex academic expressions
final permissive = Texpr(maxRecursionDepth: 1000);
```

**Attack example:**
```latex
((((((((((((((((((((((((((((((x))))))))))))))))))))))))))))))
```

**Defense:** Throws `ParserException` when depth exceeds limit.

---

### Iteration Limits

Prevents CPU pinning from large summations, products, or integrals.

| Operation                | Limit   | Configurable |
| ------------------------ | ------- | ------------ |
| Sum/Product iterations   | 100,000 | No           |
| Simpson's Rule intervals | 10,000  | No           |

**Attack example:**
```latex
\sum_{i=1}^{999999999} i
```

**Defense:** Throws `EvaluatorException` when iteration count exceeds limit.

---

### Factorial/Fibonacci Bounds

Prevents numeric overflow and excessive computation.

| Function        | Max Input | Reason                    |
| --------------- | --------- | ------------------------- |
| `\factorial{n}` | 170       | Larger overflows `double` |
| `\fibonacci{n}` | 1476      | Larger overflows `double` |

**Attack example:**
```latex
\factorial{999999}
```

**Defense:** Throws `EvaluatorException` with descriptive message.

---

### Cache Size

Prevents memory exhaustion from cache growth.

| Setting             | Default | Configurable                                  |
| ------------------- | ------- | --------------------------------------------- |
| Parse cache entries | 128     | `CacheConfig(parsedExpressionCacheSize: ...)` |
| Max cacheable input | 5KB     | `CacheConfig(maxCacheInputLength: ...)`       |
| Eviction policy     | LRU     | `CacheConfig(evictionPolicy: ...)`            |

```dart
final evaluator = Texpr(
  cacheConfig: CacheConfig(
    parsedExpressionCacheSize: 256,
    maxCacheInputLength: 2000,
    evictionPolicy: EvictionPolicy.lfu,
  ),
);
```

---

## Input Validation

### Length Limits

For untrusted input, implement length limits at the application level:

```dart
const maxExpressionLength = 5000;

String evaluateSafely(String input) {
  if (input.length > maxExpressionLength) {
    throw ArgumentError('Expression too long');
  }
  return texpr.evaluate(input).toString();
}
```

### Content Validation

Use `validate()` before `evaluate()` for early error detection:

```dart
final validation = texpr.validate(userInput);
if (!validation.isValid) {
  // Reject without attempting evaluation
  return 'Invalid: ${validation.errorMessage}';
}
```

---

## Numeric Behavior

### Special Values

`Infinity` and `NaN` are valid IEEE-754 values, **not** security vulnerabilities:

```dart
final result = texpr.evaluateNumeric(r'1/0');  // double.infinity

if (result.isInfinite || result.isNaN) {
  // Handle appropriately for your application
  return 'Result is not finite';
}
```

### Division by Zero

By default, `1/0` returns `Infinity` rather than throwing. This matches Dart's `double` behavior:

```dart
texpr.evaluate('1/0')   // NumericResult(Infinity)
texpr.evaluate('-1/0')  // NumericResult(-Infinity)
texpr.evaluate('0/0')   // NumericResult(NaN)
```

---

## Security Test Suite

TeXpr includes an 800+ line security test suite covering:

- Stack overflow via deep recursion (parentheses, fractions, powers, unary operators)
- Resource exhaustion via large iterations (sums, products)
- Integer overflow (factorial, fibonacci, powers)
- Input validation (length, null bytes, unicode)
- Parser bombs (exponential complexity)
- Memory exhaustion (cache limits)
- ReDoS resistance
- Type confusion
- Limit evaluation edge cases
- Variable injection
- Extension sandboxing
- Symbolic simplification infinite loops
- Gradient evaluation DoS
- Binomial coefficient vulnerabilities
- High-order derivative limits
- Multi-integral complexity
- Visitor pattern depth
- Export injection
- Matrix dimension attacks
- Piecewise function nesting

See [`test/security/security_vulnerabilities_test.dart`](file:///Users/xomodo/projects/js/texpr/test/security/security_vulnerabilities_test.dart) for the complete test suite.

---

## Best Practices

### For Untrusted Input

1. **Limit input length** — Reject expressions > 2,000-5,000 characters
2. **Lower recursion depth** — Use 100-200 for high-traffic applications
3. **Validate first** — Call `validate()` before `evaluate()`
4. **Catch all exceptions** — Always wrap in try-catch
5. **Handle infinity** — Check for `isInfinite` and `isNaN`
6. **Rate limit** — Throttle evaluation requests per user
7. **Timeout** — Implement application-level timeouts

### Example: Production-Ready Evaluation

```dart
class SafeEvaluator {
  final texpr = Texpr(
    maxRecursionDepth: 200,
    cacheConfig: CacheConfig(
      parsedExpressionCacheSize: 64,
      maxCacheInputLength: 2000,
    ),
  );

  static const maxLength = 3000;
  static const defaultTimeout = Duration(milliseconds: 100);

  Future<String> evaluate(String input) async {
    // 1. Length check
    if (input.length > maxLength) {
      return 'Error: Expression too long';
    }

    // 2. Validation
    final validation = texpr.validate(input);
    if (!validation.isValid) {
      return 'Error: ${validation.suggestion ?? validation.errorMessage}';
    }

    // 3. Evaluate with timeout
    try {
      final result = await Future.value(texpr.evaluate(input))
          .timeout(defaultTimeout);

      // 4. Check result validity
      if (result.isNumeric) {
        final value = result.asNumeric();
        if (value.isNaN) return 'Error: Undefined result';
        if (value.isInfinite) return 'Error: Infinite result';
      }

      return result.toString();
    } on TimeoutException {
      return 'Error: Evaluation timed out';
    } on TexprException catch (e) {
      return 'Error: ${e.suggestion ?? e.message}';
    }
  }
}
```

---

## Output Safety

### JSON Export

Standard Dart map, safe for `jsonEncode`:

```dart
final ast = texpr.parse(r'\sin{x}');
final json = jsonEncode(ast.toJson());  // Safe
```

### MathML Export

When embedding MathML in HTML, follow standard XSS prevention:

```dart
final mathml = texpr.parse('x + 1').toMathML();
// Sanitize before embedding in HTML
final sanitized = HtmlEscape().convert(mathml);
```

### LaTeX Round-Trip

`toLatex()` output is safe for LaTeX rendering but may contain backslashes:

```dart
final latex = texpr.parse(r'\frac{1}{2}').toLatex();
// Use appropriately in your template
```

---

## Extension Security

Custom extensions run in the same Dart isolate and have access to application memory. Extensions cannot:

- Access the file system
- Make network requests
- Execute shell commands

However, caution is advised:

```dart
// SAFE: Simple math extension
registry.registerEvaluator((expr, vars, eval) {
  if (expr is FunctionCall && expr.name == 'double') {
    return eval(expr.argument) * 2;
  }
  return null;
});

// UNSAFE: Don't do this
registry.registerEvaluator((expr, vars, eval) {
  if (expr is FunctionCall && expr.name == 'eval') {
    // Never pass user input to Dart's `dart:mirrors` or similar
    return dangerousEval(expr.argument.toString());
  }
  return null;
});
```

---

## Reporting Security Issues

If you discover a security vulnerability:

1. **Do not** open a public GitHub issue
2. Email security concerns to the maintainer (see GitHub profile)
3. Include:
   - Description of the vulnerability
   - Minimal reproduction case
   - Potential impact assessment

We aim to respond to security reports within 48 hours.

---

## Summary

| Defense                    | Protection            |
| -------------------------- | --------------------- |
| Recursion limit            | Stack overflow        |
| Iteration limit            | CPU exhaustion        |
| Cache limits               | Memory exhaustion     |
| Factorial/fibonacci bounds | Integer overflow      |
| Input validation           | Malformed input       |
| No regex in hot paths      | ReDoS                 |
| Bounded operations         | Infinite loops        |
| 800+ security tests        | Regression prevention |
