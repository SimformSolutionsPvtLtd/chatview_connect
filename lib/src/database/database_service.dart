import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import '../enum.dart';
import '../models/chat_room.dart';
import '../models/chat_room_display_metadata.dart';
import '../models/chat_room_metadata.dart';
import '../models/chat_room_participant.dart';
import '../models/config/message_ops_config.dart';
import '../models/message_dm.dart';
import '../typedefs.dart';

/// Defined different methods to interact with a cloud database.
abstract interface class DatabaseService {
  const DatabaseService._();

  /// Asynchronously fetches messages and returns [List] of [MessageDm].
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry fetching messages
  ///   in case of a failure.
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Used to fetch messages associated with a specific chat session.
  ///
  /// - (required): [sortBy] specifies the sorting order of messages
  /// by defaults it will be sorted by the dateTime.
  ///
  /// - (required): [sortOrder] specifies the order of sorting for messages.
  /// by defaults it will be ascending sort order.
  ///
  /// - (optional): [limit] specifies the limit of the messages to be retrieved.
  /// by defaults it will retrieve the all messages if not specified.
  ///
  /// - (optional): [startAfterDocument] specifies the message document snapshot
  /// if you want to retrieve message after the that.
  Future<List<MessageDm>> getMessages({
    required int retry,
    required String chatId,
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
  });

  /// Retrieves a stream of message batches from database with
  /// document snapshot. This method listens for real-time updates to
  /// the message's data in the database.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Determines the chat session for which messages will be streamed.
  ///
  /// - (required): [sortBy] specifies the sorting order of messages
  /// by defaults it will be sorted by the dateTime.
  ///
  /// - (required): [sortOrder] specifies the order of sorting for messages.
  /// by defaults it will be ascending sort order.
  ///
  /// - (optional): [limit] specifies the limit of the messages to be retrieved.
  /// by defaults it will retrieve the all messages if not specified.
  ///
  /// - (optional): [startAfterDocument] specifies the message document snapshot
  /// if you want to retrieve message after the that.
  ///
  /// - (optional): [from] specifies a starting date-time to fetch
  /// messages from. If provided, only messages after this timestamp will be
  /// included.
  Stream<List<MessageDm>> getMessagesStreamWithSnapshot({
    required String chatId,
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
    DateTime? from,
  });

  /// Retrieves a stream of message batches from database.
  /// This method listens for real-time updates to the chat room message's
  /// data in the database.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Used to stream messages for the specified chat session in real time.
  ///
  /// - (required): [sortBy] specifies the sorting order of messages
  /// by defaults it will be sorted by the dateTime.
  ///
  /// - (required): [sortOrder] specifies the order of sorting for messages.
  /// by defaults it will be ascending sort order.
  ///
  /// - (optional): [limit] specifies the limit of the messages to be retrieved.
  /// by defaults it will retrieve the all messages if not specified.
  ///
  /// - (optional): [startAfterDocument] specifies the message document snapshot
  /// if you want to retrieve message after the that.
  ///
  /// - (optional): [from] specifies a starting date-time to fetch
  /// messages from. If provided, only messages after this timestamp will be
  /// included.
  Stream<List<Message>> getMessagesStream({
    required String chatId,
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
    DateTime? from,
  });

  /// Retrieves a stream of users batches from database.
  /// This method listens for real-time updates to the user's data in
  /// the database.
  ///
  /// **Parameters:**
  /// - (optional): [limit] specifies the limit of the users to be retrieved.
  /// by defaults it will retrieve the all users if not specified.
  Stream<List<ChatUser>> getUsersStream({int? limit});

  /// Retrieves a list of users batches from database.
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry fetching users
  ///   in case of a failure.
  /// - (optional): [limit] specifies the limit of the users to be retrieved.
  /// by defaults it will retrieve the all users if not specified.
  Future<List<ChatUser>> getUsers({required int retry, int? limit});

  /// Retrieves a stream of a particular user based on the provided user ID.
  /// This method listens for real-time updates to the user's data in
  /// the database.
  ///
  /// **Parameters:**
  /// - (required): [userId] The ID of the user whose data is being retrieved.
  Stream<ChatUser?> getUserStreamById(String userId);

