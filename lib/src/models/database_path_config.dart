/// {@template flutter_chatview_db_connection.ChatDatabasePathConfig}
/// A configuration class for defining database paths for chat.
///
/// This class encapsulates the necessary paths for accessing chat rooms
/// and user-related data in a database.
///
/// Example usage:
/// ```dart
/// final config = DatabasePathConfig(
///   chatRoomId: 'room123',
///   chatRoomCollectionPath: 'chatRooms',
/// );
/// ```
/// {@endtemplate}
class ChatDatabasePathConfig {
  /// Creates an instance of [ChatDatabasePathConfig].
  ///
  /// - (required): [chatRoomId] is required and represents
  /// the unique identifier for the chat room.
  ///
  /// - (optional): [chatRoomCollectionPath] specifies
  /// the collection path where chat rooms are stored. Defaults to `'chats'`.
  ///
  /// - (optional): [userCollectionPath] specifies the collection path for
  /// user data. It is optional. If not provided, the default top-level
  /// `users` collection will be used.
  const ChatDatabasePathConfig({
    required this.chatRoomId,
    this.chatRoomCollectionPath = 'chats',
    this.userCollectionPath,
  });

  /// The unique identifier for the chat room.
  final String chatRoomId;

  /// The collection path where chat rooms are stored.
  ///
  /// Defaults to `'chats'`.
  final String chatRoomCollectionPath;

  /// The collection path where user data is stored.
  final String? userCollectionPath;
}
