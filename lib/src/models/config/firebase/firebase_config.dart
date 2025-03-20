import '../cloud_service_config.dart';
import 'chat_firestore_database_path_config.dart';
import 'firestore_chat_collection_name_config.dart';

/// A configuration class for Firebase integration.
///
/// This class holds the necessary configurations for database paths and
/// collection names required to interact with Firebase Firestore.
class FirebaseCloudConfig implements CloudServiceConfig {
  /// Creates a [FirebaseCloudConfig] instance with the required configurations.
  ///
  /// **Parameters:**
  /// - (optional): [databasePathConfig] Defines the Firestore database
  ///   paths for retrieving user data.
  ///   - If omitted, the default top-level `users` collection will be used.
  /// - (optional): [collectionNameConfig] Allows customization of
  ///   Firestore collection names.
  ///   - If a value is `null`, the default collection name will be used.
  const FirebaseCloudConfig({
    this.databasePathConfig,
    this.collectionNameConfig,
  });

  /// Defines the Firestore database paths for retrieving user data.
  /// Defaults to the top-level `users` collection if not provided.
  final FirestoreChatDatabasePathConfig? databasePathConfig;

  /// Allows customization of Firestore collection names.
  /// If `null`, the default collection name will be used.
  final FirestoreChatCollectionNameConfig? collectionNameConfig;
}
