import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'chatview_firestore_path.dart';

/// Provides Firestore collections.
abstract final class ChatViewFireStoreCollections {
  const ChatViewFireStoreCollections._();

  static final _firestoreInstance = FirebaseFirestore.instance;

  /// Collection reference for messages.
  static final CollectionReference<Message?> messageCollection =
      _firestoreInstance
          .collection(ChatViewFireStorePath.messages)
          .withConverter(
            fromFirestore: _messageFromFirestore,
            toFirestore: _messageToFirestore,
          );

  static Message? _messageFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return data == null ? null : Message.fromJson(data);
  }

  static Map<String, dynamic> _messageToFirestore(
    Message? message,
    SetOptions? options,
  ) {
    return message?.toJson() ?? {};
  }
}
