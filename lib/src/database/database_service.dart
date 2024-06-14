import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../enum.dart';
import '../models/config/add_message_config.dart';
import '../models/message_dm.dart';
import '../typedefs.dart';

/// Defined different methods to interact with a cloud database.
abstract interface class DatabaseService {
  const DatabaseService._();

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
  /// - (required): [addMessageConfig]
  /// {@macro flutter_chatview_db_connection.AddMessageConfig}
  Future<Message?> addMessage(
    Message message, {
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
}
