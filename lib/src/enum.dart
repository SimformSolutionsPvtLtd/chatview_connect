import 'package:cloud_firestore/cloud_firestore.dart';

/// An enumeration of databases types.
enum ChatViewDatabaseType {
  /// Indicates a Firebase Database.
  firebase;

  /// Checks if the current database type is Firebase.
  bool get isFirebase => this == firebase;
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
