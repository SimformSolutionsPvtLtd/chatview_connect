import 'database/database_service.dart';
import 'database/firebase/chatview_firestore_database.dart';
import 'enum.dart';
import 'storage/firebase/chatview_firebase_storage.dart';
import 'storage/storage_service.dart';
import 'typedefs.dart';

/// A singleton class provides different type of database's clouds services
/// for chat views.
///
/// provides methods to initialize and access the clouds service
/// Example: [storage].
final class ChatViewDbConnection {
  /// Factory constructor to create a singleton instance of
  /// [ChatViewDbConnection].
  ///
  /// * required: [databaseType] to use particular that cloud's services.
  factory ChatViewDbConnection(ChatViewDatabaseType databaseType) {
    _instance ??= ChatViewDbConnection._(databaseType);
    return _instance!;
  }

  const ChatViewDbConnection._(this._databaseType);

  static ChatViewDbConnection? _instance;
  static DatabaseService? _database;
  static StorageService? _storage;

  final ChatViewDatabaseType _databaseType;

  /// The type of database that is being used.
  ChatViewDatabaseType get databaseType => _databaseType;

  /// to Initialize the clouds services.
  /// Example: [storage] service
  void initialize() {
    final DatabaseTypeServicesRecord typeWiseService = switch (_databaseType) {
      ChatViewDatabaseType.firebase => (
          database: ChatViewFireStoreDatabase(),
          storage: ChatViewFirebaseStorage(),
        ),
    };
    _database ??= typeWiseService.database;
    _storage ??= typeWiseService.storage;
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
      '''
ChatViewDbConnection must be initialized. 
      Example: initialize ChatViewDbConnection for firebase backend
      ///```dart
      /// ChatViewDbConnection(ChatViewDatabaseType.firebase).initialize();
      /// ```''',
    );
    return _instance!;
  }

  /// Gets the database service associated with the current database connection.
  ///
  /// *Note: Ensures the storage service is initialized before accessing it.
  /// Example:
  /// ``` dart
  /// ChatViewDbConnection(ChatViewDatabaseType.firebase).initialize();
  /// ```
  static DatabaseService get database {
    assert(
      _database != null,
      '''
ChatViewDbConnection must be initialized. 
      Example: initialize ChatViewDbConnection for firebase backend
      ///```dart
      /// ChatViewDbConnection(ChatViewDatabaseType.firebase).initialize();
      /// ```''',
    );
    return _database!;
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
      '''
      ChatViewDbConnection must be initialized. 
      Example: initialize ChatViewDbConnection for firebase backend
      ///```dart
      /// ChatViewDbConnection(ChatViewDatabaseType.firebase).initialize();
      /// ```''',
    );
    return _storage!;
  }
}
