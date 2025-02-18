import 'package:chatview/chatview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/chat_room_user_dm.dart';

import 'chatview_firestore_path.dart';

/// Provides Firestore collections.
abstract final class ChatViewFireStoreCollections {
  const ChatViewFireStoreCollections._();

  static final _firestoreInstance = FirebaseFirestore.instance;

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
    const messagesCollection = ChatViewFireStorePath.messages;
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
    const usersCollection = ChatViewFireStorePath.users;

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
      return ChatUser.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _userToFirestore(
    ChatUser? user,
    SetOptions? options,
  ) {
    return user?.toJson() ?? {};
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
}
