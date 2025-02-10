import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import 'database/database_service.dart';
import 'models/chat_room_user_dm.dart';
import 'models/chat_view_participants_dm.dart';
import 'models/message_dm.dart';
import 'storage/storage_service.dart';

/// Callback function used for updating reactions.
/// - (optional): `userId` specifies id of the user who performed the reaction.
///
/// - (optional): `emoji` specifies emoji that user has used.
typedef UserReactionCallback = ({String userId, String emoji});

/// Record for storing database type wise services in single variable
typedef DatabaseTypeServicesRecord = ({
  DatabaseService database,
  StorageService storage,
});

/// Callback function for uploading document to cloud storage.
typedef UploadDocumentCallback = Future<String?> Function(
  Message message, {
  String? uploadPath,
  String? fileName,
});

/// Callback function for deleting document from storage.
typedef DeleteDocumentCallback = Future<bool> Function(Message message);

/// A callback type used for handling changes in chat room user data.
typedef ChatRoomUserStreamCallback = void Function(
  ChatRoomUserDm? chatRoomUser,
);

/// A callback type used for handling the initialization of the chat room with
/// users. this callbacks is triggered when the chat room is initialized with
/// a list of users. The callback receives a [ChatViewParticipantsDm] object
/// representing the participants of the chat room.
///
/// Example usage:
/// ```dart
/// ChatRoomInitializedCallback onChatRoomInitialized = (users) {
///   // Handle the initialized chat room users
/// };
/// ```
typedef ChatRoomInitializedCallback = void Function(
  ChatViewParticipantsDm users,
);

/// A callback type used for handling changes in chat messages.
///
/// It will be triggered when there is a change in the list of chat messages.
/// The callback receives a list of [MessageDm] objects.
///
/// Example usage:
/// ```dart
/// ChatMessagesChangeCallback onChatMessagesChange = (messages) {
///   // Handle the updated chat messages
/// };
/// ```
typedef ChatMessagesChangeCallback = void Function(List<MessageDm> messages);
