/// Contains Firebase storage path references.
abstract final class ChatViewFirebaseStorageRefs {
  /// Path for storing images in Firebase storage.
  static const String images = 'images';

  /// Path for storing voices in Firebase storage.
  static const String voices = 'voices';

  /// Path for storing chats in Firebase storage.
  static const String chats = 'chats';

  /// Returns the Firebase storage reference path for a specific chat.
  ///
  /// [chatId] - The unique identifier of the chat.
  /// Example output: 'chats/{chatId}'
  static String getChatsRefById(String chatId) => '$chats/$chatId';

  /// Returns the Firebase storage reference path for images within
  /// a specific chat.
  ///
  /// [chatId] - The unique identifier of the chat.
  /// Example output: 'chats/{chatId}/images'
  static String getImageRef(String chatId) => '$chats/$chatId/$images';

  /// Returns the Firebase storage reference path for voice messages within
  /// a specific chat.
  ///
  /// [chatId] - The unique identifier of the chat.
  /// Example output: 'chats/{chatId}/voices'
  static String getVoiceRef(String chatId) => '$chats/$chatId/$voices';
}
