import 'dart:async';
import 'dart:math';

import 'package:chatview/chatview.dart';
import 'package:chatview_db_connection/chatview_db_connection.dart';
import 'package:flutter/material.dart';

import '../../values/messages_data.dart';
import 'widgets/chat_detail_screen_app_bar.dart';
import 'widgets/chat_room_user_acitivity_tile.dart';

enum ChatOperation {
  addDemoMessage('Add Demo Message'),
  updateGroupName('Update Group Name'),
  addUser('Add User'),
  removeUser('Remove User'),
  leaveGroup('Leave Group');

  const ChatOperation(this.name);

  final String name;
}

class ChatDetailScreen extends StatefulWidget {
  const ChatDetailScreen({
    this.chatRoomId,
    this.currentUser,
    this.otherUsers,
    this.groupChatName,
    this.groupChatProfile,
    this.chatRoomType,
    super.key,
  });

  final String? chatRoomId;
  final ChatUser? currentUser;
  final List<ChatUser>? otherUsers;
  final String? groupChatName;
  final String? groupChatProfile;
  final ChatRoomType? chatRoomType;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  ChatManager? _chatController;
  ChatRoomMetadata? _chatRoomMetadata;
  final _scrollController = ScrollController();

  late final _config = ChatControllerConfig(
    syncOtherUsersInfo: true,
    onUsersActivityChange: _listenUsersActivityChanges,
    chatRoomMetadata: (metadata) => _chatRoomMetadata = metadata,
    onChatRoomDisplayMetadataChange: _listenChatRoomDisplayMetadataChanges,
  );

  final ValueNotifier<Map<String, ChatRoomParticipant>>
      _usersActivitiesNotifier = ValueNotifier({});

