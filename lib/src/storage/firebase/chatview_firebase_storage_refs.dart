/// Contains Firebase storage path references.
abstract final class ChatViewFirebaseStorageRefs {
  /// Path for storing images in Firebase storage.
  static const String _images = 'images';

  /// Path for storing voices in Firebase storage.
  static const String _voices = 'voices';

  /// Path for storing chats in Firebase storage.
  static const String _chats = 'chats';

  /// Returns the Firebase storage reference path for a specific chat.
  ///
  /// [chatId] - The unique identifier of the chat.
  /// Example output: 'chats/{chatId}'
  static String getChatsRefById(String chatId) => '$_chats/$chatId';

  /// Returns the Firebase storage reference path for images within
  /// a specific chat.
  ///
  /// [chatId] - The unique identifier of the chat.
  /// Example output: 'chats/{chatId}/images'
  static String getImageRef(String chatId) =>
      '${getChatsRefById(chatId)}/$_images';

  /// Returns the Firebase storage reference path for voice messages within
  /// a specific chat.
  ///
  /// [chatId] - The unique identifier of the chat.
  /// Example output: 'chats/{chatId}/voices'
  static String getVoiceRef(String chatId) =>
      '${getChatsRefById(chatId)}/$_voices';
}
