/// A key of the calculator keypad.
///
/// The domain only knows *what* was pressed. How a key looks or is spoken
/// belongs to the presentation layer.
enum CalculatorKey {
  /// The digit 0.
  zero(0),

  /// The digit 1.
  one(1),

  /// The digit 2.
  two(2),

  /// The digit 3.
  three(3),

  /// The digit 4.
  four(4),

  /// The digit 5.
  five(5),

  /// The digit 6.
  six(6),

  /// The digit 7.
  seven(7),

  /// The digit 8.
  eight(8),

  /// The digit 9.
  nine(9),

  /// The decimal separator. Its glyph depends on the device locale.
  decimalSeparator,

  /// Flips the sign of the current entry.
  toggleSign,

  /// Percent.
  percent,

  /// Clears the whole input (AC).
  clear,

  /// Deletes the last digit of the current entry.
  backspace,

  /// Addition.
  add,

  /// Subtraction.
  subtract,

  /// Multiplication.
  multiply,

  /// Division.
  divide,

  /// Evaluates the expression.
  equals
  ;

  const CalculatorKey([this.digit]);

  /// The value of a digit key, or `null` for every other key.
  final int? digit;

  /// Whether this key enters a digit.
  bool get isDigit => digit != null;

  /// Whether this key is one of the four arithmetic operators.
  bool get isOperator => switch (this) {
    add || subtract || multiply || divide => true,
    _ => false,
  };
}