  /// Retrieves a stream of chat room users batches from the database.
  ///
  /// In this it will listens for real-time updates to the chat room users'
  /// data such as **userStatus** and **typingStatus**, along with
  /// user information like **profile details**.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Used to stream the list of participants in the specified chat room.
  ///
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  ///
  /// - (optional): [limit] Specifies the maximum number of users to retrieve.
  ///   If not provided, all users will be retrieved.
  ///
  /// **Returns:** A [Stream] that emits a [List] of [ChatRoomParticipant]
  /// instances.
  Stream<List<ChatRoomParticipant>> getChatRoomParticipantsStream({
    required String userId,
    required String chatId,
    int? limit,
  });

  /// Returns a stream of chat room users (excluding the current user)
  /// from the database.
  ///
  /// This method listens for real-time updates to chat room users' data but
  /// does **not** fetch detailed user information.
  ///
  /// Each user is represented by [ChatRoomParticipant], which includes their
  /// **userStatus** and **typingStatus**.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Used to stream metadata of users in the specified chat room.
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (required): [observeUserInfoChanges] determines whether the stream
  /// should track changes to user metadata, such as username
  /// and profile picture updates.
  ///   - If `true`, user metadata will be tracked and updated in real-time.
  ///   - If `false`, user data will be fetched only once without tracking
  ///   updates.
  /// - (optional): [limit] Specifies the maximum number of chat room users
  /// to retrieve. If not provided, all users will be retrieved.
  ///
  /// **Returns:** A [Stream] that emits a [Map] of user IDs
  /// to [ChatRoomParticipant] instances.
  Stream<Map<String, ChatRoomParticipant>> getChatRoomUsersMetadataStream({
    required String chatId,
    required String userId,
    required bool observeUserInfoChanges,
    int? limit,
  });

  /// Retrieves a stream of unread messages count for the given chat room.
  /// This method listens for real-time updates to the unread message count.
  ///
  /// A message is considered unread if:
  /// - It was not sent by the current user.
  /// - Its status is not marked as read.
  ///
  /// **Parameters:**
  ///
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Used to fetch the count of unread messages for the specified chat session.
  ///
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  ///
  /// - (optional): [from] Specifies a starting date-time
  /// to count unread messages from. If provided, only messages after this
  /// timestamp will be considered.
  Stream<int> getUnreadMessagesCount({
    required String chatId,
    required String userId,
    DateTime? from,
  });

  /// Retrieves the current user and a list of users in the chat room from the
  /// database.
  /// This method fetches the participants of the chat room, including the
  /// current user.
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry fetching participants
  ///   in case of a failure.
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Used to retrieve the participants of the specified chat room.
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  ///
  /// Returns [ChatRoomMetadata] object containing the chat room
  /// participants.
  Future<ChatRoomMetadata?> getChatRoomMetadata({
    required int retry,
    required String chatId,
    required String userId,
  });

  /// Retrieves a stream of messages along with their associated operation
  /// types.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Used to stream messages along with their operation types in the specified
  /// chat room.
  ///
  /// - (required): [sortBy] specifies the sorting order of messages
  /// by defaults it will be sorted by the dateTime.
  ///
  /// - (required): [sortOrder] specifies the order of sorting for messages.
  /// by defaults it will be ascending sort order.
  ///
  /// - (optional): [limit] specifies the limit of the messages to be retrieved.
  /// by defaults it will retrieve the all messages if not specified.
  Stream<Map<Message, DocumentType>> getMessagesStreamWithOperationType({
    required String chatId,
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
  });

  /// Asynchronously adds a new message and returns nullable [Message].
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry adding the message
  ///   in case of a failure.
  /// - (required): [chatId]  A unique identifier for the chat room.
  /// Specifies the chat room where the message will be added.
  /// - (required): [message] specifies the [Message] to be add on database.
  /// - (required): [useAutoGeneratedId] determines whether to use
  /// the database-generated ID or the predefined message ID.
  /// If set to `true`, a database-generated ID will be used;
  /// otherwise, the predefined message ID will be applied.
  ///
  /// - (required): [messageOpsConfig]
  /// {@macro flutter_chatview_db_connection.MessageOpsConfig}
  Future<Message?> addMessage({
    required int retry,
    required String chatId,
    required Message message,
    required bool useAutoGeneratedId,
    required MessageOpsConfig messageOpsConfig,
  });

  /// Asynchronously delete a message and returns [bool] value.
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry deleting the message
  ///   in case of a failure.
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Specifies the chat room from which the message will be deleted.
  /// - (required): [message] specifies the [Message] to be delete
  /// from database.
  /// - (required): [messageConfig]
  /// {@macro flutter_chatview_db_connection.MessageOpsConfig}
  Future<bool> deleteMessage({
    required int retry,
    required String chatId,
    required Message message,
    required MessageOpsConfig messageConfig,
  });

