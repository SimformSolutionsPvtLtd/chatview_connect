import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatview_models/flutter_chatview_models.dart';

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

  /// To get chat id from firestore collection path
  String? get chatId {
    final values = split('/');
    return values.length >= 2 ? values[1] : null;
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
  Query<Message?> toMessageQuery({
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
  }) {
    return toQuery(
      limit: limit,
      descending: sortOrder.isDesc,
      startAfterDocument: startAfterDocument,
      orderByFieldName: sortBy.isNone ? null : sortBy.key,
    );
  }
}

/// An extension on [CollectionReference] that provides a method
/// to create a query with sorting and optional pagination.
extension CollectionReferenceExtension<T> on CollectionReference<T> {
  /// Creates a query with sorting and optional pagination for fetching
  /// messages.
  ///
  /// **Parameters:**
  /// - (optional): [orderByFieldName] The field name to sort by. If `null`
  /// or empty, no sorting is applied.
  /// - (optional) [descending] Determines whether the sorting is in
  /// descending order. Defaults to `false` (ascending order).
  /// - (optional): [limit] Limits the number of messages retrieved.
  /// - (optional): [startAfterDocument] Starts fetching after the given
  /// document for pagination.
  ///
  /// Returns a [Query] with the applied filters.
  Query<T> toQuery({
    String? orderByFieldName,
    bool descending = false,
    int? limit,
    DocumentSnapshot<T>? startAfterDocument,
  }) {
    var collection = orderByFieldName == null || orderByFieldName.isEmpty
        ? this
        : orderBy(orderByFieldName, descending: descending);

    if (limit != null) collection = collection.limit(limit);

    if (startAfterDocument case final startAfterDocument?) {
      collection = collection.startAfterDocument(startAfterDocument);
    }

    return collection;
  }
}
