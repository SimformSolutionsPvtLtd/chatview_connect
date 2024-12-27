import 'enum.dart';
import 'manager/chatview_connection_manager.dart';

/// A singleton class that provides various cloud database services
/// for chat views.
///
/// It offers methods to initialize and interact with cloud services,
/// such as `database` and `storage` services.
final class ChatViewDbConnection {
  /// Factory constructor to create and retrieve the singleton instance
  /// of [ChatViewDbConnection].
  ///
  /// **Parameters:**
  /// - (required): [databaseType] specifies the type of cloud database service
  /// to be used.
  factory ChatViewDbConnection(ChatViewDatabaseType databaseType) {
    _instance ??= ChatViewDbConnection._(databaseType);
    return _instance!;
  }

  const ChatViewDbConnection._(this._databaseType);

  static String? _currentUserId;
  static ChatViewDbConnection? _instance;
  final ChatViewDatabaseType _databaseType;

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
