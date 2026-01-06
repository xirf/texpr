# Supported LaTeX Commands

This document provides a reference of all LaTeX commands supported by the `texpr` library.

## Quick Reference

| Category       | Commands                                                                          |
| -------------- | --------------------------------------------------------------------------------- |
| **Arithmetic** | `+`, `-`, `*`, `/`, `^`, `\times`, `\cdot`, `\div`                                |
| **Calculus**   | `\frac`, `\int`, `\iint`, `\iiint`, `\sum`, `\prod`, `\lim`, `\partial`, `\nabla` |
| **Functions**  | `\sin`, `\cos`, `\tan`, `\log`, `\ln`, `\sqrt`, `\exp`, `\abs`                    |
| **Greek**      | `\alpha`–`\omega`, `\Alpha`–`\Psi`, `\varepsilon`, `\varphi`                      |
| **Matrices**   | `\begin{matrix}`, `\begin{pmatrix}`, `\begin{bmatrix}`                            |
| **Special**    | `\binom`, `\infty`, `\pi`, `\text{}`, `\mathbf{}`                                 |
| **Logic**      | `\forall`, `\exists`, `\Rightarrow`, `\Leftarrow`, `\Leftrightarrow`              |
| **Sets**       | `\subset`, `\subseteq`, `\cup`, `\cap`, `\setminus`                               |
| **Decoration** | `\dot`, `\ddot`, `\bar`, `\overline`                                              |

---

## Arithmetic Operators

| LaTeX           | Description                  | Example                 |
| --------------- | ---------------------------- | ----------------------- |
| `+`             | Addition                     | `3 + 4` to `7`          |
| `-`             | Subtraction                  | `5 - 2` to `3`          |
| `*` or `\times` | Multiplication               | `3 \times 4` to `12`    |
| `/` or `\div`   | Division                     | `8 \div 2` to `4`       |
| `^`             | Exponentiation               | `2^{10}` to `1024`      |
| `\cdot`         | Dot product / Multiplication | `\vec{a} \cdot \vec{b}` |

**Implicit Multiplication:** The parser supports implicit multiplication:

```latex
2x         to 2 * x
xy         to x * y
2\pi r     to 2 * π * r
\sin x \cos x to sin(x) * cos(x)
```

---

## Mathematical Functions

### Trigonometric Functions

For more details, see [Function Reference](./functions.md).

| LaTeX     | Description | Complex Support |
| --------- | ----------- | --------------- |
| `\sin{x}` | Sine        | ✅               |
| `\cos{x}` | Cosine      | ✅               |
| `\tan{x}` | Tangent     | ✅               |
| `\cot{x}` | Cotangent   | ✅               |
| `\sec{x}` | Secant      | ✅               |
| `\csc{x}` | Cosecant    | ✅               |

### Inverse Trigonometric Functions

| LaTeX        | Alias      | Description       |
| ------------ | ---------- | ----------------- |
| `\arcsin{x}` | `\asin{x}` | Inverse sine      |
| `\arccos{x}` | `\acos{x}` | Inverse cosine    |
| `\arctan{x}` | `\atan{x}` | Inverse tangent   |
| `\arccot{x}` | `\acot{x}` | Inverse cotangent |
| `\arcsec{x}` | `\asec{x}` | Inverse secant    |
| `\arccsc{x}` | `\acsc{x}` | Inverse cosecant  |

### Hyperbolic Functions

| LaTeX      | Description          | Complex Support |
| ---------- | -------------------- | --------------- |
| `\sinh{x}` | Hyperbolic sine      | ✅               |
| `\cosh{x}` | Hyperbolic cosine    | ✅               |
| `\tanh{x}` | Hyperbolic tangent   | ✅               |
| `\coth{x}` | Hyperbolic cotangent | ✅               |
| `\sech{x}` | Hyperbolic secant    | ✅               |
| `\csch{x}` | Hyperbolic cosecant  | ✅               |

### Inverse Hyperbolic Functions

| LaTeX       | Description                  |
| ----------- | ---------------------------- |
| `\asinh{x}` | Inverse hyperbolic sine      |
| `\acosh{x}` | Inverse hyperbolic cosine    |
| `\atanh{x}` | Inverse hyperbolic tangent   |
| `\acoth{x}` | Inverse hyperbolic cotangent |
| `\asech{x}` | Inverse hyperbolic secant    |
| `\acsch{x}` | Inverse hyperbolic cosecant  |

### Logarithmic & Exponential Functions

For more details, see [Function Reference](./functions.md).

