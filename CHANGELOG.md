# CHANGELOG

## 0.1.0 – 2026-01-02

**Draft Release: Benchmarks, WASM, and Documentation Overhaul.**

* **WASM Support:** Added initial WebAssembly compilation targets and examples (`wasm/`).
* **Benchmarks:** Benchmarking suite added (`benchmark/`).
* **Documentation:** Updates to API docs and feature guides.
* **Testing:** Expanded test coverage for complex features and edge cases.

## 0.0.1 – 2026-01-01

**Initial release of TeXpr.**

This is a complete rebranding and evolution of the legacy `latex_math_evaluator` project. It serves as a engine for parsing, evaluating, and analyzing LaTeX math expressions.

### ✨ Features

* **Core Parsing:**
* Full recursive descent parser for standard mathematical LaTeX.
* Generates a structured Abstract Syntax Tree.
* Supports implicit multiplication, variable binding, and custom functions.


* **Evaluation Engine:**
  * **Numeric:** Arithmetic, Trig, Log, Roots, Factorials.
  * **Complex Numbers:** Full support for `i`, Euler's identity, and complex transcendental functions.
  * **Matrix:** Determinants, Inverses, Transposition, and basic arithmetic.
  * **Calculus:** Numerical integration (Simpson's Rule) and Symbolic differentiation (Product/Chain rules).


* **Interop & Export:**
  * **JSON:** Export AST to JSON for external tooling.
  * **MathML (Alpha):** Export to standard web-compatible MathML.
  * **SymPy (Alpha):** Generate Python/SymPy code from Dart objects.


* **Advanced Features:**
  * **Optimization:** Multi-layer caching (L1-L4) with LRU/LFU policies.
  * **Analysis:** Piecewise differentiation and symbolic simplification.
  * **Diagnostics:** Levenshtein-based suggestions for syntax errors.



---

*(Note: This project builds upon 1,800+ tests and architecture from the deprecated `latex_math_evaluator` v0.2.0)*
