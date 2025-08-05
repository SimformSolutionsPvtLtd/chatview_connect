import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:chatview_connect/chatview_connect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../chat_detail/chat_detail_screen.dart';
import '../create_chat/create_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatListController = ChatViewConnect.instance.getChatListManager(
    scrollController: ScrollController(),
  );

  String? currentUserId = ChatViewConnect.instance.currentUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateChatScreen,
        child: const Icon(Icons.edit),
      ),
      body: ChatViewList(
        controller: _chatListController,
        appbar: ChatViewListAppBar(
          centerTitle: false,
          title: 'Chats',
          actions: [
            FutureBuilder(
              future: _chatListController.getUsers(),
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
        menuConfig: ChatMenuConfig(
          enabled: true,
          pinStatusCallback: (result) {
            _chatListController.pinChat(result.status, result.chat.id);
            Navigator.pop(context);
          },
          muteStatusCallback: (result) {
            _chatListController.muteChat(result.status, result.chat.id);
            Navigator.pop(context);
          },
          actions: (chat) => [
            CupertinoContextMenuAction(
              trailingIcon: Icons.delete_forever,
              onPressed: () => _chatListController.deleteChat(chat.id),
              child: const Text('Delete Chat'),
            ),
          ],
        ),
        config: ChatViewListConfig(
          searchConfig: ChatViewListSearchConfig(
            textEditingController: TextEditingController(),
            debounceDuration: const Duration(milliseconds: 300),
            onSearch: (value) async {
              if (value.isEmpty) {
                return null;
              }
              final list = _chatListController.chatListMap.values
                  .where((chat) =>
                      chat.name.toLowerCase().contains(value.toLowerCase()))
                  .toList();
              return list;
            },
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
          tileConfig: ChatViewListTileConfig(
            listTypeIndicatorConfig: const ListTypeIndicatorConfig(
              showUserNames: true,
            ),
            onTap: (value) => _navigateToChatDetailScreen(value.id),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chatListController.dispose();
    super.dispose();
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
        builder: (_) => CreateChatScreen(
          chatListController: _chatListController,
        ),
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
}
