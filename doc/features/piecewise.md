# Piecewise Functions

Piecewise functions allow you to define expressions that are only valid within specific domains or conditions. This is essential for modeling real-world scenarios where different rules apply in different ranges.

## Overview

The library supports piecewise functions through **conditional expressions** using the `ConditionalExpr` class. These expressions consist of two parts:

- **Expression**: The mathematical expression to evaluate
- **Condition**: The domain constraint that must be satisfied

## Syntax

Piecewise functions use the comma operator followed by a condition:

```latex
expression, condition
```

### Supported Conditions

The library supports these comparison operators for defining domains:

| Syntax        | Meaning          | Example                  |
| ------------- | ---------------- | ------------------------ |
| `a < x < b`   | Open interval    | `x^2, -5 < x < 5`        |
| `a <= x <= b` | Closed interval  | `\sin(x), 0 <= x <= \pi` |
| `x > a`       | Greater than     | `\ln(x), x > 0`          |
| `x >= a`      | Greater or equal | `\sqrt{x}, x >= 0`       |
| `x < a`       | Less than        | `e^x, x < 0`             |
| `x <= a`      | Less or equal    | `x^2, x <= 10`           |

You can also chain comparisons:

- `0 < x < 5` (x is between 0 and 5, exclusive)
- `-3 <= x <= 3` (x is between -3 and 3, inclusive)

## Basic Usage

### Evaluation

```dart
import 'package:texpr/texpr.dart';

final evaluator = LatexMathEvaluator();

// Define a piecewise function: x^2 for -5 < x < 5
final result1 = evaluator.evaluateNumeric(r'x^{2}, -5 < x < 5', {'x': 3.0});
print(result1); // 9.0 (3^2, within domain)

final result2 = evaluator.evaluateNumeric(r'x^{2}, -5 < x < 5', {'x': 10.0});
print(result2.isNaN); // true (outside domain)
```

### Outside Domain Behavior

When you evaluate a piecewise function outside its domain, the result is `NaN` (Not a Number):

```dart
// x must be between -3 and 3 (exclusive)
final result = evaluator.evaluateNumeric(r'\sin(x), -3 < x < 3', {'x': 5.0});
print(result.isNaN); // true
```

### Boundary Behavior

Boundaries are handled based on the comparison operator:

- **Exclusive** (`<`, `>`): Boundaries return `NaN`
- **Inclusive** (`<=`, `>=`): Boundaries return valid results

```dart
// Open interval: -5 < x < 5
final result1 = evaluator.evaluateNumeric(r'x^{2}, -5 < x < 5', {'x': -5.0});
print(result1.isNaN); // true (boundary excluded)

// Closed interval: -5 <= x <= 5
final result2 = evaluator.evaluateNumeric(r'x^{2}, -5 <= x <= 5', {'x': -5.0});
print(result2); // 25.0 (boundary included)
```

## Differentiation

One of the most powerful features is **automatic differentiation of piecewise functions**. The derivative maintains the same domain constraint.

### Basic Differentiation

```dart
// Differentiate x^2 with domain constraint
final derivative = evaluator.differentiate(r'x^{2}, -5 < x < 5', 'x');

// Evaluate the derivative at x=3: d/dx(x^2) = 2x = 6
final result = evaluator.evaluateParsed(derivative, {'x': 3.0});
print(result.asNumeric()); // 6.0

// Outside domain: NaN
final resultOut = evaluator.evaluateParsed(derivative, {'x': 10.0});
print(resultOut.asNumeric().isNaN); // true
```

### Differentiating Absolute Values

The library automatically handles absolute value differentiation using the sign function:

```dart
// d/dx(|sin(x)|) = cos(x) * sign(sin(x))
final derivative = evaluator.differentiate(r'|\sin{x}|, -3 < x < 3', 'x');

// At x = 1: sin(1) > 0, so sign = 1, derivative = cos(1)
final result1 = evaluator.evaluateParsed(derivative, {'x': 1.0});
print(result1.asNumeric()); // ≈ 0.5403 (cos(1))

// At x = 4: Outside domain
final result2 = evaluator.evaluateParsed(derivative, {'x': 4.0});
print(result2.asNumeric().isNaN); // true
```

