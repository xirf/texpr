# Evaluator

The evaluator is the third stage of the processing pipeline. It traverses the AST and computes the final result by recursively evaluating each node.

## How Evaluation Works

The evaluator performs a **post-order traversal** of the AST: it evaluates child nodes first, then applies the operation at the current node.

**Example**: Evaluating `2 * x + 1` with `x = 3`:

```
       BinaryOp(+)          Step 4: 6 + 1 = 7 ✓
         /    \
   BinaryOp(*)   1          Step 3: evaluate 1 → 1
     /    \
    2      x                Step 1: evaluate 2 → 2
                            Step 2: evaluate x → 3 (from variables)
                            Step 2.5: 2 * 3 = 6
```

The traversal order ensures operands are ready before operations are applied.

---

## Variable Resolution

When the evaluator encounters a `Variable` node, it looks up the value in the provided variable map:

```dart
final result = evaluator.evaluate(r'x^2 + y', {'x': 3, 'y': 5});
// x → 3, y → 5
// 3^2 + 5 = 14
```

### Undefined Variables

If a variable isn't in the map, the evaluator throws an `EvaluatorException`:

```dart
evaluator.evaluate(r'x + y', {'x': 1});  
// throws: "Undefined variable: y"
```

The exception includes a suggestion if similar variable names exist in the expression.

### Reserved Names

Some names are reserved and cannot be used as variables:
- `e` — Euler's number (2.71828...)
- `i` — Imaginary unit
- Greek letters like `π` (pi), `τ` (tau), `φ` (phi)

---

## Result Types

Evaluation returns an `EvaluationResult`, which is a sealed class with four variants:

```dart
sealed class EvaluationResult {
  double asNumeric();      // throws if not numeric
  Complex asComplex();     // throws if not scalar
  Matrix asMatrix();       // throws if not matrix
  Vector asVector();       // throws if not vector
}

class NumericResult extends EvaluationResult {
  final double value;
}

class ComplexResult extends EvaluationResult {
  final Complex value;
}

class MatrixResult extends EvaluationResult {
  final Matrix matrix;
}

class VectorResult extends EvaluationResult {
  final Vector vector;
}
```

### Type Determination

The result type depends on what the expression produces:

| Expression                                     | Result Type     |
| ---------------------------------------------- | --------------- |
| `2 + 3`                                        | `NumericResult` |
| `e^{i\pi}`                                     | `ComplexResult` |
| `\sqrt{-1}`                                    | `ComplexResult` |
| `\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}` | `MatrixResult`  |
| `\nabla{x^2 + y^2}`                            | `VectorResult`  |

### Pattern Matching

Use Dart's pattern matching to handle different result types:

```dart
final result = evaluator.evaluate(r'e^{i\pi}');

switch (result) {
  case NumericResult(:final value):
    print('Real number: $value');
  case ComplexResult(:final value):
    print('Complex: ${value.real} + ${value.imaginary}i');
  case MatrixResult(:final matrix):
    print('Matrix: ${matrix.rows}x${matrix.cols}');
  case VectorResult(:final vector):
    print('Vector: $vector');
}
```

---

## Built-in Functions

The evaluator knows how to compute ~50 built-in functions:

### Trigonometric Functions
`sin`, `cos`, `tan`, `cot`, `sec`, `csc` and their inverses (`asin`, `acos`, etc.) and hyperbolic variants (`sinh`, `cosh`, etc.)

### Logarithmic Functions
`log` (base 10), `ln` (natural), `log2`, `log10`, and `log_b` (arbitrary base via `\log_{b}`)

### Other Functions
`sqrt`, `abs`, `floor`, `ceil`, `round`, `max`, `min`, `gcd`, `lcm`, `factorial`, etc.

### How Functions Are Evaluated

1. Evaluate the argument(s)
2. Dispatch to the appropriate implementation
3. Return the result

```dart
// sin(x) evaluation:
// 1. Evaluate x → 3.14159
// 2. Call dart:math sin() → ~0.0
// 3. Return NumericResult(~0.0)
```

---

## Complex Number Handling

The evaluator automatically promotes to complex numbers when needed:

### Automatic Promotion
```dart
evaluator.evaluate(r'\sqrt{-1}');  
// Can't take sqrt of negative in reals
// → ComplexResult(0, 1)  // i
```

### Complex Arithmetic
All basic operations work on complex numbers:
```dart
evaluator.evaluate(r'(3 + 4i) * (1 - 2i)');
// (3 + 4i)(1 - 2i) = 3 - 6i + 4i - 8i² = 3 - 2i + 8 = 11 - 2i
// → ComplexResult(11, -2)
```

### Complex Functions
Trigonometric and exponential functions extend to complex domain:
```dart
evaluator.evaluate(r'e^{i \pi}');
// Euler's identity: e^(iπ) = -1
// → ComplexResult(-1, 0)

evaluator.evaluate(r'\sin{1 + 2i}');
// Complex sine: sin(1+2i) ≈ 3.166 + 1.960i
// → ComplexResult(3.166, 1.960)
```

