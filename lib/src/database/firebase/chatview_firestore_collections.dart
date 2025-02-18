import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import '../../chatview_db_connection.dart';
import '../../models/chat_room_dm.dart';
import '../../models/chat_room_user_dm.dart';
import '../../models/config/chat_view_firestore_path_config.dart';
import '../../models/user_chats_conversation_dm.dart';
import 'chatview_firestore_path.dart';

/// Provides Firestore collections.
abstract final class ChatViewFireStoreCollections {
  const ChatViewFireStoreCollections._();

  static final _firestoreInstance = FirebaseFirestore.instance;

  static ChatViewFireStoreCollectionNameConfig
      get _chatViewFireStorePathConfig =>
          ChatViewDbConnection.instance.getChatViewFireStorePathConfig;

  /// Collection reference for messages.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path to use
  /// message collection from that.
  ///
  /// {@template flutter_chatview_db_connection.StorageService.messageCollection}
  ///
  /// if path specified the message collection will be created at
  /// '[documentPath]/messages' and same path used to retrieve the messages.
  ///
  /// Example: 'chat/room123/messages'
  ///
  /// {@endtemplate}
  static CollectionReference<Message?> messageCollection([
    String? documentPath,
  ]) {
    final messagesCollection = _chatViewFireStorePathConfig.messages;
    final collectionRef = documentPath == null
        ? _firestoreInstance.collection(messagesCollection)
        : _firestoreInstance.doc(documentPath).collection(messagesCollection);

    return collectionRef.withConverter(
      fromFirestore: _messageFromFirestore,
      toFirestore: _messageToFirestore,
    );
  }

  static Message? _messageFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) return null;
    try {
      return Message.fromJson(data).copyWith(id: snapshot.id);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _messageToFirestore(
    Message? message,
    SetOptions? options,
  ) {
    return message?.toJson() ?? {};
  }

  /// Collection reference for chat rooms.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path where the
  /// chat collection should be accessed.
  ///
  /// {@template flutter_chatview_db_connection.StorageService.chatCollection}
  ///
  /// If a path is specified, the chat collection will be created at '[documentPath]/chats' and
  /// the same path will be used to retrieve chat rooms.
  ///
  /// Example: 'organizations/simform/chats'
  ///
  /// {@endtemplate}
  static CollectionReference<ChatRoomDm?> chatCollection([
    String? documentPath,
  ]) {
    final chatCollection = _chatViewFireStorePathConfig.chats;

    final collectionRef = documentPath == null
        ? _firestoreInstance.collection(chatCollection)
        : _firestoreInstance.doc(documentPath).collection(chatCollection);

    return collectionRef.withConverter(
      fromFirestore: _chatFromFirestore,
      toFirestore: _chatToFirestore,
    );
  }

  static ChatRoomDm? _chatFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) return null;
    try {
      return ChatRoomDm.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _chatToFirestore(
    ChatRoomDm? chat,
    SetOptions? options,
  ) {
    return chat?.toJson() ?? {};
  }

  /// Collection reference for user.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path to use
  /// user collection from that.
  ///
  /// {@template flutter_chatview_db_connection.StorageService.usersCollection}
  ///
  /// if path specified the message collection will be created at '[documentPath]/users' and
  /// same path used to retrieve the users.
  ///
  /// Example: 'users/user1'
  ///
  /// {@endtemplate}
  static CollectionReference<ChatUser?> usersCollection([
    String? documentPath,
  ]) {
    final usersCollection = _chatViewFireStorePathConfig.users;

    final collectionRef = documentPath == null
        ? _firestoreInstance.collection(usersCollection)
        : _firestoreInstance.doc(documentPath).collection(usersCollection);

    return collectionRef.withConverter(
      fromFirestore: _userFromFirestore,
      toFirestore: _userToFirestore,
    );
  }

  static ChatUser? _userFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data() ?? {};
    if (data.isEmpty) return null;
    try {
      return ChatUser.fromJson(
        data,
        config: ChatViewDbConnection.instance.getChatUserModelConfig,
      );
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _userToFirestore(
    ChatUser? user,
    SetOptions? options,
  ) {
    return user?.toJson(
          config: ChatViewDbConnection.instance.getChatUserModelConfig,
        ) ??
        {};
  }

  /// Collection reference for user in chat room collection.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path to use
  /// user collection in chat room.
  ///
  /// {@template flutter_chatview_db_connection.StorageService.chatUsersCollection}
  ///
  /// if path specified the chat room user collection will be created at '[documentPath]/users'
  /// and same path used to retrieve the users.
  ///
  /// Example: 'chat/room123/messages/users'
  ///
  /// {@endtemplate}
  static CollectionReference<ChatRoomUserDm?> chatUsersCollection([
    String? documentPath,
  ]) {
    const chatUsersCollection = ChatViewFireStorePath.users;

    final chatUsersCollectionRef = documentPath == null
        ? _firestoreInstance.collection(chatUsersCollection)
        : _firestoreInstance.doc(documentPath).collection(chatUsersCollection);

    return chatUsersCollectionRef.withConverter(
      fromFirestore: _chatUserFromFirestore,
      toFirestore: _chatUserToFirestore,
    );
  }

  static ChatRoomUserDm? _chatUserFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return data == null
        ? null
        : ChatRoomUserDm.fromJson(data).copyWith(userId: snapshot.id);
  }

  static Map<String, dynamic> _chatUserToFirestore(
    ChatRoomUserDm? user,
    SetOptions? options,
  ) {
    return user?.toJson() ?? {};
  }

  /// Collection reference for chats in user chats collection.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path to
  /// use user collection in chat room.
  ///
  /// {@template flutter_chatview_db_connection.StorageService.userChatsConversationCollection}
  ///
  /// if path specified the user chats collection will be created at '[documentPath]/user_chats/{userId}/chats'
  /// and same path used to retrieve the user chats.
  ///
  /// Example: 'user_chats/user1/chats/chat1'
  ///
  /// {@endtemplate}
  static CollectionReference<UserChatsConversationDm?>
      userChatsConversationCollection({
    required String userId,
    String? documentPath,
  }) {
    final userChatsCollection = _chatViewFireStorePathConfig.userChats;
    final collection = documentPath == null
        ? _firestoreInstance.collection(userChatsCollection)
        : _firestoreInstance.doc(documentPath).collection(userChatsCollection);
    return collection
        .doc(userId)
        .collection(ChatViewFireStorePath.chats)
        .withConverter(
          fromFirestore: _userChatsConvFromFirestore,
          toFirestore: _userChatsConvToFirestore,
        );
  }

  static UserChatsConversationDm? _userChatsConvFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return data?.isEmpty ?? true
        ? null
        : UserChatsConversationDm.fromJson(data!);
  }

  static Map<String, dynamic> _userChatsConvToFirestore(
    UserChatsConversationDm? userChatsConv,
    SetOptions? options,
  ) {
    return userChatsConv?.toJson() ?? {};
  }
}
