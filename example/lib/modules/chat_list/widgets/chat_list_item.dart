import 'package:flutter/material.dart';
import 'package:flutter_chatview_db_connection/flutter_chatview_db_connection.dart';

import '../../../widgets/chat_user_avatar.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({
    required this.chatName,
    required this.chatProfile,
    required this.usersProfileURLs,
    this.unreadMessageCount = 0,
    this.oneToOneUserStatus,
    this.description,
    this.onTap,
    this.onTapMore,
    super.key,
  });

  final String chatName;
  final String? chatProfile;
  final String? description;
  final VoidCallback? onTap;
  final VoidCallback? onTapMore;
  final List<String> usersProfileURLs;
  final UserStatus? oneToOneUserStatus;
  final int unreadMessageCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          border: Border.fromBorderSide(
            BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 40,
              child: ChatUserAvatar(
                profileURL: chatProfile,
                status: oneToOneUserStatus,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          chatName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: onTapMore,
                        child: const Icon(Icons.more_horiz_rounded, size: 18),
                      ),
                    ],
                  ),
                  if (description?.isNotEmpty ?? false) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            description!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: unreadMessageCount == 0
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (unreadMessageCount != 0) ...[
                          const SizedBox(width: 12),
                          CircleAvatar(
                            radius: 10,
                            child: Text(
                              unreadMessageCount.toString(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
