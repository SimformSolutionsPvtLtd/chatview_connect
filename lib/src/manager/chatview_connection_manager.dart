import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:uuid/uuid.dart';

import '../chatview_db_connection.dart';
import '../database/database_service.dart';
import '../database/firebase/chatview_firestore_database.dart';
import '../enum.dart';
import '../models/chat_room_user_dm.dart';
import '../models/config/add_message_config.dart';
import '../models/database_path_config.dart';
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

  /// Initializes the [ChatViewConnectionManager] with the given configuration
  /// and listeners.
  ///
  /// This method sets up the database, fetches users, and sets up listeners for
  /// chat messages and user data changes.
  ///
  /// **Parameters:**
  ///
  /// - (required): [config] The configuration for the chat database path.
  /// - (optional): [onChatRoomUserDataChange] Optional callback triggered
  /// when chat room user data changes.
  /// - (required): [onChatMessagesChange] Callback triggered when chat messages
  /// change.
  /// - (required): [onChatRoomInitialized] Callback triggered when the
  /// chat room is initialized with users.
  ///
  /// Example:
  /// ```dart
  /// await chatView.initialize(
  ///   config: config,
  ///   onChatRoomInitialized: (users) { /* Handle users */ },
  ///   onChatMessagesChange: (messages) { /* Handle messages */ },
  /// );
  /// ```
  Future<void> initialize({
    required ChatDatabasePathConfig config,
    required ChatMessagesChangeCallback onChatMessagesChange,
    required ChatRoomInitializedCallback onChatRoomInitialized,
    ChatRoomUserStreamCallback? onChatRoomUserDataChange,
  }) async {
    _database.setConfiguration(config: config);

    if (_isInitialized) dispose();

    final users = await _database.getChatRoomParticipants();
    if (users == null) throw Exception('No Users Found!');

    onChatRoomInitialized(users);

    // TODO(Yash): Handled listening of message stream in the next PR.
    if (onChatRoomUserDataChange != null) {
      _chatRoomUserStream = _database.getChatRoomUsersMetadataStream().listen(
            (users) => onChatRoomUserDataChange.call(users.values.firstOrNull),
          );
    }

    _messagesStream = _database
        .getMessagesStream(
          sortBy: MessageSortBy.dateTime,
          sortOrder: MessageSortOrder.asc,
        )
        .listen(onChatMessagesChange);
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
  Future<Message?> sendMessage(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) async {
    if (!_isInitialized) return null;

    final sentByUserId = ChatViewDbConnection.instance.currentUserId;
    if (sentByUserId == null) throw Exception("Sender ID Can't be null");
    final messageDm = Message(
      id: const Uuid().v8(),
      // TODO(Yash): Handled server time stamp in the upcoming PR.
      createdAt: DateTime.now(),
      message: message,
      sentBy: sentByUserId,
      replyMessage: replyMessage,
      messageType: messageType,
    );
    return _database.addMessage(
      messageDm,
      useAutoGeneratedId: false,
      addMessageConfig: AddMessageConfig(
        uploadImageToStorage: true,
        // TODO(Yash): Update this once the chatview supports
        //  the network voice message URL on UI.
        uploadVoiceToStorage: false,
        uploadDocumentCallback: _storage.uploadDoc,
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
  Future<void> unsendMessage(Message message) async {
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

  /// Disposes of resources related to chat room and message streams.
  ///
  /// This method is called to release any resources when the chat view is
  /// no longer needed.
  ///
  /// It cancels any active streams and resets the database configuration.
  void dispose() {
    if (!_isInitialized) return;
    _chatRoomUserStream?.cancel();
    _chatRoomUserStream = null;
    _messagesStream?.cancel();
    _messagesStream = null;
  }
}
