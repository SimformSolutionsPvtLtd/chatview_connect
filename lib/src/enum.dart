import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import 'database/database_service.dart';
import 'database/firebase/chatview_firestore_database.dart';
import 'storage/firebase/chatview_firebase_storage.dart';
import 'storage/storage_service.dart';
import 'typedefs.dart';

/// An enumeration of databases types.
enum ChatViewCloudService {
  /// Indicates a Firebase Database.
  firebase;

  /// Checks if the current database type is Firebase.
  bool get isFirebase => this == firebase;
}

/// A strongly-typed extension that provides structured access to database
/// and storage services based on the selected [ChatViewCloudService].
///
/// This type ensures that appropriate implementations of [DatabaseService]
/// and [StorageService] are used depending on the selected database type.
///
/// **Parameters:**
/// - [CloudServices]: Initializes with a specified [DatabaseService]
///   and [StorageService].
/// - [CloudServices.fromDataType]: Factory constructor that instantiates
///   the appropriate services based on the given [ChatViewCloudService].
///
/// **Getters:**
/// - [database]: Retrieves the database service instance.
/// - [storage]: Retrieves the storage service instance.
extension type const CloudServices._(CloudServicesRecord record) {
  /// Creates an instance of [CloudServices] with the given
  /// [DatabaseService] and [StorageService].
  const CloudServices({
    required DatabaseService database,
    required StorageService storage,
  }) : this._((database: database, storage: storage));

  /// Factory constructor that returns the appropriate implementation of
  /// [CloudServices] based on the provided [ChatViewCloudService].
  factory CloudServices.fromType(ChatViewCloudService type) {
    return switch (type) {
      ChatViewCloudService.firebase => CloudServices(
          database: ChatViewFireStoreDatabase(),
          storage: ChatViewFirebaseStorage(),
        ),
    };
  }

  /// The storage service instance associated with the selected database type.
  StorageService get storage => record.storage;

  /// The database service instance associated with the selected database type.
  DatabaseService get database => record.database;
}

/// An enumeration representing different sorting options for chats.
enum ChatSortBy {
  /// Sorts chats in descending order based on the latest message timestamp.
  newestFirst,

  /// No sorting is applied; chats are retrieved in their default order.
  none;

  /// Returns `true` if the sorting option is set to [newestFirst].
  bool get isNewestFirst => this == newestFirst;

  /// Returns `true` if no sorting is applied.
  bool get isNone => this == none;
}

/// Defines sorting options for messages.
///
/// This enumeration specifies the different ways messages can be sorted,
/// such as by creation time, last update time, or no sorting at all.
enum MessageSortBy {
  /// Sorts messages by their creation time (`createdAt`).
  createAt('createdAt'),

  /// Sorts messages by their last update time (`update_at`).
  updateAt('update_at'),

  /// No sorting is applied.
  none('');

  const MessageSortBy(this.key);

  /// An internal key associated with the sort type.
  /// It defines for the server by which field it will be sorted.
  final String key;

  /// Returns `true` if messages are sorted by creation time.
  bool get isCreateAt => this == createAt;

  /// Returns `true` if messages are sorted by update time.
  bool get isUpdateAt => this == updateAt;

  /// Returns `true` if no sorting is applied.
  bool get isNone => this == none;
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
/// converting Firebase [DocumentChangeType] values to
/// corresponding [DocumentType] values.
extension DocumentChangeTypeExtension on DocumentChangeType {
  /// Converts a [DocumentChangeType] from Firebase to
  /// the corresponding [DocumentType].
  ///
  /// This method maps Firebase document change types to application-specific
  /// document types.
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
enum UserActiveStatus {
  /// user is active
  online,

  /// user is inactive
  offline;

  /// is user inactive
  bool get isOnline => this == online;