  /// Asynchronously update a message.
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry updating the message
  ///   in case of a failure.
  /// - (required): [chatId]  A unique identifier for the chat room.
  /// Specifies the chat room where the message will be updated.
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (required): [message] specifies the [Message] to be update on database.
  /// - (optional): [status] specifies the [MessageStatus]
  /// to update the status of message.
  /// if the value is not provided then [status] will not update.
  /// - (optional): [reaction] specifies the [ReactionCallback]
  /// to update the reaction of particular user.
  /// if the value is not provided then [reaction] will not update.
  Future<void> updateMessage({
    required int retry,
    required String userId,
    required String chatId,
    required Message message,
    MessageStatus? status,
    ReactionCallback? reaction,
  });

  /// Updates the chat room user with the provided typing status, or
  /// membership status.
  ///
  /// **Note:** If [chatRoomUserData] is provided, it is used to
  /// update the document data; otherwise, individual parameters are used.
  ///
  /// If [userId] is not specified, the current user's ID is used.
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry updating the metadata
  ///   in case of a failure.
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Specifies the chat room where the user's metadata will be updated.
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (optional): [typingStatus] The current typing status of the user
  /// (e.g., `typing`, `typed`).
  /// - (optional): [membershipStatus] The user's membership status in the
  /// chat room (e.g., `member`, `removed`, `left`).
  /// - (optional): [chatRoomUserData] A map containing user data updates.
  ///   If provided, this data is used to update the document instead of the
  ///   other individual parameters.
  /// - (optional): [ifDataNotFound] A callback function that returns a
  ///   [ChatRoomParticipant] object. This is used when no data exists in the
  ///   backend to create an initial object for the user.
  Future<void> updateChatRoomUserMetadata({
    required int retry,
    required String chatId,
    required String userId,
    TypeWriterStatus? typingStatus,
    MembershipStatus? membershipStatus,
    Map<String, dynamic>? chatRoomUserData,
    ValueGetter<ChatRoomParticipant>? ifDataNotFound,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.updateUserActiveStatus}
  /// Updates the current user document with the current user status.
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry updating the user
  ///   status in case of a failure.
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (required): [userStatus] The current status of the user (online/offline).
  /// {@endtemplate}
  Future<bool> updateUserActiveStatus({
    required int retry,
    required String userId,
    required UserActiveStatus userStatus,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.getChatsStream}
  /// Returns a stream of chat rooms,
  /// each containing a list of users (excluding the current user).
  ///
  /// **Parameters:**
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (required): [sortBy] determines the order in which chat rooms are
  /// retrieved:
  ///   - [ChatSortBy.newestFirst] sorts chat rooms in descending order
  ///  based on the timestamp of the latest message.
  ///   - [ChatSortBy.none] retrieves chat rooms in their default order
  ///  without applying any sorting.
  ///
  /// - (required): [includeEmptyChats] determines whether to include
  /// chat rooms that have no messages.
  ///   - If `true`, one-to-one chats that have been created but contain
  /// no messages will be included in the list.
  ///   - If `false`, such empty chats will be excluded.
  ///
  /// - (required): [includeUnreadMessagesCount] determines whether the stream
  /// will listen for unread message count updates.
  ///   - If `true`, it will continuously listen and update the count.
  ///   - If `false`, it will not listen, and `unreadMessagesCount`
  ///   will always be `0`.
  ///
  /// - (optional): [limit] specifies the maximum number of chat rooms to
  /// retrieve. If not specified, all chat rooms will be retrieved by default.
  ///
  ///
  /// Each event in the stream emits a list of chat rooms, where:
  /// - Each chat room (e.g., `chat1`, `chat2`) is represented
  /// as a [ChatRoom] instances.
  /// - The list of users in each chat room **does not**
  /// include the current user.
  ///
  /// The stream dynamically updates to reflect changes in chat room users,
  /// such as:
  /// - Online/offline status updates
  /// - Typing activity
  ///
  /// {@endtemplate}
  Stream<List<ChatRoom>> getChatsStream({
    required String userId,
    required ChatSortBy sortBy,
    required bool includeEmptyChats,
    required bool includeUnreadMessagesCount,
    int? limit,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.createOneToOneChat}
  /// Creates a one-to-one chat with the specified user.
  ///
  /// **Parameters:**
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (required): [otherUserId] The unique identifier of the user to
  /// create a chat with.
  /// - (optional): [chatRoomId] The unique identifier of the
  /// chat room to use when creating chat document, if specified.
  ///
  /// If a chat with the given [otherUserId] already exists,
  /// the existing chat ID is returned.
  /// Otherwise, a new chat is created, and its ID is returned upon success.
  ///
  /// If [chatRoomId] is provided, it will be used when creating the
  /// chat document. Otherwise, a newly generated unique ID will be
  /// assigned.
  ///
  /// Returns `null` if the chat creation fails.
  /// {@endtemplate}
  Future<String?> createOneToOneChat({
    required String userId,
    required String otherUserId,
    String? chatRoomId,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.createGroupChat}
  /// Creates a new group chat with the specified details.
  ///
  /// **Parameters:**
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (required): [groupName] The name of the group chat.
  /// - (required): [participants] A map of user IDs to their assigned roles
  /// in the group chat. The current user is automatically added.
  /// - (optional): [groupProfilePic] The profile picture of the group chat.
  /// If not provided, the group will not have a profile picture.
  /// - (optional): [chatRoomId] A unique identifier for the chat room.
  /// If specified, it will be used when creating the chat document;
  /// otherwise, a new unique ID will be generated.
  ///
  /// **Behavior:**
  /// - This method initializes a new group chat with the given participants,
  ///   group name, and optional profile picture.
  /// - If [chatRoomId] is provided, it is used;
  /// otherwise, a new unique ID is assigned.
  ///
  /// Returns a ID of the newly created group chat.
  /// If the creation fails, `null` is returned.
  /// {@endtemplate}
  Future<String?> createGroupChat({
    required String userId,
    required String groupName,
    required Map<String, Role> participants,
    String? groupProfilePic,
    String? chatRoomId,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.updateGroupChat}
  /// Updates an existing group chat.
  ///
  /// This method allows updating the group chat's name and profile picture.
  ///
  /// **Parameters:**
  /// - (required) [retry]: The number of times to retry updating the
  ///   group chat in case of a failure.
  /// - (required): [chatId] A unique identifier for the group chat.
  /// Specifies the group chat that will be updated.
  /// - (optional): [groupName] is the new name for the group chat.
  /// If `null`, the group name will not be updated.
  /// - (optional): [groupProfilePic] is the new profile picture for the
  /// group chat. If `null`, the profile picture will not be updated.
  ///
  /// Returns a true/false indicating whether the update was successful (`true`) or failed (`false`).
  /// {@endtemplate}
  Future<bool> updateGroupChat({
    required int retry,
    required String chatId,
    String? groupName,
    String? groupProfilePic,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.addUserInGroup}
  /// Adds a user to the group chat with a specified role.
  /// This method updates the group's membership list and assigns the user
  /// a role.
  ///
  /// **Message Visibility:**
  /// - If [includeAllChatHistory] is `true`, the user will have access to
  ///   all previous messages in the group chat.
  /// - If [includeAllChatHistory] is `false`, the user will only see messages
  ///   from the point they are added onward.
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry the operation
  ///   in case of failure.
  /// - (required): [chatId] A unique identifier for the group chat.
  /// Specifies the group chat where the user will be added.
  /// - (required): [userId] The unique identifier of the user to be added.
  /// - (required): [role] The role assigned to the user in the group chat.
  /// - (required): [includeAllChatHistory]  Determines whether the user
  ///   should have access to all previous chat history in the group.
  /// - (optional): [startDate] The date from which the user should have access
  ///   to chat history. This is applicable whether [includeAllChatHistory] is
  ///   set to `true` or `false`.
  ///
  /// Returns a [Future] that resolves to `true` if the user was successfully
  /// added, otherwise `false`.
  /// {@endtemplate}
  Future<bool> addUserInGroup({
    required int retry,
    required String chatId,
    required String userId,
    required Role role,
    required bool includeAllChatHistory,
    DateTime? startDate,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.removeUserFromGroup}
  /// Removes a user from the group chat and updates their membership status.
  /// This method marks the user as removed but does not delete their
  /// past messages.
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry the operation
  ///   in case of failure.
  /// - (required): [chatId]  A unique identifier for the group chat.
  /// Specifies the group chat from which the user will be removed.
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (required): [removeUserId] The unique identifier of the user to
  ///   be removed.
  /// - (required): [deleteGroupIfSingleUser] Whether to delete the group
  ///   if the removed user was the last member.
  /// - (required): [deleteChatMedia] A callback function
  ///   to delete chat-related documents from storage.
  ///
  /// If the group has only one remaining user and [deleteGroupIfSingleUser]
  /// is `true`, the group will be deleted along with its chat-related
  /// documents.
  ///
  /// Returns a [Future] that resolves to `true` if the user was successfully
  /// removed, otherwise `false`.
  /// {@endtemplate}
  Future<bool> removeUserFromGroup({
    required int retry,
    required String chatId,
    required String userId,
    required String removeUserId,
    required bool deleteGroupIfSingleUser,
    required DeleteChatMediaCallback deleteChatMedia,
  });

  /// Retrieves a stream of [ChatRoomDisplayMetadata] for the specified
  /// chat room.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the group chat.
  /// Specifies the group chat whose metadata will be streamed.
  ///
  /// **Returns:**
  /// A [Stream] of [ChatRoomDisplayMetadata].
  /// Returns `null` if the chat is a one-to-one chat, as metadata is
  /// only applicable for group chats.
  Stream<ChatRoomDisplayMetadata> getGroupChatDisplayMetadataStream(
    String chatId,
  );

  /// Checks if a one-to-one chat exists with the specified user.
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of times to retry the operation
  ///   in case of failure.
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (required): [otherUserId] The unique identifier of the user
  /// to check for an existing chat.
  ///
  /// Returns the chat room ID if a chat already exists with
  /// the given [otherUserId], Otherwise, returns `null`.
  Future<String?> findOneToOneChatRoom({
    required int retry,
    required String userId,
    required String otherUserId,
  });

  /// Returns a real-time stream of metadata for a specific chat room.
  ///
  /// This stream listens for updates to the chat room's metadata and emits
  /// changes whenever the metadata is modified. This [ChatRoomDisplayMetadata]
  /// contains the chat room's name and profile photo, which may be updated
  /// dynamically.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Specifies the chat room whose metadata will be streamed.
  /// - (required) [chatRoomType] The type of the chat room
  /// (e.g., one-on-one, group).
  /// - (optional) [userId] The unique identifier of the user.
  /// **Required for one-to-one chat rooms.**
  ///
  /// Returns a [Stream] that emits [ChatRoomDisplayMetadata] whenever updates
  /// occur.
  Stream<ChatRoomDisplayMetadata> getChatRoomDisplayMetadataStream({
    required ChatRoomType chatRoomType,
    required String chatId,
    String? userId,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.getUserMembershipTimestamp}
  /// Retrieves the timestamp of when a user was added to a group chat.
  /// This timestamp helps determine which messages should be displayed
  /// to the user based on their membership start time.
  ///
  /// If `userId` is not specified, the current user's ID is used.
  /// If `chatId` is not specified, the current chat room ID is used.
  ///
  /// Returns `null` if no timestamp is found.
  ///
  /// Parameters:
  /// - (required): [retry] The number of retry attempts if the operation fails.
  /// - (required): [chatId]  A unique identifier for the group chat.
  /// Specifies the group chat where the user's addition timestamp will be
  /// retrieved.
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  ///
  /// Example usage:
  /// ```dart
  /// DateTime? joinTimestamp = await userAddedInGroupChatTimestamp(
  ///            userId: "user123",
  ///            chatId: "chat456",
  ///          );
  /// ```
  /// {@endtemplate}
  Future<DateTime?> getUserMembershipTimestamp({
    required int retry,
    required String chatId,
    required String userId,
  });

  /// Deletes the entire chat from the chat collection and removes it
  /// from all users involved in the chat.
  ///
  /// Additionally, this method triggers the [deleteMedia]
  /// to delete all associated media (such as images and voice messages)
  /// from storage.
  ///
  /// **Parameters:**
  /// - (required): [retry] The number of retry attempts if the operation fails.
  /// - (required): [chatId] The unique identifier of the chat to be deleted.
  /// - (optional): [deleteMedia] A callback function
  /// responsible for deleting the chat's media from storage.
  ///
  /// Returns a true/false indicating whether the deletion was successful.
  Future<bool> deleteChat({
    required int retry,
    required String chatId,
    DeleteChatMediaCallback? deleteMedia,
  });
}
