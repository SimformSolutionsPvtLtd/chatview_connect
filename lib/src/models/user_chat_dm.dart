import '../enum.dart';

/// Represents a user's status data model.
///
/// The [UserChatDm] class is used to manage and store a user's online/offline status
/// within a user chat system. It provides methods for JSON serialization,
/// deserialization, and copying instances with updated fields.
class UserChatDm {
  /// Constructs a [UserChatDm] instance.
  ///
  /// **Parameters:**
  /// - (required): [userStatus] represents the online/offline status of the user.
  const UserChatDm({required this.userStatus});

  /// Creates a [UserChatDm] instance from a JSON map.
  ///
  /// **Parameters:**
  /// - (required): [json] is a map containing the serialized data.
  factory UserChatDm.fromJson(Map<String, dynamic> json) {
    return UserChatDm(
      userStatus: UserStatusExtension.parse(json['user_status'].toString()),
    );
  }

  /// The online/offline status of the user.
  ///
  /// Possible values include statuses such as online or offline.
  final UserStatus userStatus;

  /// Converts the [UserChatDm] instance to a JSON map.
  Map<String, dynamic> toJson() => {'user_status': userStatus.name};

  /// Creates a copy of the current [UserChatDm] instance with
  /// updated fields.
  ///
  /// Any field not provided will retain its current value.
  ///
  /// **Parameters:**
  /// - (optional): [userStatus] is the updated online/offline status.
  ///
  /// Returns a new [UserChatDm] instance with the specified updates.
  UserChatDm copyWith({UserStatus? userStatus}) {
    return UserChatDm(userStatus: userStatus ?? this.userStatus);
  }
}
