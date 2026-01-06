# Security Considerations

This document outlines the security vulnerabilities addressed in TeXpr and the mitigation strategies implemented to ensure safe evaluation of untrusted mathematical expressions.

## Vulnerability Categories

### 1. Denial of Service (DoS) - Resource Exhaustion

TeXpr implements several limits to prevent malicious expressions from exhausting system resources.

#### Call Depth Exhaustion (Recursion Limit)
The recursive descent parser and the evaluation visitors use depth limits to prevent stack overflow from deeply nested expressions.
- **Default limit**: 500
- **Configurable**: Yes, via `Texpr(maxRecursionDepth: ...)`
- **Affects**: Parsing, evaluation, symbolic differentiation, and exports (JSON, MathML).

#### Iteration Limit (CPU Pinning)
Iterative operations like summations and products could be exploited to cause near-infinite loops.
- **Limit**: 100,000 iterations per operation, not global. There is no global limit.
- **Mechanism**: `CalculusEvaluator.maxIterations` checks the bounds `end - start + 1`.
- **Throws**: `EvaluatorException` if exceeded.

#### Triple Integrals and Nested Loops
Numerical integration (Simpson's rule) uses a fixed number of steps (10,000) for accuracy and predictability. Chained integrals or high-order derivatives are subject to cumulative recursion depth limits.

---

### 2. Numeric Limits (Not Security Vulnerabilities)

> **Note**: `Infinity` and `NaN` are well-defined IEEE-754 values that are memory-safe and non-exploitable. They represent numerical range limits, not resource exhaustion or security vulnerabilities.

For detailed documentation on numerical precision, overflow behavior, and function limits, see [KNOWN_ISSUES.md](./KNOWN_ISSUES.md#1-numerical-precision-and-stability).


---

### 3. Parser Bombs and Malicious Input

#### Regular Expression DoS (ReDoS)
Input processing avoids complex backtracking regex. Number parsing and tokenization use linear-time scanning or simple regex patterns that are not vulnerable to catastrophic backtracking.

#### Long Inputs and Variable Names
- **Input Length**: While Dart strings are limited by memory, extremely long strings should be handled by the caller before passing to the parser.
- **Variable Injection**: Variable names are validated during tokenization. Extension registries are sandboxed within the Dart execution environment.

---

### 4. Memory Exhaustion

#### Cache Entry Limits
TeXpr implements size-limited caches for parsed expressions.
- **Default Parse Cache**: 128 expressions.
- **Mechanism**: LRU (Least Recently Used) cache policy prevents unbounded growth.
- **Configurable**: Yes, via `Texpr(cacheConfig: CacheConfig(parsedExpressionCacheSize: ...))`

#### Cache Eligibility by Expression Length
Large expressions produce large ASTs. To prevent memory exhaustion, expressions exceeding a configurable length are parsed normally but not stored in L1 cache.
- **Default limit**: 5120 bytes (5KB).
- **Behavior**: Silent - no error, no warning. Expression parses and evaluates normally.
- **Configurable**: Yes, via `CacheConfig(maxCacheInputLength: ...)`.
- **Disable**: Set to `0` to cache all expressions regardless of size.

---

### 5. Export Injection

#### MathML and JSON Safety
- **MathML**: Special characters in variable names or symbols are naturally handled by the visitor pattern. Users of MathML output should still follow standard XSS prevention if embedding in HTML.
- **JSON**: Serializes to standard Dart `Map<String, dynamic>`, which is inherently safe for `jsonEncode`.

## Security Best Practices for Users

1. **Limit Recursion Depth**: If your application is high-traffic, consider lowering `maxRecursionDepth` to 100-200.
2. **Limit Input Length**: Reject expressions longer than 2,000-5,000 characters before parsing.
3. **Handle Infinity**: Be prepared for evaluation results to be `double.infinity`.
4. **Catch Exceptions**: Always wrap `evaluate()` calls in `try-catch` blocks to handle `EvaluatorException`.

## Testing

Security vulnerabilities are continuously tested in `test/security/security_vulnerabilities_test.dart`. This suite includes regression tests for known vulnerability patterns.
