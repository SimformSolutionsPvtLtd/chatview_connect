import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import '../enum.dart';
import '../extensions.dart';

/// A data model representing the participants in a chat room.
///
/// This class holds information about the participants in a chat,
/// including the current user (the user viewing the chat) and
/// the other participants in the chat. It also includes details about
/// the chat room type (whether it’s a one-to-one or a group chat),
/// along with the group name and photo (if applicable).
final class ChatViewParticipantsDm {
  /// Constructs a new [ChatViewParticipantsDm] instance with
  /// the specified parameters.
  ///
  /// This constructor requires the `chatRoomType`, `currentUser`,
  /// and `otherUsers` parameters. The `currentUser` is the user currently
  /// logged in and viewing the chat, and `otherUsers` is the list of all other
  /// participants in the chat room. Optionally, you can specify the `groupName`
  /// and `groupPhotoUrl` for group chats.
  ///
  /// - (required): [chatRoomType] The type of the chat room
  /// (one-to-one or group).
  /// - (required): [currentUser] The user currently logged in and viewing
  /// the chat.
  /// - (required): [otherUsers] A list of other participants in the chat
  /// (excluding the current user).
  /// - (optional): [groupName] The name of the group
  /// (null for one-to-one chats).
  /// - (optional): [groupPhotoUrl] The URL of the group photo
  /// (null for one-to-one chats).
  const ChatViewParticipantsDm({
    required this.chatRoomType,
    required this.currentUser,
    required this.otherUsers,
    this.groupName,
    this.groupPhotoUrl,
  });

  /// The user currently logged in and viewing the chat.
  final ChatUser currentUser;

  /// The list of other participants in the chat.
  ///
  /// This includes all users in the chat except the [currentUser].
  final List<ChatUser> otherUsers;

  /// The type of the chat room, either one-to-one or group.
  final ChatRoomType chatRoomType;

  /// The name of the group chat, if applicable.
  /// For one-to-one chats, this is `null`.
  final String? groupName;

  /// The URL of the group photo, if available.
  /// For one-to-one chats, this is `null`.
  final String? groupPhotoUrl;

  /// Returns the name of the chat room.
  /// - For one-to-one chats, it returns the name of the user.
  /// If the name is `null`, "Unknown User" is returned.
  /// - For group chats, it returns the group name, or a comma-separated
  /// list of users' names if the group name is not available.
  ///   If both the group name and users' names are unavailable,
  ///   "Unknown Group" is returned.
  String get chatName {
    return switch (chatRoomType) {
      ChatRoomType.oneToOne => otherUsers.firstOrNull?.name ?? 'Unknown User',
      ChatRoomType.group =>
        groupName ?? otherUsers.toJoinString(', ') ?? 'Unknown Group',
    };
  }

  /// Returns the profile picture URL of the chat room,
  /// or `null` if not available
  /// - For one-to-one chats, it returns the profile picture of the front user,
  /// if available.
  /// - For group chats, it returns the group photo URL, if available.
  ///
  /// Returns the profile picture URL of the chat room, or
  /// `null` if not available.
  /// - For one-to-one chats, it returns the profile picture of the front user,
  /// if available. otherwise `null` is returned.
  /// - For group chats, it returns the group photo URL, if available.
  /// otherwise `null` is returned.
  String? get chatProfile {
    return switch (chatRoomType) {
      ChatRoomType.oneToOne => otherUsers.firstOrNull?.profilePhoto,
      ChatRoomType.group => groupPhotoUrl,
    };
  }

  /// {@template flutter_chatview_db_connection.ChatViewParticipantsDm._getUsersProfilePictures}
  /// Retrieves the profile pictures of users in the chat room as
  /// a list of URLs as strings.
  ///
  /// This method will return a list of profile picture URLs of the users
  /// in the chat room.
  ///
  /// It filters out any null values to ensure only valid URLs are returned.
  /// {@endtemplate}
  List<String> get usersProfilePictures {
    final otherUsersLength = otherUsers.length;
    return [
      for (var i = 0; i < otherUsersLength; i++)
        // Filters out null values from the list.
        if (otherUsers[i].profilePhoto case final profilePic?) profilePic,
    ];
  }
}
