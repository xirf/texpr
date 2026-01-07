# Symbolic Computation

This document provides  specifications for TeXpr's symbolic computation capabilities, including exact differentiation, simplification rules, variable assumptions, and domain handling.

## Scope and Limitations

> [!IMPORTANT]
> TeXpr is **not** a full Computer Algebra System (CAS). Understanding these boundaries is critical:

| Capability               | TeXpr                 | Full CAS (SymPy, Mathematica) |
| ------------------------ | --------------------- | ----------------------------- |
| Symbolic differentiation | ✅ Exact               | ✅ Exact                       |
| Symbolic integration     | ❌ Numerical only      | ✅ Symbolic                    |
| Simplification           | Pattern-based         | Canonical forms               |
| Equation solving         | Linear/Quadratic only | General                       |
| Polynomial factoring     | Basic patterns        | Full algorithms               |
| Domain assumptions       | Basic                 | Comprehensive                 |

---

## Differentiation

### Exact vs. Numeric

TeXpr performs **exact symbolic differentiation**. Derivatives are computed by applying calculus rules to the AST, not by numerical approximation.

```dart
final expr = texpr.parse('x^3');
final deriv = texpr.differentiate(expr, 'x');
// Result: AST representing 3x²

// This is EXACT, not (f(x+h) - f(x))/h
```

### Differentiation Rules

The following rules are applied recursively:

| Rule           | Formula                      | Example                              |
| -------------- | ---------------------------- | ------------------------------------ |
| Constant       | `d/dx(c) = 0`                | `d/dx(5) = 0`                        |
| Variable       | `d/dx(x) = 1`                | `d/dx(x) = 1`                        |
| Other variable | `d/dx(y) = 0`                | `d/dx(y) = 0`                        |
| Power          | `d/dx(x^n) = n·x^(n-1)`      | `d/dx(x³) = 3x²`                     |
| Sum            | `d/dx(f+g) = f' + g'`        | `d/dx(x+1) = 1`                      |
| Product        | `d/dx(fg) = f'g + fg'`       | `d/dx(x·sin(x)) = sin(x) + x·cos(x)` |
| Quotient       | `d/dx(f/g) = (f'g - fg')/g²` | Standard quotient rule               |
| Chain          | `d/dx(f(g)) = f'(g)·g'`      | `d/dx(sin(x²)) = 2x·cos(x²)`         |
| Exponential    | `d/dx(e^f) = f'·e^f`         | `d/dx(e^x²) = 2x·e^x²`               |
| Logarithm      | `d/dx(ln(f)) = f'/f`         | `d/dx(ln(x)) = 1/x`                  |

### Function Derivatives

| Function    | Derivative       |
| ----------- | ---------------- |
| `sin(x)`    | `cos(x)`         |
| `cos(x)`    | `-sin(x)`        |
| `tan(x)`    | `sec²(x)`        |
| `sec(x)`    | `sec(x)·tan(x)`  |
| `csc(x)`    | `-csc(x)·cot(x)` |
| `cot(x)`    | `-csc²(x)`       |
| `arcsin(x)` | `1/√(1-x²)`      |
| `arccos(x)` | `-1/√(1-x²)`     |
| `arctan(x)` | `1/(1+x²)`       |
| `sinh(x)`   | `cosh(x)`        |
| `cosh(x)`   | `sinh(x)`        |
| `tanh(x)`   | `sech²(x)`       |

### Higher-Order Derivatives

```dart
texpr.differentiate(expr, 'x', order: 2);  // Second derivative
texpr.differentiate(expr, 'x', order: 3);  // Third derivative
```

**Limitation:** Very high-order derivatives (> 50) may hit recursion limits or produce very large ASTs.

---

## Integration

### Symbolic vs. Numerical

> [!WARNING]
> Integration is **numerical only**. TeXpr does not produce symbolic antiderivatives.

```dart
// This produces a numeric result, not an AST
texpr.evaluate(r'\int_{0}^{1} x^2 dx');  // 0.3333...
```

For symbolic integration, export to SymPy:

```dart
final sympy = texpr.parse(r'\int x^2 dx').toSymPy();
// "integrate(x**2, x)"  — run in Python for symbolic result
```

### Numerical Method

- **Algorithm:** Simpson's Rule
- **Intervals:** 10,000 (fixed)
- **Accuracy:** ~10 decimal places for smooth functions

