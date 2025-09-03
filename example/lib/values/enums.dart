import 'package:chatview/chatview.dart';

enum FilterType {
  all('All'),
  unread('Unread'),
  group('Groups');

  const FilterType(this.label);

  final String label;

  bool get isAll => this == all;

  bool get isUnread => this == unread;

  bool get isGroup => this == group;

  List<ChatViewListItem> filterChats(List<ChatViewListItem> chats) {
    return switch (this) {
      FilterType.unread =>
        chats.where((e) => (e.unreadCount ?? 0) > 0).toList(),
      FilterType.group => chats.where((e) => e.chatRoomType.isGroup).toList(),
      FilterType.all => chats,
    };
  }
}
