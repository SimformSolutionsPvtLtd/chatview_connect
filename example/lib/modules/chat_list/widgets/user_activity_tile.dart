import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatview_db_connection/flutter_chatview_db_connection.dart';

class UserActivityTile extends StatelessWidget {
  const UserActivityTile({
    required this.userName,
    this.userStatus = UserActiveStatus.offline,
    this.userTypeStatus = TypeWriterStatus.typed,
    this.isLast = true,
    super.key,
  });

  final String userName;
  final UserActiveStatus userStatus;
  final TypeWriterStatus userTypeStatus;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (userStatus.isOnline) ...const [
          CircleAvatar(radius: 3, backgroundColor: Colors.green),
          SizedBox(width: 6),
        ],
        AnimatedCrossFade(
          alignment: Alignment.centerLeft,
          duration: const Duration(milliseconds: 300),
          secondCurve: Curves.fastOutSlowIn,
          firstChild: Text(
            isLast ? '$userName is typing' : '$userName is typing,',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
          secondChild: Text(
            isLast ? userName : '$userName,',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
          crossFadeState: userTypeStatus.isTyping
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
        ),
      ],
    );
  }
}
