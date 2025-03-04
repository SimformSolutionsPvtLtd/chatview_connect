import 'package:flutter/material.dart';

import '../chat_room_metadata_model.dart';
import '../chat_room_user_dm.dart';
import '../chat_view_participants_dm.dart';

/// Configuration for managing chat connections and real-time updates.
class ChatControllerConfig {
  /// Creates a configuration for the connection manager.
  ///
  /// **Parameters:**
  ///
  /// - (required): [syncOtherUsersInfo] Determines whether the chat controller
  /// should listen for real-time updates to user information,
  /// such as profile picture and username changes.
  ///   - If `true`, user details (e.g., username, profile picture) will be
  ///   dynamically fetched and updated.
  ///   - If `false`, no user data will be fetched.
  ///
  /// - (optional): [chatRoomInfo] Provides details about the chat room,
  /// including participants and other metadata. This callback receives an
  /// instance of [ChatViewParticipantsDm] containing relevant chat room
  /// information.
  ///
  /// - (optional): [onUsersActivityChanges] Listens for updates on user
  /// activity within the chat room, such as online status and typing
  /// indicators. This callback receives a map of user IDs to their
  /// corresponding [ChatRoomUserDm] data.
  ///
  /// - (optional): [onChatRoomMetadataChanges] Listens for real-time updates
  /// to chat room metadata, including the chat name and profile photo.
  ///   - For **group chats**, this callback receives an instance of
  ///   [ChatRoomMetadata] with updated details.
  ///   - For **one-to-one chats**, `ChatRoomMetadata` is still provided,
  ///   but updates are based on the other user's profile.
  ///
  /// **Note:** For one-to-one chats, setting the typing indicator value from
  /// the chat controller is handled internally.
  const ChatControllerConfig({
    required this.syncOtherUsersInfo,
    this.chatRoomInfo,
    this.onUsersActivityChanges,
    this.onChatRoomMetadataChanges,
  });

  /// Whether to sync other users' information.
  final bool syncOtherUsersInfo;

  /// Callback to receive chat room participants' details.
  final ValueSetter<ChatViewParticipantsDm>? chatRoomInfo;

  /// Callback triggered when users' activity status (e.g., online/offline) changes.
  final ValueSetter<Map<String, ChatRoomUserDm>>? onUsersActivityChanges;

  /// Callback triggered when chat room metadata (e.g., name, profile) updates.
  final ValueSetter<ChatRoomMetadata>? onChatRoomMetadataChanges;
}
