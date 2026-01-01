# Limit Notation

## Syntax

```latex
\lim_{variable \to target} expression
```

## How It Works

Limits are computed using **numeric approximation**. The evaluator approaches the target value from both sides with decreasing step sizes.

> [!NOTE]
> This is not symbolic limit computation. Complex limits (like L'Hôpital's rule cases) may not evaluate correctly.

## Examples

```latex
% Simple limit
\lim_{x \to 0} x          -> 0

% Polynomial
\lim_{x \to 2} x^{2}      -> 4

% Linear function
\lim_{x \to 3} (2x + 1)   -> 7
```

## Infinity

Use `\infty` for limits at infinity:

```latex
\lim_{x \to \infty} (1/x)      -> 0
\lim_{x \to -\infty} (1/x)     -> 0
```

## Dart Example

```dart
final e = LatexMathEvaluator();

e.evaluate(r'\lim_{x \to 0} x^{2}');  // 0.0
e.evaluate(r'\lim_{x \to 2} (x + 3)');  // 5.0
e.evaluate(r'\lim_{x \to \infty} (1/x)');  // ~0
```

## Limitations

- Uses numeric approximation (not symbolic)
- May not handle indeterminate forms (0/0, ∞/∞)
- Limited precision near singularities
