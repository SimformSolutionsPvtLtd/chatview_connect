import 'package:flutter/material.dart';
import 'package:chatview_db_connection/chatview_db_connection.dart';

import '../../../widgets/chat_user_avatar.dart';

class CreateChatTile extends StatelessWidget {
  const CreateChatTile({
    required this.username,
    required this.userProfile,
    this.oneToOneUserStatus,
    this.onTap,
    super.key,
  });

  final String username;
  final String? userProfile;
  final VoidCallback? onTap;
  final UserActiveStatus? oneToOneUserStatus;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.fromBorderSide(
            BorderSide(color: Colors.grey.shade300),
          ),
          borderRadius: const BorderRadius.all(Radius.circular(16)),
        ),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 34,
              child: ChatUserAvatar(
                profileURL: userProfile,
                status: oneToOneUserStatus,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
