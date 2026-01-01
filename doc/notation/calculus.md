# Calculus Notation

The library supports basic calculus operations including limits and integration.

## Limits

Limits are evaluated by substituting the target value into the expression. Note that this is a simple substitution and does not handle indeterminate forms (like 0/0) using L'Hôpital's rule.

### Syntax

```latex
\lim_{variable \to target} expression
```

### Examples

- `\lim_{x \to 0} (x + 1)` evaluates to `1`.
- `\lim_{x \to 0} (x + 1)` evaluates to `1`.
- `\lim_{x \to \infty} \left(\frac{1}{x}\right)` evaluates to `0`.

## Integrals

The library supports both symbolic and numerical integration.

### Symbolic Integration

Indefinite and definite integrals are evaluated symbolically using standard calculus rules.

#### Supported Rules

- **Power Rule**: `\int x^n dx = \frac{x^{n+1}}{n+1}` (including `\int \frac{1}{x} dx = \ln|x|`)
- **Linearity**: `\int (f(x) \pm g(x)) dx = \int f(x) dx \pm \int g(x) dx`
- **Constant Multiple**: `\int c \cdot f(x) dx = c \cdot \int f(x) dx`
- **Exponentials**: `\int e^{ax+b} dx`, `\int \exp(ax+b) dx`
- **Trigonometric**: `\int \sin(ax+b) dx`, `\int \cos(ax+b) dx`

### Syntax

```latex
\int expression dx
\int_{lower}^{upper} expression dx
```

The differential term (e.g., `dx`, `dt`) at the end determines the variable of integration.

### Examples

- `\int x dx` evaluates to `x^2 / 2`.
- `\int_{0}^{1} x dx` evaluates to `0.5`.
- `\int \sin(x) dx` evaluates to `-\cos(x)`.
- `\int e^x dx` evaluates to `e^x`.
- `\int_{0}^{\pi} \sin{x} dx` evaluates to `2.0`.
- `\int_{1}^{e} \frac{1}{t} dt` evaluates to `1.0`.

### Numerical Integration (Fallback)

If a definite integral cannot be solved symbolically, it may fall back to numerical approximation using **Simpson's Rule**.

### Notes

- For numerical integration, the integration range is divided into 10,000 intervals for high-precision approximation.
- **Improper integrals**: Infinite bounds (e.g., `\int_{0}^{\infty}`) are basic-supported by substituting a large numeric range (e.g., ±100). This works well for functions that decay rapidly at infinity.
