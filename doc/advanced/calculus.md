# Calculus

TeXpr supports symbolic and numerical calculus operations: differentiation, integration, limits, sums, and products.

## How Calculus Works in TeXpr

Unlike computer algebra systems that manipulate symbolic expressions, TeXpr takes a **hybrid approach**:

1. **Differentiation**: Fully symbolic — applies calculus rules to produce derivative expressions
2. **Integration**: Symbolic when possible, numerical fallback for complex expressions
3. **Limits**: Numerical evaluation by substitution (no L'Hôpital's rule)
4. **Sums/Products**: Direct iteration with upper bound limits

This design fits TeXpr's purpose: evaluating expressions quickly rather than producing simplified symbolic forms.

---

## Differentiation

Differentiation is the most complete symbolic operation in TeXpr. It applies standard calculus rules recursively.

### Basic Usage

```dart
final evaluator = Texpr();

// Differentiate x³ + sin(x) with respect to x
final derivative = evaluator.differentiate(r'x^3 + \sin{x}', 'x');

// The result is an AST representing: 3x² + cos(x)
// Evaluate at x = 0
evaluator.evaluateParsed(derivative, {'x': 0});  // 1.0
```

### LaTeX Syntax

You can also express derivatives directly in LaTeX:

```latex
\frac{d}{dx}(x^2)           % First derivative
\frac{d^2}{dx^2}(x^3)       % Second derivative
\frac{d^n}{dx^n}(f)         % n-th derivative
\frac{\partial}{\partial x}(xy)  % Partial derivative
```

### Higher-Order Derivatives

```dart
// Second derivative of x⁴
final secondDerivative = evaluator.differentiate(r'x^4', 'x', order: 2);
// Result: 12x²
```

### Supported Differentiation Rules

The evaluator implements these rules:

| Rule           | Formula                    | Example                              |
| -------------- | -------------------------- | ------------------------------------ |
| Constant       | `d/dx(c) = 0`              | `d/dx(5) = 0`                        |
| Variable       | `d/dx(x) = 1`              | `d/dx(x) = 1`                        |
| Other variable | `d/dx(y) = 0`              | `d/dx(y) = 0`                        |
| Power          | `d/dx(x^n) = n·x^(n-1)`    | `d/dx(x³) = 3x²`                     |
| Sum            | `d/dx(f+g) = f'+g'`        | `d/dx(x+1) = 1`                      |
| Product        | `d/dx(fg) = f'g + fg'`     | `d/dx(x·sin(x)) = sin(x) + x·cos(x)` |
| Quotient       | `d/dx(f/g) = (f'g-fg')/g²` | Standard quotient rule               |
| Chain          | `d/dx(f(g)) = f'(g)·g'`    | `d/dx(sin(x²)) = 2x·cos(x²)`         |

### Function Derivatives

| Function    | Derivative      |
| ----------- | --------------- |
| `sin(x)`    | `cos(x)`        |
| `cos(x)`    | `-sin(x)`       |
| `tan(x)`    | `sec²(x)`       |
| `e^x`       | `e^x`           |
| `ln(x)`     | `1/x`           |
| `log(x)`    | `1/(x·ln(10))`  |
| `sqrt(x)`   | `1/(2·sqrt(x))` |
| `arcsin(x)` | `1/sqrt(1-x²)`  |
| `arctan(x)` | `1/(1+x²)`      |

### Gradient Operator

The nabla operator computes partial derivatives with respect to all detected variables:

```dart
evaluator.evaluate(r'\nabla{x^2 + y^2}', {'x': 1, 'y': 2});
// Returns Vector: [2.0, 4.0]
// Computed as: [∂/∂x = 2x, ∂/∂y = 2y] evaluated at (1, 2)
```

---

## Integration

Integration combines symbolic rules with numerical fallback.

### Symbolic Integration (Indefinite)

When TeXpr can apply known integration rules, it returns an expression:

```dart
evaluator.integrate(r'x^2', 'x');
// Returns AST for: x³/3
```

**Supported symbolic rules:**

| Pattern       | Result                     |
| ------------- | -------------------------- |
| `∫ x^n dx`    | `x^(n+1)/(n+1)` for n ≠ -1 |
| `∫ 1/x dx`    | `ln(x)`                    |
| `∫ e^x dx`    | `e^x`                      |
| `∫ sin(x) dx` | `-cos(x)`                  |
| `∫ cos(x) dx` | `sin(x)`                   |
| `∫ (f+g) dx`  | `∫f dx + ∫g dx`            |
| `∫ c·f dx`    | `c · ∫f dx`                |

### Definite Integration

For definite integrals, TeXpr first tries symbolic evaluation, then falls back to numerical:

```dart
evaluator.evaluate(r'\int_{0}^{\pi} \sin{x} dx');  // 2.0
evaluator.evaluate(r'\int_{1}^{e} \frac{1}{t} dt'); // 1.0
```

### Numerical Integration (Simpson's Rule)

When symbolic integration fails, definite integrals use **Simpson's Rule** with 10,000 intervals:

```dart
// Gaussian integral — no closed form in elementary functions
evaluator.evaluate(r'\int_{0}^{1} e^{-x^2} dx');
// Numerically approximates: ≈ 0.7468
```

