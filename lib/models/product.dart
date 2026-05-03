import 'app_enums.dart';

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.defaultUnit,
    this.brandName,
    this.keywords = const [],
  });

  final String id;
  final String name;
  final ProductCategory category;
  final String defaultUnit;
  final String? brandName;
  final List<String> keywords;

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] as String? ?? '',
      category: ProductCategory.values.byName(
        data['category'] as String? ?? 'vegetable',
      ),
      defaultUnit: data['defaultUnit'] as String? ?? '',
      brandName: data['brandName'] as String?,
      keywords: List<String>.from(data['keywords'] as List? ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category.name,
      'defaultUnit': defaultUnit,
      'brandName': brandName,
      'keywords': keywords,
    };
  }
}
