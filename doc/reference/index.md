# API Reference

Core API documentation for TeXpr.

## Texpr Class

The main entry point for parsing and evaluating expressions.

```dart
import 'package:texpr/texpr.dart';

final texpr = Texpr();
```

### Constructor Options

| Parameter           | Default | Description              |
| ------------------- | ------- | ------------------------ |
| `cacheConfig`       | enabled | LRU cache configuration  |
| `extensions`        | none    | Custom function registry |
| `maxRecursionDepth` | 500     | Max nesting depth        |

### Methods

| Method                          | Returns            | Description             |
| ------------------------------- | ------------------ | ----------------------- |
| `evaluate(expr, [vars])`        | `EvaluationResult` | Parse and evaluate      |
| `evaluateNumeric(expr, [vars])` | `double`           | Evaluate as number      |
| `evaluateParsed(ast, [vars])`   | `EvaluationResult` | Evaluate pre-parsed AST |
| `parse(expr)`                   | `Expression`       | Parse to AST            |
| `differentiate(expr, var)`      | `Expression`       | Symbolic derivative     |
| `validate(expr)`                | `ValidationResult` | Check syntax            |
| `isValid(expr)`                 | `bool`             | Quick syntax check      |

---

## Quick Links

- [LaTeX Reference](/reference/latex) — Supported LaTeX commands
- [Functions](/reference/functions) — Mathematical functions
- [Constants](/reference/constants) — Built-in constants
- [Data Types](/reference/data-types) — Complex, Matrix, Vector
- [Exceptions](/reference/exceptions) — Error handling
