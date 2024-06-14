import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../flutter_chatview_db_connection.dart';
import '../../models/config/add_message_config.dart';
import '../../typedefs.dart';
import '../database_service.dart';
import 'chatview_firestore_collections.dart';

/// provides methods for getting, adding, updating and deleting message
/// and messages streams from Firebase Firestore.
final class ChatViewFireStoreDatabase implements DatabaseService {
  static const String _status = 'status';
  static const String _reaction = 'reaction';

  @override
  Future<Message?> addMessage(
    Message message, {
    required AddMessageConfig addMessageConfig,
  }) async {
    final url = await addMessageConfig.uploadDocumentFromMessage(message);
    final result = await ChatViewFireStoreCollections.messageCollection.add(
      message.copyWith(message: url),
    );
    final fbMessage = await result.get();
    return fbMessage.data();
  }

  @override
  Stream<List<MessageDm>> getMessagesStream({
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
  }) {
    var messageCollection = switch (sortBy) {
      MessageSortBy.dateTime =>
        ChatViewFireStoreCollections.messageCollection.orderBy(
          sortBy.key,
          descending: sortOrder.isDesc,
        ),
      MessageSortBy.none => ChatViewFireStoreCollections.messageCollection,
    };

    if (limit != null) messageCollection = messageCollection.limit(limit);

    if (startAfterDocument != null) {
      messageCollection =
          messageCollection.startAfterDocument(startAfterDocument);
    }

    return messageCollection.snapshots().distinct().map(
      (docSnapshot) {
        final messages = docSnapshot.docs;
        final messagesLength = messages.length;
        return [
          for (var i = 0; i < messagesLength; i++)
            if (messages[i].data() case final message?)
              MessageDm(
                message: message.copyWith(id: messages[i].id),
                snapshot: messages[i],
              ),
        ];
      },
    );
  }

  @override
  Stream<Map<Message, DocumentType>> getMessagesStreamWithOperationType({
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
  }) {
    var messageCollection = switch (sortBy) {
      MessageSortBy.dateTime =>
        ChatViewFireStoreCollections.messageCollection.orderBy(
          sortBy.key,
          descending: sortOrder.isDesc,
        ),
      MessageSortBy.none => ChatViewFireStoreCollections.messageCollection,
    };

    if (limit != null) messageCollection = messageCollection.limit(limit);

    return messageCollection.snapshots().distinct().map(
      (docSnapshot) {
        final messagesChanges = docSnapshot.docChanges;
        final messagesChangesLength = messagesChanges.length;
        final messages = <Message, DocumentType>{};
        for (var i = 0; i < messagesChangesLength; i++) {
          final changedDoc = messagesChanges[i];
          final messageDoc = changedDoc.doc;
          final message = messageDoc.data()?.copyWith(id: messageDoc.id);
          if (message == null) continue;
          messages[message] = DocumentType.firebaseType(changedDoc.type);
        }
        return messages;
      },
    );
  }

  @override
  Future<List<MessageDm>> getMessages({
    required MessageSortBy sortBy,
    required MessageSortOrder sortOrder,
    int? limit,
    DocumentSnapshot<Message?>? startAfterDocument,
  }) async {
    var messageCollection = switch (sortBy) {
      MessageSortBy.dateTime =>
        ChatViewFireStoreCollections.messageCollection.orderBy(
          sortBy.key,
          descending: sortOrder.isDesc,
        ),
      MessageSortBy.none => ChatViewFireStoreCollections.messageCollection,
    };

    if (limit != null) messageCollection = messageCollection.limit(limit);

    if (startAfterDocument != null) {
      messageCollection =
          messageCollection.startAfterDocument(startAfterDocument);
    }

    final result = await messageCollection.get();
    final docs = result.docs;
    final docsLength = docs.length;
    return [
      for (var i = 0; i < docsLength; i++)
        if (docs[i].data() case final message?)
          MessageDm(
            message: message.copyWith(id: docs[i].id),
            snapshot: docs[i],
          ),
    ];
  }

  @override
  Future<bool> deleteMessage(
    Message message, {
    required DeleteDocumentCallback onDeleteDocument,
    required bool deleteImageFromStorage,
    required bool deleteVoiceFromStorage,
  }) async {
    final messageType = message.messageType;
    if (messageType.isImage && deleteImageFromStorage) {
      await onDeleteDocument(message);
    } else if (messageType.isVoice && deleteVoiceFromStorage) {
      await onDeleteDocument(message);
    }
    await ChatViewFireStoreCollections.messageCollection
        .doc(message.id)
        .delete();
    return true;
  }

  @override
  Future<void> updateMessage(
    Message message, {
    MessageStatus? messageStatus,
    UserReactionCallback? userReaction,
  }) async {
    final data = <String, dynamic>{};

    if (messageStatus != null) data[_status] = messageStatus.name;
    if (userReaction != null) data[_reaction] = message.reaction.toJson();

    if (data.isEmpty) return;

    return ChatViewFireStoreCollections.messageCollection
        .doc(message.id)
        .update(data);
  }
}
