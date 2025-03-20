import 'package:flutter/widgets.dart';
import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import 'enum.dart';
import 'extensions.dart';
import 'manager/chat/chat_manager.dart';
import 'models/config/chat_controller_config.dart';
import 'models/config/chat_user_model_config.dart';
import 'models/config/cloud_service_config.dart';
import 'models/config/firebase/chat_firestore_database_path_config.dart';
import 'models/config/firebase/firebase_config.dart';
import 'models/config/firebase/firestore_chat_collection_name_config.dart';

/// A singleton class provides different type of database's clouds services for
/// chat views.
///
/// provides methods to initialize and access the clouds service.
final class ChatViewDbConnection {
  /// The main entry point for using the chat database connection.
  ///
  /// This class must be instantiated to access chat-related functionality.
  /// It serves as the core connection layer for handling chat related
  /// operations across different cloud providers.
  ///
  /// - (required): [databaseType] specifies the type of cloud database service
  /// to be used. (e.g., Firebase) to be used for chat.
  ///
  /// - (optional): [chatUserModelConfig] Customizes the serialization and
  ///   deserialization of user data.
  ///   - By default, user data is stored and retrieved using standard keys
  ///   like `id`, `name`, and `profilePhoto`.
  ///   - Supports dynamic key mappings for different data sources
  ///   (e.g., mapping `username` instead of `name`).
  ///
  /// - (optional): [cloudServiceConfig] Configuration for cloud services
  ///   such as Firebase.
  ///   - If using Firebase, this allows specifying Firestore paths and
  ///     collection names.
  ///
  /// **Example Usage in `main.dart`:**
  /// ```dart
  /// ChatViewDbConnection(
  ///     ChatViewDatabaseType.firebase,
  ///     chatUserModelConfig: const ChatUserModelConfig(
  ///       idKey: 'user_id',
  ///       nameKey: 'first_name',
  ///       profilePhotoKey: 'avatar',
  ///     ),
  ///     cloudServiceConfig: FirebaseCloudConfig(
  ///       databasePathConfig: FirestoreChatDatabasePathConfig(
  ///         userCollectionPath: 'organizations/simform',
  ///       ),
  ///       collectionNameConfig: FirestoreChatCollectionNameConfig(
  ///         users: 'app_users',
  ///       ),
  ///     ),
  /// );
  /// ```
  factory ChatViewDbConnection(
    ChatViewDatabaseType databaseType, {
    ChatUserModelConfig? chatUserModelConfig,
    CloudServiceConfig? cloudServiceConfig,
  }) {
    if (_instance == null) {
      final cloudConfig = cloudServiceConfig;
      switch (databaseType) {
        case ChatViewDatabaseType.firebase
            when cloudConfig is FirebaseCloudConfig:
          if (cloudConfig.databasePathConfig case final config?) {
            _firestoreDatabasePathConfig = config;
          }
          if (cloudConfig.collectionNameConfig case final config?) {
            _firestoreCollectionNameConfig = config;
          }
        case ChatViewDatabaseType.firebase:
          break;
      }
      _chatUserModelConfig = chatUserModelConfig;
      _instance = ChatViewDbConnection._(databaseType);
      final service = DatabaseTypeServices.fromDataType(databaseType);
      _service = service;
    }
    return _instance!;
  }

  const ChatViewDbConnection._(this._databaseType);

  final ChatViewDatabaseType _databaseType;

  static ChatViewDbConnection? _instance;

  static DatabaseTypeServices? _service;

  static String? _currentUserId;

  static FirestoreChatDatabasePathConfig? _firestoreDatabasePathConfig;

  /// Retrieves the current database path configuration for chat operations.
  ///
  /// Returns a [FirestoreChatDatabasePathConfig] object containing the paths
  /// for user chats, chat collections, and optionally, user collections.
  FirestoreChatDatabasePathConfig? get getFirestoreChatDatabasePathConfig =>
      _firestoreDatabasePathConfig;

