# Complex Number Functions

The library supports complex number arithmetic and specific complex mapping functions.

## Standard Operations

Standard arithmetic operations (`+`, `-`, `*`, `/`, `^`) support complex numbers automatically.

```latex
(1 + 2i) * (3 - 4i)  -> 11 + 2i
\sqrt{-1}            -> i
e^{i \pi}            -> -1
```

## Functions

### `\Re{z}` - Real Part

Returns the real component of a complex number.

```latex
\Re{3 + 4i}      -> 3
\Re{5}           -> 5
\Re{i}           -> 0
```

### `\Im{z}` - Imaginary Part

Returns the imaginary component of a complex number.

```latex
\Im{3 + 4i}      -> 4
\Im{5}           -> 0
\Im{i}           -> 1
```

### `\conjugate{z}` / `\overline{z}` - Complex Conjugate

Returns the complex conjugate of z (negates the imaginary part).

**Syntax**:

- `\conjugate{z}`
- `\overline{z}`

```latex
\conjugate{3 + 4i}   -> 3 - 4i
\overline{3 - 4i}    -> 3 + 4i
\conjugate{5}        -> 5
```

## Examples

```dart
final e = LatexMathEvaluator();

e.evaluate(r'\Re{3+4i}');        // 3.0
e.evaluate(r'\Im{3+4i}');        // 4.0
e.evaluate(r'\conjugate{1+i}');  // Complex(1, -1)
e.evaluate(r'\abs{3+4i}');       // 5.0 (magnitude)
```
