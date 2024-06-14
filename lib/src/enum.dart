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

  /// Maps a [DocumentChangeType] from Firebase to a [DocumentType].
  static DocumentType firebaseType(DocumentChangeType type) {
    return switch (type) {
      DocumentChangeType.added => added,
      DocumentChangeType.modified => modified,
      DocumentChangeType.removed => removed,
    };
  }
}
