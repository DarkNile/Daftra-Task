/// Represents a product in the catalog.
class Item {
  /// Unique identifier for the item.
  final String id;

  /// Name of the item.
  final String name;

  /// Price of the item.
  final double price;

  /// Creates an [Item] instance.
  const Item({required this.id, required this.name, required this.price});

  /// Creates an [Item] from a JSON map.
  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
  );

  /// Converts the [Item] to a JSON map.
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'price': price};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ price.hashCode;
}
