# Known Issues and Limitations

This document provides precise boundaries between deliberate design constraints, technical limitations, and future work. Understanding these distinctions is critical for setting correct expectations and making informed architectural decisions.

## Design Scope and Definitions

These are the architectural boundaries of the library.

### Recursive Descent Parsing

**Definition:** The parser uses a recursive descent algorithm with a lookahead buffer. Structure is handled via the call stack rather than a separate symbol table pass.

**Implications:**

- Multi-character identifiers and functions are resolved greedily
- `xy` is tokenized as `x * y` (implicit multiplication) unless `allowImplicitMultiplication` is disabled
- Recursion depth is explicitly limited to prevent stack overflow (default: 500)

**Consequence:** The parser is efficient and straightforward but requires strict syntactic rules for disambiguation.

**Workaround:** Disable implicit multiplication with `allowImplicitMultiplication: false` if you need multi-character variable names, or use explicit operators.

### LaTeX Command Support

**Scope:** The library supports a curated subset of LaTeX commands focused on mathematical evaluation.

**Consequence:** Full LaTeX compatibility, including document formatting, is outside the scope of this project.

**Current Coverage:** See documentation for the complete list of [supported commands](./latex_commands.md).

**Future Work:** See [ROADMAP.md](../ROADMAP.md) for details on planned LaTeX command support.

---

## Technical Boundaries

These are constraints imposed by the underlying platform or architecture.

### 1. Numerical Precision and Stability

#### IEEE 754 Floating-Point Arithmetic

All calculations use Dart's `double` type (IEEE 754 64-bit binary floating-point).

**Specific Limitations:**

- **Non-associativity:** `(a + b) + c != a + (b + c)` in general, affecting symbolic simplification
- **Precision loss:** ~15-17 decimal digits of precision; very large or small numbers lose accuracy
- **Instability near discontinuities:** Functions like `tan(π/2)` or `1/x` near zero exhibit numerical instability
- **Transcendental function errors:** Error bounds for `sin`, `cos`, `exp`, etc. are inherited from `dart:math` (typically < 1 ULP but not guaranteed)
- **Signed zero:** `-0.0` and `+0.0` are distinct values that can affect cache keys and comparisons
- **NaN propagation:** `NaN` values poison arithmetic operations and can silently corrupt cache keys

**Impact on Caching:** Expressions involving `NaN` or signed zero may produce unexpected cache behavior.

### 2. Symbolic Computation Capabilities

**What IS Supported:**

