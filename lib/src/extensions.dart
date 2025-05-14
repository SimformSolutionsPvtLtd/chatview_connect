import 'package:chatview_utils/chatview_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'enum.dart';
import 'models/chat_room.dart';
import 'models/chat_room_participant.dart';
import 'typedefs.dart';

/// Extension methods for the `String` class.
extension StringExtension on String {
  /// To get image's directory path from the Firebase's Download URL
  String? get firebaseStorageDocumentPath {
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
  bool get isValidFirestoreDocumentName {
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

/// Extension methods for nullable [DateTime] objects.
///
/// Provides utility methods for comparing nullable [DateTime] instances.
extension NullableDateTimeExtension on DateTime? {
  /// Checks if [lastMessageTimestamp] is before the current
  /// DateTime instance.
  ///
  /// Returns `false` if the current DateTime is `null`.
  bool isMessageBeforeMembership(DateTime? lastMessageTimestamp) {
    final dateTime = this;
    return dateTime != null && lastMessageTimestamp?.compareTo(dateTime) == -1;
  }

  /// Compares this nullable [DateTime] with another nullable [other].
  ///
  /// Returns:
  /// - `0` if both dates are null or occur at the same moment.
  /// - A negative value if this date is null (considered earlier)
  /// or occurs before [other].
  /// - A positive value if [other] is null (considered later)
  /// or occurs after this date.
  int compareWith(DateTime? other) {
    final a = this;
    final b = other;
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

/// An extension on `List<ChatRoomParticipant>` to join user names into
/// a single string.
///
/// Converts the list of chat room users into a string with names separated
/// by a specified separator.
///
/// Returns `null` if the list is empty or contains only users with empty names.
extension ListOfChatRoomParticipantExtension on List<ChatRoomParticipant> {
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
  GroupInfoRecord createGroupInfo() {
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
extension NullablMessageExtension on Message? {
  /// Compares the creation timestamp of this message with another message.
  ///
  /// Returns:
  /// - `0` if both creation timestamps are null or occur at the same moment.
  /// - A negative value if this message's timestamp is null
  /// (considered earlier) or occurs before the other message's timestamp.
  /// - A positive value if the other message's timestamp is null
  /// (considered later) or occurs after this message's timestamp.
  int compareCreateAt(Message? message) {
    final dateTime = this?.createdAt;
    return dateTime.compareWith(message?.createdAt);
  }

  /// Compares the update timestamp of this message with another message.
  ///
  /// Returns:
  /// - `0` if both update timestamps are null or occur at the same moment.
  /// - A negative value if this message's update timestamp is null
  /// (considered earlier) or occurs before the other message's
  /// update timestamp.
  /// - A positive value if the other message's update timestamp is null
  /// (considered later) or occurs after this message's update timestamp.
  int compareUpdateAt(Message? message) {
    final dateTime = this?.updateAt;
    return dateTime.compareWith(message?.updateAt);
  }
}

/// Extension methods for lists of nullable [ChatRoom] objects.
///
/// Provides utility methods to filter out null values and
/// work with only non-null chat rooms.
extension ChatRoomsListExtension on List<ChatRoom?> {
  /// Returns a new list containing only non-null [ChatRoom] objects.
  ///
  /// This method filters out any `null` values from the list, ensuring that
  /// operations on the resulting list can be performed without null checks.
  List<ChatRoom> get toNonEmpty {
    final chatsLength = length;
    return [
      for (var i = 0; i < chatsLength; i++)
        if (this[i] case final chat?) chat,
    ];
  }
}
