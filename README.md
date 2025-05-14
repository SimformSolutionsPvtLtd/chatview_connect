# ChatView Connect

[![Build](https://github.com/SimformSolutionsPvtLtd/chatview_connect/actions/workflows/flutter.yaml/badge.svg?branch=master)](https://github.com/SimformSolutionsPvtLtd/chatview_connect/actions) [![chatview_connect](https://img.shields.io/pub/v/chatview_connect?label=chatview_connect)](https://pub.dev/packages/chatview_connect)

`chatview_connect` is a specialized wrapper for [`chatview`][chatViewPackage]
package providing seamless integration with Database & Storage for your flutter chat app.

_Check out other amazing
open-source [Flutter libraries](https://pub.dev/publishers/simform.com/packages)
and [Mobile libraries](https://github.com/SimformSolutionsPvtLtd/Awesome-Mobile-Libraries) developed
by Simform Solutions!_

## ✨ Key Features

- **Easy Setup:** Integrate [`chatview`][chatViewPackage] with your cloud service in 3 steps —> set
  the **Service Type** -> set **User ID** -> get **`ChatManager`**
  and use it with [`chatview`][chatViewPackage].
- Supports **one-on-one and group chats** with **media uploads** *(audio not supported).*

***Note:*** *Currently, it supports only Firebase Cloud Services. Support for additional cloud
services will be included in future releases.*

## 🎞️ Preview

<img alt="The example app running in iOS" src="https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_chatview/main/preview/chatview.gif" width="300"/>

## 🚀 Getting Started

Add dependency to `pubspec.yaml`:

```yaml
dependencies:
  chatview_connect: <latest-version>
```

## 🔧 Setup

- **Firebase Integration:** Set up a [Firebase](https://firebase.google.com/) project (if you
  haven’t) and connect it to your Flutter app
  using [this guide](https://firebase.google.com/docs/flutter/setup?platform=android).

- Initialize `chatview_connect` just after the firebase initialization, specify your
  desired cloud service for use with [`chatview`][chatViewPackage].

    ```dart
    ChatViewConnect(ChatViewCloudService.firebase);
    ````

- Set Current User:
    ```dart
    ChatViewConnect.instance.setCurrentUserId('current_user_id'); 
    ````

## 🏗 Using with [ChatView][chatViewPackage]

The `ChatController` from [`chatview`][chatViewPackage] has been replaced by `ChatManager`. It can
be used for both **existing** and **new chat rooms**, depending on the parameters
provided. [see full example here.](https://github.com/SimformSolutionsPvtLtd/chatview_connect/blob/master/example/lib/main.dart)

**Before:**

```dart
ChatController _chatController = ChatController(
  initialMessageList: [...],
  scrollController: ScrollController(),
  currentUser: const ChatUser(...),
  otherUsers: const [...],
);
````

**After:**

- Simply specify the `chatRoomId`, and it will automatically fetch the participants and return the
  corresponding `ChatManager`.

````dart
ChatManager _chatController = await ChatViewConnect.instance.getChatManager(
  // You can get `chatRoomId` from `createChat`, `createGroupChat`, or `getChats`
  chatRoomId: 'chat_room_id',
  scrollController: ScrollController(),
  config: ChatControllerConfig(syncOtherUsersInfo: true),
);
````

`ChatManager` internally manages various chat operations, when the corresponding methods are
specified in the [`chatview`][chatViewPackage] widget.

```dart

@override
Widget build(BuildContext context) {
  // ...
    child: ChatView(
      chatController: _chatController,
      // Sending messages and uploading media (image, or custom)
      // audio files are not uploaded, as network audio is not compatible with `chatview`.
      onSendTap: _chatController.onSendTap,
      sendMessageConfig: SendMessageConfiguration(
        textFieldConfig: TextFieldConfiguration(
          // Managing typing indicators 
          // Note: automatic for one-to-one chats, manual for groups chats
          onMessageTyping: _chatController.onMessageTyping,
        ),
      ),
      chatBubbleConfig: ChatBubbleConfiguration(
        inComingChatBubbleConfig: ChatBubble(
          // Tracking message read status
          onMessageRead: (message) => _chatController.onMessageRead(
            message.copyWith(status: MessageStatus.read),
          ),
        ),
      ),
      // Unsending messages
      replyPopupConfig: ReplyPopupConfiguration(
        onUnsendTap: _chatController.onUnsendTap,
      ),
      // Updating reactions
      reactionPopupConfig: ReactionPopupConfiguration(
        userReactionCallback: _chatController.userReactionCallback,
      ),
    ),
  // ...
}
````

#### 🛠️ Additional Chat Room Methods:

| Method               | Description                                                                                                                                                                                                                 | Return Type        |
|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|
| onSendTapFromMessage | Sends a message in the active chat room using an existing `Message` instance.                                                                                                                                               | `Future<Message?>` |
| updateGroupChat      | Updates the specified attributes of a group chat. Any provided fields, such as `groupName` or `groupProfilePic`, will be updated accordingly.                                                                               | `Future<bool>`     | 
| addUserInGroup       | Adds a new user to the current group chat. You can assign a role and choose whether to include previous chat history, as well as you can specify the start date from which the user should have access to the chat history. | `Future<bool>`     |
| removeUserFromGroup  | Removes a specified user from the current group chat. ***Note:*** If the last member is removed, the all chat data will be deleted.                                                                                         | `Future<bool>`     |
| leaveFromGroup       | Allows the current user to exit the group chat. ***Note:*** If the current user is the last remaining member, all chat data will be deleted.                                                                                | `Future<bool>`     |
| dispose              | When leaving the chat room, make sure to dispose of the connection to stop listening to messages, user activity, and chat room metadata streams.                                                                            | `void`             |

#### 🛠️ Chats Methods:

- To use chat methods that are not specific to a particular chat room, obtain the `ChatManager`
  using the method below. **Note:** This instance does not support chat room-specific methods.

    ```dart
    ChatManager _chatController = ChatViewConnect.instance.getChatManager();
    
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        body: child: StreamBuilder<List<ChatRoom>>(
          stream: _chatController.getChats(),
          builder: (context, snapshot) {
            // ...
          },
        ),
      );
    }
    
    ````

| Method                 | Description                                                                                                                                                        | Return Type                     | 
|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------|
| getUsers               | Retrieves a map of user IDs and their corresponding `ChatUser` details.                                                                                            | `Future<Map<String, ChatUser>>` |
| getChats               | Returns a real-time stream of chat rooms list, including details such as chat room ID, participants, last message, and unread message count.                       | `Stream<List<ChatRoom>>`        |
| createChat             | Creates a one-to-one chat room by specifying the other user's ID and it returns the `chatRoomID`.                                                                  | `Future<String?>`               |
| createGroupChat        | Creates a group chat by providing a group name, an optional profile picture, and a list of participants with their assigned roles and it returns the `chatRoomID`. | `Future<String?>`               |
| deleteChat             | Deletes a chat room by its ID, removing it from the database, all users' chat lists, and deleting associated media from storage.                                   | `Future<bool>`                  |
| updateUserActiveStatus | Updates a user’s activity status by passing the desired state (e.g., online or offline).                                                                           | `Future<bool>`                  |
| resetCurrentUserId     | Resets the current user ID                                                                                                                                         | `void`                          |

## 💾 Database & Storage Documents

| Document                   | Link                                                                           | 
|----------------------------|--------------------------------------------------------------------------------|
| Firestore Database Schema  | [Click here to view the schema](doc/firebase/firebase-database-schema.md)      |
| Firebase Storage Structure | [Click here to view the structure](doc/firebase/firebase-storage-structure.md) | 

## 🔒 Firebase Security Rules

These Firebase Security Rules define access control
for both the [Firestore Database](https://firebase.google.com/docs/firestore/security/get-started)
and [Firebase Storage](https://firebase.google.com/docs/storage/security), ensuring secure data
handling and media uploads in a chat applications using `chatview_connect`. The rules
enforce authentication, user permissions, and chat room membership validation to maintain secure
access.

Copy and paste the rules into your project's Firebase console under the Firestore Rules tab. For
more information, visit the [Firebase Security Rules](https://firebase.google.com/docs/rules)
documentation.

| Rules              | Link                                                                        | 
|--------------------|-----------------------------------------------------------------------------|
| Firestore Database | [Click here to view the rules](doc/firebase/rules/firestore-security-rules) |
| Firebase Storage   | [Click here to view the rules](doc/firebase/rules/storage-security-rules)   |

## ⚙️ Optional Configuration

#### Properties of `ChatViewConnect`:

- `chatUserConfig`: Use this if your user collection documents have field keys that differ from
  those in the default `ChatUser` model.

    ```dart
    ChatViewConnect(
      ChatViewCloudService.firebase,
      chatUserModelConfig: const ChatUserModelConfig(
        idKey: 'user_id',
        nameKey: 'first_name',
        profilePhotoKey: 'avatar',
      ),
    );
    ````

- `cloudServiceConfig`: This parameter allows you to specify a cloud configuration based on the
  selected database type.

  **Firebase**: Use the `FirebaseCloudConfig` class, which provides the following
  parameters:

    - **`databasePathConfig`**: Use this if your user collection is not located at the top level in
      Firestore.

    - **`collectionNameConfig`**: Use this if your user collection names differs from the
      default.

        ```dart
        ChatViewConnect(
          ChatViewCloudService.firebase,
          cloudServiceConfig: FirebaseCloudConfig(
            databasePathConfig: FirestoreChatDatabasePathConfig(
              // If your users collection is inside `organizations/simform/users`.
              userCollectionPath: 'organizations/simform',
            ),
            collectionNameConfig: FirestoreChatCollectionNameConfig(
              // If your user collection is named `simform_users`.
              users: 'simform_users',
              ...,
            ),
          ),
        );
        ````

#### Properties of `ChatControllerConfig`:

| Properties                      | Description                                                                               | 
|---------------------------------|-------------------------------------------------------------------------------------------|
| syncOtherUsersInfo              | Whether to sync other users' information like Username, Profile Picture, Online/Offline.  |
| onUsersActivityChange           | Callback triggered when users' Membership Status, Typing Status, Activity Status changes. |
| chatRoomMetadata                | Callback to receive chat room participants' details.                                      |
| onChatRoomDisplayMetadataChange | Callback triggered when chat name, chat profile picture changes.                          |

## 👥 Main Contributors

<table>
  <tr>
    <td align="center"><a href="https://github.com/yash-dhrangdhariya"><img src="https://avatars.githubusercontent.com/u/72062416?v=4" width="100px;" alt=""/><br /><sub><b>Yash Dhrangdhariya</b></sub></a></td>
    <td align="center"><a href="https://github.com/aditya-chavda"><img src="https://avatars.githubusercontent.com/u/41247722?v=4" width="100px;" alt=""/><br /><sub><b>Aditya Chavda</b></sub></a></td>
    <td align="center"><a href="https://github.com/vatsaltanna"><img src="https://avatars.githubusercontent.com/u/25323183?s=100" width="100px;" alt=""/><br /><sub><b>Vatsal Tanna</b></sub></a></td>
  </tr>
</table>

## 📜 License

[MIT](LICENSE)

[chatViewPackage]: https://pub.dev/packages/chatview
