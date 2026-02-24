# Benchmarks

This directory contains micro-benchmarks and comparison benchmarks for TeXpr.

## Evaluability Fast-Path Guardrail

`evaluability_fast_path_benchmark.dart` compares:

- **Annotated path**: `Expression.getEvaluability()` on parser-annotated AST nodes
- **Visitor path**: `Expression.getEvaluability()` fallback visitor traversal on unannotated AST nodes

### Run manually

```bash
dart run benchmark/evaluability_fast_path_benchmark.dart
```

### Run with guardrail enforcement

```bash
dart run benchmark/evaluability_fast_path_benchmark.dart --enforce --min-speedup=1.02 --json-out=benchmark/results/evaluability_fast_path.json
```

The benchmark exits non-zero when `--enforce` is passed and the measured speedup is below the configured threshold. CI runs this command and uploads the JSON result as an artifact.

## Cross-Language Comparison

See `benchmark/comparison/README.md` for Dart vs Python vs JavaScript comparison benchmarks.
