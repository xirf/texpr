/// Core evaluation, parsing, and tokenization functionality.
///
/// This module contains the fundamental building blocks of the LaTeX
/// math evaluator:
/// - AST (Abstract Syntax Tree) node definitions
/// - Tokenizer for lexical analysis
/// - Parser for syntax analysis
/// - Evaluator for expression evaluation
/// - Expression caching for performance
library;

// AST
export '../ast.dart';

// Tokenization
export '../token.dart';
export '../tokenizer.dart';
export '../tokenizer/command_registry.dart';

// Parsing
export '../parser.dart';

// Evaluation
export '../evaluator.dart';
export '../evaluation_result.dart';

// Caching
export '../cache/lru_cache.dart';