| LaTeX         | Description       | Example              |
| ------------- | ----------------- | -------------------- |
| `\ln{x}`      | Natural logarithm | `\ln{e}` to `1`      |
| `\log{x}`     | Logarithm base 10 | `\log{100}` to `2`   |
| `\log_{b}{x}` | Logarithm base b  | `\log_{2}{8}` to `3` |
| `\exp{x}`     | Exponential (e^x) | `\exp{1}` to `e`     |

### Power & Root Functions

| LaTeX         | Description | Example               |
| ------------- | ----------- | --------------------- |
| `\sqrt{x}`    | Square root | `\sqrt{16}` to `4`    |
| `\sqrt[n]{x}` | n-th root   | `\sqrt[3]{27}` to `3` |

### Rounding Functions

| LaTeX       | Description        | Example              |
| ----------- | ------------------ | -------------------- |
| `\floor{x}` | Floor (round down) | `\floor{3.7}` to `3` |
| `\ceil{x}`  | Ceiling (round up) | `\ceil{3.2}` to `4`  |
| `\round{x}` | Round to nearest   | `\round{3.5}` to `4` |

### Other Functions

For more details, see [Function Reference](./functions.md).

| LaTeX                   | Description             | Example                  |
| ----------------------- | ----------------------- | ------------------------ |
| `\abs{x}` or `\|x\|`    | Absolute value          | `\abs{-5}` to `5`        |
| `\sgn{x}` or `\sign{x}` | Sign function           | `\sgn{-3}` to `-1`       |
| `\min{a, b}`            | Minimum                 | `\min{3, 5}` to `3`      |
| `\max{a, b}`            | Maximum                 | `\max{3, 5}` to `5`      |
| `\gcd{a, b}`            | Greatest common divisor | `\gcd{12, 8}` to `4`     |
| `\lcm{a, b}`            | Least common multiple   | `\lcm{4, 6}` to `12`     |
| `\factorial{n}` or `n!` | Factorial               | `\factorial{5}` to `120` |
| `\fibonacci{n}`         | Fibonacci number        | `\fibonacci{10}` to `55` |

### Decoration Functions (Pass-through)

These functions wrap an expression but return the evaluated value of the argument during numerical computation.

| LaTeX          | Description       | Example               |
| -------------- | ----------------- | --------------------- |
| `\dot{x}`      | Time derivative   | `\dot{5}` to `5`      |
| `\ddot{x}`     | Second derivative | `\ddot{5}` to `5`     |
| `\bar{x}`      | Bar / Mean        | `\bar{5}` to `5`      |
| `\overline{x}` | Overline          | `\overline{5}` to `5` |

### Complex Number Functions

For more details, see [Function Reference](./functions.md).

| LaTeX                             | Description       | Example                          |
| --------------------------------- | ----------------- | -------------------------------- |
| `\Re{z}`                          | Real part         | `\Re{3 + 4i}` to `3`             |
| `\Im{z}`                          | Imaginary part    | `\Im{3 + 4i}` to `4`             |
| `\conjugate{z}` or `\overline{z}` | Complex conjugate | `\conjugate{3 + 4i}` to `3 - 4i` |

---

## Calculus Notation

For more details, see [Calculus](../advanced/calculus.md).

### Fractions

```latex
\frac{numerator}{denominator}
```

Example: `\frac{x^2 + 1}{x - 1}`

### Derivatives

| Syntax                               | Description               |
| ------------------------------------ | ------------------------- |
| `\frac{d}{dx}(f)`                    | First derivative          |
| `\frac{d^2}{dx^2}(f)`                | Second derivative         |
| `\frac{d^n}{dx^n}(f)`                | n-th derivative           |
| `\frac{\partial}{\partial x}(f)`     | Partial derivative        |
| `\frac{\partial^2}{\partial x^2}(f)` | Second partial derivative |

### Integrals

| LaTeX                | Description         |
| -------------------- | ------------------- |
| `\int{f} dx`         | Indefinite integral |
| `\int_{a}^{b}{f} dx` | Definite integral   |
| `\iint{f} dx dy`     | Double integral     |
| `\iiint{f} dx dy dz` | Triple integral     |

Example:

```latex
\int_{0}^{\pi} \sin{x} dx
\iint{x^2 + y^2} dx dy
```

### Summation & Products

| LaTeX                | Description | Example                       |
| -------------------- | ----------- | ----------------------------- |
| `\sum_{i=a}^{b}{f}`  | Summation   | `\sum_{i=1}^{10}{i}` to `55`  |
| `\prod_{i=a}^{b}{f}` | Product     | `\prod_{i=1}^{5}{i}` to `120` |

