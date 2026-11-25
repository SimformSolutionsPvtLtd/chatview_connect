---
name: chatview-connect-firebase
description: >-
  Connect a chatview chat screen and chat list to Firebase (Cloud Firestore
  and Firebase Storage) with the chatview_connect package: initialize
  ChatViewConnect, set the current user id, replace ChatListController with
  ChatListManager and ChatController with ChatManager, create one-to-one and
  group chats (createChat, createGroupChat, getChatRoomManager), send text and
  image messages, typing indicators, read receipts, reactions, unsend, group
  membership, custom user and collection names (ChatUserConfig,
  FirebaseCloudConfig), and Firestore and Storage security rules. Use when
  adding a backend to chatview, wiring ChatView or ChatList to Firebase, or
  debugging code that uses ChatViewConnect, ChatManager or ChatListManager.
---

# chatview_connect: Firebase backend for chatview

`chatview_connect` gives `ChatView` and `ChatList` a ready-made Firebase
backend. Two classes replace the controllers you would otherwise build:

- `ChatListManager` extends `ChatListController` (for `ChatList`).
- `ChatManager` extends `ChatController` (for `ChatView`).

Both are normal chatview controllers, so everything in the
`chatview-chat-screen` and `chatview-chat-list` skills still applies, except
where **Rules** below says otherwise: the managers own the data, so you never
build `Message` or `ChatListItem` objects yourself. Install those two skills
with `dart run skills@ get` (they ship with the `chatview` package).

Firebase is the only supported backend. Voice messages are not supported.

## Workflow

