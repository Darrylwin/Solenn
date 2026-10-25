/// The four binary arithmetic operators.
enum ArithmeticOperator {
  /// Addition.
  add,

  /// Subtraction.
  subtract,

  /// Multiplication.
  multiply,

  /// Division.
  divide
  ;

  /// Whether this operator binds tighter than addition and subtraction.
  bool get hasHighPrecedence => this == multiply || this == divide;
}
