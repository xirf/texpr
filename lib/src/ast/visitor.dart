// Import all AST node types
import 'basic.dart';
import 'operations.dart';
import 'functions.dart';
import 'calculus.dart';
import 'logic.dart';
import 'matrix.dart';
import 'environment.dart';

/// Visitor pattern interface for traversing and operating on AST nodes.
///
/// The Visitor pattern allows you to separate algorithms from the object
/// structure they operate on. This makes it easy to add new operations
/// without modifying the AST node classes.
///
/// ## Type Parameters
///
/// - `R`: The return type of visit methods
/// - `C`: The context type passed to visit methods (optional)
///
/// ## Usage
///
/// ```dart
/// class MyVisitor implements ExpressionVisitor<String, Map<String, num>> {
///   @override
///   String visitNumberLiteral(NumberLiteral node, Map<String, num>? context) {
///     return 'Number: ${node.value}';
///   }
///
///   @override
///   String visitVariable(Variable node, Map<String, num>? context) {
///     return 'Variable: ${node.name}';
///   }
///
///   // ... implement other visit methods
/// }
///
/// final visitor = MyVisitor();
/// final result = expression.accept(visitor, {'x': 5});
/// ```
abstract class ExpressionVisitor<R, C> {
  // Literals
  R visitNumberLiteral(NumberLiteral node, C? context);
  R visitVariable(Variable node, C? context);

  // Binary operations
  R visitBinaryOp(BinaryOp node, C? context);
  R visitUnaryOp(UnaryOp node, C? context);

  // Functions
  R visitFunctionCall(FunctionCall node, C? context);
  R visitAbsoluteValue(AbsoluteValue node, C? context);

  // Calculus
  R visitLimitExpr(LimitExpr node, C? context);
  R visitSumExpr(SumExpr node, C? context);
  R visitProductExpr(ProductExpr node, C? context);
  R visitIntegralExpr(IntegralExpr node, C? context);
  R visitMultiIntegralExpr(MultiIntegralExpr node, C? context);
  R visitDerivativeExpr(DerivativeExpr node, C? context);
  R visitPartialDerivativeExpr(PartialDerivativeExpr node, C? context);
  R visitBinomExpr(BinomExpr node, C? context);
  R visitGradientExpr(GradientExpr node, C? context);

  // Logic
  R visitComparison(Comparison node, C? context);
  R visitChainedComparison(ChainedComparison node, C? context);
  R visitConditionalExpr(ConditionalExpr node, C? context);
  R visitPiecewise(PiecewiseExpr node, C? context);

  // Matrix and Vector
  R visitMatrixExpr(MatrixExpr node, C? context);
  R visitVectorExpr(VectorExpr node, C? context);
  R visitIntervalExpr(IntervalExpr node, C? context);

  // Custom Environments
  R visitAssignmentExpr(AssignmentExpr node, C? context);
  R visitFunctionDefinitionExpr(FunctionDefinitionExpr node, C? context);
}
