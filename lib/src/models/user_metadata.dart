import '../enum.dart';

/// Represents a user's status data model.
///
/// The [UserMetadata] class is used to manage and store a user's online/offline status
/// within a user chat system. It provides methods for JSON serialization,
/// deserialization, and copying instances with updated fields.
class UserMetadata {
  /// Constructs a [UserMetadata] instance.
  ///
  /// **Parameters:**
  /// - (required): [userActiveStatus] represents the online/offline status of the user.
  const UserMetadata({required this.userActiveStatus});

  /// Creates a [UserMetadata] instance from a JSON map.
  ///
  /// **Parameters:**
  /// - (required): [json] is a map containing the serialized data.
  factory UserMetadata.fromJson(Map<String, dynamic> json) {
    return UserMetadata(
      userActiveStatus: UserActiveStatusExtension.parse(
        json['user_active_status'].toString(),
      ),
    );
  }

  /// The online/offline status of the user.
  ///
  /// Possible values include statuses such as online or offline.
  final UserActiveStatus userActiveStatus;

  /// Converts the [UserMetadata] instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {'user_active_status': userActiveStatus.name};
  }

  /// Creates a copy of the current [UserMetadata] instance with
  /// updated fields.
  ///
  /// Any field not provided will retain its current value.
  ///
  /// **Parameters:**
  /// - (optional): [userActiveStatus] is the updated online/offline status.
  ///
  /// Returns a new [UserMetadata] instance with the specified updates.
  UserMetadata copyWith({UserActiveStatus? userActiveStatus}) {
    return UserMetadata(
      userActiveStatus: userActiveStatus ?? this.userActiveStatus,
    );
  }
}
