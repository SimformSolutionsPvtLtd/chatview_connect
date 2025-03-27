/// Represents a user's chat conversation details.
///
/// This data model is used to manage and serialize/deserialize chat conversations.
/// The `userId` is used in one-to-one chats to uniquely identify that
/// the chat has already been created. For group chats,
/// `userId` field will be empty.
///
/// The [UserChatMetadata] class is essential for handling individual
/// or group chat conversations.
final class UserChatMetadata {
  /// Creates a [UserChatMetadata] instance with the specified [userId].
  ///
  /// **Parameters:**
  /// - (required): [userId] The unique identifier of the user
  /// associated with the chat conversation.
  ///
  /// In a one-to-one chat, the `userId` uniquely identifies that
  /// the chat has already been created. For group chats,
  /// the `userId` will be empty.
  const UserChatMetadata({this.userId});

  /// Creates a [UserChatMetadata] instance from a JSON object.
  ///
  /// - [json]: A [Map] containing the chat conversation data.
  factory UserChatMetadata.fromJson(Map<String, dynamic> json) {
    return UserChatMetadata(userId: json['user_id'].toString());
  }

  /// The unique identifier of the other user associated with
  /// the chat conversation.
  ///
  /// This value is used to identify a one-to-one chat already created or not.
  /// For group chats, this value is empty.
  final String? userId;

  /// Converts the [UserChatMetadata] instance into a JSON object.
  ///
  /// Returns a [Map] with the `user_id` field.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (userId?.isNotEmpty ?? false) 'user_id': userId,
    };
  }

  /// Creates a copy of the current [UserChatMetadata] with
  /// updated fields.
  ///
  /// - [userId]: The new user ID.
  /// Defaults to the current [userId] if not provided.
  ///
  /// Returns a new [UserChatMetadata] instance with the updated values.
  UserChatMetadata copyWith({String? userId}) {
    return UserChatMetadata(userId: userId ?? this.userId);
  }

  @override
  String toString() => 'UserChatMetadata(${toJson()})';
}
