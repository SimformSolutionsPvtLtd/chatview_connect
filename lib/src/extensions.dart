import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'enum.dart';

/// Extension methods for the `String` class.
extension StringExtension on String {
  /// To get image's directory path from the Firebase's Download URL
  String? get fullPath {
    return split('o/')
        .lastOrNull
        ?.split('?')
        .firstOrNull
        ?.replaceAll('%2F', '/');
  }

  /// Determines whether this string represents a valid Firestore document path.
  ///
  /// A valid Firestore document path:
  /// - Is non-empty.
  /// - Does not contain consecutive slashes (`//`).
  /// - Has an even number of path segments when split by `/`
  /// (Firestore document paths always have an even number of segments).
  ///
  /// Returns `true` if this string is a valid Firestore document path,
  /// otherwise `false`.
  bool get isValidFirestoreDocument {
    final isNotEmptyWithNoDoubleSlash = isNotEmpty && !contains('//');

    if (!isNotEmptyWithNoDoubleSlash) return false;

    final values = split('/');
    final valuesLength = values.length;
    var numberOfValues = 0;
    for (var i = 0; i < valuesLength; i++) {
      if (values[i].isEmpty) continue;
      numberOfValues++;
    }
    return numberOfValues.isEven;
  }
}

/// An extension on [CollectionReference] for [Message] that
/// provides a method to create a query with sorting and pagination.
extension MessageCollectionReferenceExtension on CollectionReference<Message?> {
  /// Creates a query with sorting and optional pagination for fetching
  /// messages.
  ///
  /// **Parameters:**
  /// - (required): [sortBy] Specifies the field to sort messages by.
  /// - (required): [sortOrder] Determines whether the sorting is ascending or
  /// descending.
  /// - (optional): [limit] Limits the number of messages retrieved.
  /// - (optional): [startAfterDocument] Starts fetching after the given
  /// document for pagination.
  ///
  /// Returns a [Query] with the applied filters.
  Query<Message?> toQuery({
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
  }) {
    final messageCollectionRef = this;

    var messageCollection = switch (sortBy) {
      MessageSortBy.dateTime => messageCollectionRef.orderBy(
          sortBy.key,
          descending: sortOrder.isDesc,
        ),
      MessageSortBy.none => messageCollectionRef,
    };

    if (limit != null) messageCollection = messageCollection.limit(limit);

    if (startAfterDocument case final startAfterDocument?) {
      messageCollection =
          messageCollection.startAfterDocument(startAfterDocument);
    }

    return messageCollection;
  }
}
