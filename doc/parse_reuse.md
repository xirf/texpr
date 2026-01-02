# Parse Once, Evaluate Multiple Times

## Overview

The library now supports parsing a LaTeX expression once and reusing it with different variable bindings. This is significantly more memory-efficient when you need to evaluate the same expression with different values.

## API

### `parse(String expression)`

Parses a LaTeX expression into an Abstract Syntax Tree (AST) without evaluating it.

**Returns:** `Expression` - The parsed AST that can be reused.

```dart
final equation = evaluator.parse(r'x^{2} + 2x + 1');
```

### `evaluateParsed(Expression ast, [Map<String, double> variables])`

Evaluates a pre-parsed expression with variable bindings.

**Parameters:**

- `ast` - The parsed expression from `parse()`
- `variables` - Optional map of variable names to values

**Returns:** `double` or `Matrix` - The computed result.

```dart
final result = evaluator.evaluateParsed(equation, {'x': 5});
```

## Usage Examples

See the runnable demo in example/misc/parse_reuse_example.dart for a parse-once benchmark and demo.

### Basic Usage

```dart
final evaluator = Texpr();

// Parse once
final equation = evaluator.parse(r'x^{2} + 2x + 1');

// Evaluate multiple times with different values
print(evaluator.evaluateParsed(equation, {'x': 1})); // 4.0
print(evaluator.evaluateParsed(equation, {'x': 2})); // 9.0
print(evaluator.evaluateParsed(equation, {'x': 3})); // 16.0
```

### Multi-Variable Expressions

```dart
final expr = evaluator.parse('2x + 3y - z');

print(evaluator.evaluateParsed(expr, {'x': 1, 'y': 2, 'z': 3}));   // 5.0
print(evaluator.evaluateParsed(expr, {'x': 5, 'y': 10, 'z': 15})); // 25.0
```

### Trigonometric Functions

```dart
final trig = evaluator.parse(r'\sin{x} + \cos{x}');

print(evaluator.evaluateParsed(trig, {'x': 0}));        // 1.0
print(evaluator.evaluateParsed(trig, {'x': 3.14/4}));   // ~1.414
```

### Complex Expressions

```dart
final complex = evaluator.parse(r'2x^{2} + 3y - \sqrt{z}');

print(evaluator.evaluateParsed(complex, {'x': 2, 'y': 3, 'z': 4})); // 15.0
```

## Performance Benefits

Parsing is done only once, which reduces:

- **Memory allocations** - Tokens and AST are created once
- **CPU usage** - No repeated tokenization and parsing
- **Execution time** - Faster evaluation for repeated calculations

Example benchmark (1000 evaluations):

```plain
Parse+Evaluate each time: 15ms
Parse once, reuse: <1ms
Speedup: ~15-20x faster
```

## When to Use

**Use `parse()` + `evaluateParsed()` when:**

- Evaluating the same expression with many different variable values
- Running simulations or iterations
- Performance is critical
- Memory efficiency is important

**Use `evaluate()` when:**

- One-off evaluations
- Different expressions each time
- Simplicity is preferred over performance

## Backward Compatibility

The existing `evaluate()` method still works exactly as before. The new methods are additions, not replacements.

```dart
// Still works
evaluator.evaluate('x + 1', {'x': 2}); // 3.0

// New efficient way for repeated evaluations
final ast = evaluator.parse('x + 1');
evaluator.evaluateParsed(ast, {'x': 2}); // 3.0
```
