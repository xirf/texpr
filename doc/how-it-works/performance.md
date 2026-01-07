# Performance Characterization

This document provides asymptotic analysis, benchmark results, and performance recommendations for TeXpr. Understanding these characteristics is essential when evaluating user-supplied expressions.

## Asymptotic Complexity

### Parsing

| Operation    | Time Complexity | Space Complexity |
| ------------ | --------------- | ---------------- |
| Tokenization | O(n)            | O(n)             |
| Parsing      | O(n)            | O(d)             |
| Total        | O(n)            | O(n + d)         |

Where:
- n = input string length
- d = maximum nesting depth

The parser is a **single-pass recursive descent** with no backtracking, ensuring linear time complexity.

### Evaluation

| Expression Type   | Time Complexity       | Notes                         |
| ----------------- | --------------------- | ----------------------------- |
| Arithmetic        | O(nodes)              | Linear in AST size            |
| Function calls    | O(nodes)              | Single function call per node |
| Summation `∑`     | O(iterations × body)  | Iteration count dominates     |
| Integration `∫`   | O(10,000 × integrand) | Fixed 10k Simpson intervals   |
| Differentiation   | O(nodes)              | Symbolic, creates new AST     |
| Matrix operations | O(n³) for inverse/det | Standard matrix algorithms    |

### Worst-Case Scenarios

| Scenario                    | Complexity       | Mitigation             |
| --------------------------- | ---------------- | ---------------------- |
| Deep nesting `(((...)))`    | O(d) stack space | Recursion depth limit  |
| Large summation `∑_{1}^{n}` | O(n × body)      | Iteration limit (100k) |
| Repeated evaluation         | O(n) per call    | Use caching            |
| Complex derivatives         | O(n × order)     | AST grows with order   |

---

## Benchmark Results

### Test Environment

Benchmarks run on:
- **Language:** Dart VM (release mode)
- **Tool:** `benchmark_harness` package
- **Cache:** Disabled to measure raw performance

### Parse + Evaluate (Cold Path)

These benchmarks measure the full cycle of parsing and evaluating an expression:

| Expression                             | Time (µs)    | Category             |
| -------------------------------------- | ------------ | -------------------- |
| `1 + 2 + 3 + 4 + 5`                    | ~2-5         | Basic arithmetic     |
| `x * y * z`                            | ~3-6         | Multiplication chain |
| `\sin{x} + \cos{x}`                    | ~5-10        | Trigonometry         |
| `\sqrt{x^2 + y^2}`                     | ~5-10        | Power and root       |
| `\int_{0}^{1} x^2 dx`                  | ~2,000-3,000 | Definite integral    |
| `\frac{d}{dx}(x^{10})`                 | ~10-20       | Derivative           |
| `\lim_{x \to \infty} \frac{2x+1}{x+3}` | ~50-100      | Limit                |
| 2×2 matrix parse                       | ~10-20       | Matrix               |
| 3×3 matrix power                       | ~30-50       | Matrix operations    |
| Normal distribution PDF                | ~15-25       | Academic             |
| Lorentz factor                         | ~8-15        | Physics              |

### Evaluate Only (Hot Path)

Pre-parsed expressions with repeated evaluation:

| Expression              | Time (µs) | Speedup vs Cold |
| ----------------------- | --------- | --------------- |
| `\sin{x} + \cos{x}`     | ~1-2      | ~5x             |
| `\frac{d}{dx}(x^{10})`  | ~3-5      | ~4x             |
| Normal distribution PDF | ~3-5      | ~5x             |

### Caching Effects

| Scenario              | Throughput             |
| --------------------- | ---------------------- |
| Cold (no cache)       | ~500 evaluations/ms    |
| Warm (L1 parse cache) | ~5,000 evaluations/ms  |
| Hot (L2 eval cache)   | ~15,000 evaluations/ms |

---

## Cross-Language Comparison

TeXpr includes benchmarks for comparison against Python (SymPy) and JavaScript (mathjs).

### Methodology

- Each language uses **native benchmarking tools**
- Dart: `benchmark_harness`
- Python: `pytest-benchmark`
- JavaScript: `benchmark.js`

### Representative Results

| Expression        | Dart (TeXpr) | Python (SymPy) | JavaScript (mathjs) |
| ----------------- | ------------ | -------------- | ------------------- |
| Simple arithmetic | ~3 µs        | ~100 µs        | ~5 µs               |
| Trigonometry      | ~8 µs        | ~150 µs        | ~10 µs              |
| Normal PDF        | ~20 µs       | ~300 µs        | ~25 µs              |
| Matrix 2×2        | ~15 µs       | ~200 µs        | ~20 µs              |

> [!NOTE]
> SymPy is a full CAS with symbolic capabilities; direct comparison is not apples-to-apples.

### Running Benchmarks

