import 'package:chatview/chatview.dart';
import 'package:chatview_connect/chatview_connect.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/chat_list_theme.dart';
import '../../values/app_colors.dart';
import '../../values/enums.dart';
import '../../values/icons.dart';
import '../chat_detail/chat_detail_screen.dart';
import '../create_chat/create_chat_screen.dart';
import 'widgets/category_chip.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  ChatListTheme _theme = ChatListTheme.uiTwoLight;
  bool _isDarkTheme = false;

  final _chatListController = ChatViewConnect.instance.getChatListManager(
    scrollController: ScrollController(),
  );

  final _searchController = TextEditingController();

  FilterType filter = FilterType.all;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.white),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: () => showSnackBar('Meta AI tapped'),
        child: Container(
          width: 46,
          height: 46,
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF5F2EB),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: SvgPicture.asset(AppIcons.ai),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: ChatList(
        backgroundColor: _theme.backgroundColor,
        controller: _chatListController,
        header: _buildHeader(),
        footer: _buildFooter(),
        appbar: CupertinoSliverNavigationBar(
          largeTitle: Text(
            'Chats',
            style: TextStyle(color: _theme.textColor),
          ),
          border: const Border.fromBorderSide(BorderSide.none),
          backgroundColor: _theme.backgroundColor,
          leading: PopupMenuButton(
            style: const ButtonStyle(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: _theme.iconButton,
              child: SvgPicture.asset(
                AppIcons.moreHoriz,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  _theme.iconColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'dark_theme',
                child: Text(' ${_isDarkTheme ? 'Light' : 'Dark'} Mode'),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'dark_theme':
                  _onThemeIconTap();
              }
            },
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => showSnackBar('Camera Button Tapped'),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: _theme.iconButton,
                  child: SvgPicture.asset(
                    AppIcons.camera,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      _theme.iconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateChatScreen(
                      chatListController: _chatListController,
                    ),
                  ),
                ),
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.uiTwoGreen,
                  child: SvgPicture.asset(
                    AppIcons.add,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      _theme.backgroundColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 80,
          endIndent: 0,
          color: _theme.divider,
        ),
        menuConfig: ChatMenuConfig(
          highlightColor: AppColors.menuHighlight,
          deleteCallback: (chat) => _chatListController.deleteChat(chat.id),
          pinStatusCallback: _chatListController.pinChat,
          muteStatusCallback: _chatListController.muteChat,
        ),
        tileConfig: ListTileConfig(
          lastMessageIconColor: _theme.iconColor,
          onTap: (chat) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(chat: chat),
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          showUserActiveStatusIndicator: false,
          userAvatarConfig: const UserAvatarConfig(
            radius: 28,
            backgroundColor: Color(0xFFD0FECF),
          ),
          lastMessageStatusConfig: LastMessageStatusConfig(
            showStatusFor: (message) =>
                message.sentBy == ChatViewConnect.instance.currentUserId,
            statusBuilder: (status) => switch (status) {
              MessageStatus.read => SvgPicture.asset(
                  AppIcons.checkMark,
                  width: 19,
                  height: 19,
                ),
              MessageStatus.delivered => SvgPicture.asset(
                  AppIcons.checkMark,
                  width: 19,
                  height: 19,
                  colorFilter: const ColorFilter.mode(
                    AppColors.uiTwoGrey,
                    BlendMode.srcIn,
                  ),
                ),
              MessageStatus.pending => const Icon(
                  Icons.schedule,
                  size: 19,
                  color: AppColors.uiTwoGrey,
                ),
              MessageStatus.undelivered => const Icon(
                  Icons.error_rounded,
                  size: 19,
                  color: Colors.red,
                ),
            },
          ),
          pinIconConfig: PinIconConfig(
            widget: SvgPicture.asset(AppIcons.pinned),
          ),
          typingStatusConfig: TypingStatusConfig(
            textBuilder: (chat) => 'Typing...',
            textStyle: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Color(0xff767779),
              fontSize: 14,
            ),
          ),
          timeConfig: const LastMessageTimeConfig(
            textStyle: TextStyle(
              color: Color(0xff767779),
              fontSize: 14,
            ),
          ),
          unreadCountConfig: UnreadCountConfig(
            backgroundColor: AppColors.uiTwoGreen,
            style: UnreadCountStyle.ninetyNinePlus,
            textStyle: TextStyle(color: _theme.backgroundColor),
          ),
          userNameTextStyle: TextStyle(
            fontSize: 16,
            color: _theme.textColor,
            fontWeight: FontWeight.w600,
          ),
          lastMessageTextStyle: const TextStyle(
            color: Color(0xff767779),
            fontSize: 14,
          ),
        ),
        searchConfig: SearchConfig(
          textEditingController: _searchController,
          hintText: 'Ask Meta AI or Search',
          hintStyle: TextStyle(
            fontSize: 16.4,
            color: _theme.searchText,
            fontWeight: FontWeight.w400,
          ),
          textFieldBackgroundColor: _theme.searchBg,
          prefixIcon: Icon(
            Icons.search,
            color: _theme.searchText,
            size: 24,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: TextStyle(color: _theme.textColor),
          clearIcon: Icon(
            Icons.clear,
            color: _theme.iconColor,
            size: 24,
          ),
          onSearch: (value) async {
            if (value.isEmpty) {
              return null;
            }

            List<ChatListItem> chats =
                _chatListController.chatListMap.values.toList();

            if (!filter.isAll) {
              chats = filter.filterChats(chats);
            }

            final list = chats
                .where((chat) =>
                    chat.name.toLowerCase().contains(value.toLowerCase()))
                .toList();
            return list;
          },
        ),
        stateConfig: ListStateConfig(
          noSearchChatsWidgetConfig: ChatViewStateWidgetConfiguration(
            title: filter.isAll ? null : 'No ${filter.label} Chats',
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _chatListController.dispose();
  }

  void _onThemeIconTap() {
    setState(() {
      if (_isDarkTheme) {
        _theme = ChatListTheme.uiTwoLight;
        _isDarkTheme = false;
      } else {
        _theme = ChatListTheme.uiTwoDark;
        _isDarkTheme = true;
      }
    });
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 8),
          child: SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                CategoryChip(
                  value: filter,
                  theme: _theme,
                  groupValue: FilterType.all,
                  onSelected: () => _filterChats(FilterType.all),
                ),
                const SizedBox(width: 8),
                CategoryChip(
                  value: filter,
                  theme: _theme,
                  groupValue: FilterType.unread,
                  onSelected: () => _filterChats(FilterType.unread),
                ),
                const SizedBox(width: 8),
                CategoryChip(
                  value: filter,
                  theme: _theme,
                  counts: _chatListController.chatListMap.values
                      .where((e) => e.chatRoomType.isGroup)
                      .length,
                  groupValue: FilterType.group,
                  onSelected: () => _filterChats(FilterType.group),
                ),
                const SizedBox(width: 8),
                _buildAddFilterChip(),
              ],
            ),
          ),
        ),
        _archiveWidget(),
        Divider(
          height: 1,
          indent: 80,
          endIndent: 0,
          color: _theme.divider,
        ),
      ],
    );
  }

  Widget _buildAddFilterChip() {
    return InkWell(
      onTap: () => showSnackBar('Add Filter Tapped'),
      borderRadius: const BorderRadius.all(Radius.circular(19)),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: _theme.chipBg,
          borderRadius: const BorderRadius.all(Radius.circular(19)),
        ),
        child: Icon(
          Icons.add,
          size: 20,
          color: _theme.chipText,
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 19),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppIcons.lock),
          const SizedBox(width: 3),
          const Text.rich(
            TextSpan(
              text: 'Your personal messages are ',
              children: [
                TextSpan(
                  text: 'end-to-end encrypted',
                  style: TextStyle(color: AppColors.uiTwoGreen),
                ),
              ],
              style: TextStyle(
                fontSize: 11,
                color: AppColors.uiTwoGrey,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _filterChats(FilterType type) {
    _searchController.clear();
    filter = type;
    if (type.isAll) {
      _chatListController.clearSearch();
    } else {
      final chats = type.filterChats(
        _chatListController.chatListMap.values.toList(),
      );
      _chatListController.setSearchChats(chats);
    }
    setState(() {});
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: _theme.backgroundColor,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.status,
            colorFilter: const ColorFilter.mode(
              AppColors.uiTwoGrey,
              BlendMode.srcIn,
            ),
          ),
          label: 'Updates',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.calls,
            colorFilter:
                const ColorFilter.mode(AppColors.uiTwoGrey, BlendMode.srcIn),
          ),
          label: 'Calls',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.community,
            colorFilter:
                const ColorFilter.mode(AppColors.uiTwoGrey, BlendMode.srcIn),
          ),
          label: 'Communities',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.messages,
            colorFilter:
                const ColorFilter.mode(AppColors.uiTwoGrey, BlendMode.srcIn),
          ),
          activeIcon: Badge(
            // TODO(): Show actual unread count
            label: const Text('1'),
            offset: const Offset(10, 0),
            backgroundColor: AppColors.uiTwoGreen,
            child: SvgPicture.asset(
              AppIcons.messages,
              colorFilter: ColorFilter.mode(_theme.iconColor, BlendMode.srcIn),
            ),
          ),
          label: 'Chats',
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset(
            AppIcons.settings,
            colorFilter:
                const ColorFilter.mode(AppColors.uiTwoGrey, BlendMode.srcIn),
          ),
          label: 'Settings',
        ),
      ],
      currentIndex: 3,
      selectedItemColor: _theme.textColor,
      unselectedItemColor: AppColors.uiTwoGrey,
      showUnselectedLabels: true,
      onTap: (index) {},
      type: BottomNavigationBarType.fixed,
    );
  }

  Widget _archiveWidget() {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 32, bottom: 10, right: 32),
      child: GestureDetector(
        onTap: () => showSnackBar('Archive tapped'),
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: [
            SvgPicture.asset(
              AppIcons.archived,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                _theme.searchText,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 28.66),
            Expanded(
              child: Text(
                'Archived',
                style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: _theme.searchText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
