import 'dart:async';

import 'package:chatview_utils/chatview_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

import '../../chatview_connect.dart';
import '../../chatview_connect_constants.dart';
import '../../database/database_service.dart';
import '../../enum.dart';
import '../../models/chat_room.dart';
import '../../storage/storage_service.dart';

/// A class responsible for managing the connection to
/// the database and storage services in a chat view list context.
final class ChatListManager extends ChatViewListController {
  /// Creates an instance of [ChatListManager] from a given [CloudServices] service.
  ///
  /// This factory method initializes a new chat list manager with
  /// default values and connects it to the provided database service.
  ///
  /// **Parameters:**
  /// - (required): [service] The database service that provides storage and
  /// database access for managing chat rooms.
  /// - (required): [scrollController] The scroll controller used to manage
  /// the scrolling behavior of the chat list.
  /// - (optional): [includeEmptyChats] Whether to include empty chats in the list.
  /// defaults to `true`.
  /// - (optional): [includeUnreadMessagesCount] Whether to include the count of
  /// unread messages in the chat list items. Defaults to `true`.
  /// - (optional): [sortEnable] Whether to enable sorting of the chat list.
  /// Defaults to `true`.
  /// - (optional): [chatSorter] An optional [ChatSorter] instance used to
  /// sort the chat list items.
  ///
  /// **Returns:**
  /// A new instance of [ChatListManager] with the specified database service.
  ///
  /// For chat room-related operations, use
  /// `ChatViewConnect.instance.getChatListManager(...)`.
  factory ChatListManager.fromService({
    required CloudServices service,
    required ScrollController scrollController,
    required bool includeEmptyChats,
    required bool includeUnreadMessagesCount,
    required bool sortEnable,
    required ChatSorter? chatSorter,
  }) {
    return ChatListManager._(
      initialChatList: const [],
      storage: service.storage,
      database: service.database,
      scrollController: scrollController,
      includeEmptyChats: includeEmptyChats,
      includeUnreadMessagesCount: includeUnreadMessagesCount,
      chatSorter: chatSorter,
      sortEnable: sortEnable,
    ).._init();
  }

  ChatListManager._({
    required DatabaseService database,
    required StorageService storage,
    required bool includeEmptyChats,
    required bool includeUnreadMessagesCount,
    required super.initialChatList,
    required super.scrollController,
    required super.chatSorter,
    required super.sortEnable,
  })  : _storage = storage,
        _database = database,
        _includeEmptyChats = includeEmptyChats,
        _includeUnreadMessagesCount = includeUnreadMessagesCount;

  final StorageService _storage;
  final DatabaseService _database;

  final bool _includeEmptyChats;
  final bool _includeUnreadMessagesCount;

  StreamSubscription<ChatRoom?>? _listenChatRoomChangesSubscription;

  String get _currentUserId {
    final userId = ChatViewConnect.instance.currentUserId ?? '';
    assert(userId.isNotEmpty, "Current User ID can't be empty!");
    return userId;
  }

  void _init() {
    // Listen to individual chat room changes
    // This gives you individual ChatRoom objects when they change
    _listenChatRoomChangesSubscription ??= _database
        .chatRoomChangesStream(
      userId: _currentUserId,
      includeEmptyChats: _includeEmptyChats,
      includeUnreadMessagesCount: _includeUnreadMessagesCount,
      onRemovedChat: removeChat,
    )
        .listen(
      (chatRoom) {
        if (chatRoom == null) return;

        final activeStatus = (chatRoom.chatRoomType.isOneToOne
                ? chatRoom.users?.firstOrNull?.userActiveStatus
                : null) ??
            UserActiveStatus.offline;

        final users = chatRoom.users ?? [];
        final usersLength = users.length;

        Set<ChatUser> typingUsers = {};

        for (var i = 0; i < usersLength; i++) {
          final user = users[i];
          if (user.typingStatus.isTyped) continue;
          typingUsers.add(
            ChatUser(
              id: user.userId,
              name: user.chatUser?.name ?? 'Unknown User',
              profilePhoto: user.chatUser?.profilePhoto,
            ),
          );
        }

        final newChatRoom = ChatViewListItem(
          id: chatRoom.chatId,
          name: chatRoom.chatName,
          chatRoomType: chatRoom.chatRoomType,
          unreadCount: chatRoom.unreadMessagesCount,
          imageUrl: chatRoom.chatProfile,
          lastMessage: chatRoom.lastMessage,
          userActiveStatus: activeStatus,
          typingUsers: typingUsers,
          settings: ChatSettings(
            pinStatus: chatRoom.pinStatus,
            pinTime: chatRoom.pinnedAt,
            muteStatus: chatRoom.muteStatus,
          ),
        );

        if (chatListMap.containsKey(chatRoom.chatId)) {
          updateChat(chatRoom.chatId, (previousChat) => newChatRoom);
        } else {
          addChat(newChatRoom);
        }
      },
    );
  }

