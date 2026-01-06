# Data Types

Evaluation results are returned as sealed classes based on the expression type.

## EvaluationResult

The base sealed class returned by `evaluate()`:

```dart
final result = texpr.evaluate(r'\sqrt{16}');

switch (result) {
  case NumericResult(:final value):
    print('Number: $value');  // 4.0
  case ComplexResult(:final value):
    print('Complex: $value');
  case MatrixResult(:final value):
    print('Matrix: ${value.rows}x${value.cols}');
  case VectorResult(:final value):
    print('Vector: ${value.dimension}D');
}
```

Convenience methods:
- `result.asNumeric()` — returns `double`
- `result.asComplex()` — returns `Complex`
- `result.asMatrix()` — returns `Matrix`
- `result.asVector()` — returns `Vector`

---

## Complex

Represents a complex number.

```dart
final z = Complex(3, 4);  // 3 + 4i
z.real;        // 3.0
z.imaginary;   // 4.0
z.abs;         // 5.0 (magnitude)
z.arg;         // 0.927... (phase angle)
z.conjugate;   // 3 - 4i
```

### Creating

```dart
Complex(3, 4);           // 3 + 4i
Complex.fromNum(5);      // 5 + 0i
```

### Operations

```dart
z1 + z2;    // Addition
z1 - z2;    // Subtraction
z1 * z2;    // Multiplication
z1 / z2;    // Division
-z;         // Negation
```

### Functions

```dart
z.exp();    // e^z
z.log();    // ln(z)
z.pow(2);   // z²
z.sqrt();   // √z
z.sin();    // sin(z)
z.cos();    // cos(z)
```

---

## Matrix

Represents a 2D matrix.

```dart
final m = Matrix([
  [1, 2],
  [3, 4],
]);
```

### Properties

| Property | Description       |
| -------- | ----------------- |
| `rows`   | Number of rows    |
| `cols`   | Number of columns |
| `data`   | Raw 2D list       |

### Methods

| Method          | Description                   |
| --------------- | ----------------------------- |
| `determinant()` | Determinant (square matrices) |
| `inverse()`     | Inverse matrix                |
| `transpose()`   | Transposed matrix             |
| `trace()`       | Sum of diagonal               |

### Operators

```dart
m1 + m2;    // Addition
m1 - m2;    // Subtraction
m1 * m2;    // Matrix multiplication
m * 2;      // Scalar multiplication
m[0];       // Access row 0
m[0][1];    // Access element at (0, 1)
```

### LaTeX

```latex
\begin{pmatrix} 1 & 2 \\ 3 & 4 \end{pmatrix}
```

---

## Vector

Represents a mathematical vector.

```dart
final v = Vector([3, 4]);
Vector.fromXY(3, 4);      // 2D vector
Vector.fromXYZ(1, 2, 3);  // 3D vector
```

### Properties

| Property     | Description             |
| ------------ | ----------------------- |
| `dimension`  | Number of components    |
| `magnitude`  | Length (Euclidean norm) |
| `components` | Raw list                |

### Methods

| Method         | Description             |
| -------------- | ----------------------- |
| `normalize()`  | Unit vector             |
| `dot(other)`   | Dot product             |
| `cross(other)` | Cross product (3D only) |

### Operators

```dart
v1 + v2;    // Addition
v1 - v2;    // Subtraction
v * 2;      // Scalar multiplication
v / 2;      // Scalar division
-v;         // Negation
v[0];       // Access component
```
