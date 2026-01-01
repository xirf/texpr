# Matrices

The library supports standard LaTeX matrix environments for defining matrices and performing matrix operations.

## Supported Environments

The following matrix environments are supported:

- `matrix`: Plain matrix (no brackets)
- `pmatrix`: Parentheses `( )`
- `bmatrix`: Square brackets `[ ]`
- `vmatrix`: Vertical bars `| |`

Note: While the parser recognizes these different environments, the evaluator treats them all as standard matrices. The visual distinction (brackets vs parentheses) is not preserved in the evaluation result, only the numerical structure.

## Syntax

Matrices are defined using the standard LaTeX syntax:

- `&` separates columns
- `\\` separates rows

```latex
\begin{matrix}
1 & 2 \\
3 & 4
\end{matrix}
```

## Operations

The following operations are supported for matrices:

### Addition and Subtraction

Matrices of the same dimensions can be added or subtracted.

```latex
\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix} + \begin{matrix} 5 & 6 \\ 7 & 8 \end{matrix}
```

### Matrix Multiplication

Matrices can be multiplied if their dimensions are compatible (columns of A = rows of B).

```latex
\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix} * \begin{matrix} 5 & 6 \\ 7 & 8 \end{matrix}
```

### Scalar Multiplication

Matrices can be multiplied by a scalar value.

```latex
2 * \begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}
```

### Negation

Matrices can be negated.

```latex
-\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}
```

### Determinant Calculation

The library calculates matrix determinants using optimized algorithms:

- **1x1, 2x2, 3x3 matrices**: Direct formulas (O(1) complexity)
- **4x4 and larger matrices**: LU decomposition (O(n³) complexity)

```latex
\det{\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}}  % Returns -2.0
\det{\begin{matrix} 1 & 2 & 3 \\ 4 & 5 & 6 \\ 7 & 8 & 9 \end{matrix}}  % Returns 0.0
```

**Performance**: For large matrices (10x10), determinant calculation typically takes 0.04-0.07 milliseconds.

### Trace

Calculates the trace of a matrix (sum of diagonal elements).

```latex
\trace{\begin{matrix} 1 & 2 \\ 3 & 4 \end{matrix}}  % Returns 5.0 (1 + 4)
\tr{A}  % Alias
```

### Transpose

Matrix transpose is supported using the `^T` notation:

```latex
\begin{matrix} 1 & 2 & 3 \\ 4 & 5 & 6 \end{matrix}^T  % Returns 3x2 matrix
```

## Examples

### Solving a System of Linear Equations (Representation)

While the library doesn't currently have a built-in solver, you can represent systems using matrices.

```latex
\begin{pmatrix}
1 & 2 & 3 \\
4 & 5 & 6 \\
7 & 8 & 9
\end{pmatrix}
```

### Transformations

Representing a 2D rotation matrix:

```latex
\begin{pmatrix}
\cos{\theta} & -\sin{\theta} \\
\sin{\theta} & \cos{\theta}
\end{pmatrix}
```

## Performance Optimizations

### Optimized Determinant Calculation

The library uses specialized algorithms for determinant calculation:

- **Small matrices (1x1, 2x2, 3x3)**: Direct mathematical formulas for maximum speed
- **Large matrices (4x4 and larger)**: LU decomposition algorithm for numerical stability

**Benchmark Results** (typical execution times):

- 3x3: 0.07 ms
- 4x4: 0.04 ms
- 5x5: 0.05 ms
- 6x6: 0.06 ms
- 10x10: 0.07 ms

### Memory Efficiency

- Matrix operations are performed in-place where possible
- LU decomposition uses partial pivoting for numerical stability
- Large matrices (up to 100x100) are supported efficiently

### Example: Performance Comparison

```dart
// Small matrix - direct formula
final small = Matrix([[1, 2], [3, 4]]);
print(small.determinant);  // Very fast (direct calculation)

// Large matrix - LU decomposition
final large = Matrix(generate10x10Matrix());
print(large.determinant);  // Fast (O(n³) algorithm)
```
