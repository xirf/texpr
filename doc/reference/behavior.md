# Determinism and Numeric Behavior

This document specifies TeXpr's guarantees about evaluation determinism, floating-point behavior, simplification rules, and cross-platform consistency. Understanding these properties is critical for applications requiring reproducible results.

## Floating-Point Arithmetic

### IEEE 754 Compliance

All numeric operations use Dart's `double` type, which implements **IEEE 754 binary64** (64-bit double-precision floating-point).

| Property          | Value                             |
| ----------------- | --------------------------------- |
| Precision         | ~15-17 significant decimal digits |
| Range             | ±1.8 × 10³⁰⁸                      |
| Smallest positive | 5 × 10⁻³²⁴ (subnormal)            |
| Epsilon           | 2.22 × 10⁻¹⁶                      |

### Special Values

TeXpr propagates IEEE 754 special values:

| Value       | When Produced              | Example                         |
| ----------- | -------------------------- | ------------------------------- |
| `Infinity`  | Overflow, division by zero | `1e308 * 10`, `1/0`             |
| `-Infinity` | Negative overflow          | `-1e308 * 10`                   |
| `NaN`       | Indeterminate forms        | `0/0`, `sqrt(-1)` for real-only |

> [!WARNING]
> `NaN` and `Infinity` are valid results, not exceptions. Always check with `isNaN` and `isInfinite` in your application code.

### Precision Limitations

```dart
// Associativity is not guaranteed
(1e15 + 1.0) - 1e15  // May not equal 1.0

// Precision loss with large numbers
1e16 + 1  // Equals 1e16, not 1e16 + 1

// Transcendental function precision
sin(π)  // ≈ 1.2e-16, not exactly 0
```

### Recommendations

1. **Never compare floats for exact equality** — use tolerance-based comparisons
2. **Check for special values** before using results in further calculations
3. **Be aware of catastrophic cancellation** when subtracting similar magnitudes

---

## Evaluation Order

### Guaranteed Properties

| Property                | Guarantee                                                   |
| ----------------------- | ----------------------------------------------------------- |
| **Operator precedence** | Strictly follows documented precedence table                |
| **Associativity**       | Left-to-right for `+`, `-`, `*`, `/`; right-to-left for `^` |
| **Short-circuit**       | Not applicable (all operands are evaluated)                 |
| **Argument evaluation** | Left-to-right for function arguments                        |

### Sub-expression Evaluation

Within a single expression, sub-expressions at the same precedence level are evaluated left-to-right:

```dart
// Guaranteed order: f() called before g()
evaluate('f(x) + g(x)', {'x': 1.0})
```

### Caching Effects

With caching enabled, identical sub-expressions may return cached results:

```dart
// Both x^2 terms may share a cached result
evaluate('x^2 + x^2', {'x': 3.0})  // = 18.0
```

This does **not** affect the final result, only performance.

---

## Simplification Rules

### Pattern-Based Simplification

TeXpr applies local pattern-based simplification, **not** canonical form transformation.

| Pattern | Simplification | Applied         |
| ------- | -------------- | --------------- |
| `x + 0` | `x`            | Always          |
| `0 + x` | `x`            | Always          |
| `x * 1` | `x`            | Always          |
| `1 * x` | `x`            | Always          |
| `x * 0` | `0`            | Always          |
| `0 * x` | `0`            | Always          |
| `x ^ 0` | `1`            | For x ≠ 0       |
| `x ^ 1` | `x`            | Always          |
| `x - x` | `0`            | Same expression |
| `x / x` | `1`            | For x ≠ 0       |
| `--x`   | `x`            | Always          |

### Trigonometric Identities

These identities are applied during symbolic operations:

| Identity                | Applied               |
| ----------------------- | --------------------- |
| `sin²(x) + cos²(x) = 1` | During simplification |
| `sin(0) = 0`            | During evaluation     |
| `cos(0) = 1`            | During evaluation     |
| `tan(0) = 0`            | During evaluation     |

### What Is NOT Simplified

> [!IMPORTANT]
> TeXpr does not produce canonical forms. These expressions are NOT recognized as equivalent:

```dart
'2x + 3x'     // NOT simplified to 5x
'x + y + x'   // NOT simplified to 2x + y
'(x+1)^2'     // NOT expanded to x^2 + 2x + 1 (unless explicitly expanded)
```

Use the `SymbolicEngine.simplify()` or `expand()` methods for more aggressive transformations.

---

## Numerical Integration

### Simpson's Rule Parameters

