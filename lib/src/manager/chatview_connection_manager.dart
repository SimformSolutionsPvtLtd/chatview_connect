import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:uuid/uuid.dart';

import '../chatview_db_connection.dart';
import '../database/database_service.dart';
import '../database/firebase/chatview_firestore_database.dart';
import '../enum.dart';
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

  bool get _isInitialized => _messagesStream != null;

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
  /// - (required): [onChatMessagesChange] Callback triggered when chat messages
  /// change.
  ///
  /// Example:
  /// ```dart
  /// await chatView.initialize(
  ///   config: config,
  ///   onChatMessagesChange: (messages) { /* Handle messages */ },
  /// );
  /// ```
  Future<void> initialize({
    required ChatDatabasePathConfig config,
    required ChatMessagesChangeCallback onChatMessagesChange,
  }) async {
    _database.setConfiguration(config: config);

    if (_isInitialized) dispose();

    // TODO(Yash): Handled listening of message stream in the next PR.
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
  /// [message] The content of the message being sent.
  /// [replyMessage] An optional reply to another message, if any.
  /// [messageType] The type of the message (e.g., text, image, video).
  ///
  /// Returns a [Future] that completes with the newly sent [Message] object,
  /// or null if the message could not be sent.
  Future<Message?> sendMessage(
    String message,
    ReplyMessage replyMessage,
    MessageType messageType,
  ) {
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
        // TODO(Yash): Update this once the chatview supports the network voice message URL on UI.
        uploadVoiceToStorage: false,
        uploadDocumentCallback: _storage.uploadDoc,
      ),
    );
  }

  /// Updates the status of a message to "read" or any other provided status.
  ///
  /// [message] The message whose status needs to be updated.
  Future<void> onMessageRead(Message message) {
    return _database.updateMessage(
      message,
      messageStatus: message.status,
    );
  }

  /// Deletes a message and removes any associated media from storage.
  ///
  /// [message] The message that is being unsent.
  Future<void> unsendMessage(Message message) {
    return _database.deleteMessage(
      message,
      deleteImageFromStorage: true,
      deleteVoiceFromStorage: false,
      onDeleteDocument: _storage.deleteDoc,
    );
  }

  /// Updates the reaction of a user on a message with the selected emoji.
  ///
  /// [message] The message to which the user is reacting.
  /// [emoji] The emoji representing the user's reaction.
  Future<void> userReactionCallback(Message message, String emoji) {
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
    _database.resetConfiguration();
    _messagesStream?.cancel();
    _messagesStream = null;
  }
}