### Limits

```latex
\lim_{x \to a} f(x)
```

Example: `\lim_{x \to 0} \frac{\sin{x}}{x}` to `1`

### Binomial Coefficient

```latex
\binom{n}{k}
```

Example: `\binom{10}{3}` to `120`

### Special Symbols

| LaTeX                  | Description                   |
| ---------------------- | ----------------------------- |
| `\partial`             | Partial derivative symbol (∂) |
| `\nabla`               | Gradient operator (∇)         |
| `\infty`               | Infinity (∞)                  |
| `\to` or `\rightarrow` | Arrow (to)                    |
| `\mapsto`              | Maps to (↦)                   |
| `\Rightarrow`          | Double right arrow (⇒)        |
| `\Leftarrow`           | Double left arrow (⇐)         |
| `\Leftrightarrow`      | Double left-right arrow (⇔)   |

---

## Greek Letters

For more details, see standard Greek letter symbols below.

### Lowercase Greek

| LaTeX      | Symbol | LaTeX      | Symbol | LaTeX      | Symbol |
| ---------- | ------ | ---------- | ------ | ---------- | ------ |
| `\alpha`   | α      | `\iota`    | ι      | `\rho`     | ρ      |
| `\beta`    | β      | `\kappa`   | κ      | `\sigma`   | σ      |
| `\gamma`   | γ      | `\lambda`  | λ      | `\tau`     | τ      |
| `\delta`   | δ      | `\mu`      | μ      | `\upsilon` | υ      |
| `\epsilon` | ε      | `\nu`      | ν      | `\phi`     | φ      |
| `\zeta`    | ζ      | `\xi`      | ξ      | `\chi`     | χ      |
| `\eta`     | η      | `\omicron` | ο      | `\psi`     | ψ      |
| `\theta`   | θ      | `\pi`      | π      | `\omega`   | ω      |

### Uppercase Greek

| LaTeX    | Symbol | LaTeX      | Symbol | LaTeX    | Symbol |
| -------- | ------ | ---------- | ------ | -------- | ------ |
| `\Gamma` | Γ      | `\Lambda`  | Λ      | `\Phi`   | Φ      |
| `\Delta` | Δ      | `\Xi`      | Ξ      | `\Psi`   | Ψ      |
| `\Theta` | Θ      | `\Pi`      | Π      | `\Omega` | Ω      |
| `\Sigma` | Σ      | `\Upsilon` | Υ      |          |        |

### Variant Greek Letters

| LaTeX         | Description         |
| ------------- | ------------------- |
| `\varepsilon` | Variant epsilon (ε) |
| `\varphi`     | Variant phi (φ)     |
| `\varrho`     | Variant rho (ρ)     |
| `\vartheta`   | Variant theta (θ)   |
| `\varpi`      | Variant pi (ϖ)      |
| `\varsigma`   | Final sigma (ς)     |

---

## Mathematical Constants

For more details, see [Constants](constants.md).

| LaTeX    | Value            | Description             |
| -------- | ---------------- | ----------------------- |
| `\pi`    | 3.14159...       | Pi                      |
| `\tau`   | 6.28318...       | Tau (2π)                |
| `\phi`   | 1.61803...       | Golden ratio            |
| `e`      | 2.71828...       | Euler's number          |
| `i`      | √(-1)            | Imaginary unit          |
| `\hbar`  | 1.054... * 10⁻³⁴ | Reduced Planck constant |
| `\infty` | ∞                | Infinity                |

---

## Matrix & Vector Notation

For more details, see matrix and vector sections below.

### Matrix Environments

| Environment                       | Description       | Delimiters |
| --------------------------------- | ----------------- | ---------- |
| `\begin{matrix}...\end{matrix}`   | Plain matrix      | None       |
| `\begin{pmatrix}...\end{pmatrix}` | Parenthesized     | ( )        |
| `\begin{bmatrix}...\end{bmatrix}` | Bracketed         | [ ]        |
| `\begin{vmatrix}...\end{vmatrix}` | Determinant       | \| \|      |
| `\begin{align}...\end{align}`     | Aligned equations | None       |

### Matrix Syntax

```latex
\begin{pmatrix}
  a & b \\
  c & d
\end{pmatrix}
```

- Use `&` to separate columns
- Use `\\` to separate rows

### Matrix Functions

| LaTeX                   | Description |
| ----------------------- | ----------- |
| `\det{A}`               | Determinant |
| `\trace{A}` or `\tr{A}` | Trace       |
| `A^T`                   | Transpose   |
| `A^{-1}`                | Inverse     |

