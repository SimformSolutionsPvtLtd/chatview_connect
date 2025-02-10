import 'enum.dart';
import 'manager/chatview_connection_manager.dart';
import 'models/chat_database_path_config.dart';

/// A singleton class provides different type of database's clouds services for
/// chat views.
///
/// provides methods to initialize and access the clouds service
/// Example: [connectionManager].
final class ChatViewDbConnection {
  /// The main entry point for using the chat database connection in
  /// this package.
  ///
  /// This class must be instantiated to access chat-related functionality.
  /// It serves as the core connection layer for handling chat related
  /// operations across different cloud providers.
  ///
  /// - (required): [databaseType] specifies the type of cloud database service
  /// to be used. (e.g., Firebase) to be used for chat.
  ///
  /// - (optional): [databasePathConfig] Defines the Firestore database paths
  /// for retrieving users data.
  ///   - If omitted, the default top-level `users` collection will be used.
  ///
  /// **Example Usage in `main.dart`:**
  /// ```dart
  /// ChatViewDbConnection(
  ///     ChatViewDatabaseType.firebase,
  ///     databasePathConfig: ChatDatabasePathConfig(
  ///       userCollectionPath: 'organizations/org123',
  ///     ),
  /// );
  /// ```
  factory ChatViewDbConnection(
    ChatViewDatabaseType databaseType, {
    ChatDatabasePathConfig? databasePathConfig,
  }) {
    _instance ??= ChatViewDbConnection._(databaseType);
    ChatViewConnectionManager(databaseType);
    _chatDatabasePathConfig = databasePathConfig ?? ChatDatabasePathConfig();
    return _instance!;
  }

  const ChatViewDbConnection._(this._databaseType);

  static String? _currentUserId;
  static ChatViewDbConnection? _instance;
  final ChatViewDatabaseType _databaseType;

  static ChatDatabasePathConfig _chatDatabasePathConfig =
      ChatDatabasePathConfig();

  /// Retrieves the current database path configuration for chat operations.
  ///
  /// Returns a [ChatDatabasePathConfig] object containing the paths for
  /// user chats, chat collections, and optionally, user collections.
  ChatDatabasePathConfig get getChatDatabasePathConfig =>
      _chatDatabasePathConfig;

  /// The type of database that is being used.
  ChatViewDatabaseType get databaseType => _databaseType;

  /// Returns current user's ID
  String? get currentUserId => _currentUserId;

  /// Retrieves the instance of the [ChatViewConnectionManager] for accessing
  /// chat related operations.
  ///
  /// **Important:** Before accessing the connection manager,
  /// you must set the current user ID.
  ///
  /// The getter will throw an assertion error if the user ID is not set,
  /// ensuring that operations relying on the user context are executed
  /// properly.
  ///
  /// Example: initialize ChatViewDbConnection for firebase backend
  /// ```dart
  /// ChatViewDbConnection(ChatViewDatabaseType.firebase);
  /// // Set the current user ID before accessing the connection manager
  /// ChatViewDbConnection.instance.setCurrentUserId(userId: '1');
  /// ```
  static ChatViewConnectionManager get connectionManager {
    assert(
      _currentUserId != null,
      '''
      Current User ID must be set. 
      Example: set Current User ID database operations
      ///```dart
      /// ChatViewDbConnection.instance.setCurrentUserId(userId: '1');
      /// ```''',
    );
    return ChatViewConnectionManager.instance;
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
  void setCurrentUserId({required String userId}) => _currentUserId = userId;
}
