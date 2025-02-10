/// {@template flutter_chatview_db_connection.ChatDatabasePathConfig}
/// A configuration class for defining database paths for chat.
///
/// This class encapsulates the necessary paths for accessing chats,
/// user related chats and users data in a database.
///
/// Example usage:
/// ```dart
/// final config = DatabasePathConfig(
///   chatRoomCollectionPath: 'chatRooms',
/// );
/// ```
/// {@endtemplate}
final class ChatDatabasePathConfig {
  /// Creates an instance of [ChatDatabasePathConfig].
  ///
  /// **Parameters:**
  /// - (optional): [chatCollectionPath] specifies the collection path
  /// where chats are stored. Defaults to `'chats'`.
  ///
  /// - (optional): [userChatsCollectionPath] specifies the collection path for
  /// user chats data. It is optional. If not provided, the default top-level
  /// `user_chats` collection will be used.
  ///
  /// - (optional): [userCollectionPath] specifies the collection path for
  /// user data. It is optional.
  /// If not provided, the default top-level `users` collection will be used.
  ChatDatabasePathConfig({
    this.chatCollectionPath = 'chats',
    this.userChatsCollectionPath,
    this.userCollectionPath,
  }) : assert(
          !chatCollectionPath.contains('/'),
          'Chat Collection Path should not have the nested collection',
        );

  /// The collection path where chats are stored.
  ///
  /// Defaults to `'chats'`.
  final String chatCollectionPath;

  /// The collection path where user chats data are stored.
  final String? userChatsCollectionPath;

  /// The collection path where user data is stored.
  final String? userCollectionPath;
}
