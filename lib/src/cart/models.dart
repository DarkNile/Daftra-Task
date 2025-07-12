import 'package:equatable/equatable.dart';
import '../catalog/item.dart';

/// Represents a line in the cart (an item, its quantity, and discount).
class CartLine extends Equatable {
  /// The item in the cart line.
  final Item item;

  /// The quantity of the item.
  final int quantity;

  /// Discount percentage (0.0 - 1.0) for this line.
  final double discount;

  /// Creates a [CartLine].
  const CartLine({
    required this.item,
    required this.quantity,
    this.discount = 0.0,
  });

  /// Net value for this line after discount.
  double get lineNet => item.price * quantity * (1 - discount);

  /// Creates a copy with new values.
  CartLine copyWith({int? quantity, double? discount}) => CartLine(
    item: item,
    quantity: quantity ?? this.quantity,
    discount: discount ?? this.discount,
  );

  /// Creates a [CartLine] from JSON.
  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    item: Item.fromJson(json['item']),
    quantity: json['quantity'],
    discount: (json['discount'] as num).toDouble(),
  );

  /// Converts [CartLine] to JSON.
  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'quantity': quantity,
    'discount': discount,
  };

  @override
  List<Object?> get props => [item, quantity, discount];
}

/// Represents the running totals for the cart.
class Totals extends Equatable {
  /// Subtotal before VAT.
  final double subtotal;

  /// VAT amount.
  final double vat;

  /// Total discount amount.
  final double discount;

  /// Grand total (subtotal + vat).
  final double grandTotal;

  /// Creates [Totals].
  const Totals({
    required this.subtotal,
    required this.vat,
    required this.discount,
    required this.grandTotal,
  });

  /// Creates [Totals] from JSON.
  factory Totals.fromJson(Map<String, dynamic> json) => Totals(
    subtotal: (json['subtotal'] as num).toDouble(),
    vat: (json['vat'] as num).toDouble(),
    discount: (json['discount'] as num).toDouble(),
    grandTotal: (json['grandTotal'] as num).toDouble(),
  );

  /// Converts [Totals] to JSON.
  Map<String, dynamic> toJson() => {
    'subtotal': subtotal,
    'vat': vat,
    'discount': discount,
    'grandTotal': grandTotal,
  };

  @override
  List<Object?> get props => [subtotal, vat, discount, grandTotal];
}

/// Represents the state of the cart (lines and totals).
class CartState extends Equatable {
  /// The lines in the cart.
  final List<CartLine> lines;

  /// The running totals for the cart.
  final Totals totals;

  /// Creates a [CartState].
  const CartState({required this.lines, required this.totals});

  /// Initial empty cart state.
  factory CartState.initial() => CartState(
    lines: const [],
    totals: const Totals(subtotal: 0, vat: 0, discount: 0, grandTotal: 0),
  );

  /// Creates a [CartState] from JSON.
  factory CartState.fromJson(Map<String, dynamic> json) => CartState(
    lines: (json['lines'] as List).map((e) => CartLine.fromJson(e)).toList(),
    totals: Totals.fromJson(json['totals']),
  );

  /// Converts [CartState] to JSON.
  Map<String, dynamic> toJson() => {
    'lines': lines.map((e) => e.toJson()).toList(),
    'totals': totals.toJson(),
  };

  @override
  List<Object?> get props => [lines, totals];
}
