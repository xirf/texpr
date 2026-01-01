# Miscellaneous Functions

## `\sqrt{x}` / `\sqrt[n]{x}` - Square Root and Nth Root

Returns the square root of x, or the nth root when optional parameter is specified.

**Syntax**: 
- `\sqrt{x}` - Square root (default)
- `\sqrt[n]{x}` - Nth root (cube root, 4th root, etc.)

**Domain**: 
- For even n: x ≥ 0
- For odd n: all real numbers

```latex
\sqrt{4}         -> 2
\sqrt{2}         -> 1.41421...
\sqrt{0}         -> 0

# Nth roots
\sqrt[3]{8}      -> 2        (cube root)
\sqrt[3]{27}     -> 3
\sqrt[3]{-8}     -> -2       (odd roots work with negatives)
\sqrt[4]{16}     -> 2        (4th root)
\sqrt[5]{32}     -> 2        (5th root)
\sqrt[2]{16}     -> 4        (explicitly 2nd root)
```

## `\exp{x}` - Exponential

Returns e^x (e raised to the power x).

```latex
\exp{0}          -> 1
\exp{1}          -> 2.71828... (e)
\exp{2}          -> 7.38905...
```

## `\abs{x}` / `|x|` - Absolute Value / Magnitude

Returns the absolute value of x (or magnitude if x is a vector).

**Syntax**: `\abs{x}` or `|x|` (pipe notation)

```latex
\abs{5}          -> 5
\abs{-5}         -> 5
|5|              -> 5
|-5|             -> 5
|x^2 - 4|        -> depends on x
||x||            -> |x| (nested)
|\vec{3, 4}|     -> 5.0 (vector magnitude)
\abs{\vec{1, 1}} -> 1.414...
```

## `\sgn{x}` - Sign Function

Returns the sign of x: -1, 0, or 1.

```latex
\sgn{5}          -> 1
\sgn{-3}         -> -1
\sgn{0}          -> 0
```

## Combinatorics

### `\binom{n}{k}` - Binomial Coefficient

Calculates the number of ways to choose k items from a set of n items.

```latex
\binom{5}{2}     -> 10
\binom{4}{4}     -> 1
```

## Number Theory

### `\gcd(a, b)` - Greatest Common Divisor

Calculates the greatest common divisor of two numbers.

```latex
\gcd(12, 18)     -> 6
```

### `\lcm(a, b)` - Least Common Multiple

Calculates the least common multiple of two numbers.

```latex
\lcm(12, 18)     -> 36
```

## `\factorial{n}` - Factorial

Returns n! (n factorial). Limited to n ≤ 170 to prevent overflow.

**Domain**: n ≥ 0, integer

The implementation includes memoization to speed up repeated calls to factorial for the same arguments.

```latex
\factorial{0}    -> 1
\factorial{5}    -> 120  (5! = 5*4*3*2*1)
\factorial{10}   -> 3628800
```

## `\fibonacci{n}` - Fibonacci

Returns the n-th Fibonacci number using 0-based indexing: `\fibonacci{0} = 0`, `\fibonacci{1} = 1`.
The implementation memoizes previous values to improve performance on repeated calls; very large n may overflow double.

**Domain**: n ≥ 0, integer

```latex
\fibonacci{0}    -> 0
\fibonacci{1}    -> 1
\fibonacci{2}    -> 1
\fibonacci{10}   -> 55
```

## `\min_{a}{b}` / `\max_{a}{b}` - Min/Max

Returns the minimum or maximum of two values.

```latex
\min_{3}{5}      -> 3
\max_{3}{5}      -> 5
\min_{-2}{-5}    -> -5
```

## Examples

```dart
final e = LatexMathEvaluator();

e.evaluate(r'\sqrt{16}');        // 4.0
e.evaluate(r'\abs{-42}');        // 42.0
e.evaluate(r'|-42|');            // 42.0 (pipe notation)
e.evaluate(r'|x^2 - 4|', {'x': 1});  // 3.0
e.evaluate(r'\factorial{6}');    // 720.0
e.evaluate(r'\min_{x}{y}', {'x': 3, 'y': 7});  // 3.0
```
