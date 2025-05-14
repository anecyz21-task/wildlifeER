class UserModel {
  final String uid;
  final String email;
  final double? lastLatitude;
  final double? lastLongitude;
  final DateTime? lastUpdated;
  String username;

  UserModel({
    required this.uid,
    required this.email,
    this.lastLatitude,
    this.lastLongitude,
    this.lastUpdated,
    required this.username,
  });
}