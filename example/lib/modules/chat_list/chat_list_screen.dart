import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:chatview_connect/chatview_connect.dart' hide UserActiveStatus;
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../chat_detail/chat_detail_screen.dart';
import '../create_chat/create_chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final _chatController = ChatViewConnect.instance.getChatManager();

  String? currentUserId = 'EWEsGWI7LXXBWHkCZVMh11XMOKz2';

  final sc = StreamController<List<ChatViewListModel>>();

  @override
  void dispose() {
    chatViewListController.dispose();
    super.dispose();
  }

  ChatViewListController chatViewListController = ChatViewListController(
    initialUsersList: [],
    scrollController: ScrollController(),
  );

  //
  // StreamController<List<ChatViewListModel>> chatListStreamController =
  //     StreamController();

  // late Stream stream = _chatController.getChats();
  @override
  void initState() {
    super.initState();
    ChatViewConnect.instance.setCurrentUserId('EWEsGWI7LXXBWHkCZVMh11XMOKz2');

    // chatViewListController = ChatViewListController(
    //   initialUsersList: [],
    //   scrollController: ScrollController(),
    // );

    print('===> Initialise stream controller');

    sc.add([
      ChatViewListModel(
        id: '1',
        name: 'Breaking Bad',
        // lastMessageText:
        //     'I am not in danger, Skyler. I am the danger. A guy opens his door and gets shot and you think that of me? No. I am the one who knocks!',
        // lastMessageTime: '',
        unreadCount: 1,
        imageUrl:
            'https://m.media-amazon.com/images/M/MV5BMzU5ZGYzNmQtMTdhYy00OGRiLTg0NmQtYjVjNzliZTg1ZGE4XkEyXkFqcGc@._V1_.jpg',
        chatType: ChatType.group,
      ),
    ]);

    // chatViewListController.addSearchResults([
    //   ChatViewListModel(
    //     id: '1',
    //     name: 'Breaking Bad',
    //     lastMessageText:
    //         'I am not in danger, Skyler. I am the danger. A guy opens his door and gets shot and you think that of me? No. I am the one who knocks!',
    //     lastMessageTime: '',
    //     unreadCount: 1,
    //     imageUrl:
    //         'https://m.media-amazon.com/images/M/MV5BMzU5ZGYzNmQtMTdhYy00OGRiLTg0NmQtYjVjNzliZTg1ZGE4XkEyXkFqcGc@._V1_.jpg',
    //     chatType: ChatType.group,
    //   ),
    // ]);

    /*_chatController.getChats().first.then(
      (event) {
        print('==> get chats');
        sc.add(event
            .map(
              (e) => ChatViewListModel(
                id: e.chatId,
                name: e.chatName,
                // userActiveStatus: (e.users?.firstOrNull?.userActiveStatus ??
                //     UserActiveStatus.offline) as UserActiveStatus,
                chatType:
                    e.chatRoomType.isOneToOne ? ChatType.user : ChatType.group,
                unreadCount: e.unreadMessagesCount,
                imageUrl: e.chatProfile,
                lastMessageTime: e.lastMessage?.createdAt.toString(),
                lastMessageText: e.lastMessage?.message,
              ),
            )
            .toList());
      },
    );*/
  }

  @override
  Widget build(BuildContext context) {
    print('ehrer');
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // print(
          //     '==> Currne ${currentUserId} || ${ChatViewConnect.instance.currentUserId}');
          // _chatController.getChats().first.then(
          //   (event) {
          //     print(
          //         '==> current user id ${currentUserId} || ${ChatViewConnect.instance.currentUserId}');
          //     chatViewListController.addSearchResults(event.map(
          //       (e) {
          //         return ChatViewListModel(
          //           id: e.chatId,
          //           name: e.chatName,
          //           // userActiveStatus: (e.users?.firstOrNull?.userActiveStatus ??
          //           //     UserActiveStatus.offline) as UserActiveStatus,
          //           chatType: e.chatRoomType.isOneToOne
          //               ? ChatType.user
          //               : ChatType.group,
          //           unreadCount: e.unreadMessagesCount,
          //           imageUrl: e.chatProfile,
          //           lastMessageTime: e.lastMessage?.createdAt.toString(),
          //           lastMessageText: e.lastMessage?.message,
          //         );
          //       },
          //     ).toList());
          //   },
          // );
        },
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
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null) {
            return const Center(
              child: RepaintBoundary(child: CircularProgressIndicator()),
            );
          } else {
            final chats = snapshot.data ?? [];
            if (chats.isEmpty) return const Center(child: Text('No Chats'));

            chatViewListController.updateChatList(chats
                .map(
                  (e) => ChatViewListModel(
                    id: e.chatId,
                    name: e.chatName,
                    chatType: e.chatRoomType.isOneToOne
                        ? ChatType.user
                        : ChatType.group,
                    unreadCount: e.unreadMessagesCount,
                    imageUrl: e.chatProfile,
                    lastMessage: e.lastMessage,
                  ),
                )
                .toList());

            return ChatViewList(
              controller: chatViewListController,
              config: ChatViewListConfig(
                chatViewListTileConfig: ChatViewListTileConfig(
                  onTap: (value) => _navigateToChatDetailScreen(value.id),
                ),
              ),
            );
          }
        },
      )
      /*StreamBuilder(
        stream: _chatController.getChats(),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   return const Center(
          //     child: RepaintBoundary(child: CircularProgressIndicator()),
          //   );
          // } else {
          //   final chats = snapshot.data ?? [];
          //   if (chats.isEmpty) return const Center(child: Text('No Chats'));
          //   chatViewListController.addSearchResults(chats
          //       .map(
          //         (e) => ChatViewListModel(
          //           id: e.chatId,
          //           name: e.chatName,
          //           // userActiveStatus: (e.users?.firstOrNull?.userActiveStatus ??
          //           //     UserActiveStatus.offline) as UserActiveStatus,
          //           chatType: e.chatRoomType.isOneToOne
          //               ? ChatType.user
          //               : ChatType.group,
          //           unreadCount: e.unreadMessagesCount,
          //           imageUrl: e.chatProfile,
          //           lastMessageTime: e.lastMessage?.createdAt.toString(),
          //           lastMessageText: e.lastMessage?.message,
          //         ),
          //       )
          //       .toList());
            return ChatViewList(
              controller: chatViewListController,
              appbar: const ChatViewListAppBar(title: 'Chat view list'),
            );
            */ /*return ListView.separated(
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
            );*/ /*
          }
        },
      )*/
      ,
    );
  }

  void _onSelectUser(String userId) {
    print('==> befire user Id $currentUserId');
    setState(() {
      currentUserId = userId;
      ChatViewConnect.instance.setCurrentUserId(userId);
    });
    // _chatController.getChats().listen(
    //   (event) {
    //     print(
    //         '==> current user id ${currentUserId} || ${ChatViewConnect.instance.currentUserId}');
    //     chatViewListController.addSearchResults(event.map(
    //       (e) {
    //         return ChatViewListModel(
    //           id: e.chatId,
    //           name: e.chatName,
    //           // userActiveStatus: (e.users?.firstOrNull?.userActiveStatus ??
    //           //     UserActiveStatus.offline) as UserActiveStatus,
    //           chatType:
    //               e.chatRoomType.isOneToOne ? ChatType.user : ChatType.group,
    //           unreadCount: e.unreadMessagesCount,
    //           imageUrl: e.chatProfile,
    //           lastMessageTime: e.lastMessage?.createdAt.toString(),
    //           lastMessageText: e.lastMessage?.message,
    //         );
    //       },
    //     ).toList());
    //   },
    // );
    print('==> After user Id $currentUserId');
  }

  // yash = guM02L7E9oRXlJ4JwZ91Pi98V303
  //
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
