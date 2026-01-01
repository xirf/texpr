# Symbolic Differentiation

The library supports symbolic differentiation using the standard LaTeX notation `\frac{d}{dx}` for first derivatives and `\frac{d^n}{dx^n}` for higher-order derivatives.

## Basic Syntax

```latex
\frac{d}{dx}(expression)
```

For higher-order derivatives:

```latex
\frac{d^{2}}{dx^{2}}(expression)  # Second derivative
\frac{d^{3}}{dx^{3}}(expression)  # Third derivative
```

## Supported Rules

The differentiation engine implements all standard calculus differentiation rules:

### Basic Rules

- **Constant Rule**: `d/dx(c) = 0`
- **Variable Rule**: `d/dx(x) = 1`, `d/dx(y) = 0` (w.r.t. x)
- **Power Rule**: `d/dx(x^n) = n·x^(n-1)`
- **Constant Multiple**: `d/dx(c·f) = c·f'`

### Combination Rules

- **Sum Rule**: `d/dx(f + g) = f' + g'`
- **Difference Rule**: `d/dx(f - g) = f' - g'`
- **Product Rule**: `d/dx(f·g) = f'·g + f·g'`
- **Quotient Rule**: `d/dx(f/g) = (f'·g - f·g')/g²`
- **Chain Rule**: `d/dx(f(g(x))) = f'(g(x))·g'(x)`

### Trigonometric Functions

| Function | Derivative     |
| -------- | -------------- |
| sin(x)   | cos(x)         |
| cos(x)   | -sin(x)        |
| tan(x)   | 1/cos²(x)      |
| cot(x)   | -1/sin²(x)     |
| sec(x)   | sec(x)·tan(x)  |
| csc(x)   | -csc(x)·cot(x) |

### Inverse Trigonometric Functions

| Function  | Derivative |
| --------- | ---------- |
| arcsin(x) | 1/√(1-x²)  |
| arccos(x) | -1/√(1-x²) |
| arctan(x) | 1/(1+x²)   |

### Hyperbolic Functions

| Function | Derivative |
| -------- | ---------- |
| sinh(x)  | cosh(x)    |
| cosh(x)  | sinh(x)    |
| tanh(x)  | 1/cosh²(x) |

### Exponential and Logarithmic Functions

| Function | Derivative   |
| -------- | ------------ |
| e^x      | e^x          |
| a^x      | a^x · ln(a)  |
| ln(x)    | 1/x          |
| log(x)   | 1/(x·ln(10)) |
| log₂(x)  | 1/(x·ln(2))  |

### Other Functions

| Function | Derivative    |
| -------- | ------------- |
| \sqrt{x} | 1/(2\sqrt{x}) |
| \|x\|    | \sign(x)      |
| \sign(x) | 0             |

### Piecewise Functions

The library supports differentiation of piecewise functions (conditional expressions). The derivative is computed for the expression part while preserving the condition.

```latex
\frac{d}{dx}(expression, condition)
```

**Rule**: `d/dx[f(x), condition] = d/dx[f(x)], condition`

**Note**: At the boundary points of the condition (e.g., x=3 for x<3), the derivative evaluates to `NaN` (undefined/discontinuous).

## Examples

### Basic Derivatives

```dart
import 'package:texpr/texpr.dart';

void main() {
  final evaluator = LatexMathEvaluator();

  // Constant rule
  print(evaluator.evaluateNumeric(r'\frac{d}{dx}(5)'));
  // Output: 0.0

  // Variable rule
  print(evaluator.evaluateNumeric(r'\frac{d}{dx}(x)', {'x': 3}));
  // Output: 1.0

  // Power rule
  print(evaluator.evaluateNumeric(r'\frac{d}{dx}(x^{2})', {'x': 3}));
  // Output: 6.0  (2·3 = 6)
}
```

### Sum and Product Rules

```dart
// Sum rule
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(x^{2} + x)', {'x': 3}));
// Output: 7.0  (2·3 + 1 = 7)

// Product rule
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(x \cdot x^{2})', {'x': 2}));
// Output: 12.0  (x² + x·2x = x² + 2x² = 3x² = 12 at x=2)
```

### Chain Rule

```dart
// d/dx(sin(x²)) = 2x·cos(x²)
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(\sin{x^{2}})', {'x': 0}));
// Output: 0.0

// d/dx((x²)³) = d/dx(x⁶) = 6x⁵
print(evaluator.evaluateNumeric(r'\frac{d}{dx}((x^{2})^{3})', {'x': 1}));
// Output: 6.0
```

### Quotient Rule

```dart
// d/dx(1/x) = -1/x²
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(\frac{1}{x})', {'x': 2}));
// Output: -0.25  (-1/4)

// d/dx(x/(x+1)) = 1/(x+1)²
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(\frac{x}{x+1})', {'x': 2}));
// Output: 0.111...  (1/9)
```

### Trigonometric Derivatives

```dart
// d/dx(sin(x)) = cos(x)
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(\sin{x})', {'x': 0}));
// Output: 1.0  (cos(0) = 1)

// d/dx(cos(x)) = -sin(x)
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(\cos{x})', {'x': 0}));
// Output: 0.0  (-sin(0) = 0)

// d/dx(tan(x)) = 1/cos²(x)
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(\tan{x})', {'x': 0}));
// Output: 1.0  (1/cos²(0) = 1)
```