---

## Matrix Operations

The evaluator supports linear algebra operations:

### Matrix Arithmetic
```dart
// Addition
evaluator.evaluate(r'\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix} + \begin{pmatrix} 5 & 6 \\ 7 & 8 \end{pmatrix}');

// Multiplication
evaluator.evaluate(r'A \cdot B', {'A': matrixA, 'B': matrixB});

// Power (repeated multiplication or inverse)
evaluator.evaluate(r'A^{-1}');  // Matrix inverse
evaluator.evaluate(r'A^2');      // A * A
```

### Matrix Functions
```dart
evaluator.evaluate(r'\det{A}');    // Determinant
evaluator.evaluate(r'\tr{A}');     // Trace
evaluator.evaluate(r'A^T');        // Transpose
```

---

## Differentiation

The evaluator can compute symbolic derivatives:

```dart
final derivative = evaluator.differentiate(r'x^3 + \sin{x}', 'x');
// Returns AST: 3*x^2 + cos(x)
```

### How It Works

Differentiation applies calculus rules recursively:

| Rule     | Example                            |
| -------- | ---------------------------------- |
| Constant | `d/dx(5) = 0`                      |
| Variable | `d/dx(x) = 1`, `d/dx(y) = 0`       |
| Power    | `d/dx(x^n) = n*x^(n-1)`            |
| Sum      | `d/dx(f+g) = f' + g'`              |
| Product  | `d/dx(f*g) = f'*g + f*g'`          |
| Chain    | `d/dx(f(g(x))) = f'(g(x)) * g'(x)` |

### Higher-Order Derivatives

```dart
evaluator.differentiate(r'x^4', 'x', order: 2);
// First: 4*x^3
// Second: 12*x^2
// Returns AST for 12*x^2
```

### Gradient

The nabla operator computes partial derivatives with respect to all variables:

```dart
evaluator.evaluate(r'\nabla{x^2 + y^2}', {'x': 1, 'y': 2});
// ∂/∂x = 2x, ∂/∂y = 2y
// At (1, 2): [2, 4]
// → VectorResult([2.0, 4.0])
```

---

## Integration

### Symbolic Integration

The evaluator applies integration rules when possible:

```dart
evaluator.integrate(r'x^2', 'x');
// Returns AST: x^3 / 3
```

Supported rules:
- Power rule: `∫x^n dx = x^(n+1)/(n+1)`
- Exponentials: `∫e^x dx = e^x`
- Trigonometric: `∫sin(x) dx = -cos(x)`
- Linearity: `∫(f+g) dx = ∫f dx + ∫g dx`

### Numerical Integration (Definite Integrals)

For definite integrals that can't be solved symbolically, the evaluator uses **Simpson's Rule** with 10,000 intervals:

```dart
evaluator.evaluate(r'\int_{0}^{1} e^{-x^2} dx');
// Can't solve symbolically
// Falls back to numerical: ≈ 0.7468
```

### Improper Integrals

Infinite bounds are approximated with large finite values:

```dart
evaluator.evaluate(r'\int_{0}^{\infty} e^{-x} dx');
// Replaces ∞ with 100
// ∫₀¹⁰⁰ e^(-x) dx ≈ 1.0
```

::: warning
This approximation works well for rapidly decaying functions but may be inaccurate for slow-converging functions or functions with asymptotes.
:::

---

## Error Handling

The evaluator throws `EvaluatorException` for runtime errors:

### Domain Errors
```dart
evaluator.evaluate(r'\log{0}');     // log of 0 undefined
evaluator.evaluate(r'\sqrt{-1}');   // OK (returns i), but \log{-1} requires complex
evaluator.evaluate(r'1 / 0');       // Division by zero
```

### Undefined Variables
```dart
evaluator.evaluate(r'x + y', {'x': 1});
// "Undefined variable: y"
```

### Function Errors
```dart
evaluator.evaluate(r'\arcsin{2}');  
// Domain error: arcsin requires -1 ≤ x ≤ 1
```

All exceptions include position information and suggestions when available.

---

## Performance Tips

1. **Parse once, evaluate many**: For repeated evaluation with different variables, use `parse()` + `evaluateParsed()`

2. **Reuse variable maps**: Creating new Map objects bypasses L2 cache. Mutate the same map:
   ```dart
   final vars = {'x': 0.0};
   for (var i = 0; i < 1000; i++) {
     vars['x'] = i.toDouble();
     evaluator.evaluateParsed(ast, vars);
   }
   ```

3. **Avoid expensive operations in loops**: Integrals and summations with large ranges are costly. Pre-compute if possible.

---

## Summary

The evaluator:
1. Traverses the AST in post-order (children first)
2. Resolves variables from the provided map
3. Applies operations and function calls
4. Returns typed results (Numeric, Complex, Matrix, Vector)
5. Supports symbolic differentiation and integration
6. Handles errors with informative messages

Results are often cached to avoid redundant computation — see [Caching](./caching.md).
