import 'package:chatview_utils/chatview_utils.dart';

import '../extensions.dart';
import 'chat_room_participant.dart';

/// A class that represents a chat room, whether it's a one-to-one chat
/// or a group chat. It holds the information about the chat ID,
/// chat room type, the users in the chat room, the group name and photo
/// (if applicable), and the last message sent  and the number of unread
/// messages. This class also provides methods to fetch profile pictures
/// and the chat room name.
///
/// The [ChatRoom] class is used to manage chat room data and simplify
/// interactions with the chat room's properties and user details.
class ChatRoom {
  /// Creates a new [ChatRoom] instance with the specified properties.
  ///
  /// The constructor requires the `chatRoomType` parameter,
  /// which determines if the chat room is a one-to-one chat or a group chat.
  /// Optionally, you can specify the `groupPhotoUrl`, `lastMessage`,
  /// `groupName`, and `users` for the chat room.
  ///
  /// The `groupPhotoUrl` and `groupName` are used for group chats,
  /// while `users` represent the list of users in the chat room.
  /// The `lastMessage` holds information about the most recent message
  /// sent in the chat room.
  ///
  /// - (required): [chatId] The unique identifier of the chat.
  /// - (required): [chatRoomType] The type of the chat room
  /// (one-to-one or group).
  /// - (optional): [unreadMessagesCount] The number of unread
  /// messages for the current user. defaults to `0`.
  /// - (optional): [groupPhotoUrl] The URL of the group photo
  /// (null for one-to-one chats).
  /// - (optional): [chatRoomCreateBy] The user who created the chat room.
  /// (null for one-to-one chats).
  /// - (optional): [lastMessage] The last message sent in the chat room
  /// (null if no message).
  /// - (optional): [groupName] The name of the group
  /// (null for one-to-one chats).
  /// - (optional): [users] The list of users in the chat room.
  const ChatRoom({
    required this.chatId,
    required this.chatRoomType,
    this.unreadMessagesCount = 0,
    this.pinStatus = PinStatus.unpinned,
    this.muteStatus = MuteStatus.unmuted,
    this.groupPhotoUrl,
    this.chatRoomCreateBy,
    this.lastMessage,
    this.groupName,
    this.users,
    this.pinnedAt,
  });

