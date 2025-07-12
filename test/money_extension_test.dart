import 'package:flutter_test/flutter_test.dart';
import 'package:daftra_task/src/util/money_extension.dart';

void main() {
  test('asMoney formats to 2 decimal places', () {
    expect(12.0.asMoney, '12.00');
    expect(12.345.asMoney, '12.35');
    expect(0.asMoney, '0.00');
    expect(99.999.asMoney, '100.00');
  });
}
