# Rounding Functions

## `\ceil{x}` - Ceiling

Returns the smallest integer greater than or equal to x.

```latex
\ceil{1.2}       -> 2
\ceil{1.9}       -> 2
\ceil{2.0}       -> 2
\ceil{-1.2}      -> -1
```

## `\floor{x}` - Floor

Returns the largest integer less than or equal to x.

```latex
\floor{1.2}      -> 1
\floor{1.9}      -> 1
\floor{2.0}      -> 2
\floor{-1.2}     -> -2
```

## `\round{x}` - Round

Returns the nearest integer to x. Rounds away from zero on .5.

```latex
\round{1.4}      -> 1
\round{1.5}      -> 2
\round{1.6}      -> 2
\round{-1.5}     -> -2
```

## Examples

```dart
final e = LatexMathEvaluator();

e.evaluate(r'\ceil{3.14}');   // 4.0
e.evaluate(r'\floor{3.14}');  // 3.0
e.evaluate(r'\round{3.14}');  // 3.0
e.evaluate(r'\round{3.5}');   // 4.0
```
