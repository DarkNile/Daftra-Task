import 'models.dart';

/// Header information for a receipt.
class ReceiptHeader {
  /// The date and time of the transaction.
  final DateTime dateTime;

  /// Any additional header info (e.g., cashier, store name).
  final String? cashier;
  final String? storeName;

  /// Creates a [ReceiptHeader].
  const ReceiptHeader({required this.dateTime, this.cashier, this.storeName});

  Map<String, dynamic> toJson() => {
    'dateTime': dateTime.toIso8601String(),
    if (cashier != null) 'cashier': cashier,
    if (storeName != null) 'storeName': storeName,
  };
}

/// Line item in a receipt.
class ReceiptLine {
  final String itemId;
  final String name;
  final int quantity;
  final double price;
  final double discount;
  final double lineNet;

  /// Creates a [ReceiptLine].
  const ReceiptLine({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.lineNet,
  });

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'name': name,
    'quantity': quantity,
    'price': price,
    'discount': discount,
    'lineNet': lineNet,
  };
}

/// DTO for a completed receipt.
class Receipt {
  final ReceiptHeader header;
  final List<ReceiptLine> lines;
  final Totals totals;

  /// Creates a [Receipt].
  const Receipt({
    required this.header,
    required this.lines,
    required this.totals,
  });

  Map<String, dynamic> toJson() => {
    'header': header.toJson(),
    'lines': lines.map((e) => e.toJson()).toList(),
    'totals': totals.toJson(),
  };
}

/// Builds a [Receipt] from the current [CartState] and [DateTime].
Receipt buildReceipt(
  CartState cart,
  DateTime dateTime, {
  String? cashier,
  String? storeName,
}) {
  return Receipt(
    header: ReceiptHeader(
      dateTime: dateTime,
      cashier: cashier,
      storeName: storeName,
    ),
    lines:
        cart.lines
            .map(
              (line) => ReceiptLine(
                itemId: line.item.id,
                name: line.item.name,
                quantity: line.quantity,
                price: line.item.price,
                discount: line.discount,
                lineNet: line.lineNet,
              ),
            )
            .toList(),
    totals: cart.totals,
  );
}