  static ChatUserModelConfig? _chatUserModelConfig;

  /// Retrieves the current chat user model configuration.
  ///
  /// This configuration defines the mapping of JSON keys to user properties
  /// (e.g., mapping `"username"` instead of `"name"`).
  ///
  /// If no configuration has been set, this will return `null`,
  /// meaning default keys (`id`, `name`, `profilePhoto`) will be used.
  ChatUserModelConfig? get getChatUserModelConfig => _chatUserModelConfig;

  static FirestoreChatCollectionNameConfig _firestoreCollectionNameConfig =
      FirestoreChatCollectionNameConfig();

  /// Retrieves the Firestore collection name configuration.
  ///
  /// Returns an instance of [FirestoreChatCollectionNameConfig] containing
  /// the configured collection names, allowing customization of
  /// Firestore collection names.
  ///
  /// Users can override default collection names by providing custom values.
  FirestoreChatCollectionNameConfig get getFirestoreChatCollectionNameConfig =>
      _firestoreCollectionNameConfig;

  /// The type of database that is being used.
  ChatViewDatabaseType get databaseType => _databaseType;

  /// Returns current user's ID
  String? get currentUserId => _currentUserId;

  /// Retrieves a new instance of [ChatManager] using the current database
  /// service.
  ///
  /// This method initializes a [ChatManager] and provides access to
  /// chat-related functionalities.
  ///
  /// **Returns:**
  /// A new instance of [ChatManager].
  ///
  /// **Note:**
  /// - This instance is meant for using methods like `updateUserActiveStatus`,
  ///   `createChat`, `createGroupChat`, `getUsers`, `deleteChat`, and
  ///   `getChats`, which do not depend on the chat room itself.
  /// - While you can access chat room-related methods, you won’t be able to
  ///   perform any operations. To fully utilize chat room functionalities,
  ///   use the chat manager from
  ///   `ChatViewDbConnection.instance.getChatRoomManager()` instead.
  ChatManager getChatManager() => ChatManager.fromService(_service!);

  /// Retrieves or initializes a [ChatManager] based on the provided
  /// parameters.
  ///
  /// **Usage:**
  /// - Either provide **[currentUser], [otherUsers], and [chatRoomType]**
  /// to create a new chat room,
  /// - Or provide **[chatRoomId]** to retrieve an existing chat room.
  ///
  /// **Required Parameters:**
  /// - (required): [initialMessageList] List of initial messages to display.
  /// - (required): [scrollController] Controller for managing chat scroll
  /// behavior.
  /// - (required): [config] Chat configuration settings.
  ///
  /// **Required parameters for create a new chat room:**
  ///
  /// - (optional): [createChatRoomOnMessageSend] Whether to create a one-to-one
  /// or group chat when sending the first message.
  /// - (optional): [currentUser] The user initiating the chat.
  /// - (optional): [otherUsers] List of users participating in the chat.
  /// - (optional): [chatRoomType] The type of chat (one-to-one or group).
  /// - (optional): [groupName] Name of the group chat
  /// (applicable for group chats).
  /// - (optional): [groupProfile] Profile picture URL of the group chat.
  /// (applicable for group chats).
  ///
  /// **Required parameters for an existing chat room:**
  /// - (optional): [chatRoomId] ID of an existing chat room.
  ///
  /// **Throws:**
  /// - An [Exception] if neither a valid chat room ID nor user details are
  /// provided.
  ///
  /// **Returns:**
  /// A [Future] resolving to an initialized [ChatManager].
  ///
  /// **Note**:
  /// If [createChatRoomOnMessageSend] is set to `true`,
  /// the following features will not work as the chat room is not created:
  /// - Typing indicator
  /// - Adding users to a group
  /// - Removing users from a group
  /// - Leaving a group
  /// - Updating the group name
  Future<ChatManager> getChatRoomManager({
    required List<Message> initialMessageList,
    required ScrollController scrollController,
    required ChatControllerConfig config,
    bool createChatRoomOnMessageSend = false,
    String? chatRoomId,
    ChatUser? currentUser,
    List<ChatUser>? otherUsers,
    ChatRoomType? chatRoomType,
    String? groupName,
    String? groupProfile,
  }) async {
    final tempCurrentUser = currentUser;
    final tempOtherUsers = otherUsers ?? [];
    final tempChatRoomType = chatRoomType;
    final tempChatRoomId = chatRoomId;
    if (tempCurrentUser != null &&
        tempOtherUsers.isNotEmpty &&
        tempChatRoomType != null) {
      return _getChatManagerByUsers(
        config: config,
        groupName: groupName,
        otherUsers: tempOtherUsers,
        groupProfile: groupProfile,
        currentUser: tempCurrentUser,
        chatRoomType: tempChatRoomType,
        scrollController: scrollController,
        initialMessageList: initialMessageList,
        createChatRoomOnMessageSend: createChatRoomOnMessageSend,
      );
    } else if (tempChatRoomId != null) {
      return _getChatManagerByChatRoomId(
        chatRoomId: tempChatRoomId,
        initialMessageList: initialMessageList,
        scrollController: scrollController,
        config: config,
      );
    } else {
      throw Exception(
        'Invalid parameters: '
        'Provide either (currentUser, otherUsers, chatRoomType) or chatRoomId.',
      );
    }
  }

