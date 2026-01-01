# Logarithmic Functions

## `\ln{x}` - Natural Logarithm

Returns the natural logarithm (base e) of x.

**Domain**: x > 0

```latex
\ln{1}           -> 0
\ln{e}           -> 1  (where e ≈ 2.71828)
\ln{10}          -> 2.302585...
```

## `\log{x}` - Base-10 Logarithm

Returns the base-10 logarithm of x.

**Domain**: x > 0

```latex
\log{1}          -> 0
\log{10}         -> 1
\log{100}        -> 2
```

## `\log_{base}{x}` - Custom Base Logarithm

Returns the logarithm of x with custom base.

**Domain**: x > 0, base > 0, base ≠ 1

```latex
\log_{2}{8}      -> 3   (2³ = 8)
\log_{3}{27}     -> 3   (3³ = 27)
\log_{10}{1000}  -> 3
```

### Error Cases

```dart
evaluator.evaluate(r'\log_{1}{10}');   // Throws: Invalid logarithm base
evaluator.evaluate(r'\log_{-2}{8}');   // Throws: Invalid logarithm base
```

## Examples

```dart
final e = LatexMathEvaluator();

// Natural log
e.evaluate(r'\ln{x}', {'x': 2.71828});  // ~1.0

// Log base 10
e.evaluate(r'\log{1000}');  // 3.0

// Log with custom base
e.evaluate(r'\log_{2}{16}');  // 4.0
```
