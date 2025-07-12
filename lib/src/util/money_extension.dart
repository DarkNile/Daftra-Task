/// Extension to format numbers as money strings.
extension MoneyExtension on num {
  /// Returns the number as a string with 2 decimal places (e.g., "12.34").
  String get asMoney => toStringAsFixed(2);
}
