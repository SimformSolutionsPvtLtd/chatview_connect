import 'package:chatview_utils/chatview_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'database/database_service.dart';
import 'enum.dart';
import 'models/chat_room_participant.dart';
import 'storage/storage_service.dart';

/// Callback function used for updating reactions.
/// **Parameters:**
/// - (optional): `userId` specifies id of the user who performed the reaction.
/// - (optional): `emoji` specifies emoji that user has used.
typedef ReactionCallback = ({String userId, String emoji});

/// A record that encapsulates cloud-based services, including database and
/// storage. This allows managing both services within a single variable.
typedef CloudServicesRecord = ({
  DatabaseService database,
  StorageService storage,
});

/// A callback function for uploading a media to cloud storage.
/// Returns the download URL as a [String] or `null` if the upload fails.
typedef UploadMediaCallback = Future<String?> Function(
  Message message, {
  String? uploadPath,
  String? fileName,
});

/// A callback function for deleting a specific media from storage.
/// Returns `true` if the deletion is successful, otherwise `false`.
typedef DeleteMediaCallback = Future<bool> Function(Message message);

/// A callback function for deleting all media associated with a specific
/// [chatId] from storage.
/// Returns `true` if the operation is successful, otherwise `false`.
typedef DeleteChatMediaCallback = Future<bool> Function(String chatId);

/// Represents a record of chat room participants,
/// including the current user and other users in the chat.
///
/// **Parameters:**
/// - (optional): `currentUser` The current user participating in the chat room.
/// If `null`, the user may not be a member.
/// - (required): `otherUsers` A list of other users in the chat room excluding
/// the current user.
typedef ChatRoomParticipantsRecord = ({
  ChatRoomParticipant? currentUser,
  List<ChatRoomParticipant> otherUsers,
});

/// A record type representing a user's information along with their status.
///
/// **Parameters:**
/// - (optional): `user` [ChatUser] instance representing the user's details.
/// - (optional): `userActiveStatus` [UserActiveStatus] indicating the user's online/offline status.
typedef UserInfoWithStatusRecord = ({
  ChatUser? user,
  UserActiveStatus? userActiveStatus,
});

/// Represents information about a group, including its name and participants.
///
/// **Parameters:**
/// - (required): `groupName` A string representing the name of the group,
/// generated based on participants' names.
/// - (required): `participants` A map of user IDs to their assigned [Role] in
/// the group.
typedef GroupInfoRecord = ({String groupName, Map<String, Role> participants});

/// Maps a [QuerySnapshot] of [Message] objects to a custom type [T].
///
/// Useful for transforming Firestore query results into
/// your desired data structure.
typedef MessageQueryMapper<T> = T Function(QuerySnapshot<Message?> docSnapshot);

/// A callback function that extracts a chat room ID from a given snapshot.
///
/// **Parameters:**
/// - (required): `snapshot` The snapshot object of type [T] from which to extract
/// the chat room ID.
typedef ChatRoomIdCallback<T> = String Function(T snapshot);

/// A callback function for filtering operations.
/// Returns `true` if the object meets the specified condition, otherwise `false`.
///
/// **Parameters:**
/// - (required): `item` The object of type [T] to be evaluated against the filter criteria.
typedef WhereCallback<T> = bool Function(T item);

/// A record type representing a chat item along with its associated status.
///
/// **Parameters:**
/// - (required): `chat` [ChatViewListItem] instance representing the chat details
/// - (required): `status` A generic type [T] representing the status associated with the chat.
typedef ChatStatusRecord<T> = ({ChatViewListItem chat, T status});
