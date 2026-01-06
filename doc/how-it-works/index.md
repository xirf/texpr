# How It Works

TeXpr processes LaTeX mathematical expressions through a multi-stage pipeline. Understanding this pipeline helps you use the library effectively and debug issues when they arise.

## The Processing Pipeline

```
┌──────────────────────────────────────────────────────────────────────────┐
│                          TeXpr Processing Pipeline                        │
├──────────────────────────────────────────────────────────────────────────┤
│                                                                           │
│  Input String          Tokens              AST                 Result     │
│  ┌─────────┐         ┌────────┐         ┌─────────┐         ┌─────────┐  │
│  │ \sin{x} │  ────►  │ Token  │  ────►  │  Func   │  ────►  │ 0.8414  │  │
│  │  + 1    │         │ Stream │         │  Call   │         │         │  │
│  └─────────┘         └────────┘         └─────────┘         └─────────┘  │
│                                                                           │
│      ▲                   ▲                  ▲                   ▲        │
│      │                   │                  │                   │        │
│  Tokenizer            Parser            Evaluator            Result      │
│                                                                           │
└──────────────────────────────────────────────────────────────────────────┘
```

### Stage 1: Tokenization

The **Tokenizer** reads the input string character-by-character and produces a stream of tokens. Each token represents a meaningful unit: a number, an operator, a function name, a variable, etc.

**Example**: `\sin{x} + 1` becomes:
```
[FUNCTION:sin] [LBRACE] [VARIABLE:x] [RBRACE] [OPERATOR:+] [NUMBER:1]
```

Key behaviors:
- **LaTeX commands** like `\sin`, `\frac`, `\sqrt` are recognized as function tokens
- **Implicit multiplication** is detected and inserted (e.g., `2x` becomes `2 * x`)
- **Greek letters** like `\pi`, `\alpha` are converted to their symbolic values and constants

[Learn more about tokenization →](./tokenizer.md)

---

### Stage 2: Parsing

The **Parser** consumes tokens and builds an **Abstract Syntax Tree (AST)**. The AST is a hierarchical representation of the expression's structure.

**Example**: `\sin{x} + 1` becomes:
```
     BinaryOp(+)
        /    \
  FunctionCall  NumberLiteral(1)
   (sin)
     |
  Variable(x)
```

Key behaviors:
- **Operator precedence** is enforced (e.g., `*` binds tighter than `+`)
- **Associativity** is applied (e.g., `2^3^4` = `2^(3^4)`, right-to-left)
- **Complex constructs** like matrices and integrals are parsed into specialized nodes

[Learn more about parsing →](./parser.md)

---

### Stage 3: Evaluation

The **Evaluator** traverses the AST and computes the result. It starts at the root node and recursively evaluates children.

**Example**: To evaluate `sin(x) + 1` with `x = 1`:
1. Evaluate left child: `sin(x)` → `sin(1)` → `0.8414...`
2. Evaluate right child: `1` → `1`
3. Apply operator: `0.8414 + 1` → `1.8414`

Key behaviors:
- **Variable binding** substitutes values from the provided map
- **Type handling** returns appropriate result types (Numeric, Complex, Matrix, Vector)
- **Built-in functions** are dispatched to their implementations

[Learn more about evaluation →](./evaluator.md)

---

### Stage 4: Caching

TeXpr uses a **multi-layer cache** to avoid redundant work:

| Layer  | What's Cached           | When It Helps                         |
| ------ | ----------------------- | ------------------------------------- |
| **L1** | Parsed ASTs             | Same expression parsed multiple times |
| **L2** | Evaluation results      | Same expression + same variables      |
| **L3** | Differentiation results | Same derivative computed again        |
| **L4** | Sub-expression results  | Repeated sub-trees during evaluation  |

**Example**: If you evaluate `sin(x)^2 + cos(x)^2` multiple times with different `x` values, L1 caches the AST so it's only parsed once.

[Learn more about caching →](./caching.md)

---

## Why This Architecture?

### Separation of Concerns
Each stage has a single responsibility. This makes the code maintainable and allows you to:
- Parse once, evaluate many times for performance
- Inspect the AST for debugging or visualization
- Apply symbolic operations (differentiation) on the AST

### Type Safety
The AST uses Dart's sealed class pattern, ensuring exhaustive handling of all expression types. Results are similarly typed, letting you pattern match on `NumericResult`, `ComplexResult`, etc.

### Extensibility
Each component can be extended:
- Add custom tokens via `ExtensionRegistry.registerCommand()`
- Add custom evaluators via `ExtensionRegistry.registerEvaluator()`
- The AST visitor pattern supports custom traversals

---

## Quick Reference

| Component | Class                   | Purpose                        |
| --------- | ----------------------- | ------------------------------ |
| Tokenizer | `Tokenizer`             | Converts string to tokens      |
| Parser    | `Parser`                | Converts tokens to AST         |
| AST Nodes | `Expression` subclasses | Represent expression structure |
| Evaluator | `Evaluator`             | Computes results from AST      |
| Cache     | `CacheManager`          | Optimizes repeated operations  |

---

## Next Steps

- [Tokenizer Deep Dive](./tokenizer.md) — How input is broken into tokens
- [Parser Deep Dive](./parser.md) — How AST is constructed
- [Evaluator Deep Dive](./evaluator.md) — How results are computed
- [Caching Deep Dive](./caching.md) — Performance optimization