### Higher-Order Derivatives

You can compute higher-order derivatives by specifying the `order` parameter:

```dart
// Second derivative of x^3
final secondDerivative = evaluator.differentiate(
  r'x^{3}, -5 < x < 5',
  'x',
  order: 2,
);

// d²/dx²(x^3) = 6x
final result = evaluator.evaluateParsed(secondDerivative, {'x': 2.0});
print(result.asNumeric()); // 12.0 (6 * 2)
```

## Common Use Cases

### 1. Domain-Restricted Functions

Mathematical functions often have natural domain restrictions:

```dart
// Natural logarithm: only defined for positive values
final ln = evaluator.evaluate(r'\ln(x), x > 0', {'x': 2.0});

// Square root: only defined for non-negative values
final sqrt = evaluator.evaluate(r'\sqrt{x}, x >= 0', {'x': 4.0});
```

### 2. Modeling Physical Constraints

```dart
// Velocity with maximum speed limit
final velocity = evaluator.evaluateNumeric(
  r'v \cdot t, 0 <= t <= 10',
  {'v': 5.0, 't': 3.0},
);
print(velocity); // 15.0

// Outside time range
final invalid = evaluator.evaluateNumeric(
  r'v \cdot t, 0 <= t <= 10',
  {'v': 5.0, 't': 15.0},
);
print(invalid.isNaN); // true
```

### 3. Analyzing Function Behavior in Intervals

```dart
// Study behavior of x^3 + 2x in specific interval
final expr = r'x^{3} + 2x, -10 < x < 10';
final derivative = evaluator.differentiate(expr, 'x');

// d/dx(x^3 + 2x) = 3x^2 + 2
final result = evaluator.evaluateParsed(derivative, {'x': 2.0});
print(result.asNumeric()); // 14.0
```

## Working with the AST

When you parse a piecewise expression, it creates a `ConditionalExpr` node in the Abstract Syntax Tree:

```dart
final expr = evaluator.parse(r'x^{2}, -5 < x < 5');
print(expr is ConditionalExpr); // true

// Convert back to LaTeX
print(expr.toLatex()); // "x^{2} \\text{ where } -5 < x < 5"
```

## `\begin{cases}` Syntax

The library now fully supports the standard LaTeX `\begin{cases}` environment for defining multi-branch piecewise functions:

### Basic Usage

```dart
final evaluator = LatexMathEvaluator();

// Parse a piecewise function using \begin{cases}
final expr = evaluator.parse(r'''
  \begin{cases}
    x^{2} & x < 0 \\
    2x & x \geq 0
  \end{cases}
''');

// Evaluate at different points
print(evaluator.evaluateParsed(expr, {'x': -2.0}).asNumeric()); // 4.0 (uses x^2)
print(evaluator.evaluateParsed(expr, {'x': 3.0}).asNumeric());  // 6.0 (uses 2x)
```

### ReLU Function Example

```dart
// ReLU: max(0, x)
final relu = evaluator.parse(r'''
  \begin{cases}
    0 & x < 0 \\
    x & x \geq 0
  \end{cases}
''');

print(evaluator.evaluateParsed(relu, {'x': -5.0}).asNumeric()); // 0.0
print(evaluator.evaluateParsed(relu, {'x': 5.0}).asNumeric());  // 5.0

// Differentiate ReLU
final reluDerivative = evaluator.differentiate(relu, 'x');
print(evaluator.evaluateParsed(reluDerivative, {'x': -1.0}).asNumeric()); // 0.0
print(evaluator.evaluateParsed(reluDerivative, {'x': 1.0}).asNumeric());  // 1.0
```

