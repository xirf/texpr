# Getting Started

## Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  texpr: ^0.0.1
```

Then run:

```bash
flutter pub get
```

## Basic Usage

```dart
import 'package:texpr/texpr.dart';

void main() {
  final evaluator = Texpr();

  // Basic expression
  print(evaluator.evaluate(r'2 + 3'));  // 5.0

  // With variables
  print(evaluator.evaluate(r'x^{2}', {'x': 4}));  // 16.0

  // LaTeX operators
  print(evaluator.evaluate(r'6 \div 2'));  // 3.0
  print(evaluator.evaluate(r'3 \times 4'));  // 12.0
}
```

## Understanding the Pipeline

The evaluator works in 3 stages:

1. **Tokenization**: LaTeX string -> Tokens
2. **Parsing**: Tokens -> Abstract Syntax Tree (AST)
3. **Evaluation**: AST + Variables -> Result
   Result types: [NumericResult], [ComplexResult], [MatrixResult], [VectorResult]

```dart
// Manual pipeline (for advanced use)
final tokens = Tokenizer(r'\sin{x}').tokenize();
final ast = Parser(tokens).parse();
final result = Evaluator().evaluate(ast, {'x': 0});
```

## Error Handling

```dart
try {
  evaluator.evaluate(r'\log{0}');
} on EvaluatorException catch (e) {
  print('Math error: $e');
} on ParserException catch (e) {
  print('Syntax error: $e');
} on TokenizerException catch (e) {
  print('Invalid character: $e');
}
```

## Next Steps

- [Functions](functions/README.md) - Available mathematical functions
- [Notation](notation/README.md) - Sum, product, and limit notation
- [Constants](constants.md) - Built-in mathematical constants
- [Extensions](extensions.md) - Adding custom functions

## Parsed Expression Caching

The evaluator supports an LRU cache to reuse parsed ASTs for repeated evaluations of the same expression string. By default caching is enabled with a sensible size.

**Configure cache size**:

```dart
// Enable advanced caching configuration
final evaluator = Texpr(
  cacheConfig: CacheConfig(
    parsedExpressionCacheSize: 256,
    evaluationResultCacheSize: 512,
  )
);

// High performance preset for graphing
final graphing = Texpr(
  cacheConfig: CacheConfig.highPerformance,
);
```

**Cache management**:

```dart
final evaluator = Texpr();
// Parse and evaluate
var result = evaluator.evaluate('\sqrt{16}');

// Clear internal parsed-expression cache when you want to free memory
// or invalidate cached ASTs after dynamic extension changes.
evaluator.clearParsedExpressionCache();
```

## Recursion Depth

For deeply nested expressions, you can configure the maximum recursion depth (default is 500).

```dart
// Increase limit for deep nesting
final evaluator = Texpr(maxRecursionDepth: 2000);
```
