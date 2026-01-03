# Complex Numbers

The library provides a complex number support with arithmetic, transcendental functions, and polar form.

## Basic Usage

Complex numbers are created using the imaginary unit `i`:

```dart
final evaluator = Texpr();

// Basic complex arithmetic
evaluator.evaluate('1 + 2*i');           // Complex(1, 2)
evaluator.evaluate('(1 + i) * (2 - i)'); // Complex(3, 1)
evaluator.evaluate('i^2');               // Complex(-1, 0)
```

## Complex Functions

All trigonometric, logarithmic, and exponential functions support complex arguments:

### Trigonometric

```dart
evaluator.evaluate(r'\sin(1 + 2*i)');  // Complex(3.1658, 1.9596)
evaluator.evaluate(r'\cos(i)');         // Complex(1.5431, 0)
evaluator.evaluate(r'\tan(i)');         // Complex(0, 0.7616)
```

### Exponential and Logarithmic

```dart
// Euler's identity: e^(iπ) = -1
evaluator.evaluate(r'e^{i*\pi}');       // Complex(-1, 0)

// Complex logarithm
evaluator.evaluate(r'\ln(-1)');         // Complex(0, π)
evaluator.evaluate(r'\ln(i)');          // Complex(0, π/2)
evaluator.evaluate(r'\exp(i*\pi/2)');   // Complex(0, 1) = i
```

### Square Root

Negative real numbers now return complex results instead of throwing:

```dart
evaluator.evaluate(r'\sqrt{-1}');       // Complex(0, 1) = i
evaluator.evaluate(r'\sqrt{-4}');       // Complex(0, 2) = 2i
```

### Hyperbolic

```dart
evaluator.evaluate(r'\sinh(i)');        // Complex(0, sin(1))
evaluator.evaluate(r'\cosh(i)');        // Complex(cos(1), 0)
```

## Power Operations

Complex powers are fully supported:

```dart
evaluator.evaluate('(1+i)^3');          // Complex(-2, 2)
evaluator.evaluate('i^i');              // Complex(0.2079, 0) ≈ e^(-π/2)
evaluator.evaluate('2^i');              // Complex(0.769, 0.639)
```

## Working with Results

Use pattern matching or type checks:

```dart
final result = evaluator.evaluate('1 + 2*i');

// Pattern matching
switch (result) {
  case ComplexResult(:final value):
    print('Real: ${value.real}, Imaginary: ${value.imaginary}');
  case NumericResult(:final value):
    print('Real number: $value');
}

// Type checks
if (result.isComplex) {
  final c = result.asComplex();
  print('Magnitude: ${c.abs}');
  print('Phase: ${c.arg}');
}
```

## Complex Class API

The `Complex` class provides:

| Property/Method              | Description                   |
| ---------------------------- | ----------------------------- |
| `real`                       | Real part                     |
| `imaginary`                  | Imaginary part                |
| `abs`                        | Magnitude (modulus)           |
| `arg`                        | Phase (argument) in radians   |
| `conjugate`                  | Complex conjugate             |
| `isReal`                     | True if imaginary part is 0   |
| `exp()`                      | Complex exponential e^z       |
| `log()`                      | Natural logarithm ln(z)       |
| `pow(n)`                     | Power z^n (real or complex n) |
| `sqrt()`                     | Principal square root         |
| `sin()`, `cos()`, `tan()`    | Trig functions                |
| `sinh()`, `cosh()`, `tanh()` | Hyperbolic functions          |
| `toPolar()`                  | String "r∠θ" format           |
| `Complex.fromPolar(r, θ)`    | Create from polar coordinates |

## Re, Im, and Conjugate Functions

Extract parts of complex numbers:

```dart
evaluator.evaluate(r'\Re(2 + 3*i)');       // 2.0
evaluator.evaluate(r'\Im(2 + 3*i)');       // 3.0
evaluator.evaluate(r'\conjugate(2 + 3*i)'); // Complex(2, -3)
```
