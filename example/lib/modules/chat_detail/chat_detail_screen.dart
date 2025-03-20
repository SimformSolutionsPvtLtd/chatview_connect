import 'dart:async';

import 'package:chatview/chatview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatview_db_connection/flutter_chatview_db_connection.dart';

import 'widgets/chat_detail_screen_app_bar.dart';
import 'widgets/chat_room_user_acitivity_tile.dart';

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
          final chatController = _chatController;
          if (chatController == null) {
            return const Center(
              child: RepaintBoundary(child: CircularProgressIndicator()),
            );
          }
          return ChatView(
            chatController: chatController,
            chatViewState: ChatViewState.hasMessages,
            chatBackgroundConfig: ChatBackgroundConfiguration(
              backgroundColor: cardColor,
            ),
            onSendTap: chatController.onSendTap,
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
                return ChatDetailScreenAppBar(
                  chatName: metadata?.chatName ?? 'Unknown',
                  chatProfileUrl: metadata?.chatProfilePhoto,
                  usersProfileURLs: _chatRoomInfo?.usersProfilePictures ?? [],
                  actions: (_chatRoomInfo?.chatRoomType.isGroup ?? false)
                      ? [
                          IconButton(
                            onPressed: chatController.leaveFromGroup,
                            icon: const Icon(Icons.remove),
                          ),
                          IconButton(
                            onPressed: () => chatController.addUserInGroup(
                              userId: '2',
                              role: Role.admin,
                              includeAllChatHistory: false,
                            ),
                            icon: const Icon(Icons.add),
                          ),
                        ]
                      : [],
                  descriptionWidget: ChatRoomUserActivityTile(
                    usersActivitiesNotifier: _usersActivitiesNotifier,
                    chatController: chatController,
                    chatRoomType:
                        _chatRoomInfo?.chatRoomType ?? ChatRoomType.oneToOne,
                  ),
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
            featureActiveConfig: const FeatureActiveConfig(
              enableOtherUserProfileAvatar: true,
              lastSeenAgoBuilderVisibility: true,
              receiptsBuilderVisibility: true,
              enableScrollToBottomButton: true,
            ),
            replyPopupConfig: ReplyPopupConfiguration(
              onUnsendTap: chatController.onUnsendTap,
            ),
            reactionPopupConfig: ReactionPopupConfiguration(
              userReactionCallback: chatController.userReactionCallback,
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
      initialMessageList: _initialMessageList,
    );
    unawaited(
      _chatController?.updateUserActiveStatus(UserActiveStatus.online),
    );
    if (mounted) setState(() {});
  }

  void _listenUsersActivityChanges(
    Map<String, ChatRoomUserDm> usersActivities,
  ) {
    _usersActivitiesNotifier.value = Map.of(usersActivities);
  }

  void _listenChatRoomMetadataChanges(ChatRoomMetadata metadata) {
    _chatRoomMetadataNotifier.value = metadata;
  }
}
