import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';

import '../../../values/app_colors.dart';
import '../../../widgets/chat_user_avatar.dart';
import '../../../widgets/user_stacked_profile.dart';

class ChatDetailScreenAppBar extends StatelessWidget {
  const ChatDetailScreenAppBar({
    required this.chatName,
    required this.usersProfileURLs,
    required this.chatProfileUrl,
    this.oneToOneUserStatus,
    this.description,
    this.descriptionWidget,
    this.actions = const [],
    super.key,
  });

  final String chatName;
  final String? description;
  final Widget? descriptionWidget;
  final String? chatProfileUrl;
  final List<String> usersProfileURLs;
  final UserActiveStatus? oneToOneUserStatus;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: 0,
      centerTitle: true,
      actions: actions,
      backgroundColor: AppColors.background,
      title: Row(
        children: [
          Center(
            child: SizedBox.square(
              dimension: 40,
              child: chatProfileUrl == null
                  ? UserStackedProfile(usersProfileURLs: usersProfileURLs)
                  : ChatUserAvatar(
                      profileURL: chatProfileUrl,
                      status: oneToOneUserStatus,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSize(
              alignment: Alignment.topLeft,
              duration: const Duration(milliseconds: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chatName,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (descriptionWidget case final descriptionWidget?) ...[
                    const SizedBox(height: 2),
                    descriptionWidget,
                  ],
                  if (description?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      titleTextStyle: const TextStyle(
        fontSize: 20,
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
