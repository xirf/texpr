# Exceptions and Validation

## TexprException

Base sealed class for all exceptions thrown by the library.

### Properties

*   `message`: Error message.
*   `position`: Index in the source string where error occurred.
*   `expression`: The source expression string.
*   `suggestion`: Helpful suggestion to fix the error.

### Subclasses

*   `TokenizerException`: Error during tokenization (e.g., unknown character).
*   `ParserException`: Error during parsing (e.g., missing parenthesis).
*   `EvaluatorException`: Error during evaluation (e.g., undefined variable, division by zero).

---

## ValidationResult

Returned by `Texpr.validate()`. The `validate()` method performs automatic error recovery, allowing it to collect multiple errors in a single pass.

### Properties

*   `isValid`: `true` if no errors found.
*   `errorMessage`: Description of the error (if invalid).
*   `position`: Error index (if invalid).
*   `suggestion`: Fix suggestion (if invalid).
*   `exceptionType`: The specific exception class that would be thrown.
*   `subErrors`: List of additional `ValidationResult`s found during parsing (if multiple errors exist).

### Methods

*   `ValidationResult.valid()`: Creates a success result.
*   `ValidationResult.fromException(TexprException e)`: Creates a failure result from an exception.
*   `ValidationResult.fromExceptions(List<TexprException> exceptions)`: Creates a result from a list of exceptions.
