# Vector Notation

This document describes vector notation and operations supported by the TeXpr.

## Creating Vectors

### Vector Notation: `\vec{}`

Create a vector by listing components in `\vec{}`:

```latex
\vec{1, 2, 3}        % 3D vector
\vec{x, y}           % 2D vector with variables
\vec{2+3, 4*5}       % Components can be expressions
```

**Example:**

```dart
final evaluator = LatexMathEvaluator();

final result = evaluator.evaluate(r'\vec{1, 2, 3}');
final vec = result.asVector();
print(vec.dimension);  // 3
print(vec[0]);         // 1.0
print(vec[1]);         // 2.0
print(vec[2]);         // 3.0
```

### Unit Vector Notation: `\hat{}`

Create a **unit vector** (normalized to magnitude 1) using `\hat{}`:

```latex
\hat{3, 4}           % Creates unit vector (0.6, 0.8)
\hat{1, 2, 3}        % Normalized 3D vector
```

**Example:**

```dart
final result = evaluator.evaluate(r'\hat{3, 4}');
final vec = result.asVector();
print(vec[0]);          // 0.6
print(vec[1]);          // 0.8
print(vec.magnitude);   // 1.0
```

> [!CAUTION]
> Cannot create a unit vector from the zero vector:

```dart
evaluator.evaluate(r'\hat{0, 0}');  // Throws EvaluatorException
```

## Vector Operations

### Magnitude (Length)

Use absolute value notation `|...|` to get the magnitude:

```latex
|\vec{3, 4}|         % Returns 5.0
|\vec{1, 2, 2}|      % Returns 3.0
```

**Example:**

```dart
final result = evaluator.evaluate(r'|\vec{3, 4}|');
print(result.asNumeric());  // 5.0
```

### Dot Product: `\cdot`

Calculate the dot product of two vectors using `\cdot`:

```latex
\vec{1, 2, 3} \cdot \vec{4, 5, 6}    % Returns 32.0 (1*4 + 2*5 + 3*6)
```

**Properties:**

- Returns a **scalar** (number)
- Commutative: `a · b = b · a`
- Orthogonal vectors have dot product zero

**Example:**

```dart
final result = evaluator.evaluate(r'\vec{1, 2, 3} \cdot \vec{4, 5, 6}');
print(result.asNumeric());  // 32.0

// Orthogonal vectors
final ortho = evaluator.evaluate(r'\vec{1, 0} \cdot \vec{0, 1}');
print(ortho.asNumeric());   // 0.0
```

> [!CAUTION]
> Dot product requires vectors of the same dimension:

```dart
evaluator.evaluate(r'\vec{1, 2} \cdot \vec{3, 4, 5}');  // Throws!
```

### Cross Product: `\times`

Calculate the cross product of two **3D vectors** using `\times`:

```latex
\vec{1, 0, 0} \times \vec{0, 1, 0}   % Returns \vec{0, 0, 1}
\vec{1, 2, 3} \times \vec{4, 5, 6}   % Returns \vec{-3, 6, -3}
```

**Properties:**

- Returns a **vector** perpendicular to both inputs
  - Defined for **3D vectors**
- Anti-commutative: `a * b = -(b * a)`
- Parallel vectors have zero cross product

**Example:**

```dart
final result = evaluator.evaluate(r'\vec{1, 0, 0} \times \vec{0, 1, 0}');
final vec = result.asVector();
print(vec[2]);  // 1.0 (z-component)

// Anti-commutative property
final v1 = evaluator.evaluate(r'\vec{1, 2, 3} \times \vec{4, 5, 6}').asVector();
final v2 = evaluator.evaluate(r'\vec{4, 5, 6} \times \vec{1, 2, 3}').asVector();
print(v1[0] == -v2[0]);  // true
```

> [!CAUTION]
> Cross product requires 3D vectors:

```dart
evaluator.evaluate(r'\vec{1, 2} \times \vec{3, 4}');  // Throws!
```

