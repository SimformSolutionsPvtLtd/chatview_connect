import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chatview_firestore_path.dart';

/// Provides Firestore collections.
abstract final class ChatViewFireStoreCollections {
  const ChatViewFireStoreCollections._();

  static final _firestoreInstance = FirebaseFirestore.instance;

  /// Collection reference for messages.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path to use
  /// message collection from that.
  ///
  /// {@template flutter_chatview_db_connection.StorageService.messageCollection}
  ///
  /// if path specified the message collection will be created at
  /// '[documentPath]/messages' and same path used to retrieve the messages.
  ///
  /// Example: 'chat/room123/messages'
  ///
  /// {@endtemplate}
  static CollectionReference<Message?> messageCollection([
    String? documentPath,
  ]) {
    const messagesCollection = ChatViewFireStorePath.messages;
    final collectionRef = documentPath == null
        ? _firestoreInstance.collection(messagesCollection)
        : _firestoreInstance.doc(documentPath).collection(messagesCollection);

    return collectionRef.withConverter(
      fromFirestore: _messageFromFirestore,
      toFirestore: _messageToFirestore,
    );
  }

  static Message? _messageFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) return null;
    try {
      return Message.fromJson(data).copyWith(id: snapshot.id);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _messageToFirestore(
    Message? message,
    SetOptions? options,
  ) {
    return message?.toJson() ?? {};
  }
}
