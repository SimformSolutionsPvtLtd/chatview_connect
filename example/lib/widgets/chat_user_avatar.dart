import 'package:chatview_connect/chatview_connect.dart';
import 'package:flutter/material.dart';

class ChatUserAvatar extends StatelessWidget {
  const ChatUserAvatar({
    required this.profileURL,
    this.status = UserActiveStatus.offline,
    super.key,
  });

  final String? profileURL;
  final UserActiveStatus? status;

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
