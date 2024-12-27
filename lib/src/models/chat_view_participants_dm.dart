import 'package:chatview/chatview.dart';

/// A data model representing the participants in a chat.
class ChatViewParticipantsDm {
  /// Constructs a [ChatViewParticipantsDm] instance.
  ///
  /// **Parameters:**
  /// - (required) [currentUser] is the user currently logged in and
  /// viewing the chat.
  /// - (required) [otherUsers] is the list of other participants in the chat.
  const ChatViewParticipantsDm({
    required this.currentUser,
    required this.otherUsers,
  });

  /// The user currently logged in and viewing the chat.
  final ChatUser currentUser;

  /// The list of other participants in the chat.
  ///
  /// This includes all users in the chat except the [currentUser].
  final List<ChatUser> otherUsers;
}
