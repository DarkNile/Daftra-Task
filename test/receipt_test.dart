import 'package:flutter_test/flutter_test.dart';
import 'package:daftra_task/src/cart/receipt.dart';
import 'package:daftra_task/src/cart/models.dart';
import 'package:daftra_task/src/catalog/item.dart';

void main() {
  test('buildReceipt returns correct Receipt', () {
    final item = Item(id: 'p01', name: 'Coffee', price: 2.5);
    final line = CartLine(item: item, quantity: 2, discount: 0.1);
    final totals = Totals(
      subtotal: 4.5,
      vat: 0.68,
      discount: 0.5,
      grandTotal: 5.18,
    );
    final cart = CartState(lines: [line], totals: totals);
    final now = DateTime.now();
    final receipt = buildReceipt(
      cart,
      now,
      cashier: 'Alice',
      storeName: 'Test Store',
    );
    expect(receipt.header.dateTime, now);
    expect(receipt.header.cashier, 'Alice');
    expect(receipt.header.storeName, 'Test Store');
    expect(receipt.lines.length, 1);
    expect(receipt.lines.first.itemId, item.id);
    expect(receipt.lines.first.quantity, 2);
    expect(receipt.lines.first.discount, 0.1);
    expect(receipt.totals.subtotal, 4.5);
    expect(receipt.totals.vat, 0.68);
    expect(receipt.totals.discount, 0.5);
    expect(receipt.totals.grandTotal, 5.18);
  });
}