### With "Otherwise" Case

```dart
final expr = evaluator.parse(r'''
  \begin{cases}
    x^{2} & x < -10 \\
    x^{3} & x > 10 \\
    0 & \text{otherwise}
  \end{cases}
''');

print(evaluator.evaluateParsed(expr, {'x': 0.0}).asNumeric()); // 0.0 (otherwise)
```

### Integration of Piecewise Functions

```dart
// Integrate each branch independently
final expr = evaluator.parse(r'''
  \begin{cases}
    x & x < 0 \\
    x^{2} & x \geq 0
  \end{cases}
''');

final integral = evaluator.integrate(expr, 'x');
// Result: PiecewiseExpr with integrated branches
// x -> x^2/2
// x^2 -> x^3/3
```

## Limitations

### 1. Single Condition Per Case

Each case in a `\begin{cases}` environment has one expression and one condition. The library evaluates cases in order and returns the first matching result.

### 2. Integration Across Case Boundaries

While symbolic integration of each branch is supported, **automatic handling of definite integrals across case boundaries** is not yet fully implemented. For definite integrals spanning multiple branches, you may need to split the integral manually:

```dart
// To compute ∫₋₁¹ f(x) dx where f(x) is piecewise:
// Split into ∫₋₁⁰ + ∫₀¹ manually if boundaries cross case conditions
```

### 3. Condition Must Use Same Variable

The condition must reference the same variable being differentiated or evaluated:

```dart
// ✅ Valid: condition uses 'x'
evaluator.differentiate(r'x^{2}, -5 < x < 5', 'x');

// ❌ Invalid: condition uses 'y' but differentiating with respect to 'x'
// evaluator.differentiate(r'x^{2}, -5 < y < 5', 'x');
```

## Sign Function

The library provides the `\sign{}` (or `\sgn{}`) function for working with absolute values and piecewise logic:

```dart
// Sign function
final pos = evaluator.evaluateNumeric(r'\sign{5}');   // 1.0
final neg = evaluator.evaluateNumeric(r'\sign{-5}');  // -1.0
final zero = evaluator.evaluateNumeric(r'\sign{0}');  // 0.0

// Used in absolute value derivatives
final deriv = evaluator.differentiate(r'|x|', 'x');
// Returns: sign(x) * 1 = sign(x)
```

## Examples

### Example 1: Piecewise Derivative

```dart
final evaluator = LatexMathEvaluator();

// Define and differentiate
final derivative = evaluator.differentiate(r'x^{3} + 2x, -10 < x < 10', 'x');

// Test at different points
print(evaluator.evaluateParsed(derivative, {'x': 2.0}).asNumeric());
// Output: 14.0 (3*4 + 2)

print(evaluator.evaluateParsed(derivative, {'x': 15.0}).asNumeric().isNaN);
// Output: true (outside domain)
```

### Example 2: Absolute Value with Domain

```dart
final evaluator = LatexMathEvaluator();

// Differentiate |sin(x)| in the domain -3 < x < 3
final derivative = evaluator.differentiate(r'|\sin{x}|, -3 < x < 3', 'x');

// At x = 1 (where sin(1) > 0)
final result = evaluator.evaluateParsed(derivative, {'x': 1.0});
print(result.asNumeric()); // cos(1) ≈ 0.5403
```

### Example 3: Higher-Order Derivatives

```dart
final evaluator = LatexMathEvaluator();

// Second derivative
final d2 = evaluator.differentiate(r'x^{4}, -5 < x < 5', 'x', order: 2);

// d²/dx²(x^4) = 12x^2
print(evaluator.evaluateParsed(d2, {'x': 2.0}).asNumeric());
// Output: 48.0
```

## See Also

- [Differentiation](calculus/differentiation.md) - General differentiation features
- [Function Reference](functions/README.md) - All supported mathematical functions
- [LaTeX Commands](latex_commands.md) - Complete list of supported LaTeX notation