  /// Creates a one-to-one chat with the specified user.
  ///
  /// **Parameters:**
  /// - (required): [userId] The unique identifier of the user to
  /// create a chat with.
  ///
  /// If a chat with the given [userId] already exists,
  /// the existing chat ID is returned.
  /// Otherwise, a new chat is created, and its ID is returned upon success.
  ///
  /// **Example Usage:**
  /// ```dart
  /// final chatRoomId = await _chatController.createChat(OTHER_USER_ID);
  ///
  /// ChatManager _chatController =
  /// await ChatViewConnect.instance.getChatRoomManager(
  ///  chatRoomId: chatRoomId,
  /// );
  /// ```
  ///
  /// Returns `null` if the chat creation fails.
  Future<String?> createChat(String userId) {
    return _database.createOneToOneChat(
      userId: _currentUserId,
      otherUserId: userId,
    );
  }

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
  /// **Example Usage:**
  /// ```dart
  /// final chatRoomId = await _chatController.createGroupChat(
  ///  groupName: 'Test Group',
  ///  groupProfilePic: 'YOUR_GROUP_PROFILE_PICTURE_URL',
  ///  participants: {
  ///   'user1': Role.admin,
  ///   'user2': Role.user,
  ///  },
  /// );
  ///
  /// ChatManager _chatController =
  /// await ChatViewConnect.instance.getChatRoomManager(
  ///  chatRoomId: chatRoomId,
  /// );
  /// ```
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
      userId: _currentUserId,
      participants: participants,
      groupProfilePic: groupProfilePic,
    );
  }

  /// Updates the current user status. (e.g. online/offline)
  ///
  /// **Parameters:**
  /// - (required): [status] The current status of the user (online/offline).
  Future<bool> updateUserActiveStatus(UserActiveStatus status) {
    return _database.updateUserActiveStatus(
      userStatus: status,
      userId: _currentUserId,
      retry: ChatViewConnectConstants.defaultRetry,
    );
  }

  /// Pins or unpins a chat in the user's chat list.
  /// This method updates the pin status of a chat room
  /// for the current user.
  ///
  /// **Parameters:**
  /// - (required): [status] The pin status to set for the chat room.
  /// - (required): [chatRoomId] The unique identifier of the chat room
  /// to pin or unpin.
  Future<void> pinChat(PinStatus status, String chatRoomId) {
    return _database.updateChatRoomUserMetadata(
      userId: _currentUserId,
      chatId: chatRoomId,
      pinStatus: status,
      retry: ChatViewConnectConstants.defaultRetry,
    );
  }

  /// Mutes or unmutes a chat room for the current user.
  /// This method updates the mute status of a chat room
  /// for the current user.
  ///
  /// **Parameters:**
  /// - (required): [status] The mute status to set for the chat room.
  /// - (required): [chatRoomId] The unique identifier of the chat room
  /// to mute or unmute.
  Future<void> muteChat(MuteStatus status, String chatRoomId) {
    return _database.updateChatRoomUserMetadata(
      userId: _currentUserId,
      chatId: chatRoomId,
      muteStatus: status,
      retry: ChatViewConnectConstants.defaultRetry,
    );
  }

  /// Deletes the specified chat for all participating users.
  ///
  /// This operation also removes all associated media from storage,
  /// including images and voice messages.
  ///
  /// **Parameters:**
  /// - (required): [chatId] The unique identifier of the chat to be deleted.
  Future<bool> deleteChat(String chatId) {
    return _database.deleteChat(
      chatId: chatId,
      deleteMedia: _storage.deleteAllMedia,
      retry: ChatViewConnectConstants.defaultRetry,
    );
  }

  /// Retrieves a list of users as a map, where the key is the user ID,
  /// and the value is their information.
  Future<Map<String, ChatUser>> getUsers() async {
    try {
      final result = await _database.getUsers(
        retry: ChatViewConnectConstants.defaultRetry,
      );
      final valuesLength = result.length;
      return {
        for (var i = 0; i < valuesLength; i++)
          if (result[i] case final user) user.id: user,
      };
    } on FirebaseException catch (_) {
      return {};
    }
  }

  @override
  void dispose() {
    super.dispose();
    _listenChatRoomChangesSubscription?.cancel();
    _listenChatRoomChangesSubscription = null;
  }
}
