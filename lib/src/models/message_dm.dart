import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// encapsulates information about message,
/// including content of [Message] Data model and
/// the corresponding [DocumentSnapshot] of [Message]? document snapshot.
class MessageDm {
  /// Takes the following (required) parameters: [message],
  /// (optional) parameters: [snapshot].
  const MessageDm({required this.message, this.snapshot});

  /// provides content of the [Message] model.
  final Message message;

  /// provides firebase document snapshot.
  final DocumentSnapshot<Message?>? snapshot;
}
