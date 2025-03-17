import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import 'enum.dart';
import 'models/chat_room_user_dm.dart';
import 'typedefs.dart';

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

  /// Validates whether the given Firestore collection name is valid.
  ///
  /// A collection name is considered valid if:
  /// - It is not empty.
  /// - It does not contain a forward slash (`/`) or double slashes (`//`).
  ///
  /// Returns `true` if the collection name is valid, otherwise `false`.
  bool get isValidFirestoreCollectionName =>
      isNotEmpty && !contains('/') && !contains('//');

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
    return values.length >= 2 ? values.lastOrNull : null;
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
  /// - (optional): [whereFieldName] Specifies the field to apply a filtering
  /// condition.
  /// - (optional): [whereFieldIsGreaterThanOrEqualTo] Filters messages where
  /// [whereFieldName] is greater than or equal to this value.
  ///
  /// Returns a [Query] with the applied filters.
  Query<Message?> toMessageQuery({
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
    String? whereFieldName,
    Object? whereFieldIsGreaterThanOrEqualTo,
  }) {
    return toQuery(
      limit: limit,
      descending: sortOrder.isDesc,
      startAfterDocument: startAfterDocument,
      orderByFieldName: sortBy.isNone ? null : sortBy.key,
      whereFieldName: whereFieldName,
      whereFieldIsGreaterThanOrEqualTo: whereFieldIsGreaterThanOrEqualTo,
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
  /// - (optional): [orderByFieldName] The field name to sort by.
  /// If `null` or empty, no sorting is applied.
  /// - (optional): [descending] Determines whether sorting is in
  /// descending order.
  /// Defaults to `false` (ascending order).
  /// - (optional): [limit] Limits the number of documents retrieved.
  /// - (optional): [startAfterDocument] Starts fetching after the given
  /// document for pagination.
  /// - (optional): [whereFieldName] The field name to apply a filtering
  /// condition.
  /// - (optional): [whereFieldIsGreaterThanOrEqualTo] Filters results
  /// where [whereFieldName] is greater than or equal to this value.
  ///
  /// Returns a [Query] with the applied filters.
  Query<T> toQuery({
    String? orderByFieldName,
    bool descending = false,
    int? limit,
    DocumentSnapshot<T>? startAfterDocument,
    String? whereFieldName,
    Object? whereFieldIsGreaterThanOrEqualTo,
  }) {
    var collection = orderByFieldName == null || orderByFieldName.isEmpty
        ? this
        : orderBy(orderByFieldName, descending: descending);

    if (whereFieldName != null && whereFieldIsGreaterThanOrEqualTo != null) {
      collection = collection.where(
        whereFieldName,
        isGreaterThanOrEqualTo: whereFieldIsGreaterThanOrEqualTo,
      );
    }

    if (limit != null) collection = collection.limit(limit);

    if (startAfterDocument case final startAfterDocument?) {
      collection = collection.startAfterDocument(startAfterDocument);
    }

    return collection;
  }
}

/// An extension on [DateTime] to provide a safe comparison method.
extension DateTimeCompareExtension on DateTime? {
  /// Checks if [lastMessageTimestamp] is before the current
  /// DateTime instance.
  ///
  /// Returns `false` if the current DateTime is `null`.
  bool isMessageBeforeMembership(DateTime? lastMessageTimestamp) {
    final dateTime = this;
    return dateTime != null && lastMessageTimestamp?.compareTo(dateTime) == -1;
  }

  /// Compares two nullable [DateTime] objects.
  ///
  /// - Returns `0` if both are `null`.
  /// - Returns `-1` if `this` is `null` and `b` is not.
  /// - Returns `1` if `b` is `null` and `this` is not.
  /// - Otherwise, delegates to [DateTime.compareTo].
  int compareTimestamp(DateTime? b) {
    final a = this;
    if (a == null && b == null) {
      return 0;
    } else if (a == null) {
      return -1;
    } else if (b == null) {
      return 1;
    } else {
      return a.compareTo(b);
    }
  }
}

/// An extension on `List<ChatRoomUserDm>` to join user names into
/// a single string.
///
/// Converts the list of chat room users into a string with names separated
/// by a specified separator.
///
/// Returns `null` if the list is empty or contains only users with empty names.
extension ListOfChatRoomUserDmExtension on List<ChatRoomUserDm> {
  /// Joins user names with a specified separator.
  ///
  /// - (optional): [separator] The string to separate names
  /// (default is `' '`).
  String? toJoinString([String separator = ' ']) {
    if (isEmpty) return null;
    final valueLength = length;
    final lastIndex = valueLength - 1;
    final stringBuffer = StringBuffer();
    for (var i = 0; i < valueLength; i++) {
      final user = this[i];
      final username = user.chatUser?.name ?? '';
      if (username.isEmpty) continue;
      stringBuffer.write(i == lastIndex ? username : '$username$separator');
    }
    return stringBuffer.toString();
  }
}

/// An extension on `List<ChatUser>` to join user names into a single string.
///
/// Converts the list of users into a string with names separated by
/// a specified separator.
///
/// Returns `null` if the list is empty or contains only users with empty names.
extension ListOfChatUserDmExtension on List<ChatUser> {
  /// Joins user names with a specified separator.
  ///
  /// - (optional): [separator] The string to separate names
  /// (default is `' '`).
  String? toJoinString([String separator = ' ']) {
    if (isEmpty) return null;
    final valueLength = length;
    final lastIndex = valueLength - 1;
    final stringBuffer = StringBuffer();
    for (var i = 0; i < valueLength; i++) {
      final user = this[i];
      final username = user.name;
      if (username.isEmpty) continue;
      stringBuffer.write(i == lastIndex ? username : '$username$separator');
    }
    return stringBuffer.toString();
  }

  /// Generates a [GroupInfoRecord] by constructing a group name from
  /// participant names and assigning them roles.
  ///
  /// This method iterates through the list of users, concatenates their names
  /// to form the group name, and assigns each user the role of [Role.admin].
  ///
  /// **Returns:**
  /// A [GroupInfoRecord] containing:
  /// - `groupName`: A comma-separated list of participant names.
  /// - `participants`: A map associating user IDs with their roles.
  GroupInfoRecord getGroupInfo() {
    final groupNameBuffer = StringBuffer();
    final usersLength = length;
    final lastLength = usersLength - 1;
    final participants = <String, Role>{};
    for (var i = 0; i < usersLength; i++) {
      final user = this[i];
      final userName = user.name;
      groupNameBuffer.write(i == lastLength ? userName : '$userName, ');
      participants[user.id] = Role.admin;
    }
    return (
      groupName: groupNameBuffer.toString(),
      participants: participants,
    );
  }
}

/// A collection of utility extensions for the `DateTime` class.
/// Provides convenient methods for checking relative dates comparisons.
extension DateTimeExtension on DateTime {
  /// Checks if the current `DateTime` instance represents
  /// the same date and time (up to the minute) as now.
  bool get isNow {
    final providedDateTime = DateTime(year, month, day, hour, minute);
    final now = DateTime.now();
    final nowDateTime =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);
    return providedDateTime.compareTo(nowDateTime) == 0;
  }
}

/// Extension on [Message] to provide utility methods for
/// comparing message creation timestamps.
extension MessageExtension on Message? {
  /// Compares the creation time of this message with another message.
  ///
  /// Returns:
  /// - `0` if both messages have the same timestamp or are null.
  /// - `-1` if this message is null (considered earlier).
  /// - `1` if the other message is null (considered later).
  /// - A positive or negative integer based on the natural ordering
  /// of timestamps.
  int compareCreateAt(Message? message) {
    final a = this?.createdAt;
    final b = message?.createdAt;
    if (a == null && b == null) {
      return 0;
    } else if (a == null) {
      return -1;
    } else if (b == null) {
      return 1;
    } else {
      return a.compareTo(b);
    }
  }
}
