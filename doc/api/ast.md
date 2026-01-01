# Abstract Syntax Tree (AST)

The `Expression` class is the abstract base class for all nodes in the parsed AST.

## Base Class

### `Expression`

Represents a node in the expression tree. All specific node types extend this class.

## Node Types

The following are the key subclasses of `Expression` produced by the parser:

### Basic Values

*   `NumberLiteral`: A numeric constant (e.g., `123`, `3.14`).
*   `Variable`: A variable reference (e.g., `x`, `\pi`).
*   `MatrixExpr`: A matrix definition (e.g., `\begin{matrix}...\end{matrix}`).
*   `VectorExpr`: A vector definition (e.g., `\vec{v}`).

### Operations

*   `BinaryOp`: Binary operation (e.g., `+`, `-`, `*`, `/`, `^`).
    *   Properties: `left`, `right`, `operator`.
*   `UnaryOp`: Unary operation (e.g., `-x`).
    *   Properties: `operand`, `operator`.
*   `AbsoluteValue`: Absolute value wrapper (e.g., `|x|`).

### Functions and Calculus

*   `FunctionCall`: A standard function call (e.g., `\sin{x}`).
    *   Properties: `name`, `argument`.
*   `LimitExpr`: Limit expression (e.g., `\lim_{x \to 0}`).
*   `SumExpr`: Summation (e.g., `\sum`).
*   `ProductExpr`: Product (e.g., `\prod`).
*   `IntegralExpr`: Integral (e.g., `\int`).
    *   Properties: `lower`, `upper`, `body`, `variable`, `isClosed`.
*   `DerivativeExpr`: Derivative (e.g., `\frac{d}{dx}`).
    *   Properties: `body`, `variable`, `order`.
*   `PartialDerivativeExpr`: Partial derivative (e.g., `\frac{\partial}{\partial x}`).
*   `MultiIntegralExpr`: Multiple integral (e.g., `\iint`, `\iiint`).
*   `BinomExpr`: Binomial coefficient (e.g., `\binom{n}{k}`).

### Logic and Comparisons

*   `Comparison`: Simple comparison (e.g., `x < 2`).
*   `ChainedComparison`: Chained comparison (e.g., `0 < x < 1`).
*   `ConditionalExpr`: Conditional expression (e.g., `x^2 \text{ where } x > 0`).
*   `PiecewiseExpr`: Piecewise function (cases).
    *   Properties: `cases` (list of `PiecewiseCase`).
*   `PiecewiseCase`: A single case in a piecewise function.
    *   Properties: `expression`, `condition`.
