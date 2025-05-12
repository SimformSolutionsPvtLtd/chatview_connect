import 'package:chatview/chatview.dart';
import 'package:chatview_db_connection/chatview_db_connection.dart';
import 'package:flutter/material.dart';

import '../chat_detail/chat_detail_screen.dart';
import 'widgets/create_chat_tile.dart';

class CreateChatScreen extends StatefulWidget {
  const CreateChatScreen({super.key});

  @override
  State<CreateChatScreen> createState() => _CreateChatScreenState();
}

class _CreateChatScreenState extends State<CreateChatScreen> {
  final _chatController = ChatViewDbConnection.instance.getChatManager();
  final currentUser = ChatViewDbConnection.instance.currentUserId;
  ChatUser? currentChatUser;
  List<ChatUser> otherChatUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Chat')),
      body: FutureBuilder(
        future: _chatController.getUsers(),
        builder: (_, snapshot) {
          final users = snapshot.data?.values.toList() ?? [];
          _separateUsers(users);
          if (users.isEmpty) {
            return const Center(child: Text('No Users'));
          } else {
            final usersLength = otherChatUsers.length + 1;
            final lastLength = usersLength - 1;
            return ListView.separated(
              itemCount: usersLength,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                if (index == lastLength) {
                  return FilledButton(
                    onPressed: _createGroupChat,
                    child: const Text('Create a group of all'),
                  );
                } else {
                  final user = otherChatUsers[index];
                  return CreateChatTile(
                    username: user.name,
                    userProfile: user.profilePhoto,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatDetailScreen(
                          otherUsers: [user],
                          groupChatName: 'Test Group',
                          currentUser: currentChatUser,
                          chatRoomType: ChatRoomType.oneToOne,
                        ),
                      ),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }

  void _separateUsers(List<ChatUser> users) {
    otherChatUsers.clear();
    final usersLength = users.length;
    for (var i = 0; i < usersLength; i++) {
      final user = users[i];
      if (user.id == currentUser) {
        currentChatUser = user;
      } else {
        otherChatUsers.add(user);
      }
    }
  }

  Future<dynamic> _createGroupChat() {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(
          groupChatName: 'Test Group',
          groupChatProfile:
              'https://images.unsplash.com/photo-1739305235159-308ddffb4129?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxmZWF0dXJlZC1waG90b3MtZmVlZHw2fHx8ZW58MHx8fHx8',
          currentUser: currentChatUser,
          otherUsers: otherChatUsers,
          chatRoomType: ChatRoomType.group,
        ),
      ),
    );
  }
}
