# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Interval Arithmetics:** Added support for interval arithmetics.

## 0.1.1 - 2026-01-07

**Bug Fixes & UX Improvements**

- **Parsing:** Fixed strict syntax parsing for integral bounds (e.g., `\int_0^1` is now supported).
- **Evaluation:** Fixed `evaluateNumeric` behavior for complex numbers; results are now handled correctly when using `evaluate()`.
- **JSON Export:** Fixed `VectorExpr` JSON schema to use `components` key, matching the AST definition.

### Added

- **LaTeX Commands:** Implemented support for common academic symbols:
  - Arrows: `\mapsto`, `\Rightarrow`, `\Leftarrow`, `\Leftrightarrow`.
  - Relation & Set Operators: `\approx`, `\propto`, `\cup`, `\cap`, `\setminus`, `\subset`, `\subseteq`, `\supset`, `\supseteq`.
  - Quantifiers: `\forall` and `\exists` (parsed as variables for syntax tolerance).
  - Decorations: `\dot`, `\ddot`, and `\bar` functions for physics and statistical notation.

### Changed

- **Breaking Change:** Renamed `LatexException` to `TexprException` (and `LatexParserException` -> `ParserException`, etc.) to better align with the library name.
- **Error Messages:** Significantly improved parser error clarity. Error messages now use readable symbols (e.g., `got: '*'`) instead of internal enum names (e.g., `got: multiply`).
- **Parser:** Improved syntax tolerance for known commands on implicit multiplication (e.g., `sin(x)`).
- **Documentation:** Updated feature guides, notation references, and example code.


## 0.1.0 - 2026-01-02

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