### Addition and Subtraction

Add or subtract vectors component-wise:

```latex
\vec{1, 2} + \vec{3, 4}              % Returns \vec{4, 6}
\vec{5, 7, 9} - \vec{2, 3, 4}        % Returns \vec{3, 4, 5}
```

**Example:**

```dart
final result = evaluator.evaluate(r'\vec{1, 2} + \vec{3, 4}');
final vec = result.asVector();
print(vec[0]);  // 4.0
print(vec[1]);  // 6.0
```

> [!CAUTION]
> Addition and subtraction require same-dimension vectors:

```dart
evaluator.evaluate(r'\vec{1, 2} + \vec{3, 4, 5}');  // Throws!
```

### Scalar Multiplication and Division

Multiply or divide a vector by a scalar:

```latex
3 * \vec{1, 2, 3}                    % Returns \vec{3, 6, 9}
\vec{6, 9, 12} / 3                   % Returns \vec{2, 3, 4}
```

**Example:**

```dart
final result = evaluator.evaluate(r'2 * \vec{1, 2, 3}');
final vec = result.asVector();
print(vec[0]);  // 2.0
print(vec[1]);  // 4.0
print(vec[2]);  // 6.0
```

### Negation

Negate all components of a vector:

```latex
-\vec{1, -2, 3}                      % Returns \vec{-1, 2, -3}
```

## Complex Expressions

Combine multiple operations:

```latex
(\vec{1, 2} + \vec{3, 4}) \cdot \vec{2, 1}      % = 14
|\vec{3, 0} + \vec{0, 4}|                       % = 5
2 * (\vec{1, 0, 0} \times \vec{0, 1, 0})        % = \vec{0, 0, 2}
```

**Example:**

```dart
final result = evaluator.evaluate(
  r'(\vec{1, 2} + \vec{3, 4}) \cdot \vec{2, 1}'
);
print(result.asNumeric());  // 14.0
```

## Working with Results

### Type Checking

```dart
final result = evaluator.evaluate(r'\vec{1, 2, 3}');

print(result.isVector);   // true
print(result.isNumeric);  // false
print(result.isMatrix);   // false
```

### Accessing Components

```dart
final vec = result.asVector();

print(vec.dimension);     // 3
print(vec[0]);            // 1.0
print(vec[1]);            // 2.0
print(vec[2]);            // 3.0
print(vec.magnitude);     // ~3.74
```

### Conversion Errors

```dart
final result = evaluator.evaluate(r'\vec{1, 2, 3}');

result.asNumeric();  // ❌ Throws StateError
result.asMatrix();   // ❌ Throws StateError
result.asVector();   // ✅ OK
```

## Domain constraints and Limitations

1. **No mixed operations**: Cannot directly add vectors to matrices or scalars
2. **Cross product**: Defined for 3D vectors
3. **Dot product**: Requires same-dimension vectors
4. **Zero vector**: Cannot normalize a zero-length vector with `\hat{}`

## Common Patterns

### Find Angle Between Vectors

Use the dot product formula: `cos(θ) = (a · b) / (|a| * |b|)`

```latex
\frac{\vec{1, 0} \cdot \vec{1, 1}}{|\vec{1, 0}| * |\vec{1, 1}|}
```

### Projection

Project vector `a` onto `b`: `proj_b(a) = ((a · b) / (b · b)) * b`

```latex
\frac{\vec{2, 3} \cdot \vec{1, 0}}{|\vec{1, 0}|^2} * \vec{1, 0}
```

### Perpendicular Vector (2D)

For 2D vector `(x, y)`, perpendicular is `(-y, x)`:

```latex
\vec{-y, x}
```

For 3D, use cross product with a reference vector.

## See Also

- [Matrix Notation](matrices.md) - Matrix operations
- [Getting Started](../getting_started.md) - Basic usage guide
- [Functions](../functions/README.md) - Mathematical functions
