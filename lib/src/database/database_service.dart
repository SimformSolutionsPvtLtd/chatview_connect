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

  /// The unique identifier for the chat room.
  ///
  /// This ID is used to distinguish between different chat rooms.
  /// It can be `null` if the chat room has not been initialized
  /// or assigned yet.
  String? get chatRoomId;

  /// Sets the chat room configuration with the specified [chatRoomId].
  ///
  /// **Parameters:**
  ///
  /// - (required): [chatRoomId] is required and represents the
  /// unique identifier for the chat room.
  void setChatRoom({required String chatRoomId});

  /// Resets the chat room configuration to its default state.
  /// This method clears any previously set chat room data or configurations.
  void resetChatRoom();

  /// Asynchronously fetches messages and returns [List] of [MessageDm].
  ///
  /// **Parameters:**
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
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
  });

  /// Retrieves a stream of message batches from database.
  /// This method listens for real-time updates to the chat room message's
  /// data in the database.
  ///
  /// **Parameters:**
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
  Stream<List<MessageDm>> getMessagesStream({
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
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
  /// - (optional): [limit] Specifies the maximum number of users to retrieve.
  ///   If not provided, all users will be retrieved.
  ///
  /// **Returns:** A [Stream] that emits a [List] of [ChatRoomUserDm] instances.
  Stream<List<ChatRoomUserDm>> getChatRoomParticipantsStream({int? limit});

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
  /// - (required): [chatId] The unique identifier of the chat room for
  /// which the unread message count is retrieved.
  Stream<int> getUnreadMessagesCount(String chatId);

  /// Retrieves the current user and a list of users in the chat room from the
  /// database.
  /// This method fetches the participants of the chat room, including the
  /// current user.
  ///
  /// Returns [ChatViewParticipantsDm] object containing the chat room
  /// participants.
  Future<ChatViewParticipantsDm?> getChatRoomParticipants();

  /// Retrieves a stream of messages along with their associated operation
  /// types.
  ///
  /// **Parameters:**
  /// - (required): [sortBy] specifies the sorting order of messages
  /// by defaults it will be sorted by the dateTime.
  ///
  /// - (required): [sortOrder] specifies the order of sorting for messages.
  /// by defaults it will be ascending sort order.
  ///
  /// - (optional): [limit] specifies the limit of the messages to be retrieved.
  /// by defaults it will retrieve the all messages if not specified.
  Stream<Map<Message, DocumentType>> getMessagesStreamWithOperationType({
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
  });

  /// Asynchronously adds a new message and returns nullable [Message].
  ///
  /// **Parameters:**
  /// - (required): [message] specifies the [Message] to be add on database.
  ///
  /// - (required): [useAutoGeneratedId] determines whether to use
  /// the database-generated ID or the predefined message ID.
  /// If set to `true`, a database-generated ID will be used;
  /// otherwise, the predefined message ID will be applied.
  ///
  /// - (required): [addMessageConfig]
  /// {@macro flutter_chatview_db_connection.AddMessageConfig}
  Future<Message?> addMessage(
    Message message, {
    required bool useAutoGeneratedId,
    required AddMessageConfig addMessageConfig,
  });

  /// Asynchronously delete a message and returns [bool] value.
  ///
  /// **Parameters:**
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
  Future<bool> deleteMessage(
    Message message, {
    required DeleteDocumentCallback onDeleteDocument,
    required bool deleteImageFromStorage,
    required bool deleteVoiceFromStorage,
  });

  /// Asynchronously update a message.
  ///
  /// **Parameters:**
  /// - (required): [message] specifies the [Message] to be update on database.
  ///
  /// - (optional): [messageStatus] specifies the [MessageStatus]
  /// to update the status of message.
  /// if the value is not provided then [messageStatus] will not update.
  ///
  /// - (optional): [userReaction] specifies the [UserReactionCallback]
  /// to update the reaction of particular user.
  /// if the value is not provided then [userReaction] will not update.
  Future<void> updateMessage(
    Message message, {
    MessageStatus? messageStatus,
    UserReactionCallback? userReaction,
  });

  // TODO(YASH): Store user online/offline status in user_chats collection
  /// Updates the chat room user with the provided typing and/or user status.
  /// This method is used to update the status of a user in the chat room, such
  /// as their typing status or overall user status.
  ///
  /// **Parameters:**
  /// - (optional): [typingStatus] The current typing status of the user
  /// (e.g., typing, typed).
  /// - (optional): [userStatus] The overall status of the user
  /// (e.g., online, offline).
  ///
  /// Returns a [Future] that completes when the user's status is updated in
  /// the database.
  Future<void> updateChatRoomUserMetadata({
    TypeWriterStatus? typingStatus,
    UserStatus? userStatus,
  });

  // TODO(YASH): Move sorting chats logic before applying the limit
  /// {@template flutter_chatview_db_connection.DatabaseService.getChats}
  /// Returns a stream of chat rooms,
  /// each containing a list of users (excluding the current user).
  ///
  /// **Parameters:**
  /// - (required): [sortBy] determines the order in which chat rooms are
  /// retrieved:
  ///  - [ChatSortBy.newestFirst] sorts chat rooms in descending order
  ///  based on the timestamp of the latest message.
  ///  - [ChatSortBy.none] retrieves chat rooms in their default order
  ///  without applying any sorting.
  ///
  /// - (required): [showEmptyMessagesChats] determines whether to include
  /// chat rooms that have no messages.
  ///   - If `true`, one-to-one chats that have been created but contain
  /// no messages will be included in the list.
  ///   - If `false`, such empty chats will be excluded.
  ///
  /// - (required): [fetchUnreadMessageCount] determines whether the stream
  /// will listen for unread message count updates.
  ///   - If `true`, it will continuously listen and update the count.
  ///   - If `false`, it will not listen, and `unreadMessagesCount`
  ///   will always be `0`.
  ///
  /// - (optional): [limit] specifies the maximum number of chat rooms to
  /// retrieve. If not specified, all chat rooms will be retrieved by default.
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
  Stream<List<ChatRoomDm>> getChats({
    required ChatSortBy sortBy,
    required bool showEmptyMessagesChats,
    required bool fetchUnreadMessageCount,
    int? limit,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.createOneToOneUserChat}
  /// Creates a one-to-one chat with the specified user.
  ///
  /// **Parameters:**
  /// - (required): [userId] The unique identifier of the user to
  /// create a chat with.
  ///
  /// If a chat with the given [userId] already exists, the existing chat ID
  /// is returned.
  /// Otherwise, a new chat is created, and its ID is returned upon success.
  ///
  /// Returns `null` if the chat creation fails.
  /// {@endtemplate}
  Future<String?> createOneToOneUserChat(String userId);

  /// {@template flutter_chatview_db_connection.DatabaseService.createGroupChat}
  /// Creates a new group chat.
  ///
  /// **Parameters:**
  /// - (required): [groupName] is the name of the group chat to be created.
  /// - (required): [userIds] is a list of user IDs to be included in
  /// the group chat. The current user is automatically added.
  /// - (optional): [groupProfilePic] is an optional profile picture for the
  /// group chat. If not specified, the group will not have a profile picture.
  ///
  /// This method creates a new group chat with the provided group name, users,
  /// and optional profile picture.
  ///
  /// Returns a ID of the newly created group chat.
  /// If the creation fails, `null` is returned.
  /// {@endtemplate}
  Future<String?> createGroupChat({
    required String groupName,
    required List<String> userIds,
    String? groupProfilePic,
  });

  /// {@template flutter_chatview_db_connection.DatabaseService.updateGroupChat}
  /// Updates an existing group chat.
  ///
  /// This method allows updating the group chat's name and profile picture.
  ///
  /// **Parameters:**
  /// - (optional): [groupName] is the new name for the group chat.
  /// If `null`, the group name will not be updated.
  /// - (optional): [groupProfilePic] is the new profile picture for the
  /// group chat. If `null`, the profile picture will not be updated.
  ///
  /// Returns a true/false indicating whether the update was successful (`true`) or failed (`false`).
  /// {@endtemplate}
  Future<bool> updateGroupChat({String? groupName, String? groupProfilePic});

  /// This method retrieves all messages of the given chat room, determines the
  /// most recent one, and updates the chat room’s last message field.
  ///
  /// **Parameters:**
  /// - (optional): [chatId] The unique identifier of the chat room to be
  /// updated. If `chatId` is `null`, the currently active chat room ID will be
  /// used.
  ///
  /// Returns a true/false indicating whether the last message is fetched and updated.
  Future<bool> fetchAndUpdateLastMessage({String? chatId});

  /// Updates the chat room with new data.
  ///
  /// **Parameters:**
  /// - (optional): [chatId] is the unique identifier of the chat room to be
  /// updated. If `chatId` is `null`, the currently active chat room ID will be
  /// used.
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
    String? chatId,
    Message? lastMessage,
    Map<String, dynamic>? data,
  });

  /// Retrieves a stream of [ChatRoomMetadata] for the specified chat room.
  ///
  /// **Parameters:**
  ///
  /// - (optional): [chatId] The ID of the chat room to fetch metadata for.
  /// If provided, this ID will be used. Otherwise, the currently active
  /// chat room ID will be used.
  ///
  /// **Returns:**
  /// A [Stream] of [ChatRoomMetadata].
  /// Returns `null` if the chat is a one-to-one chat, as metadata is
  /// only applicable for group chats.
  Stream<ChatRoomMetadata> getGroupChatMetadataStream([String? chatId]);

  /// Returns a real-time stream of metadata for a specific chat room.
  ///
  /// This stream listens for updates to the chat room's metadata and emits
  /// changes whenever the metadata is modified. This [ChatRoomMetadata]
  /// contains the chat room's name and profile photo, which may be updated
  /// dynamically.
  ///
  /// **Parameters:**
  ///
  /// - (required) [chatRoomType] The type of the chat room
  /// (e.g., one-on-one, group).
  /// - (optional) [userId] The unique identifier of the user.
  /// **Required for one-to-one chat rooms.**
  /// - (optional): [chatId] The ID of the chat room to fetch metadata for.
  ///   If provided, this ID will be used. Otherwise, the currently active
  ///   chat room ID will be used.
  ///
  /// Returns a [Stream] that emits [ChatRoomMetadata] whenever updates occur.
  Stream<ChatRoomMetadata> getChatRoomMetadataStream({
    required ChatRoomType chatRoomType,
    String? userId,
    String? chatId,
  });

  /// Deletes the entire chat from the chat collection and removes it
  /// from all users involved in the chat.
  ///
  /// Additionally, this method triggers the [deleteChatDocsFromStorageCallback]
  /// to delete all associated media (such as images and voice messages)
  /// from storage.
  ///
  /// **Parameters:**
  /// - (required): [chatId] The unique identifier of the chat to be deleted.
  /// - (optional): [deleteChatDocsFromStorageCallback] A callback function
  /// responsible for deleting the chat's media from storage.
  ///
  /// Returns a true/false indicating whether the deletion was successful.
  Future<bool> deleteChat({
    required String chatId,
    DeleteChatDocsFromStorageCallback? deleteChatDocsFromStorageCallback,
  });
}
