import 'package:chatview_utils/chatview_utils.dart';
import 'package:flutter/widgets.dart';

import 'chatview_connect_constants.dart';
import 'enum.dart';
import 'extensions.dart';
import 'manager/chat/chat_manager.dart';
import 'manager/chat_list/chat_list_manager.dart';
import 'models/config/chat_controller_config.dart';
import 'models/config/chat_user_config.dart';
import 'models/config/cloud_service_config.dart';
import 'models/config/firebase/firebase_cloud_config.dart';
import 'models/config/firebase/firestore_chat_collection_name_config.dart';
import 'models/config/firebase/firestore_chat_database_path_config.dart';

/// A singleton class provides different type of database's clouds services for
/// chat views.
///
/// provides methods to initialize and access the clouds service.
final class ChatViewConnect {
  /// Initializes the ChatViewConnect package.
  ///
  /// This is the primary entry point and must be called before using any
  /// chat-related functionality. It sets up the core configuration required
  /// to interface with the chosen cloud service.
  ///
  /// **Parameters:**
  /// - (required): [cloudServiceType] specifies the type of cloud database
  /// service to be used. (e.g., Firebase) to be used for chat.
  ///
  /// - (optional): [chatUserConfig] Customizes the serialization and
  ///   deserialization of user data.
  ///   - By default, user data is stored and retrieved using standard keys
  ///   like `id`, `name`, and `profilePhoto`.
  ///   - Allows mapping custom keys for different data sources
  ///   (e.g., mapping `username` instead of `name`).
  ///
  /// - (optional): [cloudServiceConfig] Configuration details specific
  /// to the selected cloud service.
  ///   - For Firebase, allows specifying Firestore paths and
  ///   collection names.
  ///
  /// **Example Usage in `main.dart`:**
  /// ```dart
  /// ChatViewConnect.initialize(
  ///     ChatViewCloudService.firebase,
  ///     chatUserConfig: const ChatUserConfig(
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
  factory ChatViewConnect.initialize(
    ChatViewCloudService cloudServiceType, {
    ChatUserConfig? chatUserConfig,
    CloudServiceConfig? cloudServiceConfig,
  }) {
    if (_instance == null) {
      final cloudConfig = switch (cloudServiceType) {
        ChatViewCloudService.firebase
            when cloudServiceConfig is FirebaseCloudConfig =>
          cloudServiceConfig,
        ChatViewCloudService.firebase => null,
      };
      _chatUserConfig = chatUserConfig;
      _instance = ChatViewConnect._(cloudServiceType, cloudConfig);
      final service = CloudServices.fromType(cloudServiceType);
      _service = service;
    }
    return _instance!;
  }

  const ChatViewConnect._(this._cloudServiceType, this._cloudConfig);

  final ChatViewCloudService _cloudServiceType;

  final CloudServiceConfig? _cloudConfig;

  static ChatViewConnect? _instance;

  static CloudServices? _service;

  static String? _currentUserId;

  static ChatUserConfig? _chatUserConfig;

  /// Retrieves the current chat user model configuration.
  ///
  /// This configuration defines the mapping of JSON keys to user properties
  /// (e.g., mapping `"username"` instead of `"name"`).
  ///
  /// If no configuration has been set, this will return `null`,
  /// meaning default keys (`id`, `name`, `profilePhoto`) will be used.
  ChatUserConfig? get getChatUserConfig => _chatUserConfig;

  /// Retrieves the current database path configuration for chat operations.
  ///
  /// Returns a [FirestoreChatDatabasePathConfig] object containing the paths
  /// for user chats, chat collections, and optionally, user collections.
  FirestoreChatDatabasePathConfig? get getFirestoreChatDatabasePathConfig =>
      _cloudConfig is FirebaseCloudConfig
          ? _cloudConfig.databasePathConfig
          : null;

  static final _defaultChatCollectionNameConfig =
      FirestoreChatCollectionNameConfig();

