import '../data/firestore_date.dart';

class ShoppingMemo {
  const ShoppingMemo({
    required this.id,
    required this.userId,
    required this.productName,
    required this.createdAt,
    this.kind = 'memo',
    this.martName,
    this.price,
    this.quantity,
    this.unit,
    this.cartQuantity,
    this.targetPrice,
    this.alertEnabled = true,
    this.completed = false,
  });

  final String id;
  final String userId;
  final String productName;
  final DateTime createdAt;
  final String kind;
  final String? martName;
  final int? price;
  final double? quantity;
  final String? unit;
  final int? cartQuantity;
  final int? targetPrice;
  final bool alertEnabled;
  final bool completed;

  factory ShoppingMemo.fromMap(String id, Map<String, dynamic> data) {
    return ShoppingMemo(
      id: id,
      userId: data['userId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      createdAt: dateTimeFromFirestore(data['createdAt']) ?? DateTime.now(),
      kind: data['kind'] as String? ?? 'memo',
      martName: data['martName'] as String?,
      price: (data['price'] as num?)?.toInt(),
      quantity: (data['quantity'] as num?)?.toDouble(),
      unit: data['unit'] as String?,
      cartQuantity: (data['cartQuantity'] as num?)?.toInt(),
      targetPrice: data['targetPrice'] as int?,
      alertEnabled: data['alertEnabled'] as bool? ?? true,
      completed: data['completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productName': productName,
      'createdAt': dateTimeToFirestore(createdAt),
      'kind': kind,
      'martName': martName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'cartQuantity': cartQuantity,
      'targetPrice': targetPrice,
      'alertEnabled': alertEnabled,
      'completed': completed,
    };
  }
}
