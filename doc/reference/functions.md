# Function Reference

TeXpr provides a wide range of mathematical functions, from basic trigonometry to complex number arithmetic.

## Trigonometric Functions

All trigonometric functions expect arguments in **radians**.

| LaTeX     | Purpose   | Complex Support |
| --------- | --------- | --------------- |
| `\sin{x}` | Sine      | ✅               |
| `\cos{x}` | Cosine    | ✅               |
| `\tan{x}` | Tangent   | ✅               |
| `\cot{x}` | Cotangent | ✅               |
| `\sec{x}` | Secant    | ✅               |
| `\csc{x}` | Cosecant  | ✅               |

### Hyperbolic Functions

| LaTeX      | Purpose              | Complex Support |
| ---------- | -------------------- | --------------- |
| `\sinh{x}` | Hyperbolic sine      | ✅               |
| `\cosh{x}` | Hyperbolic cosine    | ✅               |
| `\tanh{x}` | Hyperbolic tangent   | ✅               |
| `\coth{x}` | Hyperbolic cotangent | ✅               |
| `\sech{x}` | Hyperbolic secant    | ✅               |
| `\csch{x}` | Hyperbolic cosecant  | ✅               |

### Inverse Functions

| LaTeX        | Purpose                    | Alias      |
| ------------ | -------------------------- | ---------- |
| `\arcsin{x}` | Inverse sine               | `\asin{x}` |
| `\arccos{x}` | Inverse cosine             | `\acos{x}` |
| `\arctan{x}` | Inverse tangent            | `\atan{x}` |
| `\arccot{x}` | Inverse cotangent          | `\acot{x}` |
| `\arcsec{x}` | Inverse secant             | `\asec{x}` |
| `\arccsc{x}` | Inverse cosecant           | `\acsc{x}` |
| `\asinh{x}`  | Inverse hyperbolic sine    | -          |
| `\acosh{x}`  | Inverse hyperbolic cosine  | -          |
| `\atanh{x}`  | Inverse hyperbolic tangent | -          |

---

## Logarithmic & Exponential

| LaTeX         | Purpose       | Description       |
| ------------- | ------------- | ----------------- |
| `\ln{x}`      | Natural log   | Base $e$          |
| `\log{x}`     | Common log    | Base 10           |
| `\log_{b}{x}` | Arbitrary log | Base $b$          |
| `\log2{x}`    | Base 2 log    | Alias: `\log_{2}` |
| `\exp{x}`     | Exponential   | $e^x$             |

---

## Power & Roots

| LaTeX         | Purpose     | Example            |
| ------------- | ----------- | ------------------ |
| `\sqrt{x}`    | Square root | `\sqrt{16} = 4`    |
| `\sqrt[n]{x}` | n-th root   | `\sqrt[3]{27} = 3` |

---

## Rounding & Absolute Value

| LaTeX       | Purpose        | Example           |
| ----------- | -------------- | ----------------- |
| `\abs{x}`   | Absolute value | `\abs{-5} = 5`    |
| `\floor{x}` | Floor          | `\floor{3.7} = 3` |
| `\ceil{x}`  | Ceiling        | `\ceil{3.2} = 4`  |
| `\round{x}` | Round          | `\round{3.5} = 4` |
| `\sgn{x}`   | Sign function  | `\sgn{-3} = -1`   |

---

## Number Theory & Misc

| LaTeX           | Purpose   | Description                        |
| --------------- | --------- | ---------------------------------- |
| `\gcd{a, b}`    | GCD       | Greatest Common Divisor            |
| `\lcm{a, b}`    | LCM       | Least Common Multiple              |
| `\min{a, b}`    | Minimum   | Smaller of two values              |
| `\max{a, b}`    | Maximum   | Larger of two values               |
| `\factorial{n}` | Factorial | $n! = 1 \cdot 2 \cdot ... \cdot n$ |
| `\binom{n}{k}`  | Binomial  | "n choose k"                       |
| `\fibonacci{n}` | Fibonacci | n-th Fibonacci number              |

---

## Complex Numbers

Special functions for complex numbers $z = a + bi$.

| LaTeX           | Purpose        | Description            |
| --------------- | -------------- | ---------------------- |
| `\Re{z}`        | Real part      | Returns $a$            |
| `\Im{z}`        | Imaginary part | Returns $b$            |
| `\arg{z}`       | Argument       | Phase angle in radians |
| `\conjugate{z}` | Conjugate      | Returns $a - bi$       |
| `\overline{z}`  | Conjugate      | Alias for `\conjugate` |

---

## Implementation Details

Most mathematical functions delegate directly to Dart's `dart:math` library for real numbers and a custom `Complex` implementation for complex numbers.

### Precision
Calculations use IEEE 754 double-precision floating-point arithmetic. High-order functions like `\factorial` and `\fibonacci` return results as doubles and may lose precision for very large inputs (typically $n > 20$ for factorial).

### Domain Errors
If a function is called outside its domain (e.g., `\ln{-1}` with only real support enabled, or `\sqrt{-1}` without complex results expected), an `EvaluatorException` is thrown.

```dart
try {
  evaluator.evaluate(r'\ln{-1}');
} on EvaluatorException catch (e) {
  print(e.message); // "Domain error: ln() argument must be positive"
}
```

### Piecewise Definition
You can define piecewise functions using commas:
```latex
f(x) = \begin{cases} x & x > 0 \\ -x & x \leq 0 \end{cases}
```
In TeXpr syntax: `x, x > 0; -x, x \leq 0` (or similar depending on parser configuration).
Currently, the most reliable syntax for piecewise is the `ConditionalExpr` which is documented in the [Advanced Calculus](../advanced/calculus) section.
