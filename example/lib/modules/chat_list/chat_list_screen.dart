import 'package:chatview/chatview.dart';
import 'package:chatview_connect/chatview_connect.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../chat_detail/chat_detail_screen.dart';
import '../create_chat/create_chat_screen.dart';
import 'widgets/chat_list_item.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatController = ChatViewConnect.instance.getChatManager();

  String? currentUserId = ChatViewConnect.instance.currentUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateChatScreen,
        child: const Icon(Icons.edit),
      ),
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          FutureBuilder(
            future: _chatController.getUsers(),
            builder: (_, snapshot) {
              final data = snapshot.data ?? {};
              final users = data.values.toList();
              final user = data[currentUserId];
              return PopupMenuButton(
                onSelected: _onSelectUser,
                itemBuilder: (_) => List.generate(
                  users.length,
                  (index) {
                    final user = users[index];
                    return PopupMenuItem(
                      value: user.id,
                      child: Text('${user.id} - ${user.name}'),
                    );
                  },
                ),
                child: Text(user?.name ?? 'No User'),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: StreamBuilder(
        stream: _chatController.getChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: RepaintBoundary(child: CircularProgressIndicator()),
            );
          } else {
            final chats = snapshot.data ?? [];
            if (chats.isEmpty) return const Center(child: Text('No Chats'));
            return ListView.separated(
              itemCount: chats.length,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              separatorBuilder: (__, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final chat = chats[index];
                final chatId = chat.chatId;
                final users = chat.users ?? [];
                final unreadMessagesCount = chat.unreadMessagesCount;
                final lastMessage = chat.lastMessage;
                return ChatListItem(
                  chatName: chat.chatName,
                  chatProfile: chat.chatProfile,
                  unreadMessageCount: unreadMessagesCount,
                  usersProfileURLs: chat.usersProfilePictures,
                  oneToOneUserStatus: chat.chatRoomType.isOneToOne
                      ? users.firstOrNull?.userActiveStatus
                      : null,
                  description: lastMessage == null
                      ? null
                      : _getLastMessagePreview(
                          lastMessage: lastMessage,
                          count: unreadMessagesCount,
                          users: users,
                        ),
                  onTap: () => _navigateToChatDetailScreen(chatId),
                  trailing: PopupMenuButton(
                    child: const Icon(Icons.more_horiz_outlined),
                    onSelected: (_) => _chatController.deleteChat(chatId),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Chat'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _onSelectUser(String userId) {
    setState(() {
      currentUserId = userId;
      ChatViewConnect.instance.setCurrentUserId(userId);
    });
  }

  Future<dynamic> _navigateToCreateChatScreen() {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateChatScreen(),
      ),
    );
  }

  Future<dynamic> _navigateToChatDetailScreen(String chatId) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailScreen(chatRoomId: chatId),
      ),
    );
  }

  String _getLastMessagePreview({
    required Message lastMessage,
    required List<ChatRoomParticipant> users,
    int count = 0,
  }) {
    final reactedByUserId = lastMessage.update?['reaction']?.toString() ?? '';

    final reactionEmoji = _getReaction(
      userId: reactedByUserId,
      lastMessage: lastMessage,
    );

    final username = reactedByUserId == currentUserId
        ? 'You'
        : users
            .singleWhereOrNull((element) => element.userId == reactedByUserId)
            ?.chatUser
            ?.name;

    if (username != null || reactionEmoji != null) {
      String message;
      switch (lastMessage.messageType) {
        case MessageType.image:
          message = 'photo';
        case MessageType.voice:
          message = 'audio';
        case MessageType.text || MessageType.custom:
          message = lastMessage.message;
      }
      return '$username reacted $reactionEmoji to "$message"';
    }

    final sender = lastMessage.sentBy == currentUserId ? 'You' : 'They';
    final hasMoreMessages = count > 1;
    return switch (lastMessage.messageType) {
      MessageType.image =>
        hasMoreMessages ? '$sender sent $count photos' : '$sender sent a photo',
      MessageType.text => hasMoreMessages
          ? '$count messages'
          : lastMessage.replyMessage.message.isEmpty
              ? lastMessage.message
              : '↩ ${lastMessage.replyMessage.message} • ${lastMessage.message}',
      MessageType.voice => hasMoreMessages
          ? '$sender sent $count voice messages'
          : '$sender sent a voice message',
      _ => hasMoreMessages ? '$count new messages' : 'New message',
    };
  }

  String? _getReaction({required String userId, required Message lastMessage}) {
    final index = lastMessage.reaction.reactedUserIds.indexWhere(
      (id) => id == userId,
    );
    return index == -1 ? null : lastMessage.reaction.reactions[index];
  }
}
