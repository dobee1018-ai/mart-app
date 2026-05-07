import 'app_enums.dart';

class Mart {
  const Mart({
    required this.id,
    required this.name,
    required this.branchName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.businessHours,
    required this.phoneNumber,
    required this.hasParking,
    required this.closedDays,
    required this.status,
    this.flyerImageUrls = const [],
    this.memo,
  });

  final String id;
  final String name;
  final String branchName;
  final String address;
  final double latitude;
  final double longitude;
  final String businessHours;
  final String phoneNumber;
  final bool hasParking;
  final List<String> closedDays;
  final MartStatus status;
  final List<String> flyerImageUrls;
  final String? memo;

  factory Mart.fromMap(String id, Map<String, dynamic> data) {
    return Mart(
      id: id,
      name: data['name'] as String? ?? '',
      branchName: data['branchName'] as String? ?? '',
      address: data['address'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      businessHours: data['businessHours'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      hasParking: data['hasParking'] as bool? ?? false,
      closedDays: List<String>.from(data['closedDays'] as List? ?? const []),
      status: MartStatus.values.byName(data['status'] as String? ?? 'open'),
      flyerImageUrls: List<String>.from(
        data['flyerImageUrls'] as List? ?? const [],
      ),
      memo: data['memo'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'branchName': branchName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'businessHours': businessHours,
      'phoneNumber': phoneNumber,
      'hasParking': hasParking,
      'closedDays': closedDays,
      'status': status.name,
      'flyerImageUrls': flyerImageUrls,
      'memo': memo,
    };
  }
}
