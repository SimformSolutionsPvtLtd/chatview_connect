/// provides Firestore paths.
abstract final class ChatViewFireStorePath {
  /// Path to the 'messages' collection.
  static const String messages = 'messages';

  /// Path to the 'users' collection.
  static const String users = 'users';

  /// Path to the 'user_chats' collection.
  static const String userChats = 'user_chats';

  /// Path to the 'chats' collection inside 'user_chats' collection.
  static const String chats = 'chats';
}
