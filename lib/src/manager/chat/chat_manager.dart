import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import '../../database/database_service.dart';
import '../../enum.dart';
import '../../models/chat_room_dm.dart';
import '../../storage/storage_service.dart';

/// The [ChatManager] class handles chat-related operations,
/// including managing chat rooms, creating one-to-one and group chats,
/// retrieving users, and deleting chats.
final class ChatManager {
  /// Factory constructor for creating a ChatManager instance from an
  /// existing service.
  ///
  /// This allows for manual dependency injection of a `DatabaseTypeServices`
  /// instance, providing flexibility service configuration.
  factory ChatManager.fromService(DatabaseTypeServices service) =>
      ChatManager._(service.database, service.storage);

  const ChatManager._(this._database, this._storage);

  final StorageService _storage;
  final DatabaseService _database;

  /// {@macro flutter_chatview_db_connection.DatabaseService.updateCurrentUserStatus}.
  Future<bool> updateUserActiveStatus(UserActiveStatus status) =>
      _database.updateUserActiveStatus(status);

  /// {@macro flutter_chatview_db_connection.DatabaseService.getChats}
  Stream<List<ChatRoomDm>> getChats({
    ChatSortBy sortBy = ChatSortBy.newestFirst,
    bool includeUnreadMessagesCount = true,
    bool includeEmptyChats = true,
  }) =>
      _database.getChats(
        sortBy: sortBy,
        includeEmptyChats: includeEmptyChats,
        includeUnreadMessagesCount: includeUnreadMessagesCount,
      );

  /// {@macro flutter_chatview_db_connection.DatabaseService.createOneToOneUserChat}
  Future<String?> createChat(String userId) =>
      _database.createOneToOneUserChat(otherUserId: userId);

  /// Creates a new group chat with the specified details.
  ///
  /// **Parameters:**
  /// - (required): [groupName] The name of the group chat.
  /// - (required): [participants] A map of user IDs to their assigned roles
  /// in the group chat. The current user is automatically added.
  /// - (optional): [groupProfilePic] The profile picture of the group chat.
  /// If not provided, the group will not have a profile picture.
  ///
  /// **Behavior:**
  /// - This method initializes a new group chat with the given participants,
  ///   group name, and optional profile picture.
  ///
  /// Returns a ID of the newly created group chat.
  /// If the creation fails, `null` is returned.
  Future<String?> createGroupChat({
    required String groupName,
    required Map<String, Role> participants,
    String? groupProfilePic,
  }) {
    return _database.createGroupChat(
      groupName: groupName,
      participants: participants,
      groupProfilePic: groupProfilePic,
    );
  }

  /// Retrieves a list of users as a map, where the key is the user ID,
  /// and the value is their information.
  Future<Map<String, ChatUser>> getUsers() {
    return _database.getUsers().then(
      (value) {
        final users = <String, ChatUser>{};
        final valuesLength = value.length;
        for (var i = 0; i < valuesLength; i++) {
          final user = value[i];
          users[user.id] = user;
        }
        return users;
      },
    );
  }

  /// Deletes the entire chat and removes it from all users involved in
  /// the chat.
  ///
  /// **Parameters:**
  /// - (required): [chatId] The unique identifier of the chat to be deleted.
  ///
  /// Additionally, it will delete all associated media
  /// (such as images and voice messages) from storage.
  Future<bool> deleteChat(String chatId) {
    return _database.deleteChat(
      chatId: chatId,
      deleteMediaFromStorage: _storage.deleteChatMedia,
    );
  }
}