  /// Initializes and returns a [ChatManager] for the specified chat room.
  ///
  /// From the given chat room, it retrieves the chat room participants
  /// (current user and other users) and sets up listeners for messages,
  /// user activity, and chat room metadata changes if specified.
  ///
  /// **Parameters:**
  /// - (required): [chatRoomId] The unique identifier of the chat room
  ///   to initialize.
  /// - (required): [initialMessageList] A list of initial messages to
  ///   display in the chat.
  /// - (optional): [scrollController] A [ScrollController] for managing
  ///   scroll behavior within the chat.
  /// - (optional): [config]:A [ChatControllerConfig] instance that
  ///   defines settings for message listening, user activity tracking,
  ///   and chat metadata updates.
  ///
  /// **Behavior:**
  /// - Fetches the participants of the specified chat room.
  /// - Invokes the `chatRoomInfo` callback from [config], if provided.
  /// - Creates a [ChatManager] with the retrieved participants, chat
  ///   room configuration, and other provided parameters.
  ///
  /// **Note:**
  /// - For one-to-one chats, the chat controller internally manages typing
  ///   indicators.
  ///
  /// **Returns:**
  /// A [Future] resolving to an initialized [ChatManager].
  ///
  /// **Throws:**
  /// - An [Exception] if the `chatRoomId` is empty.
  /// - An [Exception] if no participants are found for the specified chat room.
  Future<ChatManager> _getChatManagerByChatRoomId({
    required String chatRoomId,
    required List<Message> initialMessageList,
    required ScrollController scrollController,
    required ChatControllerConfig config,
  }) async {
    if (chatRoomId.isEmpty) throw Exception("Chat Room ID can't be empty!");
    final chatRoomParticipants =
        await _service?.database.getChatRoomParticipants(chatRoomId);
    if (chatRoomParticipants == null) throw Exception('No Users Found!');
    config.chatRoomInfo?.call(chatRoomParticipants);
    return ChatManager.fromChatRoomId(
      config: config,
      chatRoomId: chatRoomId,
      scrollController: scrollController,
      initialMessageList: initialMessageList,
      chatRoomParticipants: chatRoomParticipants,
      service: DatabaseTypeServices.fromDataType(databaseType),
    );
  }

