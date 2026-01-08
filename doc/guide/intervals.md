# Interval Arithmetic

TeXpr supports **Interval Arithmetic**, allowing you to perform calculations with ranges of values rather than single points. This is useful for error analysis, uncertainty propagation, and bounding solutions.

## Syntax

Intervals are denoted using square brackets `[lower, upper]`, where `lower` and `upper` are expressions evaluating to numbers.

```latex
[1, 2] + [3, 4]
```

## Basic Operations

Standard arithmetic operations accept intervals and return a new interval representing all possible results.

- **Addition**: `[a, b] + [c, d] = [a+c, b+d]`
- **Subtraction**: `[a, b] - [c, d] = [a-d, b-c]`
- **Multiplication**: `[a, b] * [c, d] = [min(ac, ad, bc, bd), max(ac, ad, bc, bd)]`
- **Division**: `[a, b] / [c, d] = [a, b] * [1/d, 1/c]` (if 0 is not in [c, d])

## Functions

Mathematical functions in TeXpr are extended to support intervals:

- `sin([0, \pi])` &rarr; `[0, 1]`
- `exp([0, 1])` &rarr; `[1, 2.718...]`
- `sqrt([4, 9])` &rarr; `[2, 3]`

## Evaluation

You can evaluate expressions containing intervals just like regular expressions:

```dart
final evaluator = Texpr();
final result = evaluator.evaluate('[1, 2] + 1');
print(result); // [2, 3]
```

## Examples

### Uncertainty Propagation
Calculate area of a square with side length $3 \pm 0.1$:

```latex
let x = [2.9, 3.1]
x^2
// Result: [8.41, 9.61]
```
