/// Represents metadata for a chat room, supporting both one-to-one and
/// group chats.
///
/// This model provides details about the chat, including its name and
/// profile picture.
/// - For one-to-one chats, it retrieves the other user's name and
/// profile picture.
/// - For group chats, it includes the group name and profile photo.
///
/// The properties dynamically determine the appropriate values based
/// on the chat type.
class ChatRoomDisplayMetadata {
  /// Creates an instance of [ChatRoomDisplayMetadata].
  ///
  /// **Parameters:**
  /// - (required): [chatName] represents the name of the chat.
  ///   - In one-to-one chats, this is the name of the other user.
  ///   - In group chats, this is the group name. If unavailable,
  ///   a fallback name is used.
  /// - (optional): [chatProfilePhoto] represents the chat profile picture URL.
  ///   - In one-to-one chats, this is the profile picture of the other user.
  ///   - In group chats, this is the group photo URL, if available.
  const ChatRoomDisplayMetadata({
    required this.chatName,
    this.chatProfilePhoto,
  });

  /// The name of the chat.
  ///
  /// - For one-to-one chats, this is the name of the other user.
  /// If `null`, "Unknown User" is returned.
  /// - For group chats, this is the group name. If unavailable,
  /// a comma-separated list of user names is used.
  ///   If both the group name and user names are unavailable,
  ///   "Unknown Group" is returned.
  final String chatName;

  /// The profile picture URL of the chat.
  ///
  /// - For one-to-one chats, this is the profile picture of the other user,
  /// if available.
  /// - For group chats, this is the group photo URL, if available.
  final String? chatProfilePhoto;

  @override
  String toString() => '''
  ChatRoomDisplayMetadata(
    'chatName': $chatName,
    'chatProfilePhoto': $chatProfilePhoto,
  )''';
}
