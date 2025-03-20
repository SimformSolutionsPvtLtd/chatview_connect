/// flutter_chatview_db_connection: Cloud-Powered ChatView Integration
///
/// `flutter_chatview_db_connection` is your go-to solution for integrating
/// a fully functional, cloud-backed chat module into your Flutter applications.
///
/// Currently, the package offers seamless integration with Firebase
/// as the backend. In the future, additional cloud services will be supported,
/// ensuring flexibility and scalability. Built as a powerful wrapper around
/// the popular `chatview` package, it provides real-time chat capabilities
/// and a suite of easy-to-use methods to manage chats, users, and messages
/// without the hassle of complex backend setups.
library;

export 'src/chatview_db_connection.dart';
export 'src/enum.dart'
    hide
        ChatRoomTypeExtension,
        DocumentChangeTypeExtension,
        MembershipStatusExtension,
        RoleExtension,
        TypeWriterStatusExtension,
        UserActiveStatusExtension;
export 'src/manager/chat/chat_manager.dart';
export 'src/models/config/config.dart';
export 'src/models/models.dart';