  /// Retrieves the Firestore collection name configuration.
  ///
  /// Returns an instance of [FirestoreChatCollectionNameConfig] containing
  /// the configured collection names, allowing customization of
  /// Firestore collection names.
  ///
  /// Users can override default collection names by providing custom values.
  FirestoreChatCollectionNameConfig get getFirestoreChatCollectionNameConfig {
    final collectionNameConfig = _cloudConfig is FirebaseCloudConfig
        ? _cloudConfig.collectionNameConfig
        : null;
    return collectionNameConfig ?? _defaultChatCollectionNameConfig;
  }

  /// The type of database that is being used.
  ChatViewCloudService get cloudServiceType => _cloudServiceType;

  /// Returns current user's ID
  String? get currentUserId => _currentUserId;

  /// Retrieves a new instance of [ChatListManager] using the current
  /// database service.
  ///
  /// This method creates a [ChatListManager] and provides access to
  /// chat list-related functionalities.
  ///
  /// **Parameters:**
  /// - (required): [scrollController] A [ScrollController] for managing
  ///   scroll behavior within the chat list.
  /// - (optional): [sortEnable] If `true`, enables sorting of chat list items.
  /// - (optional): [chatSorter] A custom sorter for ordering chat items.
  /// - (optional): [includeEmptyChats] If `true`, includes empty chats in the
  ///   list.
  /// - (optional): [includeUnreadMessagesCount] If `true`, includes the count of
  ///   unread messages in the chat list items.
  ///
  /// **Returns:**
  /// A new instance of [ChatListManager].
  ChatListManager getChatListManager({
    required ScrollController scrollController,
    bool sortEnable = true,
    ChatSorter? chatSorter,
    bool includeEmptyChats = true,
    bool includeUnreadMessagesCount = true,
  }) {
    assert(
      _service != null,
      '''
      ChatViewConnect must be initialized. 
      Example: initialize ChatViewConnect for firebase backend
      ///```dart
      /// ChatViewConnect.initialize(ChatViewCloudService.firebase);
      /// ```''',
    );
    return ChatListManager.fromService(
      service: _service!,
      scrollController: scrollController,
      chatSorter: chatSorter,
      sortEnable: sortEnable,
      includeEmptyChats: includeEmptyChats,
      includeUnreadMessagesCount: includeUnreadMessagesCount,
    );
  }

