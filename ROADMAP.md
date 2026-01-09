# Texpr - Roadmap

> **Goal:** Copy-paste LaTeX from academic sources and it just works.

---

## Current State (v0.2.0)

### ✅ What Works

**Parsing & Evaluation:**

- Basic arithmetic, fractions, powers, roots
- 40+ mathematical functions (trig, hyperbolic, reciprocal, logarithmic, rounding)
- Complex number transcendental evaluation (sin, cos, tan, exp, ln for complex inputs)
- Symbolic differentiation with full calculus rules
- Symbolic integration (basic patterns)
- Numerical integration (Simpson's Rule)
- Matrix operations (determinant, inverse, transpose, trace)
- Summation (`\sum`), product (`\prod`), limit (`\lim`)
- Definite and indefinite integrals
- Multi-integrals (`\iint`, `\iiint`), closed integrals (`\oint`)

**LaTeX Notation:**

- Greek letters (lowercase, UPPERCASE, variants: `\alpha`, `\Gamma`, `\varepsilon`)
- Font commands (`\mathbf`, `\mathcal`, `\mathrm`, `\boldsymbol`)
- Delimiter sizing (`\left`, `\right`, `\big`, `\Big`, etc.)
- Spacing commands (`\,`, `\;`, `\quad` - ignored for evaluation)
- Partial derivatives (`\partial`), gradient (`\nabla`)
- Angle brackets (`\langle`, `\rangle`), set membership (`\in`)
- Blackboard bold (`\mathbb{R}`)
- Comparison operators (`\leq`, `\geq`, `\neq`)

**Academic Paper Compatibility (Tested):**

- Heisenberg Uncertainty Principle
- Schrödinger Equation (time-dependent and time-independent)
- Maxwell's Equations (Gauss's Law, Ampère's Law)
- Navier-Stokes Equation
- Fourier Transform definition
- Cauchy-Schwarz Inequality
- Einstein Field Equations
- Normal distribution PDF

**Test Coverage:** 1,874 tests passing

---

## Known Gaps

The following are known limitations discovered through testing:

### 1. Evaluation Limitations (Not Parsing)

| Expression                        | Can Parse | Can Evaluate | Notes                                        |
| --------------------------------- | --------- | ------------ | -------------------------------------------- |
| `\nabla{x^2 + y^2}`               | ✅         | ✅            | Concrete expressions with explicit vars      |
| `\nabla f` (bare symbol)          | ✅         | ❌            | Symbolic only; no structure to differentiate |
| `\oint E \cdot dA`                | ✅         | ❌            | Line/surface integrals are symbolic only     |
| Tensor notation (`R_{\mu\nu}`)    | ✅         | ❌            | Parsed as subscripted variable               |
| Set notation (`x \in \mathbb{R}`) | ✅         | ❌            | Parsed but not evaluated as constraint       |



### 2. Previously Missing LaTeX Commands ✅ Fixed

All commands below now parse successfully:

| Command                | Description            | Status |
| ---------------------- | ---------------------- | ------ |
| `\mapsto` (↦)          | Maps to arrow          | ✅      |
| `\Rightarrow` (⇒)      | Double arrow           | ✅      |
| `\approx` (≈)          | Approximately equal    | ✅      |
| `\propto` (∝)          | Proportional to        | ✅      |
| `\subset`, `\subseteq` | Subset notation        | ✅      |
| `\cup`, `\cap`         | Set union/intersection | ✅      |
| `\forall`, `\exists`   | Quantifiers            | ✅      |
| `\dot{x}`, `\ddot{x}`  | Time derivatives       | ✅      |
| `\bar{x}`              | Mean notation          | ✅      |

### 3. Syntax Variations ✅ Fixed

The following syntax variations are now automatically handled:

| Academic LaTeX          | Library Support | Notes                                                                             |
| ----------------------- | --------------- | --------------------------------------------------------------------------------- |
| `\frac12` (braceless)   | ✅ Works         | Parses as `\frac{1}{2}`. Ambiguous cases like `\frac123` error with clear message |
| `sin(x)` (no backslash) | ✅ Works         | Recognized when followed by `(`. Without `(`, remains as implicit mult            |
| `e^{ix}`                | ✅ Works         | Implicit multiplication inside exponents is handled                               |

---

## Roadmap

### Phase 1: Parsing Completeness

**Goal:** Any valid mathematical LaTeX from a textbook or paper parses successfully.

| Task                                               | Status | Description                    |
| -------------------------------------------------- | ------ | ------------------------------ |
| Add `\approx`, `\bar`, `\dot`, `\ddot`             | ✅      | Common in physics papers       |
| Add `\Rightarrow`, `\Leftarrow`, `\Leftrightarrow` | ✅      | Logic notation                 |
| Add `\forall`, `\exists`                           | ✅      | Quantifiers (parse as symbols) |
| Add `\subset`, `\subseteq`, `\supset`              | ✅      | Set notation                   |
| Add `\cup`, `\cap`, `\setminus`                    | ✅      | Set operations                 |
| Add `\propto`, `\mapsto`                           | ✅      | Relation symbols               |
| Test with 50+ real academic paper excerpts         | ✅      | Validate "just works" claim    |

### Phase 2: Common Use Case Evaluation

**Goal:** Expressions that can be numerically evaluated, are.

| Task                                          | Status | Description                                              |
| --------------------------------------------- | ------ | -------------------------------------------------------- |
| Unicode input support                         | ✅      | Accept `√`, `∑`, `∫`, `π` directly                       |
| Improved implicit multiplication heuristics   | ✅      | `e^{ix}` works, braces required for multi-char exponents |
| Better error messages for evaluation failures | ✅      | "Cannot evaluate gradient symbolically"                  |

### Phase 3: Developer Experience

**Goal:** Easy integration and debugging.

| Task            | Status | Description                 |
| --------------- | ------ | --------------------------- |
| JSON AST export | ✅      | For debugging and tooling   |
| MathML export   | ✅      | For web display             |
| SymPy export    | ✅      | For Python interoperability |

---

## Non-Goals

The following are explicitly **not** goals for this library:

1. **Full Computer Algebra System (CAS)** — We do pattern-based simplification, not canonical forms
2. **Symbolic tensor calculus** — Parsing tensor notation is supported; evaluation is not
3. **Proof verification** — Logic symbols are parsed but not reasoned about
4. **Typesetting** — Community already has it; we fill the gap with evaluation

### What TeXpr Will *Never* Support

These are permanent architectural boundaries, not future work:

| Feature                                                    | Reason                                           |
| ---------------------------------------------------------- | ------------------------------------------------ |
| **Document-level LaTeX** (`\documentclass`, `\usepackage`) | Out of scope — we parse math, not documents      |
| **Macro expansion** (`\newcommand`, `\def`)                | Would require full LaTeX interpreter             |
| **Full symbolic integration**                              | Requires CAS-level algorithms (use SymPy export) |
| **General polynomial solving** (degree > 2)                | Requires Galois theory / numerical methods       |
| **Theorem proving**                                        | Fundamentally different problem domain           |
| **Arbitrary precision arithmetic**                         | Dart's `double` is the only numeric type         |
| **Procedural programming**                                 | `if`/`for`/`while` constructs won't be added     |
| **Units and dimensions**                                   | Physical units are parsed as variables           |
| **Equation rendering**                                     | Use KaTeX/MathJax; we export LaTeX for this      |

### Scope Philosophy

TeXpr occupies a specific niche:

```
LaTeX Parser (KaTeX, MathJax)     ←  Document rendering
       ↓
    TeXpr                         ←  Mathematical evaluation
       ↓
Full CAS (SymPy, Mathematica)     ←  Symbolic computation
```

We aim to be the **best Dart library for evaluating mathematical expressions written in LaTeX notation**, not a replacement for either end of this spectrum.

---

## Quality Assurance

### Test Coverage

| Category                 | Test Count    | Purpose                                      |
| ------------------------ | ------------- | -------------------------------------------- |
| Unit tests               | 1,500+        | Individual parser/evaluator functions        |
| Integration tests        | 200+          | End-to-end expression evaluation             |
| Security tests           | 800+ lines    | DoS, overflow, resource exhaustion           |
| Fuzz tests               | 2,000+ inputs | Random ASCII and structure-aware fuzzing     |
| Semantic invariant tests | 40+           | Derivative correctness, algebraic identities |
| Academic paper tests     | 50+           | Real-world LaTeX compatibility               |

### Testing Methodology

**Property-Based Testing:**
- Fuzz testing with random ASCII garbage (1,000 iterations)
- Structure-aware fuzzing with LaTeX token combinations (1,000 iterations)
- Known crasher regression tests

**Security Testing:**
- Stack overflow via deep recursion
- Resource exhaustion via large iterations
- Integer overflow edge cases
- Input validation attacks

**Cross-Validation:**
- Manual verification against Wolfram Alpha/SymPy for complex expressions
- Round-trip testing (parse → toLatex → parse)
- Export format validation (JSON, MathML, SymPy)

### Known Testing Gaps

> These are acknowledged limitations in our test suite:

- **No automated cross-CAS validation** — Results are manually verified, not programmatically compared to SymPy/Mathematica
- **No mutation testing** — Code coverage is measured, but mutation coverage is not

---

## How to Contribute

1. Find a LaTeX expression from an academic paper that fails to parse
2. Open an issue with the exact expression
3. We'll add support and tests

### Phase 4: Performance & Optimization

**Goal:** Ensure 60fps performance on mobile devices.

| Task                    | Status | Description                                     |
| ----------------------- | ------ | ----------------------------------------------- |
| Standardized Comparison | ✅      | Cross-language comparison (Dart/JS/Python)      |
| WebAssembly (Wasm)      | ✅      | Compile to WASM for web apps                    |
| Interactive Playground  | ✅      | Live calculator embedded in docs using WASM     |
| Variable Assignment     | ✅      | Support `let x = ...` with context variables    |
| Fuzz Testing            | ✅      | Randomized input generation to catch edge cases |
| User-Defined Functions  | ✅      | Support `f(x) = x^2` style function definitions |

---

### Phase 5: Interval Arithmetic

**Goal:** Support verified computing with error bounds, matching `math_expressions` parity.

| Task                  | Status | Description                                           |
| --------------------- | ------ | ----------------------------------------------------- |
| Interval type         | ✅      | `Interval(lower, upper)` with proper bounds handling  |
| Arithmetic operations | ✅      | `+`, `-`, `*`, `/` with interval propagation          |
| Function evaluation   | ✅      | Monotonic functions (sin, cos, exp, log) on intervals |
| Parser integration    | ✅      | Support `[a, b]` interval notation in LaTeX           |
| Interval result type  | ✅      | `IntervalResult` alongside Numeric/Complex/Matrix     |

**Why this matters:** Interval arithmetic provides guaranteed error bounds for numerical computations, useful for scientific computing and verified results.

---

### Phase 6: Semantic Boundaries (Future Architecture)

**Goal:** Make the distinction between "can parse" and "can evaluate" explicit in the type system.

| Task                       | Status | Description                                                       |
| -------------------------- | ------ | ----------------------------------------------------------------- |
| Evaluability enum          | ✅      | Add `Evaluability.numeric`, `.symbolic`, `.unevaluable` to nodes  |
| Compile-time evaluability  | 📋      | Parser annotates AST with evaluability at parse time              |
| Semantic invariant testing | ✅      | Property-based tests for derivative correctness, round-trip, etc. |

**Why this matters:** As the parsed surface area grows (tensors, quantifiers, set notation), the gap between "parses successfully" and "has computable meaning" becomes a usability hazard. Explicit evaluability prevents false expectations.

#### Architectural Notes

**Evaluability Enum Concept:**
```dart
enum Evaluability {
  /// Expression can be fully evaluated to a numeric/complex/matrix result
  numeric,
  /// Expression is symbolic-only (e.g., \nabla f, tensor indices)
  symbolic,
  /// Expression cannot be evaluated (missing context or undefined)
  unevaluable,
}
```

**Cost Model Considerations:**
- Simpson's Rule integration: O(n) where n = subdivisions
- Interval arithmetic: O(4) per operation (4 endpoint combinations)
- Nested structures multiply: `\sum_{i=1}^{100} \int_0^1 [a,b] \cdot x^i dx` → O(100 × n × 4)
- Without explicit budgets, "60fps on mobile" is empirical, not guaranteed

---

**Last Updated:** 2026-01-08

