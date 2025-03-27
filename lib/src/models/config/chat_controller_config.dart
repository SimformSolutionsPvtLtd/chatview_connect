import 'package:flutter/material.dart';

import '../chat_room_display_metadata.dart';
import '../chat_room_metadata.dart';
import '../chat_room_participant.dart';

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
  /// - (optional): [chatRoomMetadata] Provides details about the chat room,
  /// including participants and other metadata. This callback receives an
  /// instance of [ChatRoomMetadata] containing relevant chat room
  /// information.
  ///
  /// - (optional): [onUsersActivityChange] Listens for updates on user
  /// activity within the chat room, such as online status and typing
  /// indicators. This callback receives a map of user IDs to their
  /// corresponding [ChatRoomParticipant] data.
  ///
  /// - (optional): [onChatRoomDisplayMetadataChange] Listens for real-time
  /// updates to chat room metadata, including the chat name and profile photo.
  ///   - For **group chats**, this callback receives an instance of
  ///   [ChatRoomDisplayMetadata] with updated details.
  ///   - For **one-to-one chats**, `ChatRoomMetadata` is still provided,
  ///   but updates are based on the other user's profile.
  ///
  /// **Note:** For one-to-one chats, setting the typing indicator value from
  /// the chat controller is handled internally.
  const ChatControllerConfig({
    required this.syncOtherUsersInfo,
    this.chatRoomMetadata,
    this.onUsersActivityChange,
    this.onChatRoomDisplayMetadataChange,
  });

  /// Whether to sync other users' information.
  final bool syncOtherUsersInfo;

  /// Callback to receive chat room participants' details.
  final ValueSetter<ChatRoomMetadata>? chatRoomMetadata;

  /// Callback triggered when users' activity status (e.g., online/offline) changes.
  final ValueSetter<Map<String, ChatRoomParticipant>>? onUsersActivityChange;

  /// Callback triggered when chat room metadata (e.g., name, profile) updates.
  final ValueSetter<ChatRoomDisplayMetadata>? onChatRoomDisplayMetadataChange;
}