  /// is user active
  bool get isOffline => this == offline;
}

/// Extension methods for [UserActiveStatus], providing utilities
/// for parsing and handling user status values.
extension UserActiveStatusExtension on UserActiveStatus {
  /// Parses a string value and returns the corresponding [UserActiveStatus].
  ///
  /// - If the [value] is `null` or empty,
  /// it defaults to [UserActiveStatus.offline].
  /// - If the [value] matches [UserActiveStatus.online.name]
  /// (case-insensitive), it returns [UserActiveStatus.online].
  /// - For all other cases, it defaults to [UserActiveStatus.offline].
  ///
  /// Example:
  /// ```dart
  /// final status = UserStatus.parse('online');
  /// print(status); // Output: UserStatus.online
  /// ```
  ///
  /// [value]: The input string to parse.
  /// Returns the corresponding [UserActiveStatus].
  static UserActiveStatus parse(String? value) {
    final safeValue = value?.trim().toLowerCase() ?? '';
    if (safeValue.isEmpty) return UserActiveStatus.offline;
    if (safeValue == UserActiveStatus.online.name) {
      return UserActiveStatus.online;
    } else {
      return UserActiveStatus.offline;
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

/// An enumeration representing different types of chat rooms.
enum ChatRoomType {
  /// A one-on-one private chat between two users.
  oneToOne,

  /// A group chat involving multiple users.
  group;

  /// Returns `true` if the chat room type is [oneToOne].
  bool get isOneToOne => this == oneToOne;

  /// Returns `true` if the chat room type is [group].
  bool get isGroup => this == group;
}

/// Provides utility methods for [ChatRoomTypeExtension].
extension ChatRoomTypeExtension on ChatRoomType {
  /// Parses a string value and returns the corresponding [ChatRoomType].
  ///
  /// Returns the corresponding [ChatRoomType] if the value matches,
  /// or `null` if it doesn't.
  static ChatRoomType? tryParse(String? value) {
    final safeValue = value?.trim().toLowerCase() ?? '';
    if (safeValue == ChatRoomType.oneToOne.name.toLowerCase()) {
      return ChatRoomType.oneToOne;
    } else if (safeValue == ChatRoomType.group.name.toLowerCase()) {
      return ChatRoomType.group;
    } else {
      return null;
    }
  }
}

/// Represents the different roles a user can have in the chat system.
enum Role {
  /// An admin has the highest level of control.
  /// They can manage users, delete messages, and moderate chatrooms.
  admin,

  /// A regular user who can participate in chat.
  /// They can send and receive messages but have no moderation privileges.
  user;

  /// Returns `true` if the user is an admin.
  bool get isAdmin => this == admin;

  /// Returns `true` if the user is a regular chat participant.
  bool get isUser => this == user;
}

/// Provides utility methods for [RoleExtension].
extension RoleExtension on Role {
  /// Parses a string value and returns the corresponding [Role].
  ///
  /// **Parameters:**
  /// (required): [value] The input string to parse.
  ///
  /// Returns the corresponding [Role] if the value matches.
  /// Defaults to [Role.admin] if the input is empty or doesn't match any role.
  static Role parse(String? value) {
    final type = value?.trim().toLowerCase() ?? '';
    if (type.isEmpty) return Role.admin;
    if (type == Role.admin.name.toLowerCase()) {
      return Role.admin;
    } else {
      return Role.user;
    }
  }
}

/// Represents the membership status of a user in a chat group.
enum MembershipStatus {
  /// The user is an active member of the group.
  member,

  /// The user has been removed from the group.
  removed,

  /// The user voluntarily left the group.
  left;

  /// Returns `true` if the user is an active member of the group.
  bool get isMember => this == member;

  /// Returns `true` if the user has been removed from the group.
  bool get isRemoved => this == removed;

  /// Returns `true` if the user has voluntarily left the group.
  bool get isLeft => this == left;
}

/// Provides utility methods for [MembershipStatusExtension].
extension MembershipStatusExtension on MembershipStatus {
  /// Parses a string value and returns the corresponding [MembershipStatus].
  ///
  /// **Parameters:**
  /// (required): [value] The input string to parse.
  ///
  /// Returns the corresponding [MembershipStatus] if the value matches.
  /// Defaults to [MembershipStatus.member] if the input is empty or doesn't
  /// match any status.
  static MembershipStatus parse(String? value) {
    final type = value?.trim().toLowerCase() ?? '';
    if (type.isEmpty) return MembershipStatus.member;
    if (type == MembershipStatus.removed.name.toLowerCase()) {
      return MembershipStatus.removed;
    } else if (type == MembershipStatus.left.name.toLowerCase()) {
      return MembershipStatus.left;
    } else {
      return MembershipStatus.member;
    }
  }
}

/// Defines the types of exceptions that can occur when interacting with
/// Cloud Firestore in Flutter.
enum FirestoreExceptionType {
  /// Represents a **not found** error,
  /// typically when a document or collection does not exist.
  notFound,

  /// Represents an **unknown** error type that is not explicitly handled.
  unknown,

  /// Represents a **permission denied** error,
  /// typically when a write operation is attempted but fails
  /// due to Firestore security rules restrictions.
  permissionDenied;
}

/// Provides an extension for converting Firestore error codes
/// into [FirestoreExceptionType] values.
extension FirestoreExceptionTypeExtension on FirestoreExceptionType {
  /// Converts a Firestore error code string into a corresponding
  /// [FirestoreExceptionType].
  ///
  /// Processes the input string by trimming, converting to lowercase, and
  /// mapping:
  /// - `not-found` to [FirestoreExceptionType.notFound].
  /// - `permission-denied` → [FirestoreExceptionType.permissionDenied].
  /// - Any other value to [FirestoreExceptionType.unknown].
  ///
  /// - (required): [value] The Firestore error code as a string.
  /// - Returns: A corresponding [FirestoreExceptionType] enum value.
  static FirestoreExceptionType fromCode(String? value) {
    final safeValue = value?.trim().toLowerCase() ?? '';
    if (safeValue == 'not-found') {
      return FirestoreExceptionType.notFound;
    } else if (safeValue == 'permission-denied') {
      return FirestoreExceptionType.permissionDenied;
    } else {
      return FirestoreExceptionType.unknown;
    }
  }
}
