/// chatview_connect: Cloud-Powered ChatView Integration
///
/// `chatview_connect` is your go-to solution for integrating
/// a fully functional, cloud-backed chat module into your Flutter applications.
///
/// Currently, the package offers seamless integration with Firebase
/// as the backend. In the future, additional cloud services will be supported,
/// ensuring flexibility and scalability. Built as a powerful wrapper around
/// the popular `chatview` package, it provides real-time chat capabilities
/// and a suite of easy-to-use methods to manage chats, users, and messages
/// without the hassle of complex backend setups.
library;

export 'src/chatview_connect.dart';
export 'src/enum.dart'
    hide
        DocumentChangeTypeExtension,
        MembershipStatusExtension,
        RoleExtension,
        TypeWriterStatusExtension;
export 'src/manager/chat/chat_manager.dart';
export 'src/manager/chat_list/chat_list_manager.dart';
export 'src/models/config/config.dart';
export 'src/models/models.dart';