| Parameter        | Value              | Notes                      |
| ---------------- | ------------------ | -------------------------- |
| Intervals        | 10,000             | Fixed, not configurable    |
| Error bound      | ~O(h⁴)             | For smooth functions       |
| Typical accuracy | 10+ decimal places | For well-behaved functions |

### Improper Integral Handling

| Bound | Replacement | Notes                                           |
| ----- | ----------- | ----------------------------------------------- |
| `∞`   | `100.0`     | May be inaccurate for slow-converging functions |
| `-∞`  | `-100.0`    | May be inaccurate for slow-converging functions |

### Limitations

- **Singularities**: Integrals crossing vertical asymptotes produce incorrect results
- **Oscillating functions**: May not converge properly near infinity
- **Slow convergence**: Functions like `1/x` near infinity need larger bounds

---

## Limit Evaluation

### Algorithm

1. **Finite limit**: Direct substitution of target value
2. **Limit at infinity**: Evaluate at `[10², 10⁴, 10⁶, 10⁸]`, return last stable value
3. **No L'Hôpital's rule**: Indeterminate forms are not symbolically resolved

### Behavior

```dart
lim_{x→0} sin(x)/x     // = 1.0 (numerical convergence)
lim_{x→∞} 1/x          // = 0.0 (evaluated at large values)
lim_{x→0} 1/x          // = Infinity (direct substitution)
```

---

## Caching Determinism

### Cache Keys

Cache keys are computed from:
- Expression structure (AST hash)
- Variable bindings (sorted by name)
- Numeric values (exact IEEE 754 representation)

### Guarantees

| Property                         | Guarantee                               |
| -------------------------------- | --------------------------------------- |
| **Same input → same result**     | Yes, within a single evaluator instance |
| **Cache hit → identical result** | Yes                                     |
| **Cross-instance consistency**   | Yes, for same expression and variables  |

### Edge Cases

| Scenario                | Behavior                                       |
| ----------------------- | ---------------------------------------------- |
| `NaN` in expressions    | Cache may produce unexpected hits              |
| `-0.0` vs `+0.0`        | Distinct cache keys                            |
| Floating-point rounding | May cause cache misses for "equivalent" values |

---

## Cross-Platform Consistency

### Dart VM vs JavaScript

| Aspect                   | Consistency           |
| ------------------------ | --------------------- |
| Integer arithmetic       | Identical             |
| Basic float ops          | Generally identical   |
| Transcendental functions | May differ by 1-2 ULP |
| Special value handling   | Identical             |

### Recommendations

1. **Use tolerance-based comparisons** for cross-platform testing
2. **Avoid relying on exact bit patterns** for numerical results
3. **Cache behavior is deterministic** within a platform

---

## Random Number Generation

TeXpr does **not** use random numbers in any evaluation path. All operations are deterministic given the same input.

---

## Thread Safety

> [!CAUTION]
> TeXpr evaluator instances are **NOT thread-safe**.

| Operation         | Thread Safety                                |
| ----------------- | -------------------------------------------- |
| Parse (stateless) | Safe when using separate tokenizer instances |
| Evaluate          | Unsafe (mutable cache state)                 |
| Differentiate     | Unsafe (uses shared evaluator)               |

### Recommendations

- Create one `Texpr` instance per thread/isolate
- Or disable caching for shared instances (performance penalty)

---

## Versioning and Stability

### Behavioral Guarantees

| Aspect                   | Stability                           |
| ------------------------ | ----------------------------------- |
| Valid expression parsing | Stable within major versions        |
| Operator precedence      | Stable within major versions        |
| Numeric results          | Stable for same inputs              |
| Error types              | May add new types in minor versions |
| Error messages           | May change without notice           |

### Breaking Changes

The following would require a major version bump:
- Changing operator precedence
- Changing associativity rules
- Removing support for currently-supported syntax
- Changing the exception hierarchy

---

## Summary

| Property         | TeXpr Behavior                                     |
| ---------------- | -------------------------------------------------- |
| Floating-point   | IEEE 754 binary64                                  |
| Special values   | `Infinity`, `-Infinity`, `NaN` propagated          |
| Evaluation order | Deterministic, left-to-right at same precedence    |
| Simplification   | Pattern-based only, not canonical form             |
| Integration      | Simpson's Rule, 10k intervals                      |
| Limits           | Numerical, no L'Hôpital                            |
| Caching          | Deterministic within instance                      |
| Thread safety    | Not thread-safe                                    |
| Cross-platform   | Generally consistent, ±1-2 ULP for transcendentals |
