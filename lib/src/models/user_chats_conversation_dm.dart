import '../enum.dart';

/// Represents a user's chat conversation details.
/// This data model is used to manage and serialize/deserialize chat conversations.
final class UserChatsConversationDm {
  /// Creates a [UserChatsConversationDm] instance with
  ///
  /// **Parameters:**
  /// - (required): [chatType] The type of chat conversation.
  /// - (required): [userId] The unique identifier of the user.
  const UserChatsConversationDm({
    required this.chatType,
    required this.userId,
  });

  /// Creates a [UserChatsConversationDm] instance from a JSON object.
  ///
  /// - [json]: A [Map] containing the chat conversation data.
  /// - Defaults [chatType] to [ChatRoomType.oneToOne]
  /// if corresponding ChatRoomType not found.
  factory UserChatsConversationDm.fromJson(Map<String, dynamic> json) {
    return UserChatsConversationDm(
      chatType: ChatRoomTypeExtension.tryParse(json['chat_type'].toString()) ??
          ChatRoomType.oneToOne,
      userId: json['user_id'].toString(),
    );
  }

  /// The type of chat room (e.g., oneToOne).
  final ChatRoomType chatType;

  /// The unique identifier of other user associated with the chat conversation.
  final String userId;

  /// Converts the [UserChatsConversationDm] instance into a JSON object.
  ///
  /// Returns a [Map] with the `chat_type` and `user_id` fields.
  Map<String, dynamic> toJson() {
    return {
      'chat_type': chatType.name,
      'user_id': userId,
    };
  }

  /// Creates a copy of the current [UserChatsConversationDm] with
  /// updated fields.
  ///
  /// - [chatType]: The new chat type.
  /// Defaults to the current [chatType] if not provided.
  /// - [userId]: The new user ID.
  /// Defaults to the current [userId] if not provided.
  ///
  /// Returns a new [UserChatsConversationDm] instance with the updated values.
  UserChatsConversationDm copyWith({
    ChatRoomType? chatType,
    String? userId,
  }) {
    return UserChatsConversationDm(
      chatType: chatType ?? this.chatType,
      userId: userId ?? this.userId,
    );
  }

  @override
  String toString() => 'UserChatsConversationDm(${toJson()})';
}