```bash
# Dart
dart run benchmark/advanced_benchmark.dart

# Python
cd benchmark/comparison/python
pip install pytest pytest-benchmark sympy
pytest benchmark_pytest.py --benchmark-only -v

# JavaScript
cd benchmark/comparison/js
npm install
npm run benchmark
```

---

## Memory Characteristics

### Per-Expression Memory

| Component              | Typical Size  |
| ---------------------- | ------------- |
| Token                  | ~40 bytes     |
| AST node               | ~50-100 bytes |
| Simple expression AST  | ~500 bytes    |
| Complex expression AST | ~2-5 KB       |

### Cache Memory

| Cache Layer        | Default Size | Memory         |
| ------------------ | ------------ | -------------- |
| L1 Parse cache     | 128 entries  | ~64 KB typical |
| L2 Eval cache      | 256 entries  | ~16 KB typical |
| L3 Differentiation | 64 entries   | ~32 KB typical |
| L4 Sub-expression  | Transient    | Per-evaluation |

### Memory Limits

Configure cache sizes to bound memory usage:

```dart
final evaluator = Texpr(
  cacheConfig: CacheConfig(
    parsedExpressionCacheSize: 64,    // Smaller cache
    maxCacheInputLength: 2000,         // Reject very long inputs
  ),
);
```

---

## Performance Recommendations

### For High-Throughput Applications

1. **Parse once, evaluate many**
   ```dart
   final ast = texpr.parse(expression);
   for (final vars in variableSets) {
     texpr.evaluateParsed(ast, vars);
   }
   ```

2. **Enable caching** (default)
   ```dart
   final texpr = Texpr();  // Caching enabled by default
   ```

3. **Pre-warm cache** for known expressions
   ```dart
   for (final expr in commonExpressions) {
     texpr.parse(expr);  // Populates L1 cache
   }
   ```

### For User-Supplied Expressions

1. **Limit input length**
   ```dart
   if (input.length > 5000) {
     throw ArgumentError('Expression too long');
   }
   ```

2. **Validate before evaluating**
   ```dart
   final validation = texpr.validate(input);
   if (!validation.isValid) return handleError(validation);
   ```

3. **Consider timeouts**
   ```dart
   await Future.value(texpr.evaluate(input))
       .timeout(Duration(milliseconds: 100));
   ```

### For Real-Time Applications (60 FPS)

At 60 FPS, you have ~16ms per frame. Budget for expressions:

| Expression Complexity | Evaluations per Frame |
| --------------------- | --------------------- |
| Simple arithmetic     | ~5,000                |
| Trigonometry          | ~2,000                |
| With derivatives      | ~500                  |
| With integrals        | ~5-10                 |

**Recommendations:**
- Pre-parse all expressions outside the render loop
- Use evaluation-only caching
- Avoid integration in per-frame calculations

### For Mobile Devices

Mobile devices have slower CPUs. Apply a 2-4× slowdown factor:

| Desktop  | Mobile (estimated) |
| -------- | ------------------ |
| 3 µs     | 6-12 µs            |
| 20 µs    | 40-80 µs           |
| 2,000 µs | 4,000-8,000 µs     |

---

## Profiling Your Application

### Dart DevTools

```dart
import 'dart:developer';

Timeline.startSync('texpr_parse');
final ast = texpr.parse(expression);
Timeline.finishSync();

Timeline.startSync('texpr_evaluate');
final result = texpr.evaluateParsed(ast, variables);
Timeline.finishSync();
```

### Manual Timing

```dart
final sw = Stopwatch()..start();
for (var i = 0; i < 1000; i++) {
  texpr.evaluate(expression, variables);
}
sw.stop();
print('Average: ${sw.elapsedMicroseconds / 1000} µs');
```

---

## Optimization Internals

### L1-L4 Cache Layers

```
Expression String
       │
       ▼
┌──────────────────┐
│ L1 Parse Cache   │ ─── Hash(string) → AST
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ L2 Eval Cache    │ ─── Hash(AST, vars) → Result
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ L3 Diff Cache    │ ─── Hash(AST, var) → Derivative AST
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ L4 Sub-expr      │ ─── Per-evaluation transient cache
└──────────────────┘
```

### Cache Hit Rates

Typical hit rates in production use:

| Cache       | Expected Hit Rate                          |
| ----------- | ------------------------------------------ |
| L1 Parse    | 90-99% (repeated expressions)              |
| L2 Eval     | 50-80% (same expression, same vars)        |
| L3 Diff     | 80-95% (calculus operations)               |
| L4 Sub-expr | Variable (depends on expression structure) |

---

## Summary

| Metric                 | Typical Value   |
| ---------------------- | --------------- |
| Parse time             | 2-20 µs         |
| Eval time (simple)     | 1-10 µs         |
| Eval time (integral)   | 2,000-3,000 µs  |
| Cache speedup          | 5-30×           |
| Memory per expression  | 0.5-5 KB        |
| Throughput (hot cache) | 15,000 evals/ms |
