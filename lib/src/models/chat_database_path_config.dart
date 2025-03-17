import '../extensions.dart';

/// {@template flutter_chatview_db_connection.ChatFirestoreDatabasePathConfig}
/// Configuration class for defining database paths for chat-related data.
///
/// This class allows customization of Firestore database paths for
/// storing user data, ensuring efficient organization of collections.
///
/// ### Example Usage:
/// ```dart
/// ChatViewDbConnection(
///     ChatViewDatabaseType.firebase,
///     databasePathConfig: ChatDatabasePathConfig(
///         userCollectionPath: 'organizations/org123',
///     ),
/// )
/// ```
/// If [userCollectionPath] is not specified,
/// the default top-level `users` collection is used.
/// {@endtemplate}
final class ChatDatabasePathConfig {
  /// Creates a new instance of [ChatDatabasePathConfig].
  ///
  /// **Parameters:**
  /// - (optional): [userCollectionPath] The Firestore collection path
  /// for storing user data.
  ///   If omitted, defaults to the top-level `users` collection.
  ///
  /// {@macro flutter_chatview_db_connection.ChatFirestoreDatabasePathConfig.userCollectionPath}
  ChatDatabasePathConfig({this.userCollectionPath})
      : assert(
          userCollectionPath == null ||
              userCollectionPath.isValidFirestoreCollectionName,
          'Chat Collection Path should not have the nested collection',
        );

  /// {@template flutter_chatview_db_connection.ChatFirestoreDatabasePathConfig.userCollectionPath}
  /// The collection path where user data is stored.
  ///
  /// If the 'users' collection is nested within other collections, specify
  /// the parent path excluding 'users'. For example, if the user collection
  /// is located at:
  ///
  /// **Firestore structure:**
  /// `organizations/org123/users`
  ///
  /// Then specify:
  ///
  /// ```dart
  /// userCollectionPath: 'organizations/org123'
  /// ```
  /// {@endtemplate}
  final String? userCollectionPath;
}