1. **Inspect the project first.** Check for `firebase_core`,
   `firebase_options.dart`, Firebase Auth, and any existing Firestore `users`
   collection and its field names. Find where sign-in and sign-out happen and
   how the app navigates. If there is no Firebase setup, follow
   [FlutterFire](https://firebase.google.com/docs/flutter/setup) first
   (`flutterfire configure`), and enable Authentication, Cloud Firestore and
   Cloud Storage in the Firebase console.
2. **Add dependencies:** `flutter pub add chatview chatview_connect
   firebase_core cloud_firestore firebase_auth` (the last one if the app uses
   Firebase Auth). Never hard-code versions. See **Troubleshooting** if
   `pub get` fails.
3. **Initialize** in `main` (**Setup**).
4. **Users:** make sure every signed-in user has a document in the `users`
   collection (**Users**).
5. **Wire the list:** `getChatListManager` into `ChatList`.
6. **Wire the chat screen:** `getChatRoomManager` into `ChatView`.
7. **Deploy the security rules** (**Security rules**).
8. Run `flutter analyze`. Test with two real accounts on two devices: send
   text and an image, type, read, react and unsend.

Method tables, configuration classes and enums: `references/api.md`.

## Rules

- **Order matters:** `Firebase.initializeApp` → `ChatViewConnect.initialize`
  → `ChatViewConnect.instance.setCurrentUserId` (after sign-in) → create
  managers. `ChatViewConnect.instance` asserts when not initialized.
  `initialize` only works once: later calls are ignored, including ones with a
  different config, so set `chatUserConfig` and `cloudServiceConfig` in the
  first call.
- **The current user id must be the Firebase Auth uid.** The security rules
  compare `request.auth.uid` with the user document id and the chat's user
  documents. Call `setCurrentUserId(uid)` after sign-in. On sign-out dispose
  the managers, then call `resetCurrentUserId()`. `setCurrentUserId` asserts a
  non-empty id and `getChatRoomManager` throws "Current User ID can't be
  empty!" before it is set.
- **The package never writes the `users` collection.** Each user needs a
  document in it (**Users**). `createChat` and `createGroupChat` throw
  "Some of User IDs … not exists" when one is missing.
- **Firestore is the source of truth. Don't touch the local data.** On every
  snapshot the manager replaces `initialMessageList` with all messages of the
  room (for a group, from when the user joined). The list manager
  replaces a tile whenever its room changes in Firestore. So don't call
  `addMessage`, `updateMessage`, `setReaction`, `addChat`, `updateChat` or
  `removeChat` yourself, and don't seed `initialMessageList`. Use the manager
  methods in the table below instead.
- **Dispose both managers.** `ChatManager.dispose()` cancels its Firestore
  streams and disposes the `ScrollController`; `ChatListManager.dispose()`
  cancels its subscription the same way. Pass each a new `ScrollController`.
  Don't share one, and dispose only after `ChatView` or `ChatList` is
  unmounted.
- **`chatViewState` is always `ChatViewState.hasMessages`.** Messages come
  from the stream, not from you. Show your own spinner while
  `await getChatRoomManager(...)` runs, and only then build `ChatView`.
- **Create the manager in the `State` that builds the widget** and keep
  `ChatList` mounted (see `chatview-chat-list`: the controller emits its first
  list once).
- **`ChatListItem.id` is the chat room id.** Pass `chat.id` as
  `chatRoomId` to `getChatRoomManager`. `createChat(otherUserId)` returns the
  existing room's id if the two users already have one.
- **Voice is not uploaded.** Set
  `SendMessageConfiguration(allowRecordingVoice: false)`. Otherwise a recorded
  message is written to Firestore with the sender's local file path, which no
  other device can play.
- **Images** are sent as usual through `onSendTap` (a local path); the manager
  uploads them to Storage (`chats/{chatId}/images/…`) and stores the URL.
  Deleting a message or chat deletes its files.
- **Message editing is not supported.** `ChatManager` has no edit method, so
  leave `FeatureActiveConfig.enableMessageEditing` off.
- **Typing indicator:** wire `onMessageTyping`. One-to-one chats show the
  indicator automatically. In group chats nothing is shown automatically: use
  `ChatControllerConfig.onUsersActivityChange` to draw it.
- **Read receipts:** `onMessageRead` is called by an incoming bubble that is
  not yet `read`. Pass `message.copyWith(status: MessageStatus.read)`. The
  status comes back through the stream.
- **Sent messages** are written with status `delivered`. A message is added to
  the local list first, then written to Firestore.
- **Pagination:** the manager streams the whole history, and
  `enablePagination` is off by default. Leave it off.
  `RepliedMessageConfiguration.loadOldReplyMessage` is required by chatview, so
  always wire it to `manager.loadOldReplyMessage`.
- **`lazyCreateChat: true`** (with `currentUser`, `otherUsers` and
  `chatRoomType` instead of `chatRoomId`) creates the room on the first send,
  so no empty chats appear. Until then typing indicators, group changes and
  leaving don't work. `ChatListManager` lists one-to-one rooms without
  messages by default; `includeEmptyChats: false` hides them (groups are always
  listed).
- **Custom user fields or collection names** (**Custom fields and paths**) must
  also be changed in the security rules.
- A message whose `createdAt` can't be parsed is silently skipped.

Manager methods that replace the usual chatview wiring:

| `ChatView` / `ChatList` parameter | Pass |
|---|---|
| `onSendTap` | `manager.onSendTap` |
| `textFieldConfig.onMessageTyping` | `manager.onMessageTyping` |
| `inComingChatBubbleConfig.onMessageRead` | `(m) => manager.onMessageRead(m.copyWith(status: MessageStatus.read))` |
| `repliedMessageConfig.loadOldReplyMessage` | `(id) => manager.loadOldReplyMessage(id, batchSize: 8)` |
| `replyPopupConfig.onUnsendTap` | `manager.onUnsendTap` |
| `reactionPopupConfig.userReactionCallback` | `manager.userReactionCallback` |
| `menuConfig.pinStatusCallback` | `listManager.pinChat` |
| `menuConfig.muteStatusCallback` | `listManager.muteChat` |
| `menuConfig.deleteCallback` | `(chat) => listManager.deleteChat(chat.id)` |

## Setup

```dart
import 'package:chatview_connect/chatview_connect.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';

// Generated by `flutterfire configure`.
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ChatViewConnect.initialize(ChatViewCloudService.firebase);
  runApp(const MyApp()); // your app
}
```

Set the user after sign-in and reset it on sign-out:

```dart
import 'package:chatview_connect/chatview_connect.dart';
import 'package:firebase_auth/firebase_auth.dart';

void onAuthChanged(User? user) {
  if (user == null) {
    // Leave the chat screens first, so ChatManager / ChatListManager are
    // disposed while no widget uses them.
    ChatViewConnect.instance.resetCurrentUserId();
  } else {
    ChatViewConnect.instance.setCurrentUserId(user.uid);
  }
}
```

## Users

The package reads users from the top-level `users` collection. Create the
document when the account is created (and keep it current), with the Auth uid
as the document id. The field names below are the defaults; if you set a
`ChatUserConfig` (**Custom fields and paths**), write its `idKey`, `nameKey`
and `profilePhotoKey` instead:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> saveChatUser(User user) {
  return FirebaseFirestore.instance.collection('users').doc(user.uid).set({
    'id': user.uid,
    'name': user.displayName ?? 'Unknown',
    'profilePhoto': user.photoURL, // http(s) URL or null
  });
}
```

To list people for "new chat" screens use `getUsers()` on either manager. It
returns `Map<String, ChatUser>` (an empty map on a Firebase error). Remove
the current user from it yourself.

## Examples

Chat list with pin, mute, delete and a tile tap that opens the room:

```dart
import 'package:chatview/chatview.dart';
import 'package:chatview_connect/chatview_connect.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late final ChatListManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = ChatViewConnect.instance.getChatListManager(
      scrollController: ScrollController(),
    );
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChatList(
        controller: _manager,
        appbar: const ChatListAppBar(titleText: 'Chats'),
        tileConfig: ListTileConfig(
          onTap: (chat) => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChatRoomScreen(chatRoomId: chat.id),
            ),
          ),
        ),
        menuConfig: ChatMenuConfig(
          pinStatusCallback: _manager.pinChat,
          muteStatusCallback: _manager.muteChat,
          deleteCallback: (chat) => _manager.deleteChat(chat.id),
        ),
      ),
    );
  }
}
```

Chat screen for an existing room:

```dart
class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({required this.chatRoomId, super.key});

  final String chatRoomId;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  ChatManager? _manager;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _open();
  }

  Future<void> _open() async {
    try {
      final manager = await ChatViewConnect.instance.getChatRoomManager(
        chatRoomId: widget.chatRoomId,
        scrollController: ScrollController(),
      );
      if (!mounted) {
        manager.dispose();
        return;
      }
      setState(() => _manager = manager);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  void dispose() {
    _manager?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final manager = _manager;
    if (manager == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: _error == null
              ? const CircularProgressIndicator()
              : Text('Could not open chat: $_error'),
        ),
      );
    }
    return Scaffold(
      body: ChatView(
        chatController: manager,
        chatViewState: ChatViewState.hasMessages,
        onSendTap: manager.onSendTap,
        sendMessageConfig: SendMessageConfiguration(
          allowRecordingVoice: false, // voice is not uploaded
          textFieldConfig: TextFieldConfiguration(
            onMessageTyping: manager.onMessageTyping,
            textStyle: const TextStyle(color: Colors.black87),
          ),
        ),
        chatBubbleConfig: ChatBubbleConfiguration(
          inComingChatBubbleConfig: ChatBubble(
            onMessageRead: (message) => manager.onMessageRead(
              message.copyWith(status: MessageStatus.read),
            ),
          ),
        ),
        repliedMessageConfig: RepliedMessageConfiguration(
          loadOldReplyMessage: (messageId) =>
              manager.loadOldReplyMessage(messageId, batchSize: 8),
        ),
        replyPopupConfig: ReplyPopupConfiguration(
          onUnsendTap: manager.onUnsendTap,
        ),
        reactionPopupConfig: ReactionPopupConfiguration(
          userReactionCallback: manager.userReactionCallback,
        ),
      ),
    );
  }
}
```

Starting a chat with a user from a "new chat" screen (creates the room, or
returns the existing one, then opens it):

```dart
Future<void> startChat(
  BuildContext context,
  ChatListManager manager,
  String otherUserId,
) async {
  final chatRoomId = await manager.createChat(otherUserId);
  if (chatRoomId == null || !context.mounted) return; // creation failed
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ChatRoomScreen(chatRoomId: chatRoomId),
    ),
  );
}
```

For a group, `createGroupChat(groupName: ..., participants: {'uid1':
Role.admin, 'uid2': Role.user})` returns the room id; the current user is
added automatically.

Typing, activity and header data (group name and photo, who is online) come
from `ChatControllerConfig`, passed to `getChatRoomManager(config: ...)`:

```dart
final config = ChatControllerConfig(
  syncOtherUsersInfo: true,
  chatRoomMetadata: (metadata) {
    // Room type, group name, group photo, current user and other users.
  },
  onUsersActivityChange: (users) {
    // Map<userId, ChatRoomParticipant>: typingStatus, userActiveStatus,
    // membershipStatus, role.
  },
  onChatRoomDisplayMetadataChange: (display) {
    // display.chatName and display.chatProfilePhoto changed: update the app bar.
  },
);
```

Presence is not automatic: call `updateUserActiveStatus(UserActiveStatus.online)`
on either manager when the app resumes and `offline` when it pauses (for
example from `WidgetsBindingObserver.didChangeAppLifecycleState`).

## Custom fields and paths

Different user field names:

```dart
ChatViewConnect.initialize(
  ChatViewCloudService.firebase,
  chatUserConfig: const ChatUserConfig(
    idKey: 'user_id',
    nameKey: 'first_name',
    profilePhotoKey: 'avatar',
  ),
);
```

Different collection names or a nested users collection:

```dart
ChatViewConnect.initialize(
  ChatViewCloudService.firebase,
  cloudServiceConfig: FirebaseCloudConfig(
    // The users collection is organizations/simform/users.
    databasePathConfig: FirestoreChatDatabasePathConfig(
      userCollectionPath: 'organizations/simform',
    ),
    collectionNameConfig: FirestoreChatCollectionNameConfig(
      users: 'simform_users',
      chats: 'conversations',
    ),
  ),
);
```

Collection names can't be empty or contain `/`. Update the matching
`*Collection()` functions in the security rules.

## Security rules

Use the rules that ship with the installed `chatview_connect`, so they match
its version. Find the package folder in `.dart_tool/package_config.json`
(`chatview_connect` → `rootUri`) and copy these files, then deploy them
(Firebase console or `firebase deploy --only firestore:rules,storage`):

- Firestore: `doc/firebase/rules/firestore-security-rules`
- Storage: `doc/firebase/rules/storage-security-rules`

They require a signed-in user whose Auth uid has a `users` document, and let
only room members read and write a room's messages and files. Edit the
`TODO` path functions at the top if you used custom collection names. Without
deployed rules, reads and writes fail with `permission-denied` (or the project
is left in an open test mode). The Storage rules read Firestore, so the first
deploy may ask you to grant the Firebase Rules service access to Firestore.
Accept it, or Storage reads and writes fail.

## Troubleshooting

- `version solving failed` → use the `chatview` and `chatview_connect`
  versions that the Compatibility table in the `chatview_connect` README lists
  together. Don't use `dependency_overrides` to force them.
- "Current User ID can't be empty!" → `setCurrentUserId` wasn't called yet
  (or `resetCurrentUserId` ran) before creating a manager.
- "No Users Found!" or "Some of User IDs … not exists" → the room or user has
  no matching document in the `users` collection.
- `permission-denied` → rules not deployed, signed out, or the current user id
  isn't the Auth uid. Some methods swallow Firebase errors instead of
  throwing (`getUsers` returns an empty map, `deleteMessage` returns `false`),
  so an empty result can also mean a rules failure. Room methods
  (`onUnsendTap`, `onMessageRead`, group changes…) also do nothing, or return
  `false`, until the room exists and its streams are running (for example
  before the first send with `lazyCreateChat`).
- Chat list stays empty → the user is in no rooms yet, or
  `includeEmptyChats: false` hides one-to-one rooms without messages.
- Chat list spinner, or it appears only after the next change → see the
  `chatview-chat-list` skill: create the manager in the `State` that builds
  `ChatList` and keep it mounted.
- Messages appear only on the sender's device → the other user isn't a member
  of the room, or the rules reject the write.
- A voice message plays only on the sender's device → `allowRecordingVoice`
  is true.
- `ChatView`-side problems (theme, bubbles, reply popup, translations) →
  `chatview-chat-screen` skill. Upgrading → `chatview-migration` skill.