  /// Initializes and returns a [ChatManager] for a one-to-one or
  /// group chat with the specified users.
  ///
  /// - **For one-to-one chats:**
  ///   If a chat already exists between the [currentUser] and [otherUsers],
  ///   the existing chat room is used. Otherwise, a new chat room is created.
  ///
  /// - **For group chats:**
  ///   A new chat room is created with the specified [groupName] and
  ///   [groupProfile].
  ///   - If [groupName] is not provided, a default name is generated
  ///     by combining participant names (e.g., `"User 1, User 2, ..."`).
  ///   - If [groupProfile] is provided, it will be set as the group's profile
  ///     picture.
  ///
  /// **Parameters:**
  ///
  /// - (required): [chatRoomType] Specifies whether the chat is one-to-one or
  /// group.
  /// - (required): [currentUser] The user initiating or joining the chat.
  /// - (required): [otherUsers] A list of users participating in the chat.
  /// - (required): [initialMessageList] A list of initial messages to display.
  /// - (required): [scrollController] Manages scroll behavior within the chat.
  /// - (required): [config] A [ChatControllerConfig] instance that defines
  /// settings for message listening, user activity tracking, and metadata
  /// updates.
  /// - (optional): [groupName] The name of the group chat
  /// (applicable for group chats).
  /// - (optional): [groupProfile] The profile picture URL for the group chat.
  /// (only applicable for group chats).
  /// - (optional): [createChatRoomOnMessageSend] If `true`, the one-to-one or
  /// group chat is created only when a message is sent (default: `false`).
  ///
  /// **Behavior:**
  /// - For one-to-one chats, it first checks if an existing chat room exists.
  /// - If no chat room exists, a new one is created based on the provided
  /// parameters.
  ///
  /// **Returns:**
  /// A [Future] resolving to an initialized [ChatManager].
  ///
  /// **Throws:**
  /// - An [Exception] if [otherUsers] is empty.
  /// - An [Exception] if chat initialization fails.
  Future<ChatManager> _getChatManagerByUsers({
    required ChatRoomType chatRoomType,
    required ChatUser currentUser,
    required List<ChatUser> otherUsers,
    required List<Message> initialMessageList,
    required ScrollController scrollController,
    required ChatControllerConfig config,
    bool createChatRoomOnMessageSend = false,
    String? groupName,
    String? groupProfile,
  }) async {
    if (otherUsers.isEmpty) throw Exception("Other Users can't be empty!");
    if (chatRoomType.isOneToOne) {
      final chatRoomID = await _service?.database.isOneToOneChatExists(
        otherUsers.first.id,
      );
      if (chatRoomID case final chatRoomId?) {
        return _getChatManagerByChatRoomId(
          config: config,
          chatRoomId: chatRoomId,
          scrollController: scrollController,
          initialMessageList: initialMessageList,
        );
      }
    }

    String? chatRoomId;

    if (!createChatRoomOnMessageSend) {
      switch (chatRoomType) {
        case ChatRoomType.oneToOne:
          chatRoomId = await _service?.database.createOneToOneUserChat(
            otherUserId: otherUsers.first.id,
          );
        case ChatRoomType.group:
          final groupInfo = otherUsers.createGroupInfo();
          chatRoomId = await _service?.database.createGroupChat(
            groupName: groupInfo.groupName,
            participants: groupInfo.participants,
          );
      }
    }

    return ChatManager.fromUsers(
      config: config,
      groupName: groupName,
      otherUsers: otherUsers,
      chatRoomId: chatRoomId,
      currentUser: currentUser,
      groupProfile: groupProfile,
      chatRoomType: chatRoomType,
      scrollController: scrollController,
      initialMessageList: initialMessageList,
      service: DatabaseTypeServices.fromDataType(databaseType),
    );
  }

  /// Gets the singleton instance of [ChatViewDbConnection].
  ///
  /// *Note: Ensures the instance is initialized before accessing it.
  /// Example:
  /// ``` dart
  /// ChatViewDbConnection(ChatViewDatabaseType.firebase);
  /// ```
  static ChatViewDbConnection get instance {
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

  /// To set current user's ID
  void setCurrentUserId({required String userId}) {
    assert(userId.isNotEmpty, "User ID can't be empty!");
    _currentUserId = userId;
  }
}
