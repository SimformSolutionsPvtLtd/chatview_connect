import 'package:chatview/chatview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatview_db_connection/flutter_chatview_db_connection.dart';

import '../../chat_list/widgets/user_activity_tile.dart';

class ChatRoomUserActivityTile extends StatelessWidget {
  const ChatRoomUserActivityTile({
    required this.usersActivitiesNotifier,
    required this.chatController,
    required this.chatRoomType,
    super.key,
  });

  final ChatManager chatController;
  final ChatRoomType chatRoomType;
  final ValueListenable<Map<String, ChatRoomParticipant>>
      usersActivitiesNotifier;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: usersActivitiesNotifier,
      builder: (_, usersActivity, __) {
        final otherUsers = chatController.otherActiveUsers;
        final otherUsersLength = otherUsers.length;
        final otherUsersLastIndex = otherUsersLength - 1;
        return Row(
          children: List.generate(
            otherUsersLength,
            (index) {
              final user = otherUsers[index];
              final userActivity = usersActivity[user.id];
              final typeStatus =
                  userActivity?.typingStatus ?? TypeWriterStatus.typed;
              final status =
                  userActivity?.userActiveStatus ?? UserActiveStatus.offline;
              return switch (chatRoomType) {
                ChatRoomType.oneToOne when status.isOnline =>
                  const UserActivityTile(
                    userName: 'Online',
                    userStatus: UserActiveStatus.online,
                  ),
                ChatRoomType.group => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: UserActivityTile(
                      userStatus: status,
                      userName: user.name,
                      userTypeStatus: typeStatus,
                      isLast: index == otherUsersLastIndex,
                    ),
                  ),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        );
      },
    );
  }
}