### Exponential and Logarithmic Derivatives

```dart
// d/dx(e^x) = e^x
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(e^{x})', {'x': 1}));
// Output: 2.718... (e¹)

// d/dx(ln(x)) = 1/x
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(\ln{x})', {'x': 2}));
// Output: 0.5

// d/dx(2^x) = 2^x · ln(2)
print(evaluator.evaluateNumeric(r'\frac{d}{dx}(2^{x})', {'x': 1}));
// Output: 1.386... (2 · ln(2))
```

### Higher Order Derivatives

```dart
// Second derivative: d²/dx²(x³) = 6x
print(evaluator.evaluateNumeric(r'\frac{d^{2}}{dx^{2}}(x^{3})', {'x': 2}));
// Output: 12.0

// Third derivative: d³/dx³(x⁴) = 24x
print(evaluator.evaluateNumeric(r'\frac{d^{3}}{dx^{3}}(x^{4})', {'x': 2}));
// Output: 48.0

// Fourth derivative: d⁴/dx⁴(x⁴) = 24
print(evaluator.evaluateNumeric(r'\frac{d^{4}}{dx^{4}}(x^{4})', {'x': 2}));
// Output: 24.0
```

## Using the API for Symbolic Derivatives

The `differentiate()` method allows you to obtain symbolic derivatives that can be reused:

```dart
final evaluator = LatexMathEvaluator();

// Parse the original expression (optional)
final expr = evaluator.parse(r'x^{2} + 3x + 1');

// Get the symbolic derivative using Expression object
final derivative = evaluator.differentiate(expr, 'x');

// OR pass the string directly (easier!)
final derivative2 = evaluator.differentiate(r'x^{2} + 3x + 1', 'x');

// The derivative can now be evaluated at multiple points
print(evaluator.evaluateParsed(derivative, {'x': 0}).asNumeric());  // 3.0
print(evaluator.evaluateParsed(derivative, {'x': 1}).asNumeric());  // 5.0
print(evaluator.evaluateParsed(derivative, {'x': 2}).asNumeric());  // 7.0
```

### Multiple Derivatives

You can apply differentiation multiple times:

```dart
final expr = evaluator.parse(r'x^{3}');

// First derivative
final firstDeriv = evaluator.differentiate(expr, 'x');
// Result: 3·x²

// Second derivative
final secondDeriv = evaluator.differentiate(firstDeriv, 'x');
// Result: 6·x

// Evaluate
print(evaluator.evaluateParsed(secondDeriv, {'x': 2}).asNumeric());
// Output: 12.0
```

## Simplification

The differentiation engine performs basic algebraic simplifications:

- `0 + x` → `x`
- `x + 0` → `x`
- `0 · x` → `0`
- `1 · x` → `x`
- `x · 1` → `x`
- `x / 1` → `x`
- `x ^ 0` → `1`
- `x ^ 1` → `x`
- `-(-x)` → `x`

This makes the derivative results more readable.

## Complex Examples

### Polynomial Function

```dart
// f(x) = x³ + 2x² - 5x + 7
// f'(x) = 3x² + 4x - 5
final result = evaluator.evaluateNumeric(
  r'\frac{d}{dx}(x^{3} + 2x^{2} - 5x + 7)',
  {'x': 2}
);
// Output: 15.0  (3·4 + 4·2 - 5 = 12 + 8 - 5 = 15)
```

### Rational Function

```dart
// d/dx((x² + 1)/(x - 1))
final result = evaluator.evaluateNumeric(
  r'\frac{d}{dx}(\frac{x^{2} + 1}{x - 1})',
  {'x': 3}
);
// At x=3: (2·3·(3-1) - (9+1))/(3-1)² = (12 - 10)/4 = 0.5
```

### Exponential Function with Variable Base and Exponent

```dart
// d/dx(x^x) = x^x · (1 + ln(x))
final result = evaluator.evaluateNumeric(
  r'\frac{d}{dx}(x^{x})',
  {'x': 2}
);
// At x=2: 2² · (1 + ln(2)) ≈ 6.77
```

## Limitations

1. **No symbolic simplification beyond basic algebra**: The engine performs basic simplifications but doesn't do advanced algebraic manipulation.
2. **Maximum derivative order**: Currently supports up to 10th order derivatives.
3. **Discontinuities**: Derivatives at points of discontinuity (like floor, ceil, sign at 0) return 0, which is technically undefined.

## Performance Tips

For repeated differentiation of the same expression at different points:

```dart
// Parse once
final expr = evaluator.parse(r'x^{2} + 3x + 1');

// Differentiate once
final derivative = evaluator.differentiate(expr, 'x');

// Evaluate many times (very fast)
for (var x = 0; x < 100; x++) {
  final result = evaluator.evaluateParsed(derivative, {'x': x.toDouble()});
  print('f\'($x) = ${result.asNumeric()}');
}
```

This is much more efficient than calling `evaluateNumeric` with the full `\frac{d}{dx}` expression each time.