**How Simpson's Rule works:**
The integral ∫ₐᵇ f(x)dx is approximated by dividing [a,b] into n intervals and applying weighted sums of function values. With 10,000 intervals, accuracy is typically 10+ decimal places for smooth functions.

### Multiple Integrals

```dart
evaluator.evaluate(r'\iint{x^2 + y^2} dx dy');
evaluator.evaluate(r'\iiint{xyz} dx dy dz');
```

The differential at the end (`dx dy`) determines the order of integration.

### Improper Integrals

Infinite bounds are approximated with finite values:

```dart
evaluator.evaluate(r'\int_{0}^{\infty} e^{-x} dx');
// Replaces ∞ with 100, computes ∫₀¹⁰⁰ e⁻ˣ dx ≈ 1.0
```

::: warning Limitations of Improper Integrals
- Default bound: ±100 for infinity
- Works well for rapidly decaying functions (e^(-x), 1/x², etc.)
- May be inaccurate for slow-decaying functions
- **Asymptotes are problematic**: If the integration path crosses a vertical asymptote (like tan(x) or 1/x near 0), results will be incorrect
:::

---

## Limits

Limits are evaluated by direct substitution and numerical probing.

### Basic Usage

```dart
evaluator.evaluate(r'\lim_{x \to 0} (x + 1)');  // 1.0
evaluator.evaluate(r'\lim_{x \to \infty} \frac{1}{x}');  // 0.0
```

### LaTeX Syntax

```latex
\lim_{variable \to target} expression
```

Examples:
```latex
\lim_{x \to 0} \frac{\sin{x}}{x}      % → 1.0
\lim_{n \to \infty} (1 + \frac{1}{n})^n  % → e (≈ 2.718)
```

### How Limits Work Internally

1. **Direct substitution**: If the target is finite, substitute directly
2. **Infinity handling**: For x→∞, evaluate at [10², 10⁴, 10⁶, 10⁸] and return the last stable value
3. **No indeterminate form handling**: 0/0 and ∞/∞ are not resolved via L'Hôpital's rule

::: warning Limitation
Limits **do not** apply L'Hôpital's rule. Indeterminate forms like `lim_{x→0} sin(x)/x` work because numerical evaluation at values near 0 converges correctly, not because of symbolic manipulation.
:::

---

## Summation

Compute finite sums by iteration:

```dart
evaluator.evaluate(r'\sum_{i=1}^{10}{i}');      // 55 (1+2+...+10)
evaluator.evaluate(r'\sum_{i=1}^{10}{i^2}');    // 385
evaluator.evaluate(r'\sum_{k=0}^{5}{\frac{1}{k!}}');  // ≈ e
```

### LaTeX Syntax

```latex
\sum_{variable=start}^{end}{expression}
```

### Performance

- Iterations are bounded at **100,000** per operation
- Memory usage is O(1) — results accumulate, not stored
- For large sums, consider mathematical simplification

---

## Products

Compute finite products by iteration:

```dart
evaluator.evaluate(r'\prod_{i=1}^{5}{i}');  // 120 (5!)
evaluator.evaluate(r'\prod_{k=1}^{n}{\frac{k+1}{k}}', {'n': 10});  // 11
```

### LaTeX Syntax

```latex
\prod_{variable=start}^{end}{expression}
```

---

## Piecewise Functions and Calculus

TeXpr supports differentiation of piecewise functions:

```dart
// Absolute value of sin(x) on interval (-3, 3)
final derivative = evaluator.differentiate(r'|\sin{x}|, -3 < x < 3', 'x');
evaluator.evaluateParsed(derivative, {'x': 1});  // cos(1) for x > 0
```

---

## Error Handling

Calculus operations can throw `EvaluatorException`:

| Error            | Cause                                     | Example                         |
| ---------------- | ----------------------------------------- | ------------------------------- |
| Division by zero | Differentiated expression divides by zero | `d/dx(1/x)` at x=0              |
| Domain error     | Function undefined at evaluation point    | `∫ ln(x) dx` evaluated at x=0   |
| Recursion limit  | Expression too deeply nested              | Very complex nested derivatives |

---

## Performance Tips

1. **Cache parsed expressions**: For repeated differentiation/integration
   ```dart
   final ast = evaluator.parse(r'x^3');
   final d1 = evaluator.differentiate(ast, 'x');
   final d2 = evaluator.differentiate(d1, 'x');
   ```

2. **Avoid unnecessary precision**: Numerical integration with 10,000 intervals is usually overkill for visualizations

3. **Pre-compute derivatives**: If you need dy/dx at many points, differentiate once and evaluate the derivative AST

---

## Comparison with CAS Systems

| Feature                  | TeXpr                 | SymPy/Mathematica |
| ------------------------ | --------------------- | ----------------- |
| Symbolic differentiation | ✓                     | ✓                 |
| Symbolic integration     | Limited rules         | Comprehensive     |
| Simplification           | Basic                 | Full              |
| Equation solving         | Linear/quadratic only | General           |
| Performance              | Fast (µs)             | Slower (ms)       |
| Domain                   | Numerical focus       | Symbolic focus    |

TeXpr is designed for **fast evaluation**, not symbolic manipulation. Use a CAS when you need algebraic simplification or complex symbolic integration.
