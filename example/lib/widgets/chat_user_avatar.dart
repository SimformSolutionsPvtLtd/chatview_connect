import 'package:flutter/material.dart';
import 'package:flutter_chatview_db_connection/flutter_chatview_db_connection.dart';

class ChatUserAvatar extends StatelessWidget {
  const ChatUserAvatar({
    required this.profileURL,
    this.status = UserStatus.offline,
    super.key,
  });

  final String? profileURL;
  final UserStatus? status;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage:
              profileURL == null ? null : NetworkImage(profileURL!),
        ),
        if (status?.isOnline ?? false)
          const Positioned(
            top: 0,
            right: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(width: 2, color: Colors.white),
                ),
              ),
              child: SizedBox(width: 14, height: 14),
            ),
          ),
      ],
    );
  }
}
