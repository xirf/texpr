# Summation and Product Notation

## Summation: `\sum`

Computes the sum of an expression over a range.

### Syntax

```latex
\sum_{variable=start}^{end} expression
```

### Examples

```latex
% Sum of 1 to 5
\sum_{i=1}^{5} i         -> 15 (1+2+3+4+5)

% Sum of squares
\sum_{i=1}^{3} i^{2}     -> 14 (1+4+9)

% Sum of constants
\sum_{i=1}^{10} 2        -> 20 (2*10)

% Using variables
\sum_{k=1}^{n} k         -> With n=4: 10
```

### Dart Example

```dart
final e = Texpr();

e.evaluate(r'\sum_{i=1}^{100} i');  // 5050
e.evaluate(r'\sum_{i=1}^{n} i^{2}', {'n': 5});  // 55
```

---

## Product: `\prod`

Computes the product of an expression over a range.

### Syntax

```latex
\prod_{variable=start}^{end} expression
```

### Examples

```latex
% Factorial: 5!
\prod_{i=1}^{5} i        -> 120 (1*2*3*4*5)

% Powers of 2
\prod_{i=1}^{3} 2        -> 8 (2³)

% Product of expressions
\prod_{i=1}^{3} (i + 1)  -> 24 (2*3*4)
```

### Dart Example

```dart
final e = Texpr();

// Factorial
e.evaluate(r'\prod_{i=1}^{6} i');  // 720 (6!)

// Power
e.evaluate(r'\prod_{i=1}^{n} 2', {'n': 10});  // 1024 (2^10)
```

## Nested Notation

Summation and products can be combined:

```dart
// Sum of factorials
e.evaluate(r'\sum_{n=1}^{3} \prod_{i=1}^{n} i');  
// = 1! + 2! + 3! = 1 + 2 + 6 = 9
```
