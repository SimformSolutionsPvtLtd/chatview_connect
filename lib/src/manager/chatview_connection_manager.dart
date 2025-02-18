import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_chatview_models/flutter_chatview_models.dart';
import 'package:uuid/uuid.dart';

import '../chatview_db_connection.dart';
import '../database/database_service.dart';
import '../database/firebase/chatview_firestore_database.dart';
import '../enum.dart';
import '../models/chat_room_dm.dart';
import '../models/chat_room_user_dm.dart';
import '../models/chat_view_participants_dm.dart';
import '../models/config/add_message_config.dart';
import '../models/message_dm.dart';
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
  static StreamSubscription<List<MessageDm>>? _messagesStream;
  static StreamSubscription<Map<String, ChatRoomUserDm>>? _chatRoomUserStream;
  static ChatController? _controller;

  bool get _isInitialized =>
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
  /// user activity.
  ///
  /// **Parameters:**
  /// - (required) [chatRoomId]: The unique identifier of the chat room
  /// to be initialized.
  /// - (optional) [initialMessageList]: An list of initial messages to
  /// display in the chat.
  /// - (optional) [scrollController]: An custom [ScrollController] for managing
  /// scroll behavior.
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
    ValueSetter<ChatViewParticipantsDm>? chatRoomInfo,
    ValueSetter<Map<String, ChatRoomUserDm>>? onUsersActivityChanges,
  }) async {
    if (_isInitialized) dispose();

    _database.setChatRoom(chatRoomId: chatRoomId);

    final chatRoomParticipants = await _database.getChatRoomParticipants();
    if (chatRoomParticipants == null) throw Exception('No Users Found!');

    final controller = ChatController(
      initialMessageList: initialMessageList ?? [],
      scrollController: scrollController ?? ScrollController(),
      currentUser: chatRoomParticipants.currentUser,
      otherUsers: chatRoomParticipants.otherUsers,
    );

    chatRoomInfo?.call(chatRoomParticipants);

    _controller = controller;

    _chatRoomUserStream = _database.getChatRoomUsersMetadataStream().listen(
          (users) => _listenChatRoomUsersActivities(
            users: users,
            userActivityChangeCallback: onUsersActivityChanges,
          ),
        );

    _messagesStream = _database
        .getMessagesStream(
          sortBy: MessageSortBy.dateTime,
          sortOrder: MessageSortOrder.asc,
        )
        .listen(_listenMessages);

    return controller;
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
    if (!_isInitialized) return null;

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
    if (!_isInitialized) return null;

    final chatRoomId = _database.chatRoomId;
    if (chatRoomId == null) throw Exception("ChatRoom ID Can't be null");

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
    await _database.deleteMessage(
      message,
      deleteImageFromStorage: true,
      deleteVoiceFromStorage: false,
      onDeleteDocument: _storage.deleteDoc,
    );
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
  }) =>
      _database.getChats(sortBy: sortBy);

  /// {@macro flutter_chatview_db_connection.DatabaseService.createOneToOneUserChat}
  Future<String?> createOneToOneChat(String userId) =>
      _database.createOneToOneUserChat(userId);

  /// {@macro flutter_chatview_db_connection.DatabaseService.createGroupChat}
  Future<String?> createGroupChat({
    required String groupName,
    required List<String> userIds,
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
  /// - This method does **not** restrict updates based on whether the chat room is
  ///   one-to-one or a group. If called for a one-to-one chat, it will still attempt
  ///   to update the group name without validation.
  Future<bool> updateGroupChat({
    String? groupName,
    String? groupProfilePic,
  }) {
    return _database.updateGroupChat(
      groupName: groupName,
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
  Future<bool> deleteChat(String chatId) => _database.deleteChat(
        chatId: chatId,
        deleteChatDocsFromStorageCallback: _storage.deleteChatDocs,
      );

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

  void _listenMessages(List<MessageDm> messages) {
    _controller
      ?..initialMessageList.clear()
      ..loadMoreData(messages.map((e) => e.message).toList());
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
    _chatRoomUserStream?.cancel();
    _chatRoomUserStream = null;
    _messagesStream?.cancel();
    _messagesStream = null;
  }
}
