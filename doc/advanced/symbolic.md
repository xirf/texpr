# Symbolic Algebra

The `SymbolicEngine` provides algebraic manipulation beyond numeric evaluation.

## Overview

```dart
import 'package:texpr/texpr.dart';

final engine = SymbolicEngine();
final texpr = Texpr();

final expr = texpr.parse('0 + x');
final simplified = engine.simplify(expr);
// Result: x
```

## Simplification

```dart
engine.simplify(expr);
```

Applies algebraic rules:

| Rule       | Example                      |
| ---------- | ---------------------------- |
| Identity   | `x + 0` → `x`, `x * 1` → `x` |
| Zero       | `x * 0` → `0`, `x - x` → `0` |
| Constants  | `2 + 3` → `5`                |
| Negation   | `--x` → `x`                  |
| Like terms | `x + x` → `2x`               |
| Powers     | `x * x` → `x²`               |

## Expansion

```dart
engine.expand(expr);
```

Expands polynomial expressions using binomial theorem:

```dart
// (x + 1)² → x² + 2x + 1
// (x + 2)³ → x³ + 6x² + 12x + 8
```

Supports `(a + b)^n` and `(a - b)^n` for integer n ≤ 10.

## Factorization

```dart
engine.factor(expr);
```

Factors polynomials:

```dart
// x² - 4 → (x - 2)(x + 2)  (difference of squares)
// x² - 1 → (x - 1)(x + 1)
```

## Trigonometric Identities

Recognized identities:

- `sin²(x) + cos²(x)` → `1`
- `sin(-x)` → `-sin(x)`
- `cos(-x)` → `cos(x)`
- `sin(2x)` → `2·sin(x)·cos(x)`

## Logarithm Laws

- `log(ab)` → `log(a) + log(b)`
- `log(a/b)` → `log(a) - log(b)`
- `log(aⁿ)` → `n·log(a)`
- `log(1)` → `0`

## Equation Solving

### Linear

```dart
// Solve 2x + 4 = 0
engine.solveLinear(equation, 'x');  // → -2
```

### Quadratic

```dart
// Solve x² - 4 = 0
engine.solveQuadratic(equation, 'x');  // → [2, -2]
```

## Assumptions

Provide domain constraints for more aggressive simplification:

```dart
// Without assumption: √(x²) → |x|
// With assumption: √(x²) → x

engine.assume('x', Assumption.nonNegative);
engine.simplify(expr);  // √(x²) → x
```

Available assumptions:
- `Assumption.real`
- `Assumption.integer`
- `Assumption.positive`
- `Assumption.nonNegative`
- `Assumption.negative`
- `Assumption.nonPositive`

## Equivalence Testing

```dart
engine.areEquivalent(expr1, expr2);  // true/false
```

Compares expressions after simplification.
