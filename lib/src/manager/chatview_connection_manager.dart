import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_chatview_models/flutter_chatview_models.dart';
import 'package:uuid/uuid.dart';

import '../chatview_db_connection.dart';
import '../database/database_service.dart';
import '../database/firebase/chatview_firestore_database.dart';
import '../enum.dart';
import '../extensions.dart';
import '../models/chat_room_dm.dart';
import '../models/chat_room_metadata_model.dart';
import '../models/chat_room_user_dm.dart';
import '../models/chat_view_participants_dm.dart';
import '../models/config/add_message_config.dart';
import '../models/config/chat_controller_config.dart';
import '../storage/firebase/chatview_firebase_storage.dart';
import '../storage/storage_service.dart';
import '../typedefs.dart';

/// A singleton class responsible for managing the connection to
/// the database and storage services in a chat view context.
///
/// This class provides a centralized way to manage and access the
/// [DatabaseService] and [StorageService] for chat-related operations.
final class ChatViewConnectionManager {
  /// This constructor initializes the [ChatViewConnectionManager] based on
  /// the provided [databaseType].
  ///
  /// **Parameters:**
  /// - (required): [databaseType] The type of the cloud service to use
  /// (e.g., [ChatViewDatabaseType.firebase]).
  ///
  /// It creates instances of the corresponding [DatabaseService] and
  /// [StorageService] based on the provided [databaseType].
  ///
  /// If the instance has already been created, it returns the existing
  /// singleton instance.
  ///
  /// Example:
  /// ```dart
  /// ChatViewConnectionManager(ChatViewDatabaseType.firebase);
  /// ```
  ///
  /// Returns the singleton instance of [ChatViewConnectionManager].
  factory ChatViewConnectionManager(ChatViewDatabaseType databaseType) {
    final DatabaseTypeServicesRecord services = switch (databaseType) {
      ChatViewDatabaseType.firebase => (
          database: ChatViewFireStoreDatabase(),
          storage: ChatViewFirebaseStorage(),
        ),
    };
    _instance ??= ChatViewConnectionManager._(
      services.database,
      services.storage,
    );
    return _instance!;
  }

  const ChatViewConnectionManager._(this._database, this._storage);

  final StorageService _storage;
  final DatabaseService _database;

  static ChatViewConnectionManager? _instance;
  static StreamSubscription<List<Message>>? _messagesStream;
  static StreamSubscription<Map<String, ChatRoomUserDm>>? _chatRoomUserStream;
  static StreamSubscription<ChatRoomMetadata>? _chatRoomStreamController;
  static ChatController? _controller;
  static ChatControllerConfig? _config;
  static ChatViewParticipantsDm? _currentChatRoomInfo;

  // This is for identifying that is chat room is created
  static bool _isChatRoomCreated = false;

  static bool get _isInitialized =>
      _chatRoomUserStream != null || _messagesStream != null;

  /// Returns the singleton instance of [ChatViewConnectionManager].
  ///
  /// Ensure that [ChatViewDbConnection] is initialized with a
  /// [ChatViewDatabaseType] before accessing this getter.
  ///
  /// ### Initialization Example:
  /// ```dart
  /// ChatViewDbConnection(ChatViewDatabaseType.firebase);
  /// ```
  static ChatViewConnectionManager get instance {
    assert(
      _instance != null,
      '''
      ChatViewDbConnection must be initialized. 
      Example: initialize ChatViewDbConnection for firebase backend
      ///```dart
      /// ChatViewDbConnection(ChatViewDatabaseType.firebase);
      /// ```''',
    );
    return _instance!;
  }

