import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import '../chatview_db_connection.dart';
import '../enum.dart';

/// A data model representing a user in a chat room.
class ChatRoomUserDm {
  /// Constructs a [ChatRoomUserDm] instance.
  ///
  /// **Parameters:**
  /// - (optional): [userId] is the unique identifier of the user.
  /// - (optional): [chatUser] contains detailed information about the user
  /// in the chat room.
  /// - (optional): [userStatus] represents the online/offline status of the user.
  /// - (optional): [typingStatus] indicates the typing status of the user,
  /// with a default value of [TypeWriterStatus.typed].
  const ChatRoomUserDm({
    required this.userId,
    required this.chatUser,
    required this.userStatus,
    this.typingStatus = TypeWriterStatus.typed,
  });

  /// Creates a [ChatRoomUserDm] instance from a JSON map.
  ///
  /// **Parameters:**
  /// - (required): [json] is a map containing the serialized data.
  ///
  /// Throws an error if required fields are missing or
  /// if data types do not match expectations.
  factory ChatRoomUserDm.fromJson(Map<String, dynamic> json) {
    final chatUserData = json['chat_user'];
    return ChatRoomUserDm(
      chatUser: chatUserData is Map<String, dynamic>
          ? ChatUser.fromJson(
              chatUserData,
              config: ChatViewDbConnection.instance.getChatUserModelConfig,
            )
          : null,
      userId: json['user_id']?.toString() ?? '',
      userStatus: UserStatusExtension.parse(json['user_status'].toString()),
      typingStatus: TypeWriterStatusExtension.parse(
        json['typing_status'].toString(),
      ),
    );
  }

  /// Detailed information about the user in the chat room.
  ///
  /// This can be `null` if no data is available for the user.
  final ChatUser? chatUser;

  /// The unique identifier of the user.
  final String userId;

  /// The online/offline status of the user.
  ///
  /// Possible values include statuses such as online or offline.
  final UserStatus userStatus;

  /// The typing status of the user.
  ///
  /// Possible values include statuses such as typing or typed.
  final TypeWriterStatus typingStatus;

  /// Converts the [ChatRoomUserDm] instance to a JSON map.
  ///
  /// **Note**: The [chatUser] field is not included in `toJson` because it serves as an aggregation
  /// of multiple data streams. The [chatUser] property is populated dynamically using the `copyWith` method
  /// when merging data from different sources, such as chat document IDs and user collection data.
  /// Since it is dynamically assembled from multiple streams, serializing it back to JSON is not necessary.
  ///
  /// Additionally, [chatUser] is not meant for storing in a database document because it is retrieved
  /// from different sources rather than being a single entity. It is primarily used for runtime operations
  /// where data from different sources is combined for ease of use in the application.
  ///
  /// Returns a map containing the `user_status` and `typing_status` fields.
  Map<String, dynamic> toJson({bool includeUserId = true}) {
    return {
      if (includeUserId) 'user_id': userId,
      'user_status': userStatus.name,
      'typing_status': typingStatus.name,
    };
  }

  /// Creates a copy of the current [ChatRoomUserDm] instance with
  /// updated fields.
  ///
  /// Any field not provided will retain its current value.
  ///
  /// **Parameters:**
  /// - (optional): [userId] is the updated user ID.
  /// - (optional): [chatUser] is the updated chat user details.
  /// - (optional): [userStatus] is the updated online/offline status.
  /// - (optional): [typingStatus] is the updated typing status.
  ///
  /// Returns a new [ChatRoomUserDm] instance with the specified updates.
  ChatRoomUserDm copyWith({
    String? userId,
    ChatUser? chatUser,
    UserStatus? userStatus,
    TypeWriterStatus? typingStatus,
    bool forceNullValue = false,
  }) {
    return ChatRoomUserDm(
      userId: userId ?? this.userId,
      chatUser: forceNullValue ? chatUser : chatUser ?? this.chatUser,
      userStatus: userStatus ?? this.userStatus,
      typingStatus: typingStatus ?? this.typingStatus,
    );
  }

  @override
  String toString() => 'ChatRoomUserDm(${toJson()})';
}