### Vector Notation

| LaTeX     | Description             |
| --------- | ----------------------- |
| `\vec{v}` | Vector (arrow notation) |
| `\hat{v}` | Unit vector             |

---

## Comparison Operators

| LaTeX     | Symbol | Description           |
| --------- | ------ | --------------------- |
| `=`       | =      | Equal                 |
| `\neq`    | ≠      | Not equal             |
| `<`       | <      | Less than             |
| `>`       | >      | Greater than          |
| `\leq`    | ≤      | Less than or equal    |
| `\geq`    | ≥      | Greater than or equal |
| `\approx` | ≈      | Approximately equal   |
| `\propto` | ∝      | Proportional to       |

### Set Notation & Logic

| LaTeX       | Symbol | Description       |
| ----------- | ------ | ----------------- |
| `\in`       | ∈      | Element of        |
| `\subset`   | ⊂      | Proper subset     |
| `\subseteq` | ⊆      | Subset or equal   |
| `\supset`   | ⊃      | Proper superset   |
| `\supseteq` | ⊇      | Superset or equal |
| `\cup`      | ∪      | Union             |
| `\cap`      | ∩      | Intersection      |
| `\setminus` | \      | Set difference    |
| `\forall`   | ∀      | For all           |
| `\exists`   | ∃      | There exists      |

---

## Spacing Commands

These commands are recognized but ignored during evaluation (they're for display only):

| LaTeX        | Description         |
| ------------ | ------------------- |
| `\,`         | Thin space          |
| `\;`         | Medium space        |
| `\:`         | Thick space         |
| `\!`         | Negative thin space |
| `\quad`      | Quad space          |
| `\qquad`     | Double quad space   |
| `\thinspace` | Thin space (alias)  |

---

## Delimiter Sizing

These commands are recognized but ignored during parsing:

| LaTeX                | Description             |
| -------------------- | ----------------------- |
| `\left( ... \right)` | Auto-sizing parentheses |
| `\big( ... \big)`    | Big parentheses         |
| `\Big( ... \Big)`    | Bigger parentheses      |
| `\bigg( ... \bigg)`  | Even bigger             |
| `\Bigg( ... \Bigg)`  | Largest                 |

---

## Font Commands

Font styling commands wrap content and preserve it for LaTeX round-trip:

| LaTeX            | Description     | Output Variable |
| ---------------- | --------------- | --------------- |
| `\mathbf{E}`     | Bold            | `mathbf:E`      |
| `\mathcal{L}`    | Calligraphic    | `mathcal:L`     |
| `\mathrm{d}`     | Roman (upright) | `mathrm:d`      |
| `\mathit{x}`     | Italic          | `mathit:x`      |
| `\mathsf{A}`     | Sans-serif      | `mathsf:A`      |
| `\mathtt{x}`     | Typewriter      | `mathtt:x`      |
| `\textbf{text}`  | Bold text       | `textbf:text`   |
| `\boldsymbol{x}` | Bold symbol     | `boldsymbol:x`  |

---

## Text Mode

```latex
\text{some text}
```

Text within `\text{}` is treated as a single variable/token.

---

## Escaped Characters

| LaTeX | Result                |
| ----- | --------------------- |
| `\{`  | Literal `{`           |
| `\}`  | Literal `}`           |
| `\\`  | Line break (in align) |

---

## Usage Notes

### Function Arguments

Functions can take arguments in several ways:

```latex
\sin{x}       % Recommended: braces
\sin(x)       % Also works: parentheses
\sin x        % Works with implicit multiplication enabled
```

### Order of Operations

Standard mathematical precedence applies:

1. Parentheses and braces
2. Exponentiation (right-to-left)
3. Unary minus
4. Multiplication and division (left-to-right)
5. Addition and subtraction (left-to-right)
6. Comparisons

### Complex Number Support

Use `i` for the imaginary unit:

```latex
3 + 4i
e^{i\pi}
\sqrt{-1}     % Returns i
\sin{1 + 2i} % Complex trigonometry
```

### Textbook Notation Compatibility

The parser supports common textbook notation for copy-paste compatibility:

**Function Power Notation:**

```latex
\sin^2{x} + \cos^2{x}    % Pythagorean identity
\tan^3{\theta}           % Third power of tangent
\sin^{-1}{x}             % Power of -1 on sin
```

**Multi-argument Function Calls:**

```latex
f(x,y)                   % Function with multiple arguments
g(a,b,c)                 % Function with 3 arguments
\iint_{D} f(x,y) dx dy   % Double integral with function notation
```
