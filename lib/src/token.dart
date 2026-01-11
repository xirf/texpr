/// Token types and Token class for the LaTeX math lexer.
library;

/// Represents the type of a lexical token.
enum TokenType {
  /// Numeric literal (integer or decimal).
  number,

  /// Variable identifier (single letter).
  variable,

  /// Addition operator `+`.
  plus,

  /// Subtraction operator `-`.
  minus,

  /// Multiplication operator `*`, `\times`, or `\cdot`.
  multiply,

  /// Division operator `/` or `\div`.
  divide,

  /// Power/exponent operator `^`.
  power,

  /// Left parenthesis `(` or left brace `{`.
  lparen,

  /// Right parenthesis `)` or right brace `}`.
  rparen,

  /// Left square bracket `[`.
  lbracket,

  /// Right square bracket `]`.
  rbracket,

  /// Left angle bracket `\langle`.
  langle,

  /// Right angle bracket `\rangle`.
  rangle,

  /// Underscore `_` for subscripts.
  underscore,

  /// Function name (e.g., `\log`, `\ln`, `\sin`).
  function,

  /// Fraction `\frac`.
  frac,

  /// Binomial coefficient `\binom`.
  binom,

  /// Limit keyword `\lim`.
  lim,

  /// Sum keyword `\sum`.
  sum,

  /// Product keyword `\prod`.
  prod,

  /// Integral keyword `\int`.
  int,

  /// Double integral `\iint`.
  iint,

  /// Triple integral `\iiint`.
  iiint,

  /// Closed surface integral `\oint`.
  oint,

  /// Square root `\sqrt`.
  sqrt,

  /// Partial derivative symbol `\partial`.
  partial,

  /// Gradient operator `\nabla`.
  nabla,

  /// Arrow `\to` or `\rightarrow`.
  to,

  /// Equals sign `=`.
  equals,

  /// Infinity `\infty`.
  infty,

  /// Mathematical constant (e.g., `\pi`, `\tau`, `\phi`).
  constant,

  // Comparison
  less,
  greater,
  lessEqual,
  greaterEqual,

  // Misc
  /// Comma `,`.
  comma,

  /// Pipe `|` for absolute value.
  pipe,

  /// Ampersand `&` for matrix column separation.
  ampersand,

  /// Double backslash `\\` for matrix row separation.
  backslash,

  /// Begin environment `\begin`.
  begin,

  /// End environment `\end`.
  end,

  /// Text mode `\text`.
  text,

  /// Not equal `\neq`.
  notEqual,

  /// Set membership `\in`.
  member,

  // Boolean operators
  /// Logical AND: `\land`, `\wedge`
  boolAnd,

  /// Logical OR: `\lor`, `\vee`
  boolOr,

  /// Logical NOT: `\neg`, `\lnot`
  boolNot,

  /// Logical XOR: `\oplus`
  boolXor,

  /// Logical implication: `\Rightarrow`, `\implies`
  boolImplies,

  /// Logical biconditional: `\Leftrightarrow`, `\iff`
  boolIff,

  /// Spacing commands (e.g., `\,`, `\;`, `\quad`).
  spacing,

  /// Ignored command (e.g., `\left`, `\right`, `\big`).
  ignored,

  /// Font command (e.g., `\mathbf`, `\mathcal`, `\mathrm`).
  fontCommand,

  /// The `let` keyword for variable assignment.
  letKeyword,

  /// End of input.
  eof,
}

/// Extension to provide user-friendly names for tokens.
extension TokenTypeReadable on TokenType {
  /// Returns a human-readable name for the token type.
  String get readableName {
    switch (this) {
      case TokenType.number:
        return 'number';
      case TokenType.variable:
        return 'variable';
      case TokenType.plus:
        return "'+'";
      case TokenType.minus:
        return "'-'";
      case TokenType.multiply:
        return "'*'";
      case TokenType.divide:
        return "'/'";
      case TokenType.power:
        return "'^'";
      case TokenType.lparen:
        return "'(' or '{'";
      case TokenType.rparen:
        return "')' or '}'";
      case TokenType.lbracket:
        return "'['";
      case TokenType.rbracket:
        return "']'";
      case TokenType.langle:
        return "'\\langle'";
      case TokenType.rangle:
        return "'\\rangle'";
      case TokenType.underscore:
        return "'_'";
      case TokenType.function:
        return 'function';
      case TokenType.frac:
        return "'\\frac'";
      case TokenType.binom:
        return "'\\binom'";
      case TokenType.lim:
        return "'\\lim'";
      case TokenType.sum:
        return "'\\sum'";
      case TokenType.prod:
        return "'\\prod'";
      case TokenType.int:
        return "'\\int'";
      case TokenType.iint:
        return "'\\iint'";
      case TokenType.iiint:
        return "'\\iiint'";
      case TokenType.oint:
        return "'\\oint'";
      case TokenType.sqrt:
        return "'\\sqrt'";
      case TokenType.partial:
        return "'\\partial'";
      case TokenType.nabla:
        return "'\\nabla'";
      case TokenType.to:
        return "'\\to'";
      case TokenType.equals:
        return "'='";
      case TokenType.infty:
        return "'\\infty'";
      case TokenType.constant:
        return 'constant';
      case TokenType.less:
        return "'<'";
      case TokenType.greater:
        return "'>'";
      case TokenType.lessEqual:
        return "'<='";
      case TokenType.greaterEqual:
        return "'>='";
      case TokenType.comma:
        return "','";
      case TokenType.pipe:
        return "'|'";
      case TokenType.ampersand:
        return "'&'";
      case TokenType.backslash:
        return "'\\\\'";
      case TokenType.begin:
        return "'\\begin'";
      case TokenType.end:
        return "'\\end'";
      case TokenType.text:
        return "'\\text'";
      case TokenType.notEqual:
        return "'\\neq'";
      case TokenType.member:
        return "'\\in'";
      case TokenType.boolAnd:
        return "'\\land'";
      case TokenType.boolOr:
        return "'\\lor'";
      case TokenType.boolNot:
        return "'\\neg'";
      case TokenType.boolXor:
        return "'\\oplus'";
      case TokenType.boolImplies:
        return "'\\Rightarrow'";
      case TokenType.boolIff:
        return "'\\Leftrightarrow'";
      case TokenType.spacing:
        return 'spacing';
      case TokenType.ignored:
        return 'modifier';
      case TokenType.fontCommand:
        return 'font command';
      case TokenType.letKeyword:
        return "'let'";
      case TokenType.eof:
        return 'end of expression';
    }
  }
}

/// Represents a single lexical token.
class Token {
  /// The type of this token.
  final TokenType type;

  /// The literal value of this token (e.g., "3.14" for a number).
  final String value;

  /// The position in the source string where this token starts.
  final int position;

  /// The numeric value if this is a number token.
  final double? numberValue;

  const Token({
    required this.type,
    required this.value,
    required this.position,
    this.numberValue,
  });

  @override
  String toString() => 'Token($type, "$value", pos:$position)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Token &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          value == other.value;

  @override
  int get hashCode => type.hashCode ^ value.hashCode;
}