  /// Converts a JSON object to a [ChatRoom] instance.
  ///
  /// This method is used to parse the data when a chat room is fetched from
  /// the backend and convert it into a usable object.
  ///
  /// Returns a [ChatRoom] instance populated with data from the JSON.
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      chatRoomType:
          ChatRoomTypeExtension.tryParse(json['chat_room_type'].toString()) ??
              ChatRoomType.oneToOne,
      unreadMessagesCount:
          num.tryParse(json['unread_messages_count'].toString())?.toInt() ?? 0,
      chatId: json['chat_id']?.toString() ?? '',
      groupName: json[_groupName]?.toString(),
      groupPhotoUrl: json[_groupPhotoUrl]?.toString(),
      chatRoomCreateBy: json[_chatRoomCreateBy]?.toString(),
    );
  }

  static const String _chatRoomCreateBy = 'chat_room_create_by';
  static const String _groupName = 'group_name';
  static const String _groupPhotoUrl = 'group_photo_url';

  /// The type of the chat room, either one-to-one or group.
  final ChatRoomType chatRoomType;

  /// The name of the group chat, if applicable.
  /// For one-to-one chats, this is `null`.
  final String? groupName;

  /// The URL of the group photo, if available.
  /// For one-to-one chats, this is `null`.
  final String? groupPhotoUrl;

  /// The last message sent in the chat room, if available.
  final Message? lastMessage;

  /// A list of users in the chat room.
  final List<ChatRoomParticipant>? users;

  /// The unique identifier of the chat.
  final String chatId;

  /// The unique identifier of the user who created this chat room.
  /// This is `null` for one-to-one chat rooms or if the creator information
  /// is unavailable.
  final String? chatRoomCreateBy;

  /// The status of the pin in the chat room for the current user.
  final PinStatus pinStatus;

  /// The date and time when the chat room was pinned.
  final DateTime? pinnedAt;

  /// The mute status of the chat room for the current user.
  final MuteStatus muteStatus;

  /// The number of unread messages in the chat room for the current user.
  ///
  /// A value of `0` indicates that there are no unread messages.
  final int unreadMessagesCount;

  /// Returns the name of the chat room.
  /// - For one-to-one chats, it returns the name of the user.
  /// If the name is `null`, "Unknown User" is returned.
  /// - For group chats, it returns the group name, or a comma-separated
  /// list of users' names if the group name is not available.
  ///   If both the group name and users' names are unavailable,
  ///   "Unknown Group" is returned.
  String get chatName {
    return switch (chatRoomType) {
      ChatRoomType.oneToOne =>
        users?.firstOrNull?.chatUser?.name ?? 'Unknown User',
      ChatRoomType.group =>
        groupName ?? users?.toJoinString(', ') ?? 'Unknown Group',
    };
  }

  /// Returns the profile picture URL of the chat room,
  /// or `null` if not available
  /// - For one-to-one chats, it returns the profile picture of the front user,
  /// if available.
  /// - For group chats, it returns the group photo URL, if available.
  ///
  /// Returns the profile picture URL of the chat room,
  /// or `null` if not available.
  /// - For one-to-one chats, it returns the profile picture of the front user,
  /// if available. otherwise `null` is returned.
  /// - For group chats, it returns the group photo URL,
  /// if available. otherwise `null` is returned.
  String? get chatProfile {
    return switch (chatRoomType) {
      ChatRoomType.oneToOne => users?.firstOrNull?.chatUser?.profilePhoto,
      ChatRoomType.group => groupPhotoUrl,
    };
  }

  /// {@template chatview_connect.ChatRoom.usersProfilePictures}
  /// Retrieves the profile pictures of users in the chat room as
  /// a list of URLs as strings.
  ///
  /// This method will return a list of profile picture URLs of the users
  /// in the chat room.
  ///
  /// It filters out any null values to ensure only valid URLs are returned.
  /// {@endtemplate}
  List<String> get usersProfilePictures {
    final users = this.users ?? [];
    final usersLength = users.length;
    return [
      for (var i = 0; i < usersLength; i++)
        // Filters out null values from the list.
        if (users[i].chatUser?.profilePhoto case final profilePic?) profilePic,
    ];
  }

  /// Converts the [ChatRoom] instance to a JSON object.
  ///
  /// This method is used to serialize the [ChatRoom] instance when sending
  /// data to the backend or saving it locally.
  ///
  /// Returns a `Map<String, dynamic>` representing the chat room's data.
  Map<String, dynamic> toJson({
    bool includeChatId = true,
    bool includeNullValues = true,
  }) {
    final data = <String, dynamic>{
      if (includeChatId) 'chat_id': chatId,
      'chat_room_type': chatRoomType.name,
    };

    if (includeNullValues) {
      data[_chatRoomCreateBy] = chatRoomCreateBy;
      data[_groupName] = groupName;
      data[_groupPhotoUrl] = groupPhotoUrl;
    } else {
      if (chatRoomCreateBy case final chatRoomCreateBy?) {
        data[_chatRoomCreateBy] = chatRoomCreateBy;
      }
      if (groupName case final groupName?) {
        data[_groupName] = groupName;
      }
      if (groupPhotoUrl case final groupPhotoUrl?) {
        data[_groupPhotoUrl] = groupPhotoUrl;
      }
    }
    return data;
  }

  /// Creates and Returns a copy of the current [ChatRoom] instance
  /// with updated fields.
  ///
  /// This method is useful when you want to update some properties of
  /// the chat room without affecting the rest of the properties.
  ///
  /// It creates a new instance with the provided updates while keeping
  /// the existing values for other properties.
  ChatRoom copyWith({
    String? chatId,
    ChatRoomType? chatRoomType,
    String? groupName,
    String? groupPhotoUrl,
    Message? lastMessage,
    List<ChatRoomParticipant>? users,
    int? unreadMessagesCount,
    String? chatRoomCreateBy,
    PinStatus? pinStatus,
    DateTime? pinnedAt,
    MuteStatus? muteStatus,
    bool forceNullValue = false,
  }) {
    return ChatRoom(
      unreadMessagesCount: unreadMessagesCount ?? this.unreadMessagesCount,
      chatId: chatId ?? this.chatId,
      chatRoomType: chatRoomType ?? this.chatRoomType,
      groupName: forceNullValue ? groupName : groupName ?? this.groupName,
      groupPhotoUrl:
          forceNullValue ? groupPhotoUrl : groupPhotoUrl ?? this.groupPhotoUrl,
      lastMessage:
          forceNullValue ? lastMessage : lastMessage ?? this.lastMessage,
      users: forceNullValue ? users : users ?? this.users,
      chatRoomCreateBy: forceNullValue
          ? chatRoomCreateBy
          : chatRoomCreateBy ?? this.chatRoomCreateBy,
      pinStatus: pinStatus ?? this.pinStatus,
      pinnedAt: forceNullValue ? pinnedAt : pinnedAt ?? this.pinnedAt,
      muteStatus: muteStatus ?? this.muteStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is ChatRoom &&
            runtimeType == other.runtimeType &&
            chatId == other.chatId &&
            chatRoomType == other.chatRoomType &&
            groupName == other.groupName &&
            groupPhotoUrl == other.groupPhotoUrl &&
            lastMessage == other.lastMessage &&
            users == other.users &&
            unreadMessagesCount == other.unreadMessagesCount &&
            chatRoomCreateBy == other.chatRoomCreateBy &&
            pinStatus == other.pinStatus &&
            pinnedAt == other.pinnedAt &&
            muteStatus == other.muteStatus;
  }

  @override
  int get hashCode {
    return Object.hash(
      chatId,
      chatRoomType,
      groupName,
      groupPhotoUrl,
      lastMessage,
      users,
      unreadMessagesCount,
      chatRoomCreateBy,
      pinStatus,
      pinnedAt,
      muteStatus,
    );
  }

  @override
  String toString() {
    return '''ChatRoom(
      chatId: $chatId,
      chatRoomType: $chatRoomType,
      unreadMessagesCount: $unreadMessagesCount,
      groupPhotoUrl: $groupPhotoUrl,
      chatRoomCreateBy: $chatRoomCreateBy,
      lastMessage: $lastMessage,
      groupName: $groupName,
      users: ${users?.map((e) => e.toString()).toList()},
      pinStatus: $pinStatus,
      pinnedAt: $pinnedAt,
      muteStatus: $muteStatus,
    )''';
  }
}
