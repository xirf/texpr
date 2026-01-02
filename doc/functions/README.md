# Functions

This library includes 30+ built-in mathematical functions organized by category.

## Categories

| Category                                 | Functions                                 | Description                |
| ---------------------------------------- | ----------------------------------------- | -------------------------- |
| [Trigonometry](trigonometry.md)          | sin, cos, tan, asin, acos, atan           | Standard trig functions    |
| [Hyperbolic](trigonometry.md#hyperbolic) | sinh, cosh, tanh                          | Hyperbolic functions       |
| [Logarithms](logarithms.md)              | ln, log                                   | Natural and base-10/custom |
| [Rounding](rounding.md)                  | ceil, floor, round                        | Round to integers          |
| [Miscellaneous](misc.md)                 | sqrt, exp, abs, sgn, factorial, fibonacci | Other common functions     |

- **Vector and Matrix operations**: See [Vectors](../notation/vectors.md) and [Matrices](../notation/matrices.md) for notation and behavior.  

## Function Syntax

Most functions use braces for arguments:

```latex
\sin{x}
\sqrt{16}
\abs{-5}
```

Some functions accept a subscript for additional parameters:

```latex
\log_{2}{8}        % log base 2 of 8
\min_{a}{b}        % minimum of a and b
```

## Examples

```dart
final e = Texpr();

// Trigonometry
e.evaluate(r'\sin{0}');           // 0.0
e.evaluate(r'\cos{0}');           // 1.0

// Logarithms
e.evaluate(r'\ln{e}', {'e': 2.718});  // ~1.0
e.evaluate(r'\log_{2}{8}');       // 3.0

// Rounding
e.evaluate(r'\ceil{1.2}');        // 2.0
e.evaluate(r'\floor{1.8}');       // 1.0

// Misc
e.evaluate(r'\sqrt{16}');         // 4.0
e.evaluate(r'\factorial{5}');     // 120.0
```