  /// Initializes the chat controller for the specified chat room.
  ///
  /// From the given chat room, it retrieves the chat room participants
  /// (current user and other users) and sets up listeners for messages,
  /// user activity, and chat room metadata changes if specified.
  ///
  /// **Parameters:**
  ///
  /// - (required): [chatRoomId] The unique identifier of the chat room to
  /// be initialized.
  /// - (optional): [initialMessageList] An list of initial messages to
  /// display in the chat.
  /// - (optional): [scrollController] An custom [ScrollController] for
  /// managing scroll behavior.
  /// - (optional): [config]: A [ChatControllerConfig] instance that
  /// defines settings for message listening, user activity tracking,
  /// and chat metadata updates.
  ///
  /// **Note:**
  /// - For one-to-one chats, setting the typing indicator value from the
  /// chat controller is handled internally.
  ///
  /// **Returns:**
  /// A [Future] that resolves to an initialized [ChatController].
  ///
  /// **Throws:**
  /// An [Exception] if no chat room participants are found.
  Future<ChatController> getChatControllerByChatRoomId({
    required String chatRoomId,
    List<Message>? initialMessageList,
    ScrollController? scrollController,
    ChatControllerConfig? config,
  }) async {
    if (_isInitialized) dispose();

    _config = config;
    _database.setChatRoom(chatRoomId: chatRoomId);

    final chatRoomParticipants = await _database.getChatRoomParticipants();
    if (chatRoomParticipants == null) throw Exception('No Users Found!');

    final controller = ChatController(
      initialMessageList: initialMessageList ?? [],
      scrollController: scrollController ?? ScrollController(),
      currentUser: chatRoomParticipants.currentUser,
      otherUsers: chatRoomParticipants.otherUsers,
    );

    _controller = controller;
    _currentChatRoomInfo = chatRoomParticipants;
    _config?.chatRoomInfo?.call(chatRoomParticipants);

    _initStreams();

    return controller;
  }

  /// Initializes a chat controller for a one-to-one or
  /// group chat with the specified users.
  ///
  /// If a one-to-one chat already exists between the [currentUser]
  /// and [otherUsers], the existing chat room is used.
  /// Otherwise, a new chat room is created.
  ///
  /// For group chats, a new chat room is created with the specified [groupName]
  /// and [groupProfile].
  /// - if [groupName] is not provided, a default name is assigned by combining
  /// participant names. For example: `User Name 1, User Name 2, ...`
  /// - If [groupProfile] is provided, it will be set as the group’s profile
  /// picture.
  ///
  /// **Parameters:**
  ///
  /// - (required): [currentUser] The current user initiating or
  /// joining the chat.
  /// - (required): [otherUsers] A list of users participating in the chat.
  /// - (optional): [groupName] The name of the group chat
  /// (only applicable for group chats).
  /// - (optional): [groupProfile] The profile picture URL for the group chat
  /// (only applicable for group chats).
  /// - (optional): [config] A [ChatControllerConfig] instance that defines
  /// settings for message listening, user activity tracking, and
  /// chat metadata updates.
  /// - (optional): [initialMessageList] A list of initial messages to
  /// display in the chat.
  /// - (optional): [scrollController] A custom [ScrollController] for
  /// managing scroll behavior.
  ///
  /// **Returns:**
  /// A [Future] that resolves to an initialized [ChatController].
  ///
  /// **Throws:**
  /// An [Exception] if chat initialization fails.
  Future<ChatController> getChatControllerByUsers({
    required ChatUser currentUser,
    required List<ChatUser> otherUsers,
    String? groupName,
    String? groupProfile,
    ChatControllerConfig? config,
    List<Message>? initialMessageList,
    ScrollController? scrollController,
  }) async {
    assert(
      otherUsers.isNotEmpty,
      'At least one user is required to initiate chat.',
    );

    if (_isInitialized) dispose();

    final chatRoomType =
        otherUsers.length == 1 ? ChatRoomType.oneToOne : ChatRoomType.group;

    if (chatRoomType.isOneToOne) {
      final chatRoomID = await _database.isOneToOneChatExists(
        otherUsers.first.id,
      );
      if (chatRoomID case final chatRoomId?) {
        return getChatControllerByChatRoomId(
          config: config,
          chatRoomId: chatRoomId,
          scrollController: scrollController,
          initialMessageList: initialMessageList,
        );
      }
    }
    _isChatRoomCreated = false;
    _config = config;

    _database.setChatRoom(chatRoomId: const Uuid().v8());

    final controller = ChatController(
      otherUsers: otherUsers,
      currentUser: currentUser,
      initialMessageList: initialMessageList ?? [],
      scrollController: scrollController ?? ScrollController(),
    );

    final chatViewParticipantsDm = ChatViewParticipantsDm(
      chatRoomType: chatRoomType,
      currentUser: currentUser,
      otherUsers: otherUsers,
      groupPhotoUrl: chatRoomType.isGroup ? groupProfile : null,
      groupName: groupName ??
          (chatRoomType.isGroup ? otherUsers.toJoinString(', ') : null),
    );

    config?.chatRoomInfo?.call(chatViewParticipantsDm);

    _currentChatRoomInfo = chatViewParticipantsDm;
    _controller = controller;

    return controller;
  }

