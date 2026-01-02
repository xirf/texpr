# Trigonometric Functions

## Standard Trigonometric

### `\sin{x}` - Sine

Returns the sine of x (in radians).

```latex
\sin{0}          -> 0
\sin{1.5707963}  -> 1  (π/2)
```

### `\cos{x}` - Cosine

Returns the cosine of x (in radians).

```latex
\cos{0}          -> 1
\cos{3.1415926}  -> -1 (π)
```

### `\tan{x}` - Tangent

Returns the tangent of x (in radians).

```latex
\tan{0}          -> 0
```

### `\sec{x}` - Secant

Returns the secant of x (1/cos(x)).

```latex
\sec{0}          -> 1
```

### `\csc{x}` - Cosecant

Returns the cosecant of x (1/sin(x)).

```latex
\csc{1.5707963}  -> 1  (π/2)
```

### `\cot{x}` - Cotangent

Returns the cotangent of x (1/tan(x)).

```latex
\cot{0.7853981}  -> 1  (π/4)
```

## Inverse Trigonometric

### `\asin{x}` / `\arcsin{x}` - Arcsine

Returns the arcsine of x. Domain: [-1, 1]

```latex
\asin{0}         -> 0
\asin{1}         -> 1.5707963 (π/2)
```

### `\acos{x}` / `\arccos{x}` - Arccosine

Returns the arccosine of x. Domain: [-1, 1]

```latex
\acos{1}         -> 0
\acos{0}         -> 1.5707963 (π/2)
```

### `\atan{x}` / `\arctan{x}` - Arctangent

Returns the arctangent of x.

```latex
\atan{0}         -> 0
\atan{1}         -> 0.7853981 (π/4)
```

## Hyperbolic Functions

### `\sinh{x}` - Hyperbolic Sine

```latex
\sinh{0}         -> 0
```

### `\cosh{x}` - Hyperbolic Cosine

```latex
\cosh{0}         -> 1
```

### `\tanh{x}` - Hyperbolic Tangent

```latex
\tanh{0}         -> 0
```

### `\sech{x}` - Hyperbolic Secant

```latex
\sech{0}         -> 1
```

### `\csch{x}` - Hyperbolic Cosecant

```latex
\csch{1}         -> 0.8509181
```

### `\coth{x}` - Hyperbolic Cotangent

```latex
\coth{1}         -> 1.3130352
```

## Inverse Hyperbolic Functions

### `\asinh{x}` - Inverse Hyperbolic Sine

Returns the inverse hyperbolic sine of x.

```latex
\asinh{0}        -> 0
```

### `\acosh{x}` - Inverse Hyperbolic Cosine

Returns the inverse hyperbolic cosine of x. Domain: x ≥ 1

```latex
\acosh{1}        -> 0
```

### `\atanh{x}` - Inverse Hyperbolic Tangent

Returns the inverse hyperbolic tangent of x. Domain: -1 < x < 1

```latex
\atanh{0}        -> 0
```

## Example

```dart
final e = Texpr();

// Using with pi constant
e.evaluate(r'\sin{x}', {'x': 3.14159 / 2});  // ~1.0

// Inverse trig
e.evaluate(r'\asin{1}');  // π/2
```
