# Piecewise Functions

TeXpr supports piecewise functions, allowing you to define expressions that change their formula based on conditions. This is commonly used for functions like absolute value, step functions, and ReLU.

## The `cases` Environment

The primary way to define a piecewise function in LaTeX is using the `cases` environment:

```latex
f(x) = \begin{cases} 
  x^2 & x < 0 \\
  x   & x \geq 0
\end{cases}
```

In TeXpr, you pass this string to the evaluator:

```dart
final expr = evaluator.parse(r'''
  \begin{cases}
    x^2 & x < 0 \\
    x   & x \geq 0
  \end{cases}
''');

print(evaluator.evaluateParsed(expr, {'x': -2}).asNumeric()); // 4.0
print(evaluator.evaluateParsed(expr, {'x': 3}).asNumeric());  // 3.0
```

### Syntax Details

- **`\\`**: Separates cases (rows).
- **`&`**: Separates the expression from the condition.
- **Conditions**: Must be valid boolean expressions using comparison operators (`<`, `>`, `\leq`, `\geq`, `=`).

## "Otherwise" Case

You can specify a default case using `\text{otherwise}` (or just leaving the condition blank in some contexts, but explicit "otherwise" is clearer).

```latex
\begin{cases}
  1 & x > 0 \\
  -1 & x < 0 \\
  0 & \text{otherwise}
\end{cases}
```

If no condition matches and there is no "otherwise" case, the result is `NaN`.

## Common Examples

### Absolute Value
```latex
|x| = \begin{cases}
  -x & x < 0 \\
  x  & x \geq 0
\end{cases}
```

### ReLU (Rectified Linear Unit)
```latex
\text{ReLU}(x) = \begin{cases}
  0 & x < 0 \\
  x & x \geq 0
\end{cases}
```

### Step Function
```latex
H(x) = \begin{cases}
  0 & x < 0 \\
  1 & x \geq 0
\end{cases}
```

## Calculus with Piecewise Functions

TeXpr allows you to differentiate and integrate piecewise functions. The operation is applied to each expression case, while preserving the intervals.

### Differentiation

```dart
final derivative = evaluator.differentiate(r'''
  \begin{cases}
    x^2 & x < 0 \\
    5x  & x \geq 0
  \end{cases}
''', 'x');
// Result is equivalent to:
// \begin{cases}
//   2x & x < 0 \\
//   5  & x \geq 0
// \end{cases}
```

### Integration

```dart
final integral = evaluator.integrate(r'''
  \begin{cases}
    2 & x < 0 \\
    3 & x \geq 0
  \end{cases}
''', 'x');
// Result is equivalent to:
// \begin{cases}
//   2x & x < 0 \\
//   3x & x \geq 0
// \end{cases}
```

> [!NOTE]
> Symbolic operations currently treat cases independently. Continuity at boundaries is not automatically enforced or checked during symbolic manipulation.

## See Also

- [Logic & Comparisons](logic.md) - For details on valid conditions.
- [Calculus](../advanced/calculus.md) - For more on differentiation and integration.