- Local pattern-based simplification (e.g., `x * 0 → 0`, `x + 0 → x`)
- Basic derivative rules for elementary functions
- Linear and quadratic equation solving (via `solveLinear()` and `solveQuadratic()`)
- Piecewise function evaluation and differentiation (via `ConditionalExpr`)
- Numerical integration (Simpson's Rule)

**What IS NOT Supported:**

- **No canonical form:** `2x + 3x` and `5x` are not recognized as equivalent
- **No expression rewriting:** No general term collection, factoring, or expansion beyond basic patterns
- **No algebraic equivalence checking:** Cannot determine if two expressions are mathematically equal
- **No symbolic integration:** Only numerical integration is available (Simpson's Rule)
- **No general equation solving:** Only linear and quadratic equations can be solved; no support for higher-degree polynomials, transcendental equations, or systems of equations

**Consequence:** Computer algebra system (CAS) capabilities such as term rewriting are not currently implemented.

### 3. Recursion Depth Limit

**Limit:** Default maximum recursion depth is 500, but this is configurable via `maxRecursionDepth` in the `Texpr` constructor.

**Worst Case:** Deeply nested right-associative trees (e.g., `a^(b^(c^(...)))`) hit this limit fastest.

**Consequence:** This limit ensures stack safety during recursive operations.

**Impact:** Expressions exceeding the configured depth will throw a `ParserException` (during parsing) or `EvaluatorException` (during differentiation/integration), even if they are mathematically valid.

### 4. Performance Characteristics

#### Parse Time

- **Complexity:** O(n) relative to expression length
- **Bottleneck:** Tokenization and node allocation

#### Evaluation Time

- **Without caching:** Can be exponential for redundant sub-trees
- **With caching:** Near-linear amortized time due to **L4 Sub-expression Caching**
- **Throughput:** ~15,000 evaluations/ms (hot cache) vs ~500/ms (cold)

### 5. Infinity Approximation in Calculus Operations

**Limitation:** Infinite bounds and limits at infinity use large finite values as approximations.

**Specific Behaviors:**

- **Improper integrals:** `∫_{-∞}^{∞}` replaces infinity with `±100.0`
- **Limits at infinity:** `lim_{x→∞}` evaluates at `[1e2, 1e4, 1e6, 1e8]` and returns the last successful value
- **Why this matters:** Results are approximations, not exact analytical values

**Examples:**

- `∫_{-∞}^{∞} e^{-x²} dx` approximates as `∫_{-100}^{100} e^{-x²} dx`
- `lim_{x→∞} 1/x` evaluates `1/x` at increasingly large x values

**Impact:**

- Functions with slow convergence may produce inaccurate results
- Oscillating functions (e.g., `sin(x)`) may give misleading limits
- Integrals of functions that don't decay quickly may be inaccurate
- **Functions with asymptotes** (e.g., `tan(x)`, `1/x`) are particularly problematic - the integration path may cross vertical asymptotes, causing incorrect results or errors

**Consequence:** Numerical integration and limit evaluation require finite intervals.

**Workaround:** For better accuracy with slow-converging functions, use finite but large bounds explicitly, or use symbolic analysis if available.

---

## Caching Architecture

### Multi-Layer Caching Strategy

**Definition:** The system uses a 4-layer cache to optimize different stages of evaluation.

1.  **L1 Parsed Cache:** Maps source strings to ASTs (avoids re-parsing)
2.  **L2 Evaluation Cache:** Maps (AST + Variables) to Results
3.  **L3 Differentiation Cache:** Maps (AST + Variable) to Derived ASTs
4.  **L4 Sub-expression Cache:** Caches intermediate node results during recursion

**Consequence:** Redundant calculations are minimized at every level, but memory usage scales with cache size configurations.

### Cache Eviction and Validity

**Mechanisms:**
- **Eviction:** Configurable **LRU** (Least Recently Used) or **LFU** (Least Frequently Used) policies
- **TTL:** Optional Time-To-Live prevents stale data in long-running applications
- **Capacity:** Per-layer size limits (default: 128-512 entries)

**Tradeoff:** There is still no automatic invalidation when external context changes (e.g., redefining a custom function); the user must clear relevant cache layers or create a new evaluator.

---

## Platform and Runtime Considerations

### Thread Safety

**Status:** **NOT thread-safe.**

**Details:**

- Evaluator instances maintain mutable cache state
- Concurrent access from multiple threads will cause data races
- Each thread should have its own evaluator instance

### Cross-Platform Determinism

**Dart VM vs. JavaScript:**

- Floating-point operations may differ slightly between platforms
- `dart:math` functions may have different implementations
- Cache behavior is deterministic within a platform but may differ across platforms

**Recommendation:** Do not rely on exact numerical results across platforms. Use tolerance-based comparisons.

### Error Classification Stability

**API Stability:** Exception types are part of the public API and follow semantic versioning.

**Guarantees:**

- Exception types will not change in patch versions
- New exception types may be added in minor versions
- Exception hierarchy may be refactored in major versions

**Current Exception Types:**

- `LatexMathException`: Sealed base class for all library exceptions
- `TokenizerException`: Lexical errors during tokenization
- `ParserException`: Syntax errors during parsing
- `EvaluatorException`: Runtime errors (division by zero, domain errors, undefined variables, etc.)

### Parser Behavior Versioning

**Guarantee:** Parser behavior for valid expressions is stable within major versions.

**What May Change:**

- Error messages (not considered breaking)
- Performance characteristics (not considered breaking)
- New features (additive, not breaking)

**What Will NOT Change Without Major Version:**

- Parsing of previously valid expressions
- Operator precedence
- Associativity rules

---

## Reporting Issues

If you encounter behavior not documented here:

1. Check the [GitHub Issues](https://github.com/xirf/texpr/issues)
2. Use the appropriate issue template:
   - **Bug Report:** Unexpected behavior contradicting documentation
   - **Feature Request:** New capabilities within scope
   - **Performance Issue:** Specific performance problems with measurements
3. Provide:
   - Minimal reproduction example
   - Expected vs actual behavior
   - Version information (`pubspec.yaml`)
   - Platform details (Dart VM vs. JS, OS)
   - Stack trace if applicable

---

## Future Work (Not Yet Implemented)

These are potential enhancements under consideration but not yet scheduled:

- **Improved symbolic simplification:** More sophisticated pattern matching
- **Partial evaluation:** Simplify expressions with some variables bound
- **Expression serialization:** Save/load parsed expressions
- **Custom operator precedence:** User-defined precedence rules
- **Incremental parsing:** Reparse only changed portions of expressions

See [ROADMAP.md](../ROADMAP.md) for the full development plan.
