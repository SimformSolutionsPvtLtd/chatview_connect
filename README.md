# Flutter ChatView DB Connection

[![flutter_chatview_db_connection](https://img.shields.io/pub/v/flutter_chatview_db_connection?label=flutter_chatview_db_connection)](https://pub.dev/packages/flutter_chatview_db_connection)

`flutter_chatview_db_connection` is a specialized wrapper for the [`chatview`][chatViewPackage]
package that enables seamless integration with cloud services. It streamlines chat application
development when used alongside [`chatview`][chatViewPackage], supporting both one-on-one and group
chats.

***Note:*** *Currently, it supports only Firebase Cloud Services. Support for additional cloud
services will be included in future releases.*

_Check out other amazing
open-source [Flutter libraries](https://pub.dev/publishers/simform.com/packages)
and [Mobile libraries](https://github.com/SimformSolutionsPvtLtd/Awesome-Mobile-Libraries) developed
by Simform Solutions!_

## 🎞️ Preview

![The example app running in iOS](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/flutter_chatview/main/preview/chatview.gif)

## 🚀 Getting Started

#### 📥 Installation

Add `flutter_chatview_db_connection` to your project by updating the `pubspec.yaml`:

```yaml
dependencies:
  flutter_chatview_db_connection: <latest-version>
```

#### 📌 Version Compatibility

| `flutter_chatview_db_connection` Version | Compatible `chatview` Version | `flutter_chatview_models` Version |
|------------------------------------------|-------------------------------|-----------------------------------|
| 1.0.0                                    | 2.5.0                         | 1.0.0                             |

This table helps ensure compatibility
between `flutter_chatview_db_connection`, [`chatview`][chatViewPackage],
and [`flutter_chatview_models`][chatViewModels] (which serves as a centralized repository for shared
data models).

#### ✅ Requirements

Dart >=3.3.0 and Flutter >=3.19.0,

- **Firebase** Integration:
    1. Create a [Firebase](https://firebase.google.com/) project if you haven’t already.
    2. Connect your Flutter app to Firebase by following the official
       guide: [Add Firebase to your Flutter app](https://firebase.google.com/docs/flutter/setup?platform=android).

#### 📘 Usage Guide

Learn how to implement and use the package by exploring
the [example app on GitHub](https://github.com/SimformSolutionsPvtLtd/flutter_chatview_db_connection/tree/master/example).

## ✨ Key Features

- **Easy Setup:** Integrate [`chatview`][chatViewPackage] with your chosen cloud service in just
  three simple steps:
    1. Initialize the package by specifying the cloud service type (e.g., Firebase).
    2. Set the current user ID.
    3. Obtain the `ChatManager` for [`chatview`][chatViewPackage] and cloud services operations;
       link the necessary methods to specific actions (e.g. `onSendTap: _chatController.onSendTap`).
- **Supports image uploads**; *audio files are not supported at this time.*

## 🔧 Setup

- To initialize the `flutter_chatview_db_connection` package, create an instance and specify the
  cloud service you want to use with [`chatview`][chatViewPackage].

    ```dart
    ChatViewDbConnection(ChatViewDatabaseType.firebase);
    ````

  Additionally, you can customize the database structure using the following optional parameters:
    - `chatUserConfig`: Use this if your user collection documents have field keys that differ from
      those in the default `ChatUser` model.

        ```dart
        ChatViewDbConnection(
          ChatViewDatabaseType.firebase,
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

        - **`databasePathConfig`**: Use this if your user collection is not located at the top level
          in Firestore.

        - **`collectionNameConfig`**: Use this if your user collection names differs from the
          default.

        ```dart
        ChatViewDbConnection(
          ChatViewDatabaseType.firebase,
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

- Setting the Current User:
    ```dart
    ChatViewDbConnection.instance.setCurrentUserId('current_user_id')
    ````
- For resetting the Current User:
    ```dart
    ChatViewDbConnection.instance.resetCurrentUserId()
    ````

## 🏗 Using with [ChatView][chatViewPackage]

The `ChatController` from [`chatview`][chatViewPackage] has been replaced by `ChatManager`. It can
be used for both **existing** and **new chat rooms**, depending on the parameters provided. You can
obtain an instance by calling the **`getChatManager()`** method:

```dart
ChatManager? _chatController;

_chatController = await ChatViewDbConnection.instance.getChatManager(...);
````

**Before:**

```dart
ChatController? _chatController;

_chatController = ChatController(
  initialMessageList: [...],
  scrollController: ScrollController(),
  currentUser: const ChatUser(...),
  otherUsers: const [...],
);
````

**After:**

- For **Existing Chat Rooms**: Simply specify the `chatRoomId`, and it will automatically fetch the
  participants and return the corresponding `ChatManager`.

````dart
ChatManager? _chatController;

_chatController = await ChatViewDbConnection.instance.getChatManager(
  chatRoomId: 'chat_room_id',
  scrollController: ScrollController(),
  config: ChatControllerConfig(...),
);
````

- For **Creating New Chat Rooms**: Specify `chatRoomType`, `currentUser`, `otherUsers`, and (if it’s
  a group chat) a `groupName` or `groupProfile` to create a new chat room. For one-to-one chats, it
  checks if a chat already exists and connects to it; for group chats, it creates a new chat room.

````dart
ChatManager? _chatController;

_chatController = await ChatViewDbConnection.instance.getChatManager(
  scrollController: ScrollController(),
  config: ChatControllerConfig(...),
  otherUsers: [ChatUser(...), ChatUser(...)],
  currentUser: ChatUser(...),
  chatRoomType: ChatRoomType.group,
  groupName: 'your_group_name',
  groupProfile: 'your_group_profile_picture',
);
````

The `config` parameter manages chat room settings with real-time synchronization for user
information, activity, and metadata. It helps auto-update user details, chat name, and profile
picture outside the [`chatview`][chatViewPackage].

This method internally manages various chat operations, including:

- Sending messages and uploading media (text, image, audio, or custom)
- Updating reactions
- Tracking message read status
- Unsending messages
- Replying to messages
- Managing typing indicators (automatic for one-to-one chats, manual for groups chats)
- Handling the past and upcoming new messages.

*These operations are triggered when the corresponding methods are specified in
the [`chatview`][chatViewPackage] widget, as outlined in the table below:*

| [`chatview`][chatViewPackage] parameter | `flutter_chatview_db_connection` method | Notes                                                                                        |
|-----------------------------------------|-----------------------------------------|----------------------------------------------------------------------------------------------|
| onSendTap                               | _chatController.onSendTap               | Currently, audio files are not uploaded, as network audio is not compatible with `chatview`. |
| onMessageTyping                         | _chatController.onMessageTyping         | for group chats, you need to manage it manually using the `onUsersActivityChanges` callback. |
| onMessageRead                           | _chatController.onMessageRead           |                                                                                              |
| onUnsendTap                             | _chatController.onUnsendTap             |                                                                                              |
| userReactionCallback                    | _chatController.userReactionCallback    |                                                                                              |

#### 🛠️ Additional Chat Room Methods:

| Method               | Description                                                                                                                                                                                                                 | 
|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| onSendTapFromMessage | Sends a message in the active chat room using an existing `Message` instance.                                                                                                                                               |
| updateGroupChat      | Updates the specified attributes of a group chat. Any provided fields, such as `groupName` or `groupProfilePic`, will be updated accordingly.                                                                               |
| addUserInGroup       | Adds a new user to the current group chat. You can assign a role and choose whether to include previous chat history, as well as you can specify the start date from which the user should have access to the chat history. |
| removeUserFromGroup  | Removes a specified user from the current group chat. ***Note:*** If the last member is removed, the all chat data will be deleted.                                                                                         |
| leaveFromGroup       | Allows the current user to exit the group chat. ***Note:*** If the current user is the last remaining member, all chat data will be deleted.                                                                                |
| dispose              | When leaving the chat room, make sure to dispose of the connection to stop listening to messages, user activity, and chat room metadata streams.                                                                            |

#### 🛠️ Chats Methods:

- To use chat methods that are not specific to a particular chat room, obtain the `ChatManager`
  using the method below. **Note:** This instance does not support chat room-specific methods.

    ```dart
    final _chatController = ChatViewDbConnection.instance.getChatManager();
    ````

| Method                 | Description                                                                                                                             | 
|------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|
| getUsers               | Retrieves a map of user IDs and their corresponding `ChatUser` details.                                                                 |
| getChats               | Returns a real-time stream of chat rooms, including details such as chat room ID, participants, last message, and unread message count. |
| createChat             | Creates a one-to-one chat room by specifying the other user's ID.                                                                       |
| createGroupChat        | Creates a group chat by providing a group name, an optional profile picture, and a list of participants with their assigned roles.      |
| deleteChat             | Deletes a chat room by its ID, removing it from the database, all users' chat lists, and deleting associated media from storage.        |
| updateUserActiveStatus | Updates a user’s activity status by passing the desired state (e.g., online or offline).                                                |

## 💾 Database & Storage Documents

| Document                   | Link                                                                           | 
|----------------------------|--------------------------------------------------------------------------------|
| Firestore Database Schema  | [Click here to view the schema](doc/firebase/firebase-database-schema.md)      |
| Firebase Storage Structure | [Click here to view the structure](doc/firebase/firebase-storage-structure.md) | 

## 🔒 Firebase Security Rules

These Firebase Security Rules define access control
for both the [Firestore Database](https://firebase.google.com/docs/firestore/security/get-started)
and [Firebase Storage](https://firebase.google.com/docs/storage/security), ensuring secure data
handling and media uploads in a chat applications using `flutter_chatview_db_connection`. The rules
enforce authentication, user permissions, and chat room membership validation to maintain secure
access.

Copy and paste the rules into your project's Firebase console under the Firestore Rules tab. For
more information, visit the [Firebase Security Rules](https://firebase.google.com/docs/rules)
documentation.

| Rules              | Link                                                                        | 
|--------------------|-----------------------------------------------------------------------------|
| Firestore Database | [Click here to view the rules](doc/firebase/rules/firestore-security-rules) |
| Firebase Storage   | [Click here to view the rules](doc/firebase/rules/storage-security-rules)   |

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

[chatViewModels]: https://pub.dev/packages/flutter_chatview_models
