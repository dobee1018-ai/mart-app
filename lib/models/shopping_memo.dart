import '../data/firestore_date.dart';

class ShoppingMemo {
  const ShoppingMemo({
    required this.id,
    required this.userId,
    required this.productName,
    required this.createdAt,
    this.quantity,
    this.unit,
    this.targetPrice,
    this.alertEnabled = true,
    this.completed = false,
  });

  final String id;
  final String userId;
  final String productName;
  final DateTime createdAt;
  final double? quantity;
  final String? unit;
  final int? targetPrice;
  final bool alertEnabled;
  final bool completed;

  factory ShoppingMemo.fromMap(String id, Map<String, dynamic> data) {
    return ShoppingMemo(
      id: id,
      userId: data['userId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      createdAt: dateTimeFromFirestore(data['createdAt']) ?? DateTime.now(),
      quantity: (data['quantity'] as num?)?.toDouble(),
      unit: data['unit'] as String?,
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
      'quantity': quantity,
      'unit': unit,
      'targetPrice': targetPrice,
      'alertEnabled': alertEnabled,
      'completed': completed,
    };
  }
}
