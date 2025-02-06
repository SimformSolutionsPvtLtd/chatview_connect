import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatview_db_connection/flutter_chatview_db_connection.dart';

class ChatDetailScreen extends StatefulWidget {
  ChatDetailScreen({
    this.chatRoomId,
    this.currentUser,
    this.otherUsers,
    this.groupChatName,
    this.groupChatProfile,
    super.key,
  }) : assert(
          chatRoomId != null ||
              (currentUser != null && (otherUsers?.isNotEmpty ?? true)),
          'chatRoomId must not be null, or currentUser must be non-null with at least one other user.',
        );

  final String? chatRoomId;
  final ChatUser? currentUser;
  final List<ChatUser>? otherUsers;
  final String? groupChatName;
  final String? groupChatProfile;

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  ChatController? _chatController;
  ChatViewParticipantsDm? _chatRoomInfo;
  final _scrollController = ScrollController();
  final _initialMessageList = <Message>[];

  late final _config = ChatControllerConfig(
    syncOtherUsersInfo: true,
    chatRoomInfo: (chatRoom) => _chatRoomInfo = chatRoom,
    onUsersActivityChanges: _listenUsersActivityChanges,
    onChatRoomMetadataChanges: _listenChatRoomMetadataChanges,
  );

  final ValueNotifier<Map<String, ChatRoomUserDm>> _usersActivitiesNotifier =
      ValueNotifier({});

  final ValueNotifier<ChatRoomMetadata?> _chatRoomMetadataNotifier =
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
          final controller = _chatController;
          if (controller == null) {
            return const Center(
              child: RepaintBoundary(child: CircularProgressIndicator()),
            );
          }
          return ChatView(
            chatController: controller,
            chatViewState: ChatViewState.hasMessages,
            chatBackgroundConfig: ChatBackgroundConfiguration(
              backgroundColor: cardColor,
            ),
            onSendTap: ChatViewDbConnection.connectionManager.onSendTap,
            loadingWidget: const RepaintBoundary(
              child: CircularProgressIndicator(),
            ),
            typeIndicatorConfig: TypeIndicatorConfiguration(
              indicatorSize: 6,
              indicatorSpacing: 2,
              flashingCircleDarkColor: cardColor,
              flashingCircleBrightColor: primaryColor,
            ),
            appBar: ValueListenableBuilder(
              valueListenable: _chatRoomMetadataNotifier,
              builder: (_, chatRoomMetadata, __) {
                final metadata = chatRoomMetadata ?? _chatRoomInfo?.metadata;
                return ChatViewAppBar(
                  leading: Navigator.of(context).canPop()
                      ? null
                      : const SizedBox(width: 12),
                  chatTitle: metadata?.chatName ?? '-',
                  profilePicture: metadata?.chatProfilePhoto,
                );
              },
            ),
            profileCircleConfig: const ProfileCircleConfiguration(
              profileImageUrl: Constants.profileImage,
            ),
            sendMessageConfig: SendMessageConfiguration(
              replyTitleColor: primaryColor,
              replyDialogColor: cardColor,
              defaultSendButtonColor: primaryColor,
              textFieldConfig: TextFieldConfiguration(
                textStyle: const TextStyle(color: Colors.black),
                onMessageTyping: ChatViewDbConnection
                    .connectionManager.updateCurrentUserTypingStatus,
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
                onMessageRead:
                    ChatViewDbConnection.connectionManager.onMessageRead,
              ),
            ),
            featureActiveConfig: const FeatureActiveConfig(
              enableOtherUserProfileAvatar: true,
              lastSeenAgoBuilderVisibility: true,
              receiptsBuilderVisibility: true,
              enableScrollToBottomButton: true,
            ),
            replyPopupConfig: ReplyPopupConfiguration(
              onUnsendTap: ChatViewDbConnection.connectionManager.onUnsendTap,
            ),
            reactionPopupConfig: ReactionPopupConfiguration(
              userReactionCallback:
                  ChatViewDbConnection.connectionManager.userReactionCallback,
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
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    ChatViewDbConnection.connectionManager
      ..updateCurrentUserStatus(UserStatus.offline)
      ..dispose();
    _chatController?.dispose();
    super.dispose();
  }

  Future<void> _initChatRoom() async {
    final chatId = widget.chatRoomId;
    final currentUser = widget.currentUser;
    final otherUsers = widget.otherUsers ?? [];
    if (chatId != null) {
      _chatController = await ChatViewDbConnection.connectionManager
          .getChatControllerByChatRoomId(
        chatRoomId: chatId,
        initialMessageList: _initialMessageList,
        scrollController: _scrollController,
        config: _config,
      );
    } else if (currentUser != null && otherUsers.isNotEmpty) {
      _chatController =
          await ChatViewDbConnection.connectionManager.getChatControllerByUsers(
        otherUsers: otherUsers,
        currentUser: currentUser,
        groupName: widget.groupChatName,
        groupProfile: widget.groupChatProfile,
        initialMessageList: _initialMessageList,
        scrollController: _scrollController,
        config: _config,
      );
    }
    unawaited(
      ChatViewDbConnection.connectionManager.updateCurrentUserStatus(
        UserStatus.online,
      ),
    );
    if (mounted) setState(() {});
  }

  void _listenUsersActivityChanges(
    Map<String, ChatRoomUserDm> usersActivities,
  ) {
    _usersActivitiesNotifier.value = usersActivities;
  }

  void _listenChatRoomMetadataChanges(ChatRoomMetadata metadata) {
    _chatRoomMetadataNotifier.value = metadata;
  }
}