  /// Retrieves or initializes a [ChatManager] based on the provided
  /// parameters.
  ///
  /// **Usage:**
  /// - Either provide **[currentUser], [otherUsers], and [chatRoomType]**
  /// to create a new chat room,
  /// - Or provide **[chatRoomId]** to retrieve an existing chat room.
  ///
  /// **Required Parameters:**
  /// - (required): [scrollController] Controller for managing chat scroll
  /// behavior.
  ///
  /// **Required parameters for create a new chat room:**
  /// - (optional): [currentUser] The user initiating the chat.
  /// - (optional): [otherUsers] List of users participating in the chat.
  /// - (optional): [chatRoomType] The type of chat (one-to-one or group).
  /// - (optional): [groupName] Name of the group chat
  /// (applicable for group chats).
  /// - (optional): [groupProfile] Profile picture URL of the group chat.
  /// (applicable for group chats).
  /// - (optional): [config] Chat configuration settings.
  /// - (optional): [lazyCreateChat] If `true`, the one-to-one or
  /// group chat is created only when a message is sent (default: `false`).
  ///
  /// **Required parameters for an existing chat room:**
  /// - (optional): [chatRoomId] ID of an existing chat room.
  /// - (optional): [config] Chat configuration settings.
  ///
  /// **Throws:**
  /// - An [Exception] if neither a valid chat room ID nor user details are
  /// provided.
  ///
  /// **Returns:**
  /// A [Future] resolving to an initialized [ChatManager].
  ///
  /// **Note**:
  /// If [lazyCreateChat] is set to `true`,
  /// the following features will not work as the chat room is not created:
  /// - Typing indicator
  /// - Adding users to a group
  /// - Removing users from a group
  /// - Leaving a group
  /// - Updating the group name
  Future<ChatManager> getChatRoomManager({
    required ScrollController scrollController,
    bool lazyCreateChat = false,
    ChatControllerConfig? config,
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
        lazyCreateChat: lazyCreateChat,
      );
    } else if (tempChatRoomId != null) {
      return _getChatManagerByChatRoomId(
        chatRoomId: tempChatRoomId,
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
    required ScrollController scrollController,
    ChatControllerConfig? config,
  }) async {
    final userId = _currentUserId ?? '';
    if (userId.isEmpty) throw Exception("Current User ID can't be empty!");
    if (chatRoomId.isEmpty) throw Exception("Chat Room ID can't be empty!");
    final chatRoomParticipants = await _service?.database.getChatRoomMetadata(
      userId: userId,
      chatId: chatRoomId,
      retry: ChatViewConnectConstants.defaultRetry,
    );
    if (chatRoomParticipants == null) throw Exception('No Users Found!');
    config?.chatRoomMetadata?.call(chatRoomParticipants);
    return ChatManager.fromChatRoomId(
      config: config,
      id: chatRoomId,
      scrollController: scrollController,
      participants: chatRoomParticipants,
      service: CloudServices.fromType(cloudServiceType),
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
  /// - (required): [scrollController] Manages scroll behavior within the chat.
  /// - (optional): [config] A [ChatControllerConfig] instance that defines
  /// settings for message listening, user activity tracking, and metadata
  /// updates.
  /// - (optional): [groupName] The name of the group chat
  /// (applicable for group chats).
  /// - (optional): [groupProfile] The profile picture URL for the group chat.
  /// (only applicable for group chats).
  /// - (optional): [lazyCreateChat] If `true`, the one-to-one or
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
    required ScrollController scrollController,
    bool lazyCreateChat = false,
    ChatControllerConfig? config,
    String? groupName,
    String? groupProfile,
  }) async {
    final userId = _currentUserId ?? '';
    if (userId.isEmpty) throw Exception("Current User ID can't be empty!");
    if (otherUsers.isEmpty) throw Exception("Other Users can't be empty!");
    if (chatRoomType.isOneToOne) {
      final chatRoomID = await _service?.database.findOneToOneChatRoom(
        userId: userId,
        otherUserId: otherUsers.first.id,
        retry: ChatViewConnectConstants.defaultRetry,
      );
      if (chatRoomID case final chatRoomId?) {
        return _getChatManagerByChatRoomId(
          config: config,
          chatRoomId: chatRoomId,
          scrollController: scrollController,
        );
      }
    }

    String? chatRoomId;

    if (!lazyCreateChat) {
      switch (chatRoomType) {
        case ChatRoomType.oneToOne:
          chatRoomId = await _service?.database.createOneToOneChat(
            userId: userId,
            otherUserId: otherUsers.first.id,
          );
        case ChatRoomType.group:
          final groupInfo = otherUsers.createGroupInfo();
          chatRoomId = await _service?.database.createGroupChat(
            userId: userId,
            groupProfilePic: groupProfile,
            groupName: groupInfo.groupName,
            participants: groupInfo.participants,
          );
      }
    }

    return ChatManager.fromParticipants(
      config: config,
      groupName: groupName,
      otherUsers: otherUsers,
      chatRoomId: chatRoomId,
      currentUser: currentUser,
      groupProfile: groupProfile,
      chatRoomType: chatRoomType,
      scrollController: scrollController,
      service: CloudServices.fromType(cloudServiceType),
    );
  }

  /// Gets the singleton instance of [ChatViewConnect].
  ///
  /// *Note: Ensures the instance is initialized before accessing it.
  /// Example:
  /// ``` dart
  /// ChatViewConnect.initialize(ChatViewCloudService.firebase);
  /// ```
  static ChatViewConnect get instance {
    assert(
      _instance != null,
      '''
      ChatViewConnect must be initialized. 
      Example: initialize ChatViewConnect for firebase backend
      ///```dart
      /// ChatViewConnect.initialize(ChatViewCloudService.firebase);
      /// ```''',
    );
    return _instance!;
  }

  /// To set current user's ID
  void setCurrentUserId(String userId) {
    assert(userId.isNotEmpty, "User ID can't be empty!");
    _currentUserId = userId;
  }

  /// Resets the current user ID by setting it to `null`.
  void resetCurrentUserId() => _currentUserId = null;
}