  final ValueNotifier<ChatRoomDisplayMetadata?> _displayMetadataNotifier =
      ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    unawaited(_initChatRoom());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final cardColor = theme.cardColor;
    return Scaffold(
      body: Builder(
        builder: (context) {
          final chatController = _chatController;
          if (chatController == null) {
            return const Center(
              child: RepaintBoundary(child: CircularProgressIndicator()),
            );
          }
          final randomUser = chatController.otherUsers.elementAt(
            Random().nextInt(chatController.otherUsers.length),
          );
          return ChatView(
            chatController: chatController,
            chatViewState: ChatViewState.hasMessages,
            featureActiveConfig: const FeatureActiveConfig(
              enableScrollToBottomButton: true,
            ),
            chatBackgroundConfig: ChatBackgroundConfiguration(
              backgroundColor: cardColor,
            ),
            appBar: ValueListenableBuilder(
              valueListenable: _displayMetadataNotifier,
              builder: (_, displayMetadata, __) {
                final metadata = displayMetadata ?? _chatRoomMetadata?.metadata;
                final roomType =
                    _chatRoomMetadata?.chatRoomType ?? ChatRoomType.oneToOne;
                return ChatDetailScreenAppBar(
                  actions: [
                    _getOperationsPopMenu(
                      randomUser: randomUser,
                      roomType: roomType,
                      onSelected: (operation) => _onSelectOperation(
                        operation: operation,
                        controller: chatController,
                        randomUser: randomUser,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  chatName: metadata?.chatName ?? 'Unknown',
                  chatProfileUrl: metadata?.chatProfilePhoto,
                  usersProfileURLs:
                      _chatRoomMetadata?.usersProfilePictures ?? [],
                  descriptionWidget: ChatRoomUserActivityTile(
                    usersActivitiesNotifier: _usersActivitiesNotifier,
                    chatController: chatController,
                    chatRoomType: _chatRoomMetadata?.chatRoomType ??
                        ChatRoomType.oneToOne,
                  ),
                );
              },
            ),
            loadingWidget: const RepaintBoundary(
              child: CircularProgressIndicator(),
            ),
            typeIndicatorConfig: TypeIndicatorConfiguration(
              indicatorSize: 6,
              indicatorSpacing: 2,
              flashingCircleDarkColor: cardColor,
              flashingCircleBrightColor: primaryColor,
            ),
            profileCircleConfig: const ProfileCircleConfiguration(
              profileImageUrl: Constants.profileImage,
            ),
            scrollToBottomButtonConfig: ScrollToBottomButtonConfig(
              backgroundColor: Colors.white,
              border: Border.fromBorderSide(
                BorderSide(color: Colors.grey.shade300),
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                weight: 10,
                size: 30,
              ),
            ),
            repliedMessageConfig: RepliedMessageConfiguration(
              backgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            ),
            onSendTap: chatController.onSendTap,
            sendMessageConfig: SendMessageConfiguration(
              replyTitleColor: primaryColor,
              replyDialogColor: cardColor,
              defaultSendButtonColor: primaryColor,
              textFieldConfig: TextFieldConfiguration(
                textStyle: const TextStyle(color: Colors.black),
                onMessageTyping: chatController.onMessageTyping,
              ),
              voiceRecordingConfiguration: const VoiceRecordingConfiguration(
                backgroundColor: Colors.white,
                recorderIconColor: Colors.black,
                waveStyle: WaveStyle(waveColor: Colors.black),
              ),
            ),
            chatBubbleConfig: ChatBubbleConfiguration(
              // Add any action on double tap
              onDoubleTap: (message) {},
              outgoingChatBubbleConfig: ChatBubble(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                receiptsWidgetConfig: const ReceiptsWidgetConfig(
                  showReceiptsIn: ShowReceiptsIn.all,
                ),
                textStyle: const TextStyle(fontSize: 15, color: Colors.white),
              ),
              inComingChatBubbleConfig: ChatBubble(
                textStyle: const TextStyle(fontSize: 15),
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                onMessageRead: (message) => chatController.onMessageRead(
                  message.copyWith(status: MessageStatus.read),
                ),
              ),
            ),
            replyPopupConfig: ReplyPopupConfiguration(
              onUnsendTap: chatController.onUnsendTap,
            ),
            reactionPopupConfig: ReactionPopupConfiguration(
              userReactionCallback: chatController.userReactionCallback,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _chatController
      ?..updateUserActiveStatus(UserActiveStatus.offline)
      ..dispose();
    super.dispose();
  }

  Future<void> _initChatRoom() async {
    _chatController = await ChatViewDbConnection.instance.getChatRoomManager(
      config: _config,
      chatRoomId: widget.chatRoomId,
      otherUsers: widget.otherUsers,
      currentUser: widget.currentUser,
      groupName: widget.groupChatName,
      chatRoomType: widget.chatRoomType,
      scrollController: _scrollController,
      groupProfile: widget.groupChatProfile,
    );
    unawaited(
      _chatController?.updateUserActiveStatus(UserActiveStatus.online),
    );
    if (mounted) setState(() {});
  }

  void _listenUsersActivityChanges(
    Map<String, ChatRoomParticipant> usersActivities,
  ) {
    _usersActivitiesNotifier.value = Map.of(usersActivities);
  }

  void _listenChatRoomDisplayMetadataChanges(ChatRoomDisplayMetadata metadata) {
    _displayMetadataNotifier.value = metadata;
  }

  Widget _getOperationsPopMenu({
    required ChatRoomType roomType,
    required ChatUser randomUser,
    void Function(ChatOperation)? onSelected,
  }) {
    return PopupMenuButton(
      child: const Icon(Icons.more_horiz_outlined),
      onSelected: (operation) => onSelected?.call(operation),
      itemBuilder: (_) => roomType.isOneToOne
          ? [
              PopupMenuItem(
                value: ChatOperation.addDemoMessage,
                child: Text(ChatOperation.addDemoMessage.name),
              ),
            ]
          : [
              for (var i = 0; i < ChatOperation.values.length; i++)
                if (ChatOperation.values[i] == ChatOperation.addUser ||
                    ChatOperation.values[i] == ChatOperation.removeUser)
                  PopupMenuItem(
                    value: ChatOperation.values[i],
                    child: Text(
                      '${ChatOperation.values[i].name} - ${randomUser.name}',
                    ),
                  )
                else
                  PopupMenuItem(
                    value: ChatOperation.values[i],
                    child: Text(ChatOperation.values[i].name),
                  ),
            ],
    );
  }

  Future<void> _onSelectOperation({
    required ChatOperation operation,
    required ChatManager controller,
    required ChatUser randomUser,
  }) async {
    switch (operation) {
      case ChatOperation.addDemoMessage:
        final messages = MessagesData.getMessages(
          controller.otherUsers.map((e) => e.id).toList(),
        );
        final messagesLength = messages.length;
        await Future.wait([
          for (var i = 0; i < messagesLength; i++)
            controller.onSendTapFromMessage(messages[i]),
        ]);
        break;
      case ChatOperation.updateGroupName:
        await controller.updateGroupChat(
          displayMetadata: ChatRoomDisplayMetadata(
            chatName: 'Group ${Random().nextInt(100)}',
            chatProfilePhoto: Constants.profileImage,
          ),
        );
        break;
      case ChatOperation.addUser:
        await controller.addUserInGroup(
          role: Role.admin,
          userId: randomUser.id,
          includeAllChatHistory: true,
          startDate: DateTime(2020, 12, 1),
        );
        break;
      case ChatOperation.removeUser:
        await controller.removeUserFromGroup(userId: randomUser.id);
        break;
      case ChatOperation.leaveGroup:
        await controller.leaveFromGroup();
        if (mounted) Navigator.maybePop(context);
        break;
    }
  }
}
