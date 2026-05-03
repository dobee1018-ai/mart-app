import 'app_enums.dart';
import '../data/firestore_date.dart';

class PriceItem {
  const PriceItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.category,
    required this.martId,
    required this.martName,
    required this.salePrice,
    required this.unit,
    required this.source,
    required this.approvalStatus,
    this.brandName,
    this.volume,
    this.originalPrice,
    this.discountRate,
    this.saleStartDate,
    this.saleEndDate,
    this.reportId,
  });

  final String id;
  final String productId;
  final String productName;
  final ProductCategory category;
  final String martId;
  final String martName;
  final int salePrice;
  final String unit;
  final String source;
  final ApprovalStatus approvalStatus;
  final String? brandName;
  final String? volume;
  final int? originalPrice;
  final double? discountRate;
  final DateTime? saleStartDate;
  final DateTime? saleEndDate;
  final String? reportId;

  bool get isApproved => approvalStatus == ApprovalStatus.approved;

  factory PriceItem.fromMap(String id, Map<String, dynamic> data) {
    return PriceItem(
      id: id,
      productId: data['productId'] as String? ?? '',
      productName: data['productName'] as String? ?? '',
      category: ProductCategory.values.byName(
        data['category'] as String? ?? 'vegetable',
      ),
      martId: data['martId'] as String? ?? '',
      martName: data['martName'] as String? ?? '',
      salePrice: data['salePrice'] as int? ?? 0,
      unit: data['unit'] as String? ?? '',
      source: data['source'] as String? ?? '',
      approvalStatus: ApprovalStatus.values.byName(
        data['approvalStatus'] as String? ?? 'pending',
      ),
      brandName: data['brandName'] as String?,
      volume: data['volume'] as String?,
      originalPrice: data['originalPrice'] as int?,
      discountRate: (data['discountRate'] as num?)?.toDouble(),
      saleStartDate: dateTimeFromFirestore(data['saleStartDate']),
      saleEndDate: dateTimeFromFirestore(data['saleEndDate']),
      reportId: data['reportId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'category': category.name,
      'martId': martId,
      'martName': martName,
      'salePrice': salePrice,
      'unit': unit,
      'source': source,
      'approvalStatus': approvalStatus.name,
      'brandName': brandName,
      'volume': volume,
      'originalPrice': originalPrice,
      'discountRate': discountRate,
      'saleStartDate': dateTimeToFirestore(saleStartDate),
      'saleEndDate': dateTimeToFirestore(saleEndDate),
      'reportId': reportId,
    };
  }
}
