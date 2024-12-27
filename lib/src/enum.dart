import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// An enumeration of databases types.
enum ChatViewDatabaseType {
  /// Indicates a Firebase Database.
  firebase;

  /// Checks if the current database type is Firebase.
  bool get isFirebase => this == firebase;
}

/// An enumeration of messages sort by types.
enum MessageSortBy {
  /// Sorts messages by the DateTime.
  dateTime('createdAt'),

  /// No sorting is applied.
  none('');

  const MessageSortBy(this.key);

  /// An internal key associated with the sort type.
  /// It defines for the server by which field it will be sorted.
  final String key;
}

/// An enumeration of messages sorting types.
enum MessageSortOrder {
  /// Sorts messages in ascending order.
  /// Example: if sorting from datetime, the oldest message gets first.
  asc,

  /// Sorts messages in descending order.
  /// Example: if sorting from datetime, the newest message gets first.
  desc;

  /// Checks if the sort order type is ascending.
  bool get isAsc => this == asc;

  /// Checks if the sort order type is descending.
  bool get isDesc => this == desc;
}

/// An enumeration of document change types.
enum DocumentType {
  /// Indicates a new document was added to the set of documents matching the
  /// query.
  added,

  /// Indicates a document within the query was modified.
  modified,

  /// Indicates a document within the query was removed (either deleted or no
  /// longer matches the query.
  removed;
}

/// Extension on [DocumentChangeType] to provide a utility method for
/// converting Firebase [DocumentChangeType] values to corresponding [DocumentType] values.
extension DocumentChangeTypeExtension on DocumentChangeType {
  /// Converts a [DocumentChangeType] from Firebase to the corresponding [DocumentType].
  ///
  /// This method maps Firebase document change types to application-specific document types.
  ///
  /// - [DocumentChangeType.added] → [DocumentType.added]
  /// - [DocumentChangeType.modified] → [DocumentType.modified]
  /// - [DocumentChangeType.removed] → [DocumentType.removed]
  ///
  /// **Returns:** The corresponding [DocumentType] based on the type of change.
  ///
  /// Example:
  /// ```dart
  /// final documentType = DocumentChangeType.added.toDocumentType();
  /// print(documentType); // Output: DocumentType.added
  /// ```

  DocumentType toDocumentType() {
    return switch (this) {
      DocumentChangeType.added => DocumentType.added,
      DocumentChangeType.modified => DocumentType.modified,
      DocumentChangeType.removed => DocumentType.removed,
    };
  }
}

/// An enumeration of user status.
enum UserStatus {
  /// user is active
  online,

  /// user is inactive
  offline;

  /// is user inactive
  bool get isOnline => this == online;

  /// is user active
  bool get isOffline => this == offline;
}

/// Extension methods for [UserStatus], providing utilities
/// for parsing and handling user status values.
extension UserStatusExtension on UserStatus {
  /// Parses a string value and returns the corresponding [UserStatus].
  ///
  /// - If the [value] is `null` or empty, it defaults to [UserStatus.offline].
  /// - If the [value] matches [UserStatus.online.name] (case-insensitive),
  ///   it returns [UserStatus.online].
  /// - For all other cases, it defaults to [UserStatus.offline].
  ///
  /// Example:
  /// ```dart
  /// final status = UserStatus.parse('online');
  /// print(status); // Output: UserStatus.online
  /// ```
  ///
  /// [value]: The input string to parse.
  /// Returns the corresponding [UserStatus].
  static UserStatus parse(String? value) {
    final safeValue = value?.trim().toLowerCase() ?? '';
    if (safeValue.isEmpty) return UserStatus.offline;
    if (safeValue == UserStatus.online.name) {
      return UserStatus.online;
    } else {
      return UserStatus.offline;
    }
  }
}

/// Provides utility methods for [TypeWriterStatus].
extension TypeWriterStatusExtension on TypeWriterStatus {
  /// Parses a string value and returns the corresponding [TypeWriterStatus].
  ///
  /// **Parameters:**
  /// - (required): [value] The input string to parse.
  ///
  /// - If the [value] is `null` or empty,
  /// it defaults to [TypeWriterStatus.typed].
  /// - If the [value] matches [TypeWriterStatus.typing.name]
  /// (case-insensitive), it returns [TypeWriterStatus.typing].
  /// - For all other cases, it defaults to [TypeWriterStatus.typed].
  ///
  /// Example:
  /// ```dart
  /// final status = TypeWriterStatus.parse('typing');
  /// print(status); // Output: TypeWriterStatus.typing
  /// ```
  ///
  /// Returns the corresponding [TypeWriterStatus].
  static TypeWriterStatus parse(String? value) {
    final type = value?.trim().toLowerCase() ?? '';
    if (type.isEmpty) return TypeWriterStatus.typed;
    if (type == TypeWriterStatus.typing.name.toLowerCase()) {
      return TypeWriterStatus.typing;
    } else {
      return TypeWriterStatus.typed;
    }
  }
}
