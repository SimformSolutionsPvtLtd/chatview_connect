import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import '../chatview_db_connection.dart';
import '../enum.dart';
import '../extensions.dart';

/// A data model representing a user in a chat room.
class ChatRoomParticipant {
  /// Constructs a [ChatRoomParticipant] instance.
  ///
  /// **Parameters:**
  /// - (required): [userId] is the unique identifier of the user.
  /// - (required): [chatUser] contains detailed information about the user
  /// in the chat room.
  /// - (required): [userActiveStatus] represents the online/offline status of the user.
  /// - (optional): [typingStatus] indicates the typing status of the user,
  /// with a default value of [TypeWriterStatus.typed].
  /// - (required): [role] defines the user's permissions within the chat room.
  /// - (required): [membershipStatus] indicates whether the user is an active
  /// member, has left, or was removed.
  /// - (required): [membershipStatusTimestamp] records the timestamp of
  /// the last membership status change, helping track when a user joined,
  /// left, or was removed.
  const ChatRoomParticipant({
    required this.role,
    required this.userId,
    required this.chatUser,
    required this.membershipStatus,
    required this.membershipStatusTimestamp,
    this.userActiveStatus = UserActiveStatus.offline,
    this.typingStatus = TypeWriterStatus.typed,
  });

  /// Creates a [ChatRoomParticipant] instance from a JSON map.
  ///
  /// **Parameters:**
  /// - (required): [json] is a map containing the serialized data.
  ///
  /// Throws an error if required fields are missing or
  /// if data types do not match expectations.
  factory ChatRoomParticipant.fromJson(Map<String, dynamic> json) {
    final chatUserData = json['chat_user'];
    final createAtJson = json[_membershipStatusTimestamp];
    final createAt = createAtJson is Timestamp
        ? createAtJson.toDate().toLocal().toIso8601String()
        : createAtJson;
    json[_membershipStatusTimestamp] = createAt;

    return ChatRoomParticipant(
      chatUser: chatUserData is Map<String, dynamic>
          ? ChatUser.fromJson(
              chatUserData,
              config: ChatViewDbConnection.instance.getChatUserConfig,
            )
          : null,
      userId: json['user_id']?.toString() ?? '',
      userActiveStatus: UserActiveStatusExtension.parse(
        json['user_active_status'].toString(),
      ),
      typingStatus: TypeWriterStatusExtension.parse(
        json['typing_status'].toString(),
      ),
      role: RoleExtension.parse(json['role'].toString()),
      membershipStatus: MembershipStatusExtension.parse(
        json['membership_status'].toString(),
      ),
      membershipStatusTimestamp: DateTime.tryParse(
        json[_membershipStatusTimestamp].toString(),
      ),
    );
  }

  static const String _membershipStatusTimestamp =
      'membership_status_timestamp';

  /// Detailed information about the user in the chat room.
  ///
  /// This can be `null` if no data is available for the user.
  final ChatUser? chatUser;

  /// The unique identifier of the user.
  final String userId;

  /// The online/offline status of the user.
  ///
  /// Possible values include statuses such as online or offline.
  final UserActiveStatus userActiveStatus;

  /// The typing status of the user.
  ///
  /// Possible values include statuses such as typing or typed.
  final TypeWriterStatus typingStatus;

  /// The role of the user in the chat room.
  ///
  /// Determines the user's permissions within the chat.
  final Role role;

  /// The membership status of the user in the chat room.
  ///
  /// Indicates whether the user is an active member, has left, or was removed.
  final MembershipStatus? membershipStatus;

  /// The timestamp of the last membership status change.
  /// This helps determine when a user joined, left, or was removed from
  /// the chat room.
  /// If `null`, the exact time of the status change is unknown.
  final DateTime? membershipStatusTimestamp;

  /// Converts the [ChatRoomParticipant] instance to a JSON map.
  ///
  /// **Note**: The [chatUser], [userActiveStatus] field is not included in
  /// `toJson` because it serves as an aggregation of multiple data streams.
  /// The [chatUser], [userActiveStatus] property is populated dynamically using
  /// the `copyWith` method when merging data from different sources, such as
  /// chat document IDs and user collection data. Since it is dynamically
  /// assembled from multiple streams, serializing it back to JSON is not
  /// necessary.
  ///
  /// Additionally, [chatUser], [userActiveStatus] is not meant for storing in
  /// a database document because it is retrieved from different sources rather
  /// than being a single entity. It is primarily used for runtime operations
  /// where data from different sources is combined for ease of use in the
  /// application.
  ///
  /// Returns a map containing the `user_active_status` and `typing_status`
  /// fields.
  Map<String, dynamic> toJson({bool includeUserId = true}) {
    final data = <String, dynamic>{
      if (includeUserId) 'user_id': userId,
      'role': role.name,
      'typing_status': typingStatus.name,
      'membership_status': membershipStatus?.name,
      _membershipStatusTimestamp: membershipStatusTimestamp?.toIso8601String(),
    };
    if (membershipStatusTimestamp case final membershipStatusTimestamp?) {
      data[_membershipStatusTimestamp] = membershipStatusTimestamp.isNow
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(membershipStatusTimestamp);
    }
    return data;
  }

  /// Creates a copy of the current [ChatRoomParticipant] instance with
  /// updated fields.
  ///
  /// Any field not provided will retain its current value.
  ///
  /// **Parameters:**
  /// - (optional): [role] is the updated role of the user in the chat room.
  /// - (optional): [userId] is the updated user ID.
  /// - (optional): [chatUser] is the updated chat user details.
  /// - (optional): [userActiveStatus] is the updated online/offline status.
  /// - (optional): [typingStatus] is the updated typing status.
  /// - (optional): [membershipStatus] is the updated membership status
  /// of the user in the chat room.
  /// - (optional): [membershipStatusTimestamp] is the updated timestamp
  /// of the last membership status change. If `null`, the existing
  /// timestamp is retained.
  ///
  /// Returns a new [ChatRoomParticipant] instance with the specified updates.
  ChatRoomParticipant copyWith({
    Role? role,
    String? userId,
    ChatUser? chatUser,
    UserActiveStatus? userActiveStatus,
    TypeWriterStatus? typingStatus,
    MembershipStatus? membershipStatus,
    DateTime? membershipStatusTimestamp,
    bool forceNullValue = false,
  }) {
    return ChatRoomParticipant(
      role: role ?? this.role,
      userId: userId ?? this.userId,
      chatUser: forceNullValue ? chatUser : chatUser ?? this.chatUser,
      userActiveStatus: userActiveStatus ?? this.userActiveStatus,
      typingStatus: typingStatus ?? this.typingStatus,
      membershipStatus: forceNullValue
          ? membershipStatus
          : membershipStatus ?? this.membershipStatus,
      membershipStatusTimestamp: forceNullValue
          ? membershipStatusTimestamp
          : membershipStatusTimestamp ?? this.membershipStatusTimestamp,
    );
  }

  @override
  String toString() => 'ChatRoomParticipant(${toJson()})';
}
