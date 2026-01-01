# Cross-Language Benchmark Suite

This directory contains standalone benchmarks for comparing `texpr` against Python (SymPy) and JavaScript (mathjs).

Each benchmark uses **language-native benchmarking tools** for proper statistical measurement.

## Quick Start

### Dart (texpr)

```bash
cd /path/to/texpr
dart run benchmark/advanced_benchmark.dart
```

### Python (SymPy + pytest-benchmark)

```bash
cd benchmark/comparison/python
pip install pytest pytest-benchmark sympy antlr4-python3-runtime
pytest benchmark_pytest.py --benchmark-only -v
```

### JavaScript (mathjs + benchmark.js)

```bash
cd benchmark/comparison/js
npm install
npm run benchmark
```

## Expression Categories

| Category          | Description                                   |
| ----------------- | --------------------------------------------- |
| **Basic Algebra** | Simple arithmetic, multiplication, trig, sqrt |
| **Calculus**      | Definite integrals (Dart/Python only)         |
| **Matrix**        | 2x2 and 3x3 matrix operations                 |
| **Academic**      | Normal PDF, Lorentz factor, Euler polyhedra   |
| **Complex**       | Nested functions, polynomials                 |

## Output Format

Each tool produces output in its native format:

- **Dart (benchmark_harness)**: `Name(RunTime): X.XX us.`
- **Python (pytest-benchmark)**: Full statistical table with min/max/mean/stddev
- **JavaScript (benchmark.js)**: `Name x X,XXX ops/sec ±X.XX% (X runs sampled)`

## Notes

- Calculus benchmarks (integrals, limits) are **Dart/Python only** as mathjs doesn't support LaTeX integral syntax
- Matrix operations use native syntax in Python/JS since LaTeX matrix parsing isn't universal
