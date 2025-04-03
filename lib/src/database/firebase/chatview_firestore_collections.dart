import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatview_models/flutter_chatview_models.dart';

import '../../chatview_db_connection.dart';
import '../../extensions.dart';
import '../../models/chat_room.dart';
import '../../models/chat_room_participant.dart';
import '../../models/config/chat_user_config.dart';
import '../../models/config/firebase/firestore_chat_collection_name_config.dart';
import '../../models/user_chat_metadata.dart';
import '../../models/user_metadata.dart';
import 'chatview_firestore_path.dart';

/// Provides Firestore collections.
abstract final class ChatViewFireStoreCollections {
  const ChatViewFireStoreCollections._();

  static const String _createdAt = 'createdAt';
  static const String _updateAt = 'update_at';

  static final _firestoreInstance = FirebaseFirestore.instance;

  static FirestoreChatCollectionNameConfig get _chatCollectionNameConfig =>
      ChatViewDbConnection.instance.getFirestoreChatCollectionNameConfig;

  static ChatUserConfig? get _chatUserConfig =>
      ChatViewDbConnection.instance.getChatUserConfig;

  /// Collection reference for messages.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path to use
  /// message collection from that.
  ///
  /// if path specified the message collection will be created at
  /// '[documentPath]/messages' and same path used to retrieve the messages.
  ///
  /// Example: 'chat/room123/messages'
  static CollectionReference<Message?> messageCollection([
    String? documentPath,
  ]) {
    final messagesCollection = _chatCollectionNameConfig.messages;
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
      final createAtJson = data[_createdAt];
      final createAt = createAtJson is Timestamp
          ? createAtJson.toDate().toLocal().toIso8601String()
          : createAtJson;
      data[_createdAt] = createAt;
      final updateAtJson = data[_updateAt];
      final updateAt = updateAtJson is Timestamp
          ? updateAtJson.toDate().toLocal().toIso8601String()
          : updateAtJson;
      data[_updateAt] = updateAt;
      return Message.fromJson(data).copyWith(id: snapshot.id);
    } on FormatException catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _messageToFirestore(
    Message? message,
    SetOptions? options,
  ) {
    final data = message?.toJson(includeNullValues: false) ?? {};
    if (message?.createdAt case final createAtDateTime?) {
      data[_createdAt] = createAtDateTime.isNow
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createAtDateTime);
    }
    if (message?.updateAt case final updateAtDateTime?) {
      data[_updateAt] = updateAtDateTime.isNow
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(updateAtDateTime);
    }
    return data;
  }

  /// Collection reference for chat rooms.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path where the
  /// chat collection should be accessed.
  ///
  /// If a path is specified, the chat collection will be created at '[documentPath]/chats' and
  /// the same path will be used to retrieve chat rooms.
  ///
  /// Example: 'organizations/simform/chats'
  static CollectionReference<ChatRoom?> chatCollection([
    String? documentPath,
  ]) {
    final chatCollection = _chatCollectionNameConfig.chats;

    final collectionRef = documentPath == null
        ? _firestoreInstance.collection(chatCollection)
        : _firestoreInstance.doc(documentPath).collection(chatCollection);

    return collectionRef.withConverter(
      fromFirestore: _chatFromFirestore,
      toFirestore: _chatToFirestore,
    );
  }

  static ChatRoom? _chatFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) return null;
    try {
      return ChatRoom.fromJson(data).copyWith(chatId: snapshot.id);
    } on FormatException catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _chatToFirestore(
    ChatRoom? chat,
    SetOptions? options,
  ) {
    // `includeChatId` is set to false to exclude `chat_id` from the JSON,
    // preventing it from being stored in the database since it is obtained
    // from the Firebase collection reference.
    return chat?.toJson(includeChatId: false, includeNullValues: false) ?? {};
  }

  /// Collection reference for user.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path to use
  /// user collection from that.
  ///
  /// if path specified the message collection will be created at '[documentPath]/users' and
  /// same path used to retrieve the users.
  ///
  /// Example: 'users/user1'
  static CollectionReference<ChatUser?> userCollection([
    String? documentPath,
  ]) {
    final usersCollection = _chatCollectionNameConfig.users;

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
      return ChatUser.fromJson(data, config: _chatUserConfig);
    } on FormatException catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _userToFirestore(
    ChatUser? user,
    SetOptions? options,
  ) {
    return user?.toJson(config: _chatUserConfig) ?? {};
  }

  /// Collection reference for user in chat room collection.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path to use
  /// user collection in chat room.
  ///
  /// if path specified the chat room user collection will be created at '[documentPath]/users'
  /// and same path used to retrieve the users.
  ///
  /// Example: 'chat/room123/messages/users'
  static CollectionReference<ChatRoomParticipant?> chatParticipantsCollection([
    String? documentPath,
  ]) {
    const chatUsersCollection = ChatViewFireStorePath.users;

    final chatUsersCollectionRef = documentPath == null
        ? _firestoreInstance.collection(chatUsersCollection)
        : _firestoreInstance.doc(documentPath).collection(chatUsersCollection);

    return chatUsersCollectionRef.withConverter(
      fromFirestore: _chatParticipantsFromFirestore,
      toFirestore: _chatParticipantsToFirestore,
    );
  }

  static ChatRoomParticipant? _chatParticipantsFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return data == null
        ? null
        : ChatRoomParticipant.fromJson(data).copyWith(userId: snapshot.id);
  }

  static Map<String, dynamic> _chatParticipantsToFirestore(
    ChatRoomParticipant? user,
    SetOptions? options,
  ) {
    // `includeUserId` is set to false to exclude `user_id` from the JSON,
    // preventing it from being stored in the database since it is obtained
    // from the Firebase collection reference.
    return user?.toJson(includeUserId: false) ?? {};
  }

  /// Collection reference for chats in user chats collection.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path to
  /// use user collection in chat room.
  ///
  /// if path specified the user chats collection will be created at '[documentPath]/user_chats/{userId}/chats'
  /// and same path used to retrieve the user chats.
  ///
  /// Example: 'user_chats/user1/chats/chat1'
  static CollectionReference<UserChatMetadata?> userConversationsCollection({
    required String userId,
    String? documentPath,
  }) {
    final userChatsCollection = _chatCollectionNameConfig.userChats;
    final collection = documentPath == null
        ? _firestoreInstance.collection(userChatsCollection)
        : _firestoreInstance.doc(documentPath).collection(userChatsCollection);
    return collection
        .doc(userId)
        .collection(ChatViewFireStorePath.chats)
        .withConverter(
          fromFirestore: _userConvFromFirestore,
          toFirestore: _userConvToFirestore,
        );
  }

  static UserChatMetadata? _userConvFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return data?.isEmpty ?? true ? null : UserChatMetadata.fromJson(data!);
  }

  static Map<String, dynamic> _userConvToFirestore(
    UserChatMetadata? userChatsConv,
    SetOptions? options,
  ) {
    return userChatsConv?.toJson() ?? {};
  }

  /// Collection reference for user document in user chats collection.
  ///
  /// **Parameters:**
  /// - (optional): [documentPath] specifies the database path to
  /// use user chat collection.
  ///
  /// if path specified the user chats collection will be created at '[documentPath]/user_chats/{userId}'
  /// and same path used to retrieve the user chats.
  ///
  /// Example: 'user_chats/user1'
  static CollectionReference<UserMetadata?> userChatCollection({
    String? documentPath,
  }) {
    final userChatsCollection = _chatCollectionNameConfig.userChats;
    final collection = documentPath == null
        ? _firestoreInstance.collection(userChatsCollection)
        : _firestoreInstance.doc(documentPath).collection(userChatsCollection);
    return collection.withConverter(
      fromFirestore: _userChatFromFirestore,
      toFirestore: _userChatToFirestore,
    );
  }

  static UserMetadata? _userChatFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data() ?? {};
    return data.isEmpty ? null : UserMetadata.fromJson(data);
  }

  static Map<String, dynamic> _userChatToFirestore(
    UserMetadata? userChat,
    SetOptions? options,
  ) {
    return userChat?.toJson() ?? {};
  }
}