  void _initStreams() {
    if (_isChatRoomCreated) return;

    _isChatRoomCreated = true;

    final chatViewParticipants = _currentChatRoomInfo;
    if (chatViewParticipants == null) return;
    final chatRoomType = chatViewParticipants.chatRoomType;
    if (_config?.onChatRoomMetadataChanges
        case final metadataChangesCallback?) {
      _chatRoomStreamController = _database
          .getChatRoomMetadataStream(
            chatRoomType: chatRoomType,
            userId: chatRoomType.isOneToOne
                ? chatViewParticipants.otherUsers.firstOrNull?.id
                : null,
          )
          .listen(metadataChangesCallback);
    }

    _chatRoomUserStream = _database
        .getChatRoomUsersMetadataStream(
          observeUserInfoChanges: _config?.syncOtherUsersInfo ?? true,
        )
        .listen(
          (users) => _listenChatRoomUsersActivityStream(
            users: users,
            syncOtherUsersInfo: _config?.syncOtherUsersInfo ?? true,
            userActivityChangeCallback: _config?.onUsersActivityChanges,
          ),
        );

    if (chatRoomType.isGroup) {
      // TODO(YASH): Handle case when the remove/left status arrived then don't listen the messages
      _database.userAddedInGroupChatTimestamp().then(
        (startMessageTimestamp) {
          _messagesStream = _database
              .getMessagesStream(
                sortBy: MessageSortBy.dateTime,
                sortOrder: MessageSortOrder.asc,
                startFromDateTime: startMessageTimestamp,
              )
              .listen(_listenMessages);
        },
      );
    } else {
      _messagesStream = _database
          .getMessagesStream(
            sortBy: MessageSortBy.dateTime,
            sortOrder: MessageSortOrder.asc,
          )
          .listen(_listenMessages);
    }
  }

  /// Sends a message and optionally attaches a reply message and message type.
  /// This method is triggered when a user sends a new message in the chat.
  /// It also handles uploading media and stores the message in the database.
  ///
  /// **Parameters:**
  /// - (required): [message] The content of the message being sent.
  /// - (required): [replyMessage] An optional reply to another message, if any.
  /// - (required): [messageType] The type of the message
  /// (e.g., text, image, video).
  ///
  /// Returns a [Future] that completes with the newly sent [Message] object,
  /// or null if the message could not be sent.
  Future<Message?> onSendTap(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) async {
    if (_isChatRoomCreated && !_isInitialized) return null;

    final chatRoomId = _database.chatRoomId;
    if (chatRoomId == null) throw Exception("ChatRoom ID Can't be null");

    final sentByUserId = ChatViewDbConnection.instance.currentUserId;
    if (sentByUserId == null) throw Exception("Sender ID Can't be null");
    return onSendTapFromMessage(
      Message(
        id: const Uuid().v8(),
        // TODO(Yash): Handled server time stamp in the upcoming PR.
        createdAt: DateTime.now(),
        message: message,
        sentBy: sentByUserId,
        replyMessage: replyMessage,
        messageType: messageType,
      ),
    );
  }

  /// Sends a message within an active chat room.
  ///
  /// This method is responsible for handling the sending of a new message in
  /// the provided the chat room ID, It also handles uploading media
  /// and stores the message in the database.
  ///
  /// **Parameters:**
  /// - (required): [messageDm] The message object containing the content
  /// and metadata.
  ///
  /// Returns a [Future] that completes with the newly sent [Message] object,
  /// or null if the message could not be sent.
  Future<Message?> onSendTapFromMessage(Message messageDm) async {
    if (_isChatRoomCreated && !_isInitialized) return null;

    final chatRoomId = _database.chatRoomId;
    if (chatRoomId == null) throw Exception("ChatRoom ID Can't be null");

    if (!_isChatRoomCreated) {
      final controller = _controller;
      final chatViewParticipants = _currentChatRoomInfo;
      if (controller == null || chatViewParticipants == null) return null;
      final chatRoomType = chatViewParticipants.chatRoomType;
      controller.addMessage(messageDm);
      switch (chatRoomType) {
        case ChatRoomType.oneToOne:
          await _database.createOneToOneUserChat(
            chatRoomId: chatRoomId,
            chatViewParticipants.otherUsers.first.id,
          );
        case ChatRoomType.group:
          final users = chatViewParticipants.otherUsers;
          final usersLength = users.length;
          final lastLength = usersLength - 1;
          final groupNameBuffer = StringBuffer();
          final userIds = <String, Role>{};
          for (var i = 0; i < usersLength; i++) {
            final user = users[i];
            final userName = user.name;
            groupNameBuffer.write(i == lastLength ? userName : '$userName, ');
            userIds[user.id] = Role.admin;
          }
          await _database.createGroupChat(
            chatRoomId: chatRoomId,
            userIds: userIds,
            groupName:
                chatViewParticipants.groupName ?? groupNameBuffer.toString(),
          );
      }
      _initStreams();
    }

    return _database.addMessage(
      messageDm,
      useAutoGeneratedId: false,
      addMessageConfig: AddMessageConfig(
        uploadImageToStorage: true,
        // TODO(Yash): Update this once the chatview supports
        //  the network voice message URL on UI.
        uploadVoiceToStorage: false,
        uploadDocumentCallback: (message, {fileName, uploadPath}) =>
            _storage.uploadDoc(
          message: message,
          chatId: chatRoomId,
          fileName: fileName,
          uploadPath: uploadPath,
        ),
      ),
    );
  }

