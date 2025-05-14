import 'package:chatview_utils/chatview_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// encapsulates information about message,
/// including content of [Message] Data model and
/// the corresponding [DocumentSnapshot] of [Message]? document snapshot.
class MessageDm {
  /// Creates an instance of [MessageDm]
  ///
  /// **Parameters:**
  /// - (required): [message] The [Message] model containing the message data.
  /// - (optional): [snapshot] The Firestore [DocumentSnapshot] associated
  /// with the message.
  const MessageDm({required this.message, this.snapshot});

  /// provides content of the [Message] model.
  final Message message;

  /// provides firebase document snapshot.
  final DocumentSnapshot<Message?>? snapshot;
}
