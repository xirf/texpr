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

1. **Full Computer Algebra System (CAS)** - We do pattern-based simplification, not canonical forms
2. **Symbolic tensor calculus** - Parsing tensor notation is supported; evaluation is not
3. **Proof verification** - Logic symbols are parsed but not reasoned about
4. **Typesetting** - Community already had it, we fill the gap with evaluation

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
| AOT Compilation Profile | 📋      | Verify performance in release builds            |
| Fuzz Testing            | 📋      | Randomized input generation to catch edge cases |
| User-Defined Functions  | 📋      | Support `f(x) = x^2` style function definitions |

### Phase 5: Interval Arithmetic

**Goal:** Support verified computing with error bounds, matching `math_expressions` parity.

| Task                  | Status | Description                                           |
| --------------------- | ------ | ----------------------------------------------------- |
| Interval type         | 📋      | `Interval(lower, upper)` with proper bounds handling  |
| Arithmetic operations | 📋      | `+`, `-`, `*`, `/` with interval propagation          |
| Function evaluation   | 📋      | Monotonic functions (sin, cos, exp, log) on intervals |
| Parser integration    | 📋      | Support `[a, b]` interval notation in LaTeX           |
| Interval result type  | 📋      | `IntervalResult` alongside Numeric/Complex/Matrix     |

**Why this matters:** Interval arithmetic provides guaranteed error bounds for numerical computations, useful for scientific computing and verified results.

---

**Last Updated:** 2026-01-07