---

## Simplification Rules

### Pattern-Based, Not Canonical

TeXpr applies local pattern matching. It does **not** produce canonical polynomial forms.

```dart
// These succeed
engine.simplify(parse('0 + x'));      // → x
engine.simplify(parse('x * 1'));      // → x
engine.simplify(parse('x + x'));      // → 2x

// This does NOT simplify
engine.simplify(parse('2x + 3x'));    // → 2x + 3x (not 5x)
```

### Applied Rules

| Pattern | Result | Condition          |
| ------- | ------ | ------------------ |
| `x + 0` | `x`    | Always             |
| `0 + x` | `x`    | Always             |
| `x - 0` | `x`    | Always             |
| `x * 1` | `x`    | Always             |
| `1 * x` | `x`    | Always             |
| `x * 0` | `0`    | Always             |
| `0 * x` | `0`    | Always             |
| `x / 1` | `x`    | Always             |
| `x ^ 0` | `1`    | x ≠ 0              |
| `x ^ 1` | `x`    | Always             |
| `0 ^ x` | `0`    | x > 0              |
| `1 ^ x` | `1`    | Always             |
| `x - x` | `0`    | Same subexpression |
| `x / x` | `1`    | x ≠ 0              |
| `--x`   | `x`    | Always             |
| `x + x` | `2x`   | Same subexpression |
| `x * x` | `x²`   | Same subexpression |

### Trigonometric Identities

| Identity                      | Applied            |
| ----------------------------- | ------------------ |
| `sin²(x) + cos²(x) = 1`       | Yes                |
| `sin(0) = 0`                  | Yes                |
| `cos(0) = 1`                  | Yes                |
| `tan(0) = 0`                  | Yes                |
| `sin(-x) = -sin(x)`           | Yes                |
| `cos(-x) = cos(x)`            | Yes                |
| `sin(2x) = 2·sin(x)·cos(x)`   | Via `expandTrig()` |
| `cos(2x) = cos²(x) - sin²(x)` | Via `expandTrig()` |

### Logarithm Laws

| Law                          | Applied             |
| ---------------------------- | ------------------- |
| `log(1) = 0`                 | Yes                 |
| `log(e) = 1` (for ln)        | Yes                 |
| `log(x^n) = n·log(x)`        | Yes                 |
| `log(ab) = log(a) + log(b)`  | Via specific method |
| `log(a/b) = log(a) - log(b)` | Via specific method |

---

## Variable Assumptions

### Default Behavior

Without assumptions, TeXpr assumes variables can be any complex number:

```dart
engine.simplify(parse('sqrt(x^2)'));  // → |x| (absolute value)
engine.simplify(parse('ln(x^2)'));    // → ln(|x|^2) or similar safe form
```

### Setting Assumptions

```dart
engine.assume('x', Assumption.nonNegative);
engine.simplify(parse('sqrt(x^2)'));  // → x (not |x|)
```

### Available Assumptions

| Assumption               | Meaning | Enables                       |
| ------------------------ | ------- | ----------------------------- |
| `Assumption.real`        | x ∈ ℝ   | Real-valued operations        |
| `Assumption.complex`     | x ∈ ℂ   | Default, no restrictions      |
| `Assumption.integer`     | x ∈ ℤ   | Integer optimizations         |
| `Assumption.positive`    | x > 0   | `sqrt(x²) = x`, `ln(x)` valid |
| `Assumption.nonNegative` | x ≥ 0   | `sqrt(x²) = x`                |
| `Assumption.negative`    | x < 0   | `sqrt(x²) = -x`               |
| `Assumption.nonPositive` | x ≤ 0   | Domain restrictions           |

### Clearing Assumptions

```dart
engine.clearAssumption('x');
// Or create a new engine instance
```

---

## Domain Restrictions

### Implicit Domains

Functions have implicit domain restrictions:

| Function    | Domain       | Behavior Outside          |
| ----------- | ------------ | ------------------------- |
| `sqrt(x)`   | x ≥ 0 (real) | Returns complex           |
| `ln(x)`     | x > 0 (real) | Returns complex or throws |
| `arcsin(x)` | -1 ≤ x ≤ 1   | Returns complex           |
| `arccos(x)` | -1 ≤ x ≤ 1   | Returns complex           |
| `1/x`       | x ≠ 0        | Returns ±∞                |

