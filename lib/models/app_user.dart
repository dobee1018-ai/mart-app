import 'app_enums.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.nickname,
    required this.email,
    required this.role,
    required this.defaultRegion,
    required this.pointBalance,
    this.photoUrl,
    this.provider,
    this.locationAgreed = false,
  });

  final String id;
  final String nickname;
  final String email;
  final UserRole role;
  final String defaultRegion;
  final int pointBalance;
  final String? photoUrl;
  final String? provider;
  final bool locationAgreed;

  Map<String, dynamic> toMap() {
    return {
      'nickname': nickname,
      'email': email,
      'role': role.name,
      'defaultRegion': defaultRegion,
      'pointBalance': pointBalance,
      'photoUrl': photoUrl,
      'provider': provider,
      'locationAgreed': locationAgreed,
    };
  }
}
