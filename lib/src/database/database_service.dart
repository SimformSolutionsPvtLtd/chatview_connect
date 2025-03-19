import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import '../enum.dart';
import '../models/chat_room_dm.dart';
import '../models/chat_room_metadata_model.dart';
import '../models/chat_room_user_dm.dart';
import '../models/chat_view_participants_dm.dart';
import '../models/config/add_message_config.dart';
import '../models/message_dm.dart';
import '../typedefs.dart';

/// Defined different methods to interact with a cloud database.
abstract interface class DatabaseService {
  const DatabaseService._();

  /// Asynchronously fetches messages and returns [List] of [MessageDm].
  ///
  /// **Parameters:**
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
  /// - (optional): [startFromDateTime] specifies a starting date-time to fetch
  /// messages from. If provided, only messages after this timestamp will be
  /// included.
  Stream<List<MessageDm>> getMessagesStreamWithSnapshot({
    required String chatId,
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
    DateTime? startFromDateTime,
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
  /// - (optional): [startFromDateTime] specifies a starting date-time to fetch
  /// messages from. If provided, only messages after this timestamp will be
  /// included.
  Stream<List<Message>> getMessagesStream({
    required String chatId,
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
    DateTime? startFromDateTime,
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
  /// - (optional): [limit] specifies the limit of the users to be retrieved.
  /// by defaults it will retrieve the all users if not specified.
  Future<List<ChatUser>> getUsers({int? limit});

  /// Retrieves a stream of a particular user based on the provided user ID.
  /// This method listens for real-time updates to the user's data in
  /// the database.
  ///
  /// **Parameters:**
  /// - (required): [userId] The ID of the user whose data is being retrieved.
  Stream<ChatUser?> getUserStreamById({required String userId});

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
  /// **Returns:** A [Stream] that emits a [List] of [ChatRoomUserDm] instances.
  Stream<List<ChatRoomUserDm>> getChatRoomParticipantsStream({
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
  /// Each user is represented by [ChatRoomUserDm], which includes their
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
  /// to [ChatRoomUserDm] instances.
  Stream<Map<String, ChatRoomUserDm>> getChatRoomUsersMetadataStream({
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
  /// - (optional): [startMessageFromDateTime] Specifies a starting date-time
  /// to count unread messages from. If provided, only messages after this
  /// timestamp will be considered.
  Stream<int> getUnreadMessagesCount({
    required String chatId,
    required String userId,
    DateTime? startMessageFromDateTime,
  });

  /// Retrieves the current user and a list of users in the chat room from the
  /// database.
  /// This method fetches the participants of the chat room, including the
  /// current user.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Used to retrieve the participants of the specified chat room.
  ///
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  ///
  /// Returns [ChatViewParticipantsDm] object containing the chat room
  /// participants.
  Future<ChatViewParticipantsDm?> getChatRoomParticipants({
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
  /// - (required): [chatId]  A unique identifier for the chat room.
  /// Specifies the chat room where the message will be added.
  ///
  /// - (required): [message] specifies the [Message] to be add on database.
  ///
  /// - (required): [useAutoGeneratedId] determines whether to use
  /// the database-generated ID or the predefined message ID.
  /// If set to `true`, a database-generated ID will be used;
  /// otherwise, the predefined message ID will be applied.
  ///
  /// - (required): [addMessageConfig]
  /// {@macro flutter_chatview_db_connection.AddMessageConfig}
  Future<Message?> addMessage({
    required String chatId,
    required Message message,
    required bool useAutoGeneratedId,
    required AddMessageConfig addMessageConfig,
  });

  /// Asynchronously delete a message and returns [bool] value.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Specifies the chat room from which the message will be deleted.
  ///
  /// - (required): [message] specifies the [Message] to be delete
  /// from database.
  ///
  /// - (required): [deleteImageFromStorage] specifies whether the image
  /// should be deleted from the storage or not.
  ///
  /// - (required): [deleteVoiceFromStorage] specifies whether the voice
  /// should be deleted from the storage or not.
  ///
  /// - (required): [onDeleteDocument] specifies function for deleting
  /// image or voice document from cloud storage before deleting the message
  /// from database.
  Future<bool> deleteMessage({
    required String chatId,
    required Message message,
    required DeleteDocumentCallback onDeleteDocument,
    required bool deleteImageFromStorage,
    required bool deleteVoiceFromStorage,
  });

  /// Asynchronously update a message.
  ///
  /// **Parameters:**
  /// - (required): [chatId]  A unique identifier for the chat room.
  /// Specifies the chat room where the message will be updated.
  ///
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  ///
  /// - (required): [message] specifies the [Message] to be update on database.
  ///
  /// - (optional): [messageStatus] specifies the [MessageStatus]
  /// to update the status of message.
  /// if the value is not provided then [messageStatus] will not update.
  ///
  /// - (optional): [userReaction] specifies the [UserReactionCallback]
  /// to update the reaction of particular user.
  /// if the value is not provided then [userReaction] will not update.
  Future<void> updateMessage({
    required String userId,
    required String chatId,
    required Message message,
    MessageStatus? messageStatus,
    UserReactionCallback? userReaction,
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
  Future<void> updateChatRoomUserMetadata({
    required String chatId,
    required String userId,
    TypeWriterStatus? typingStatus,
    MembershipStatus? membershipStatus,
    Map<String, dynamic>? chatRoomUserData,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.updateUserActiveStatus}
  /// Updates the current user document with the current user status.
  ///
  /// **Parameters:**
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (required): [userStatus] The current status of the user (online/offline).
  /// {@endtemplate}
  Future<bool> updateUserActiveStatus({
    required String userId,
    required UserActiveStatus userStatus,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.getChats}
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
  /// as a [ChatRoomDm] instances.
  /// - The list of users in each chat room **does not**
  /// include the current user.
  ///
  /// The stream dynamically updates to reflect changes in chat room users,
  /// such as:
  /// - Online/offline status updates
  /// - Typing activity
  ///
  /// {@endtemplate}
  Stream<List<ChatRoomDm>> getChatsStream({
    required String userId,
    required ChatSortBy sortBy,
    required bool includeEmptyChats,
    required bool includeUnreadMessagesCount,
    int? limit,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.createOneToOneUserChat}
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
  Future<String?> createOneToOneUserChat({
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
    required String chatId,
    String? groupName,
    String? groupProfilePic,
  });

  /// This method retrieves all messages of the given chat room, determines the
  /// most recent one, and updates the chat room’s last message field.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Specifies the chat room where the last message will be fetched
  /// and updated.
  ///
  /// Returns a true/false indicating whether the last message is fetched and updated.
  Future<bool> fetchAndUpdateLastMessage({required String chatId});

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
  /// - (required): [chatId] A unique identifier for the group chat.
  /// Specifies the group chat where the user will be added.
  /// - (required): [userId] The unique identifier of the user to be added.
  /// - (required): [role] The role assigned to the user in the group chat.
  /// - (required): [includeAllChatHistory]  Determines whether the user
  ///   should have access to all previous chat history in the group.
  ///
  /// Returns a [Future] that resolves to `true` if the user was successfully
  /// added, otherwise `false`.
  /// {@endtemplate}
  Future<bool> addUserInGroup({
    required String chatId,
    required String userId,
    required Role role,
    required bool includeAllChatHistory,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.removeUserFromGroup}
  /// Removes a user from the group chat and updates their membership status.
  /// This method marks the user as removed but does not delete their
  /// past messages.
  ///
  /// **Parameters:**
  /// - (required): [chatId]  A unique identifier for the group chat.
  /// Specifies the group chat from which the user will be removed.
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (required): [removeUserId] The unique identifier of the user to
  ///   be removed.
  /// - (required): [deleteGroupIfSingleUser] Whether to delete the group
  ///   if the removed user was the last member.
  /// - (required): [deleteChatDocsFromStorage] A callback function
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
    required String chatId,
    required String userId,
    required String removeUserId,
    required bool deleteGroupIfSingleUser,
    required DeleteChatMediaFromStorageCallback deleteChatDocsFromStorage,
  });

  /// Updates the chat room with new data.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the chat room.
  /// Specifies the chat room that will be updated with the provided data.
  ///
  /// - (optional): [lastMessage] represents the most recent message in the
  /// chat room.
  ///
  /// - (optional): [data] is a map containing additional fields to update in
  /// the chat room. If `data` is provided, it will be used for the update.
  /// Otherwise, if `lastMessage` is specified, it will be used to update
  /// the chat room.
  ///
  /// Returns a `Future<bool>` indicating whether the update was successful.
  Future<bool> updateChatRoom({
    required String chatId,
    Message? lastMessage,
    Map<String, dynamic>? data,
  });

  /// Retrieves a stream of [ChatRoomMetadata] for the specified chat room.
  ///
  /// **Parameters:**
  /// - (required): [chatId] A unique identifier for the group chat.
  /// Specifies the group chat whose metadata will be streamed.
  ///
  /// **Returns:**
  /// A [Stream] of [ChatRoomMetadata].
  /// Returns `null` if the chat is a one-to-one chat, as metadata is
  /// only applicable for group chats.
  Stream<ChatRoomMetadata> getGroupChatMetadataStream(String chatId);

  /// Checks if a one-to-one chat exists with the specified user.
  ///
  /// **Parameters:**
  /// - (required): [userId] The unique identifier of the currently logged-in
  /// user.
  /// - (required): [otherUserId] The unique identifier of the user
  /// to check for an existing chat.
  ///
  /// Returns the chat room ID if a chat already exists with
  /// the given [otherUserId], Otherwise, returns `null`.
  Future<String?> isOneToOneChatExists({
    required String userId,
    required String otherUserId,
  });

  /// Returns a real-time stream of metadata for a specific chat room.
  ///
  /// This stream listens for updates to the chat room's metadata and emits
  /// changes whenever the metadata is modified. This [ChatRoomMetadata]
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
  /// Returns a [Stream] that emits [ChatRoomMetadata] whenever updates occur.
  Stream<ChatRoomMetadata> getChatRoomMetadataStream({
    required ChatRoomType chatRoomType,
    required String chatId,
    String? userId,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.userAddedInGroupChatTimestamp}
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
  Future<DateTime?> userAddedInGroupChatTimestamp({
    required String chatId,
    required String userId,
  });

  /// Deletes the entire chat from the chat collection and removes it
  /// from all users involved in the chat.
  ///
  /// Additionally, this method triggers the [deleteMediaFromStorage]
  /// to delete all associated media (such as images and voice messages)
  /// from storage.
  ///
  /// **Parameters:**
  /// - (required): [chatId] The unique identifier of the chat to be deleted.
  /// - (optional): [deleteMediaFromStorage] A callback function
  /// responsible for deleting the chat's media from storage.
  ///
  /// Returns a true/false indicating whether the deletion was successful.
  Future<bool> deleteChat({
    required String chatId,
    DeleteChatMediaFromStorageCallback? deleteMediaFromStorage,
  });
}
