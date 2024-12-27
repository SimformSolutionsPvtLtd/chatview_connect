import 'enum.dart';
import 'storage/firebase/chatview_firebase_storage.dart';
import 'storage/storage_service.dart';

/// A singleton class provides different type of database's clouds services for chat views.
///
/// provides methods to initialize and access the clouds service
/// Example: [storage].
final class ChatViewDbConnection {
  const ChatViewDbConnection._(this._databaseType);

  /// Factory constructor to create a singleton instance of [ChatViewDbConnection].
  ///
  /// * required: [databaseType] to use particular that cloud's services.
  factory ChatViewDbConnection(ChatViewDatabaseType databaseType) {
    _instance ??= ChatViewDbConnection._(databaseType);
    return _instance!;
  }

  static ChatViewDbConnection? _instance;
  static StorageService? _storage;

  final ChatViewDatabaseType _databaseType;

  /// The type of database that is being used.
  ChatViewDatabaseType get databaseType => _databaseType;

  /// to Initialize the clouds services.
  /// Example: [storage] service
  void initialize() {
    _storage ??= switch (_databaseType) {
      ChatViewDatabaseType.firebase => ChatViewFirebaseStorage(),
    };
  }

  /// Gets the singleton instance of [ChatViewDbConnection].
  ///
  /// *Note: Ensures the instance is initialized before accessing it.
  /// Example:
  /// ``` dart
  /// ChatViewDbConnection(ChatViewDatabaseType.firebase).initialize();
  /// ```
  static ChatViewDbConnection get instance {
    assert(
      _instance != null,
      """ChatViewDbConnection must be initialized. 
      Example: initialize ChatViewDbConnection for firebase backend
      ///```dart
      /// ChatViewDbConnection(ChatViewDatabaseType.firebase).initialize();
      /// ```""",
    );
    return _instance!;
  }

  /// Gets the storage service associated with the current database connection.
  ///
  /// *Note: Ensures the storage service is initialized before accessing it.
  /// Example:
  /// ``` dart
  /// ChatViewDbConnection(ChatViewDatabaseType.firebase).initialize();
  /// ```
  static StorageService get storage {
    assert(
      _storage != null,
      """ChatViewDbConnection must be initialized. 
      Example: initialize ChatViewDbConnection for firebase backend
      ///```dart
      /// ChatViewDbConnection(ChatViewDatabaseType.firebase).initialize();
      /// ```""",
    );
    return _storage!;
  }
}
