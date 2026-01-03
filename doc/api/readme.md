# API Reference

Welcome to the API reference for the `texpr` package. This documentation covers the public API surface of the library.

## Core

*   [Texpr](core.md#Texpr): The main entry point for parsing and evaluating expressions.
*   [EvaluationResult](core.md#evaluationresult): The type-safe result returned by evaluation.

## Data Types

*   [Matrix](data_types.md#matrix): Support for matrix operations.
*   [Vector](data_types.md#vector): Support for vector operations.
*   [Complex](data_types.md#complex): Support for complex number operations.

## Customization

*   [ExtensionRegistry](customization.md#extensionregistry): Mechanism to add custom commands and evaluators.
*   [Tokenizer](customization.md#tokenizer): Low-level access to the tokenizer.
*   [Parser](customization.md#parser): Low-level access to the parser.

## AST (Abstract Syntax Tree)

*   [Expression](ast.md): The base class for all parsed expression nodes.
    *   Supports: Basic operations, Functions, Matrices, Vectors, Limits, Integrals (`\int`, `\oint`, `\iint`), Derivatives, Partial Derivatives, Gradient (`\nabla`).
    *   Logic: Comparisons, Piecewise functions (`\begin{cases}`).

## Exceptions

*   [TexprException](exceptions.md): Base class for all library exceptions.
*   [ValidationResult](exceptions.md#validationresult): Detailed validation information.

## Security

*   [Security Considerations](../security.md): Overview of security mitigations and limits.