### Complex Number Handling

When domain restrictions are violated, TeXpr returns complex numbers:

```dart
texpr.evaluate('sqrt(-1)');   // ComplexResult(0, 1) = i
texpr.evaluate('ln(-1)');     // ComplexResult(0, π) = πi
texpr.evaluate('arcsin(2)');  // Complex result
```

Check result type:
```dart
final result = texpr.evaluate('sqrt(-1)');
if (result.isComplex) {
  final c = result.asComplex();
  print('${c.real} + ${c.imaginary}i');
}
```

---

## SymbolicEngine API

### Overview

```dart
import 'package:texpr/texpr.dart';

final engine = SymbolicEngine();
final texpr = Texpr();

final expr = texpr.parse('0 + x');
final simplified = engine.simplify(expr);
```

### Methods

| Method                    | Purpose                    | Example                            |
| ------------------------- | -------------------------- | ---------------------------------- |
| `simplify(expr)`          | Apply simplification rules | `0 + x` → `x`                      |
| `expand(expr)`            | Expand powers and products | `(x+1)²` → `x² + 2x + 1`           |
| `factor(expr)`            | Factor polynomials         | `x² - 4` → `(x-2)(x+2)`            |
| `expandTrig(expr)`        | Expand trig identities     | `sin(2x)` → `2·sin(x)·cos(x)`      |
| `solveLinear(eq, var)`    | Solve linear equations     | `2x + 4 = 0` → `-2`                |
| `solveQuadratic(eq, var)` | Solve quadratic equations  | `x² - 4 = 0` → `[2, -2]`           |
| `assume(var, assumption)` | Set domain assumption      | `assume('x', Assumption.positive)` |
| `areEquivalent(e1, e2)`   | Test equivalence           | `x + 1` ≡ `1 + x`                  |

### Expansion

```dart
engine.expand(texpr.parse('(x + 1)^2'));
// Result: x² + 2x + 1
```

Supports `(a + b)^n` for integer n ≤ 10.

### Factorization

```dart
engine.factor(texpr.parse('x^2 - 4'));
// Result: (x - 2)(x + 2)
```

Limited to recognizable patterns (difference of squares, perfect squares).

### Equation Solving

```dart
// Linear: ax + b = 0
engine.solveLinear(equation, 'x');

// Quadratic: ax² + bx + c = 0
engine.solveQuadratic(equation, 'x');
```

> [!WARNING]
> General polynomial solving (degree > 2) is not supported.

---

## Equivalence Testing

```dart
final e1 = texpr.parse('x + 1');
final e2 = texpr.parse('1 + x');
engine.areEquivalent(e1, e2);  // true
```

This works by:
1. Simplifying both expressions
2. Comparing the canonical AST structures

**Limitations:** May return `false` for equivalent expressions that require advanced algebraic manipulation to prove equal.

---

## What TeXpr Does NOT Do

For clarity, here's what you **cannot** do with TeXpr's symbolic engine:

| Operation                   | Status | Alternative         |
| --------------------------- | ------ | ------------------- |
| Symbolic integration        | ❌      | Export to SymPy     |
| General equation solving    | ❌      | External CAS        |
| System of equations         | ❌      | External CAS        |
| Polynomial long division    | ❌      | Manual or CAS       |
| Gröbner basis               | ❌      | Specialized library |
| Limit evaluation (symbolic) | ❌      | Numerical only      |
| Series expansion            | ❌      | External CAS        |
| Laplace/Fourier transforms  | ❌      | External CAS        |

---

## Performance Considerations

### Simplification Complexity

Simplification is **O(n)** for a single pass but may iterate up to 100 times for convergence:

```dart
// Worst case: 100 iterations × O(n) per iteration
engine.simplify(veryComplexExpression);
```

### AST Growth in Expansion

Expansion can produce exponentially larger ASTs:

```dart
(x + 1)^10  // Produces 11 terms
(x + y + z)^10  // Produces 66 terms
```

### Caching Derivatives

For repeated differentiation, cache the parsed expression:

```dart
final expr = texpr.parse('sin(x^2)');
final d1 = texpr.differentiate(expr, 'x');
final d2 = texpr.differentiate(d1, 'x');
// More efficient than re-parsing
```
