import '../data/firestore_date.dart';

class ReceiptRecord {
  const ReceiptRecord({
    required this.id,
    required this.userId,
    required this.purchaseDate,
    required this.totalAmount,
    required this.items,
    this.martId,
    this.martName,
    this.imageUrl,
    this.ocrResult,
  });

  final String id;
  final String userId;
  final DateTime purchaseDate;
  final int totalAmount;
  final List<ReceiptItem> items;
  final String? martId;
  final String? martName;
  final String? imageUrl;
  final Map<String, dynamic>? ocrResult;

  factory ReceiptRecord.fromMap(String id, Map<String, dynamic> data) {
    return ReceiptRecord(
      id: id,
      userId: data['userId'] as String? ?? '',
      purchaseDate:
          dateTimeFromFirestore(data['purchaseDate']) ?? DateTime.now(),
      totalAmount: data['totalAmount'] as int? ?? 0,
      items: (data['items'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ReceiptItem.fromMap)
          .toList(),
      martId: data['martId'] as String?,
      martName: data['martName'] as String?,
      imageUrl: data['imageUrl'] as String?,
      ocrResult: data['ocrResult'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'purchaseDate': dateTimeToFirestore(purchaseDate),
      'totalAmount': totalAmount,
      'items': items.map((item) => item.toMap()).toList(),
      'martId': martId,
      'martName': martName,
      'imageUrl': imageUrl,
      'ocrResult': ocrResult,
    };
  }
}

class ReceiptItem {
  const ReceiptItem({
    required this.productName,
    required this.category,
    required this.amount,
    this.quantity,
    this.unitPrice,
  });

  final String productName;
  final String category;
  final int amount;
  final double? quantity;
  final int? unitPrice;

  factory ReceiptItem.fromMap(Map<String, dynamic> data) {
    return ReceiptItem(
      productName: data['productName'] as String? ?? '',
      category: data['category'] as String? ?? '',
      amount: data['amount'] as int? ?? 0,
      quantity: (data['quantity'] as num?)?.toDouble(),
      unitPrice: data['unitPrice'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productName': productName,
      'category': category,
      'amount': amount,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}
