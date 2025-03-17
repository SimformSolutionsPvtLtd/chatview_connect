import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import 'database/database_service.dart';
import 'enum.dart';
import 'models/chat_room_user_dm.dart';
import 'storage/storage_service.dart';

/// Callback function used for updating reactions.
/// - (optional): `userId` specifies id of the user who performed the reaction.
///
/// - (optional): `emoji` specifies emoji that user has used.
typedef UserReactionCallback = ({String userId, String emoji});

/// Record for storing database type wise services in single variable
typedef DatabaseTypeServicesRecord = ({
  DatabaseService database,
  StorageService storage,
});

/// Callback function for uploading document to cloud storage.
typedef UploadDocumentCallback = Future<String?> Function(
  Message message, {
  String? uploadPath,
  String? fileName,
});

/// Callback function for deleting document from storage.
typedef DeleteDocumentCallback = Future<bool> Function(Message message);

/// Callback function for deleting all documents of specific [chatId] from
/// storage.
typedef DeleteChatMediaFromStorageCallback = Future<bool> Function(
  String chatId,
);

/// Represents a record of chat room participants,
/// including the current user and other users in the chat.
///
/// **Fields:**
/// - (optional) `currentUser` The current user participating in the chat room.
/// If `null`, the user may not be a member.
/// - (required) `otherUsers` A list of other users in the chat room excluding
/// the current user.
typedef ChatRoomParticipantsRecord = ({
  ChatRoomUserDm? currentUser,
  List<ChatRoomUserDm> otherUsers,
});

/// A record type representing a user's information along with their status.
///
/// The [UserInfoWithStatusRecord] type contains:
/// - [user]: An optional [ChatUser] instance representing the user's details.
/// - [userActiveStatus]: An optional [UserActiveStatus] indicating the user's online/offline status.
typedef UserInfoWithStatusRecord = ({
  ChatUser? user,
  UserActiveStatus? userActiveStatus,
});

/// Represents information about a group, including its name and participants.
///
/// **Fields:**
/// - (required): `groupName` A string representing the name of the group,
/// generated based on participants' names.
/// - (required): `participants` A map of user IDs to their assigned [Role] in
/// the group.
typedef GroupInfoRecord = ({String groupName, Map<String, Role> participants});
