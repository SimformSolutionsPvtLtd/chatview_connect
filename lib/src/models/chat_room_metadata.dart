import 'package:chatview_utils/chatview_utils.dart';

import '../extensions.dart';
import 'chat_room_display_metadata.dart';

/// A data model representing the participants in a chat room.
///
/// This class holds information about the participants in a chat,
/// including the current user (the user viewing the chat) and
/// the other participants in the chat. It also includes details about
/// the chat room type (whether it’s a one-to-one or a group chat),
/// along with the group name and photo (if applicable).
final class ChatRoomMetadata {
  /// Constructs a new [ChatRoomMetadata] instance with
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
  const ChatRoomMetadata({
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

  /// {@template chatview_connect.ChatRoomMetadata.usersProfilePictures}
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

  /// Retrieves metadata for the chat room, supporting both one-to-one
  /// and group chats.
  ///
  /// This provides details such as the chat name and profile picture.
  ///
  /// - **For one-to-one chats:**
  ///   - The `chatName` is the other user's name. If unavailable,
  ///   "Unknown User" is used.
  ///   - The `chatProfilePhoto` is the other user's profile picture,
  ///   if available.
  ///
  /// - **For group chats:**
  ///   - The `chatName` is the group name. If unavailable, a comma-separated
  ///   list of user names is used.
  ///   - The `chatProfilePhoto` is the group photo URL, if available.
  ChatRoomDisplayMetadata get metadata {
    final (chatName, chatProfile) = switch (chatRoomType) {
      ChatRoomType.oneToOne => (
          otherUsers.firstOrNull?.name ?? 'Unknown User',
          otherUsers.firstOrNull?.profilePhoto,
        ),
      ChatRoomType.group => (
          groupName ?? otherUsers.toJoinString(', ') ?? 'Unknown Group',
          groupPhotoUrl,
        ),
    };
    return ChatRoomDisplayMetadata(
      chatName: chatName,
      chatProfilePhoto: chatProfile,
    );
  }

  /// Creates a copy of the current [ChatRoomMetadata] instance
  /// with updated fields.
  ///
  /// Any field not provided will retain its current value.
  ///
  /// **Parameters:**
  /// - (optional) [currentUser] The updated current user of the chat room.
  /// - (optional) [otherUsers] The updated list of other participants
  /// in the chat.
  /// - (optional) [chatRoomType] The updated chat room type
  /// (one-to-one or group).
  /// - (optional) [groupName] The updated name of the group chat
  /// (only applicable for group chats).
  /// - (optional) [groupPhotoUrl] The updated group photo URL
  /// (only applicable for group chats).
  ///
  /// Returns a new [ChatRoomMetadata] instance with the
  /// specified updates.
  ChatRoomMetadata copyWith({
    ChatUser? currentUser,
    List<ChatUser>? otherUsers,
    ChatRoomType? chatRoomType,
    String? groupName,
    String? groupPhotoUrl,
  }) {
    return ChatRoomMetadata(
      currentUser: currentUser ?? this.currentUser,
      otherUsers: otherUsers ?? this.otherUsers,
      chatRoomType: chatRoomType ?? this.chatRoomType,
      groupName: groupName ?? this.groupName,
      groupPhotoUrl: groupPhotoUrl ?? this.groupPhotoUrl,
    );
  }
}
