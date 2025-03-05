import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import '../enum.dart';
import '../extensions.dart';
import 'chat_room_user_dm.dart';

/// A class that represents a chat room, whether it's a one-to-one chat
/// or a group chat. It holds the information about the chat ID,
/// chat room type, the users in the chat room, the group name and photo
/// (if applicable), and the last message sent. This class also provides
/// methods to fetch profile pictures and the chat room name.
///
/// The `ChatRoomDm` class is used to manage chat room data and
/// simplify interactions with the chat room's properties and user details.
class ChatRoomDm {
  /// Creates a new `ChatRoomDm` instance with the specified properties.
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
  /// - (optional): [groupPhotoUrl] The URL of the group photo
  /// (null for one-to-one chats).
  /// - (optional): [lastMessage] The last message sent in the chat room
  /// (null if no message).
  /// - (optional): [groupName] The name of the group
  /// (null for one-to-one chats).
  /// - (optional): [users] The list of users in the chat room.
  const ChatRoomDm({
    required this.chatId,
    required this.chatRoomType,
    this.groupPhotoUrl,
    this.lastMessage,
    this.groupName,
    this.users,
  });

  /// Converts a JSON object to a `ChatRoomDm` instance.
  ///
  /// This method is used to parse the data when a chat room is fetched from
  /// the backend and convert it into a usable object.
  ///
  /// Returns a `ChatRoomDm` instance populated with data from the JSON.
  factory ChatRoomDm.fromJson(Map<String, dynamic> json) {
    final lastMessageData = json['last_message'];
    Message? lastMessage;
    if (lastMessageData is Map<String, dynamic>) {
      try {
        lastMessage = Message.fromJson(lastMessageData);
      } catch (_) {}
    }

    return ChatRoomDm(
      chatRoomType:
          ChatRoomTypeExtension.tryParse(json['chat_room_type'].toString()) ??
              ChatRoomType.oneToOne,
      chatId: json['chat_id']?.toString() ?? '',
      groupName: json['group_name']?.toString(),
      groupPhotoUrl: json['group_photo_url']?.toString(),
      lastMessage: lastMessage,
    );
  }

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
  final List<ChatRoomUserDm>? users;

  /// The unique identifier of the chat.
  final String chatId;

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

  /// {@template flutter_chatview_db_connection.ChatRoomDm._getUsersProfilePictures}
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

  /// Converts the `ChatRoomDm` instance to a JSON object.
  ///
  /// This method is used to serialize the `ChatRoomDm` instance when sending
  /// data to the backend or saving it locally.
  ///
  /// Returns a `Map<String, dynamic>` representing the chat room's data.
  Map<String, dynamic> toJson({bool includeChatId = true}) {
    return {
      if (includeChatId) 'chat_id': chatId,
      'chat_room_type': chatRoomType.name,
      'group_name': groupName,
      'group_photo_url': groupPhotoUrl,
      'last_message': lastMessage?.toJson(),
    };
  }

  /// Creates and Returns a copy of the current `ChatRoomDm` instance
  /// with updated fields.
  ///
  /// This method is useful when you want to update some properties of
  /// the chat room without affecting the rest of the properties.
  ///
  /// It creates a new instance with the provided updates while keeping
  /// the existing values for other properties.
  ChatRoomDm copyWith({
    String? chatId,
    ChatRoomType? chatRoomType,
    String? groupName,
    String? groupPhotoUrl,
    Message? lastMessage,
    List<ChatRoomUserDm>? users,
    bool forceNullValue = false,
  }) {
    return ChatRoomDm(
      chatId: chatId ?? this.chatId,
      chatRoomType: chatRoomType ?? this.chatRoomType,
      groupName: forceNullValue ? groupName : groupName ?? this.groupName,
      groupPhotoUrl:
          forceNullValue ? groupPhotoUrl : groupPhotoUrl ?? this.groupPhotoUrl,
      lastMessage:
          forceNullValue ? lastMessage : lastMessage ?? this.lastMessage,
      users: forceNullValue ? users : users ?? this.users,
    );
  }

  @override
  String toString() => '''ChatRoomDm(${toJson()})''';
}
