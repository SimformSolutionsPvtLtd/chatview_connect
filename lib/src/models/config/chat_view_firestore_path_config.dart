import '../../database/firebase/chatview_firestore_path.dart';
import '../../extensions.dart';

/// This allows users to customize the collection names used in Firestore
/// if they prefer different names than the default.
///
/// Example usage:
/// ```dart
/// final config = ChatViewFireStorePathConfig(
///   messages: 'custom_messages',
///   users: 'custom_users',
///   userChats: 'custom_user_chats',
///   chats: 'custom_chats',
/// );
/// ```
///
/// If a value is `null`, the default collection name will be used.
class ChatViewFireStoreCollectionNameConfig {
  /// Creates a configuration for firestore collection names.
  ChatViewFireStoreCollectionNameConfig({
    this.users = ChatViewFireStorePath.users,
    this.chats = ChatViewFireStorePath.chats,
    this.messages = ChatViewFireStorePath.messages,
    this.userChats = ChatViewFireStorePath.userChats,
  }) : assert(
          users.isValidFirestoreCollectionName &&
              chats.isValidFirestoreCollectionName &&
              messages.isValidFirestoreCollectionName &&
              userChats.isValidFirestoreCollectionName,
          'a collectionPath path must be a non-empty string or a must not contain "//" or "/"',
        );

  /// Collection name for storing messages.
  final String messages;

  /// Collection name for storing user data.
  final String users;

  /// Collection name for storing user-to-chat relationships.
  final String userChats;

  /// Collection name for storing chat details inside `userChats`.
  final String chats;
}