  /// Updates the current user document with the current typing status.
  ///
  /// **Parameters:**
  /// - (required) [status] The current typing status of the user.
  Future<void> updateCurrentUserTypingStatus(TypeWriterStatus status) async {
    if (!_isInitialized) return;
    return _database.updateChatRoomUserMetadata(typingStatus: status);
  }

  /// Updates the current user document with the current user status.
  ///
  /// **Parameters:**
  /// - (required): [status] The current status of the user (online/offline).
  Future<void> updateCurrentUserStatus(UserStatus status) async {
    if (!_isInitialized) return;
    return _database.updateChatRoomUserMetadata(userStatus: status);
  }

  /// Updates the status of a message to "read" or any other provided status.
  ///
  /// **Parameters:**
  /// - (required): [message] The message whose status needs to be updated.
  Future<void> onMessageRead(Message message) async {
    if (!_isInitialized) return;
    return _database.updateMessage(
      message,
      // TODO(YASH): Update this once correct status received from chatview
      messageStatus: MessageStatus.read,
    );
  }

  /// Deletes a message and removes any associated media from storage.
  ///
  /// **Parameters:**
  /// - (required): [message] The message that is being unsent.
  Future<void> onUnsendTap(Message message) async {
    if (!_isInitialized) return;

    final initialMessageList = _controller?.initialMessageList ?? [];

    final length = initialMessageList.length;

    final lastMessage = length > 0 ? initialMessageList[length - 1] : null;

    final isDeleted = await _database.deleteMessage(
      message,
      deleteImageFromStorage: true,
      deleteVoiceFromStorage: false,
      onDeleteDocument: _storage.deleteDoc,
    );

    final isLastMessage = message.id == lastMessage?.id;

    if (isLastMessage && isDeleted) {
      final secondLastMessage =
          length > 1 ? initialMessageList[length - 2] : null;

      if (secondLastMessage == null &&
          (_currentChatRoomInfo?.chatRoomType.isGroup ?? false)) {
        await _database.fetchAndUpdateLastMessage();
        return;
      }

      await _database.updateChatRoom(lastMessage: secondLastMessage);
    }
  }

  /// Updates the reaction of a user on a message with the selected emoji.
  ///
  /// **Parameters:**
  /// - (required): [message] The message to which the user is reacting.
  /// - (required): [emoji] The emoji representing the user's reaction.
  Future<void> userReactionCallback(Message message, String emoji) async {
    if (!_isInitialized) return;
    final userId = ChatViewDbConnection.instance.currentUserId;
    if (userId == null) throw Exception("Sender ID Can't be null");
    return _database.updateMessage(
      message,
      userReaction: (userId: userId, emoji: emoji),
    );
  }

  /// Returns a stream of chat rooms, each chat room containing
  /// a list of users (excluding the current user).
  /// {@macro flutter_chatview_db_connection.DatabaseService.getChats}
  Stream<List<ChatRoomDm>> getChats({
    ChatSortBy sortBy = ChatSortBy.newestFirst,
    bool includeUnreadMessagesCount = true,
    bool includeEmptyChats = true,
  }) =>
      _database.getChats(
        sortBy: sortBy,
        showEmptyMessagesChats: includeEmptyChats,
        fetchUnreadMessageCount: includeUnreadMessagesCount,
      );

  /// {@macro flutter_chatview_db_connection.DatabaseService.createOneToOneUserChat}
  Future<String?> createOneToOneChat(String userId) =>
      _database.createOneToOneUserChat(userId);

