# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.1-Nightly - 2026-01-02

### Added

- **LaTeX Commands:** Implemented support for common academic symbols:
  - Arrows: `\mapsto`, `\Rightarrow`, `\Leftarrow`, `\Leftrightarrow`.
  - Relation & Set Operators: `\approx`, `\propto`, `\cup`, `\cap`, `\setminus`, `\subset`, `\subseteq`, `\supset`, `\supseteq`.
  - Quantifiers: `\forall` and `\exists` (parsed as variables for syntax tolerance).
  - Decorations: `\dot`, `\ddot`, and `\bar` functions for physics and statistical notation.
- **WASM Support:** Added dedicated WebAssembly build artifacts and examples.
- **CI/CD:** Automated publishing to pub.dev via GitHub Actions using the official Dart-lang workflow.

### Changed

- **Breaking Change:** Renamed base exception from `LatexException` (or similar) to `TexprException` to align with the new branding.
- **Parser:** Improved syntax tolerance for certain mathematical notations.
- **Documentation:** Comprehensive updates to feature guides, notation references, and example code.

### Fixed

- Resolved several merge conflicts and stabilized the integration test pipeline.
- Fixed workflow syntax errors that prevented automated publishing.
- Improved test coverage for core LaTeX commands and edge cases.

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
