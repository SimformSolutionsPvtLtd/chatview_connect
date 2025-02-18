import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../enum.dart';
import '../models/chat_room_user_dm.dart';
import '../models/chat_view_participants_dm.dart';
import '../models/config/add_message_config.dart';
import '../models/database_path_config.dart';
import '../models/message_dm.dart';
import '../typedefs.dart';

/// Defined different methods to interact with a cloud database.
abstract interface class DatabaseService {
  const DatabaseService._();

  /// Sets the database configuration for the chat system.
  ///
  /// This method allows you to specify the configuration details
  /// required to access the chat database, such as chat room
  /// and user collection paths.
  ///
  /// - (required): [config] is required and should be an instance of
  /// [ChatDatabasePathConfig] containing the necessary database paths.
  ///
  /// {@macro flutter_chatview_db_connection.ChatDatabasePathConfig}
  void setConfiguration({required ChatDatabasePathConfig config});

  /// Reset the database configuration
  void resetConfiguration();

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

  /// Returns a stream of chat room users from the database.
  ///
  /// This method listens for real-time updates to chat room users' data but
  /// does **not** fetch detailed user information.
  ///
  /// Each user is represented by [ChatRoomUserDm], which includes their
  /// **userStatus** and **typingStatus**.
  ///
  /// **Parameters:**
  /// - (optional): [limit] Specifies the maximum number of chat room users
  /// to retrieve. If not provided, all users will be retrieved.
  ///
  /// **Returns:** A [Stream] that emits a [Map] of user IDs
  /// to [ChatRoomUserDm] instances.
  Stream<Map<String, ChatRoomUserDm>> getChatRoomUsersMetadataStream({
    int? limit,
  });

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
}