  /// {@macro flutter_chatview_db_connection.DatabaseService.createGroupChat}
  Future<String?> createGroupChat({
    required String groupName,
    required Map<String, Role> userIds,
    String? groupProfilePic,
  }) {
    return _database.createGroupChat(
      groupName: groupName,
      userIds: userIds,
      groupProfilePic: groupProfilePic,
    );
  }

  /// {@macro flutter_chatview_db_connection.DatabaseService.updateGroupChat}
  ///
  /// **Note:**
  /// - This method does **not** restrict updates based on whether the
  /// chat room is one-to-one or a group. If called for a one-to-one chat,
  /// it will still attempt to update the group name without validation.
  Future<bool> updateGroupChat({
    String? groupName,
    String? groupProfilePic,
  }) {
    return _database.updateGroupChat(
      groupName: groupName,
      groupProfilePic: groupProfilePic,
    );
  }

  /// {@macro flutter_chatview_db_connection.DatabaseService.addUserInGroup}
  Future<bool> addUserInGroup({
    required String userId,
    required Role role,
  }) =>
      _database.addUserInGroup(userId: userId, role: role);

  /// Removes a user from the group chat and updates their membership status
  /// to [MembershipStatus.removed].
  ///
  /// **Parameters:**
  /// - (required): [userId] The unique identifier of the user to be removed.
  ///
  /// Returns a [Future] that resolves to `true`
  /// if the user was successfully removed, otherwise `false`.
  Future<bool> removeUserFromGroup(String userId) =>
      _database.removeUserFromGroup(
        userId: userId,
        deleteGroupIfSingleUser: true,
        deleteChatDocsFromStorageCallback: _storage.deleteChatDocs,
      );

  /// Allows the current user to leave the group chat by updating their
  /// membership status to [MembershipStatus.left].
  ///
  /// Returns a [Future] that resolves to `true`
  /// if the user successfully left the group, otherwise `false`.
  Future<bool> leaveCurrentUserFromGroup() {
    final currentUserId = ChatViewDbConnection.instance.currentUserId;
    if (currentUserId == null) throw Exception("Current User ID can't be null");
    return _database.removeUserFromGroup(
      userId: currentUserId,
      deleteGroupIfSingleUser: true,
      deleteChatDocsFromStorageCallback: _storage.deleteChatDocs,
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
  Future<bool> deleteChat(String chatId) => _database.deleteChat(
        chatId: chatId,
        deleteChatDocsFromStorageCallback: _storage.deleteChatDocs,
      );

  void _listenChatRoomUsersActivityStream({
    required Map<String, ChatRoomUserDm> users,
    required bool syncOtherUsersInfo,
    ValueSetter<Map<String, ChatRoomUserDm>>? userActivityChangeCallback,
  }) {
    if (syncOtherUsersInfo) _listenChatRoomUsersInfoChanges(users);
    _listenChatRoomUsersActivities(
      users: users,
      userActivityChangeCallback: userActivityChangeCallback,
    );
  }

  void _listenChatRoomUsersActivities({
    required Map<String, ChatRoomUserDm> users,
    ValueSetter<Map<String, ChatRoomUserDm>>? userActivityChangeCallback,
  }) {
    final isOneToOneChat = users.length == 1;
    if (isOneToOneChat) {
      _controller?.setTypingIndicator =
          users.values.first.typingStatus.isTyping;
    }
    if (userActivityChangeCallback case final callback?) callback(users);
  }

  void _listenChatRoomUsersInfoChanges(Map<String, ChatRoomUserDm> users) {
    final chatUsers = users.values.toList();
    final usersLength = chatUsers.length;

    for (var i = 0; i < usersLength; i++) {
      final chatUser = chatUsers[i].chatUser;
      if (chatUser == null) continue;
      _controller?.updateOtherUser(chatUser);
    }
    // TODO(YASH): Rebuild chatview once the user details udapted.
  }

  void _listenMessages(List<Message> messages) {
    _controller
      ?..initialMessageList.clear()
      ..loadMoreData(messages);
  }

  /// Disposes of resources related to chat room and message streams.
  ///
  /// This method is called to release any resources when the chat view is
  /// no longer needed.
  ///
  /// It cancels any active streams and resets the database configuration.
  void dispose() {
    if (!_isInitialized) return;
    _controller = null;
    _database.resetChatRoom();
    _chatRoomStreamController?.cancel();
    _chatRoomStreamController = null;
    _chatRoomUserStream?.cancel();
    _chatRoomUserStream = null;
    _messagesStream?.cancel();
    _messagesStream = null;
    _config = null;
    _isChatRoomCreated = false;
    _currentChatRoomInfo = null;
  }
}
