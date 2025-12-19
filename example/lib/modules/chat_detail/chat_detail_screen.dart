import 'dart:async';
import 'dart:math';

import 'package:chatview/chatview.dart';
import 'package:chatview_connect/chatview_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../values/app_colors.dart';
import '../../values/borders.dart';
import '../../values/icons.dart';
import '../../values/images.dart';
import '../../values/messages_data.dart';
import '../chat_list/widgets/chatview_custom_chat_bar.dart';
import '../chat_list/widgets/reply_message_tile.dart';
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
  const ChatDetailScreen({required this.chat, super.key});

  final ChatListItem chat;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarColor: AppColors.chatviewBackground,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Builder(
        builder: (context) {
          final chatController = _chatController;
          if (chatController == null) {
            return const Center(
              child: RepaintBoundary(child: CircularProgressIndicator()),
            );
          }
          return ChatView(
            chatController: chatController,
            chatViewState: ChatViewState.hasMessages,
            featureActiveConfig: const FeatureActiveConfig(
              enableOtherUserName: false,
              enableOtherUserProfileAvatar: false,
              lastSeenAgoBuilderVisibility: false,
            ),
            appBar: ValueListenableBuilder(
              valueListenable: _displayMetadataNotifier,
              builder: (_, displayMetadata, __) {
                final metadata = displayMetadata ?? _chatRoomMetadata?.metadata;
                final roomType =
                    _chatRoomMetadata?.chatRoomType ?? ChatRoomType.oneToOne;
                final randomUser = chatController.otherUsers.isNotEmpty
                    ? chatController.otherUsers[
                        Random().nextInt(chatController.otherUsers.length)]
                    : chatController.currentUser;
                return ChatDetailScreenAppBar(
                  actions: [
                    IconButton(
                      // Handle video call
                      onPressed: () {},
                      icon: SvgPicture.asset(AppIcons.video),
                    ),
                    IconButton(
                      // Handle voice call
                      onPressed: () {},
                      icon: SvgPicture.asset(AppIcons.phone),
                    ),
                    _getOperationsPopMenu(
                      randomUser: randomUser,
                      roomType: roomType,
                      onSelected: (operation) => _onSelectOperation(
                        operation: operation,
                        controller: chatController,
                        randomUser: randomUser,
                        currentUser:
                            _chatController?.currentUser.id ?? randomUser.id,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  chatName: metadata?.chatName ?? widget.chat.name,
                  chatProfileUrl:
                      metadata?.chatProfilePhoto ?? widget.chat.imageUrl,
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
            typeIndicatorConfig: TypeIndicatorConfiguration(
              customIndicator: Container(
                margin: const EdgeInsets.only(left: 6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: AppBorders.chatBubbleBorder,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12.75,
                  horizontal: 8.75,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 2.75, backgroundColor: AppColors.grey),
                    SizedBox(width: 3),
                    CircleAvatar(radius: 2.75, backgroundColor: AppColors.grey),
                    SizedBox(width: 3),
                    CircleAvatar(radius: 2.75, backgroundColor: AppColors.grey),
                  ],
                ),
              ),
            ),
            profileCircleConfig: const ProfileCircleConfiguration(
              padding: EdgeInsets.only(right: 4),
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
            loadMoreData: (direction, message) => chatController.onLoadMoreData(
              direction,
              message,
              batchSize: 8,
            ),
            repliedMessageConfig: RepliedMessageConfiguration(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              backgroundColor: Colors.grey.shade100,
              verticalBarColor: const Color(0xFF128C7E),
              loadOldReplyMessage: (messageId) =>
                  chatController.loadOldReplyMessage(
                messageId,
                batchSize: 8,
              ),
              repliedMessageWidgetBuilder: (replyMessage) => ReplyMessageTile(
                replyMessage: replyMessage,
                chatController: chatController,
              ),
            ),
            loadingWidget: const RepaintBoundary(
              child: CircularProgressIndicator(),
            ),
            chatBackgroundConfig: ChatBackgroundConfiguration(
              backgroundColor: AppColors.background,
              backgroundImage: AppImages.chatBackground,
              groupSeparatorBuilder: (separator) {
                final date = DateTime.tryParse(separator);
                if (date == null) {
                  return const SizedBox.shrink();
                }
                String separatorDate;
                final now = DateTime.now();
                if (date.day == now.day &&
                    date.month == now.month &&
                    date.year == now.year) {
                  separatorDate = 'Today';
                } else if (date.day == now.day - 1 &&
                    date.month == now.month &&
                    date.year == now.year) {
                  separatorDate = 'Yesterday';
                } else {
                  separatorDate = DateFormat('d MMMM y').format(date);
                }
                return Align(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 3,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: AppBorders.chatBubbleBorder,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Text(
                      separatorDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xff0A0A0A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
            chatBubbleConfig: ChatBubbleConfiguration(
              // Add any action on double tap
              onDoubleTap: (message) {},
              outgoingChatBubbleConfig: const ChatBubble(
                linkPreviewConfig: LinkPreviewConfiguration(
                  linkStyle: TextStyle(color: Colors.black87, fontSize: 16),
                ),
                border: AppBorders.chatBubbleBorder,
                color: Color(0xFFD0FECF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(4),
                ),
                textStyle: TextStyle(color: Colors.black87, fontSize: 16),
                padding: EdgeInsets.all(5.5),
                receiptsWidgetConfig: ReceiptsWidgetConfig(
                  showReceiptsIn: ShowReceiptsIn.lastMessage,
                ),
              ),
              inComingChatBubbleConfig: ChatBubble(
                linkPreviewConfig: const LinkPreviewConfiguration(
                  linkStyle: TextStyle(color: Colors.black87, fontSize: 16),
                ),
                border: AppBorders.chatBubbleBorder,
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(12),
                ),
                textStyle: const TextStyle(color: Colors.black87, fontSize: 16),
                padding: const EdgeInsets.all(5.5),
                onMessageRead: (message) => chatController.onMessageRead(
                  message.copyWith(status: MessageStatus.read),
                ),
              ),
            ),
            messageConfig: MessageConfiguration(
              voiceMessageConfig: VoiceMessageConfiguration(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                playIcon: (_) => const Icon(
                  Icons.play_arrow_rounded,
                  size: 38,
                  color: Color(0xff767779),
                ),
                pauseIcon: (_) => const Icon(
                  Icons.pause_rounded,
                  size: 38,
                  color: Color(0xff767779),
                ),
                inComingPlayerWaveStyle: const PlayerWaveStyle(
                  liveWaveColor: Color(0xff000000),
                  fixedWaveColor: Color(0x33000000),
                  backgroundColor: Colors.transparent,
                  scaleFactor: 60,
                  waveThickness: 3,
                  spacing: 4,
                ),
                outgoingPlayerWaveStyle: const PlayerWaveStyle(
                  liveWaveColor: Color(0xff000000),
                  fixedWaveColor: Color(0x33000000),
                  backgroundColor: Colors.transparent,
                  scaleFactor: 60,
                  waveThickness: 3,
                  spacing: 4,
                ),
              ),
              messageReactionConfig: MessageReactionConfiguration(
                backgroundColor: Colors.white,
                borderColor: Colors.grey.shade300,
                reactionsBottomSheetConfig:
                    const ReactionsBottomSheetConfiguration(
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            sendMessageBuilder: (replyMessage) => ChatViewCustomChatBar(
              chatController: chatController,
              replyMessage: replyMessage ?? const ReplyMessage(),
              onAttachPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Attach button pressed')),
              ),
              onSendTap: chatController.onSendTap,
            ),
            replyPopupConfig: ReplyPopupConfiguration(
              onUnsendTap: chatController.onUnsendTap,
            ),
            reactionPopupConfig: ReactionPopupConfiguration(
              backgroundColor: Colors.white,
              shadow: const BoxShadow(
                blurRadius: 8,
                color: Colors.black26,
                offset: Offset(0, 4),
              ),
              userReactionCallback: chatController.userReactionCallback,
            ),
            replySuggestionsConfig: ReplySuggestionsConfig(
              onTap: (item) => chatController.onSendTap(
                item.text,
                const ReplyMessage(),
                MessageType.text,
              ),
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
    _chatController = await ChatViewConnect.instance.getChatRoomManager(
      config: _config,
      chatRoomId: widget.chat.id,
      scrollController: _scrollController,
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
    required String currentUser,
  }) async {
    switch (operation) {
      case ChatOperation.addDemoMessage:
        final messages = MessagesData.getMessages(
          [...controller.otherUsers.map((e) => e.id).toList(), currentUser],
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
