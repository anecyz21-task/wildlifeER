/// Represents the status of a post.
enum PostStatus {
  /// Indicates that a ride is needed.
  rideNeeded,

  /// Indicates that the user is in transfer.
  inTransfer,

  /// Indicates that the user is at the hospital.
  atHospital,
}

/// Extension methods for the [PostStatus] enum.
extension PostStatusExtension on PostStatus {
  /// Converts the [PostStatus] to a string for database storage.
  String toDatabaseValue() => name;

  /// Converts a string from the database to a [PostStatus] enum.
  static PostStatus fromDatabaseValue(String value) {
    return PostStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PostStatus.rideNeeded, // Default value
    );
  }

  // Convert enum to readable string
  String toReadableString() {
    switch (this) {
      case PostStatus.rideNeeded:
        return 'Ride Needed';
      case PostStatus.inTransfer:
        return 'In Transfer';
      case PostStatus.atHospital:
        return 'At Hospital';
    }
  }
}
