![ChatView Connect - Simform LLC.](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview_connect/master/preview/banner.png)

# Overview

ChatView Connect is a specialized wrapper for the [chatview](https://pub.dev/packages/chatview) package that
enables seamless integration with cloud services.

## Preview

| ChatViewList                                                                                                               | ChatView                                                                                                           |
|----------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|
| ![ChatViewList_Preview](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview/master/preview/chatviewlist.gif) | ![ChatView Preview](https://raw.githubusercontent.com/SimformSolutionsPvtLtd/chatview/master/preview/chatview.gif) |

## Features

- **Easy Setup:** Integrate with [chatview](https://pub.dev/packages/chatview) in 3 steps:
    1. Initialize the package by specifying **Cloud Service** (e.g., Firebase).
    2. Set the current **User ID**.
    3. Widget-wise controllers to use it with the [chatview](https://pub.dev/packages/chatview) package:
       1. For `ChatViewList` obtain the **`ChatListManager`**
       2. For `ChatView` obtain the **`ChatManager`**
- Supports **one-on-one** and **group chats** with **media uploads** *(audio not supported).*

# Installation Guide

## Compatibility with [chatview](https://pub.dev/packages/chatview)

| [chatview](https://pub.dev/packages/chatview) version | chatview_connect version |
|-------------------------------------------------------|--------------------------|
| `>=2.4.1 <3.0.0`                                      | `0.0.1`                  |
| `>= 3.0.0`                                            | `0.0.2`                  |

## Adding the dependency

1. Add the package dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  chatview_connect: <latest-version>
```

You can find the latest version on [pub.dev](https://pub.dev/packages/chatview_connect) under
the 'Installing' tab.

2. Import the package in your Dart code:

```dart
import 'package:chatview_connect/chatview_connect.dart';
```

# Backend Setup

## Firebase:

- Set up a [Firebase](https://firebase.google.com/) project (if you haven’t) and connect it to your
  Flutter app using [this guide](https://firebase.google.com/docs/flutter/setup?platform=android).

# Basic Usage

## Step 1: Initialize

Initialize package just after the firebase initialization, specify your
desired cloud service for use with [chatview](https://pub.dev/packages/chatview).

```dart
ChatViewConnect.initialize(ChatViewCloudService.firebase);
```

## Step 2: Set Logged In User ID

```dart
ChatViewConnect.instance.setCurrentUserId('current_user_id'); 
```

## Step 3: Using with [ChatViewList](https://pub.dev/packages/chatview)

The `ChatViewListController` from [ChatViewList](https://pub.dev/packages/chatview) has been replaced by `ChatListManager`.

**Before:**

```dart
ChatViewListController _chatListController = ChatViewListController(
  initialChatList: [...],
  scrollController: ScrollController(),
);
```

**After:**

```dart
ChatListManager _chatListController = ChatViewConnect.instance.getChatListManager(
  scrollController: ScrollController(),
);
```

`ChatListManager` internally manages chat rooms list, including details such as chat ID, last message, unread message count
and various chats operations, when the corresponding methods are specified in the `ChatViewList` widget.

```dart
ChatViewList(
  controller: _chatListController,
  // ...
  menuConfig: ChatMenuConfig(
    deleteCallback: (chat) => _chatListController.deleteChat(chat.id),
    pinStatusCallback: _chatListController.pinChat,
    muteStatusCallback: _chatListController.muteChat,
  ),
  // ...
)
```

## Step 4: Using with [ChatView](https://pub.dev/packages/chatview)

The `ChatController` from [chatview](https://pub.dev/packages/chatview) has been replaced by `ChatManager`. It can
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
```

**After:**

- Simply specify the `chatRoomId`, and it will automatically fetch the participants and return the
  corresponding `ChatManager`.

```dart
ChatManager _chatController = await ChatViewConnect.instance.getChatManager(
  // You can get `chatRoomId` from `createChat`, `createGroupChat`, or `getChats`
  chatRoomId: 'chat_room_id',
  scrollController: ScrollController(),
);
```

`ChatManager` internally manages various chat operations, when the corresponding methods are
specified in the [chatview](https://pub.dev/packages/chatview) widget.

```dart
ChatView(
  // ...
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
  // Loads more messages in the chat room for pagination, either before or after
  // the specified message.
  loadMoreData: (direction, message) => _chatController.onLoadMoreData(
    direction,
    message,
    batchSize: 8,
  ),
  // Unsending messages
  replyPopupConfig: ReplyPopupConfiguration(
    onUnsendTap: _chatController.onUnsendTap,
  ),
  // Loads a reply message and its surrounding context
  // in the chat room for a given message ID.
  repliedMessageConfig: RepliedMessageConfiguration(
    loadOldReplyMessage: (messageId) => _chatController.loadOldReplyMessage(
      messageId,
      batchSize: 8,
    ),
  ),
  // Updating reactions
  reactionPopupConfig: ReactionPopupConfiguration(
    userReactionCallback: _chatController.userReactionCallback,
  ),
  // ...
)
```

# Advanced Usage

### Additional Chat Room Methods:

| Method               | Description                                                                                                                                                                                                                 | Return Type        |
|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|
| onSendTapFromMessage | Sends a message in the active chat room using an existing `Message` instance.                                                                                                                                               | `Future<Message?>` |
| updateGroupChat      | Updates the specified attributes of a group chat. Any provided fields, such as `groupName` or `groupProfilePic`, will be updated accordingly.                                                                               | `Future<bool>`     | 
| addUserInGroup       | Adds a new user to the current group chat. You can assign a role and choose whether to include previous chat history, as well as you can specify the start date from which the user should have access to the chat history. | `Future<bool>`     |
| removeUserFromGroup  | Removes a specified user from the current group chat. ***Note:*** If the last member is removed, the all chat data will be deleted.                                                                                         | `Future<bool>`     |
| leaveFromGroup       | Allows the current user to exit the group chat. ***Note:*** If the current user is the last remaining member, all chat data will be deleted.                                                                                | `Future<bool>`     |
| dispose              | When leaving the chat room, make sure to dispose of the connection to stop listening to messages, user activity, and chat room metadata streams.                                                                            | `void`             |

### Additional Chats Methods:

| Method                 | Description                                                                                                                                                        | Return Type                     | 
|------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------|
| getUsers               | Retrieves a map of user IDs and their corresponding `ChatUser` details.                                                                                            | `Future<Map<String, ChatUser>>` |
| createChat             | Creates a one-to-one chat room by specifying the other user's ID and it returns the `chatRoomID`.                                                                  | `Future<String?>`               |
| createGroupChat        | Creates a group chat by providing a group name, an optional profile picture, and a list of participants with their assigned roles and it returns the `chatRoomID`. | `Future<String?>`               |
| deleteChat             | Deletes a chat room by its ID, removing it from the database, all users' chat lists, and deleting associated media from storage.                                   | `Future<bool>`                  |
| muteChat               | Mutes or unmutes a chat room by passing the desired state (e.g., muted for mute, unmuted for unmute).                                                              | `Future<void>`                  |
| pinChat                | Pins or unpins a chat room by passing the desired state (e.g., pinned for pin, unpinned for unpin).                                                                | `Future<void>`                  |
| updateUserActiveStatus | Updates a user’s activity status by passing the desired state (e.g., online or offline).                                                                           | `Future<bool>`                  |
| resetCurrentUserId     | Resets the current user ID                                                                                                                                         | `void`                          |


### Configuration Options:

#### Properties of `ChatViewConnect`:

- `chatUserConfig`: Use this if your user collection documents have field keys that differ from
  those in the default `ChatUser` model.

    ```dart
    ChatViewConnect.initialize(
      ChatViewCloudService.firebase,
      chatUserConfig: const ChatUserConfig(
        idKey: 'user_id',
        nameKey: 'first_name',
        profilePhotoKey: 'avatar',
      ),
      //...
    );
    ```

- `cloudServiceConfig`: This parameter allows you to specify a cloud configuration based on the
  selected database type.

  **Firebase**: Use the `FirebaseCloudConfig` class, which provides the following
  parameters:

    - **`databasePathConfig`**: Use this if your user collection is not located at the top level in
      Firestore.

    - **`collectionNameConfig`**: Use this if your user collection names differs from the
      default.

        ```dart
        ChatViewConnect.initialize(
          ChatViewCloudService.firebase,
          cloudServiceConfig: FirebaseCloudConfig(
            databasePathConfig: FirestoreChatDatabasePathConfig(
              // If your users collection is inside `organizations/simform/users`.
              userCollectionPath: 'organizations/simform',
            ),
            collectionNameConfig: FirestoreChatCollectionNameConfig(
              // If your user collection is named `simform_users`.
              users: 'simform_users',
              //...
            ),
          ),
          //...
        );
        ```

#### Properties of `ChatControllerConfig`:

| Properties                      | Description                                                                               | 
|---------------------------------|-------------------------------------------------------------------------------------------|
| syncOtherUsersInfo              | Whether to sync other users' information like Username, Profile Picture, Online/Offline.  |
| onUsersActivityChange           | Callback triggered when users' Membership Status, Typing Status, Activity Status changes. |
| chatRoomMetadata                | Callback to receive chat room participants' details.                                      |
| onChatRoomDisplayMetadataChange | Callback triggered when chat name, chat profile picture changes.                          |

```dart
ChatManager chatManager = await ChatViewConnect.instance.getChatRoomManager(
  config: ChatControllerConfig(
   syncOtherUsersInfo: true,
   chatRoomMetadata: (metadata) { /*...*/ },
   onUsersActivityChange: (usersActivities) { /*...*/ },
   onChatRoomDisplayMetadataChange: (displayMetadata) { /*...*/ },
  ),
  //...
);
```

# Firebase Documentation

## Firestore Database Structure:

This document outlines the Firestore database schema for a chat application. Firestore uses a NoSQL,
document-based structure in which data is stored in collections and documents.

### Collections & Documents:

#### Users Collection:

The `users` collection stores user information, with each document representing a single user. This
collection is read-only for us.

```
📂 users (Collection)
   ├── 📄 {userId} (Document)
       ├── id: string (Unique identifier for the user.)
       ├── name: string (User’s display name.)
       ├── profilePhoto: string (URL to the user's profile picture.)
```

This collection is **mandatory** for enabling chat between users, as it provides essential user
details. It is used to fetch user information during chat creation and in other operation, without
modifying the data.

**Note:** If your Firestore database has a different path for the user collection, a different
collection name, or different field keys for user details, configure the `cloudServiceConfig`.
for Firebase, use the `FirebaseCloudConfig` class while initializing the `ChatViewConnect`
constructor.

#### Chats Collection:

The `chats` collection contains chat room details.

```
📂 chats (Collection)
   ├── 📄 {chatId} (Document)
       ├── chat_room_type: string (one-to-one/group)
       ├── chat_room_create_by: string (User who created the group. Applicable only for group chats.)
       ├── group_name: string (Name of the group)
       ├── group_photo_url: string (URL of the group profile picture)

📂 messages (Subcollection under chats)
   ├── 📄 {messageId} (Document)
       ├── createAt: Timestamp
       ├── id: string
       ├── message: string
       ├── message_type: string (image/text/voice/custom)
       ├── reaction: map
       ├── reply_message: map
       ├── sentBy: string (user_id)
       ├── status: string (read/delivered/undelivered/pending)
       ├── voice_message_duration: string (optional)
       ├── update: map (optional)
       ├── update_at: Timestamp (optional)

📂 users (Subcollection under chats)
   ├── 📄 {userId} (Document)
       ├── membership_status: string (Status of the user in the chat ie: member/left/removed)
       ├── membership_status_timestamp: Timestamp (Timestamp of when the membership status changed)
       ├── role: string (Role of the user in the chat ie: admin/user)
       ├── typing_status: string (Indicates whether the user is typing ie: typed/typing)
       ├── pin_status: string (Indicates whether the chat is pinned or not ie: pinned/unpinned)
       ├── pin_status_timestamp: Timestamp (Timestamp of when the chat is pinned)
       ├── mute_status: string (Indicates whether the chat is muted or not ie: muted/unmuted)
```

#### User Chats Collection:

The `user_chats` collection maintains a mapping between individual users and their associated chat
rooms.

```
📂 user_chats (Collection)
   ├── 📄 {userId} (Document)
       ├── user_active_status: string (online/offline)

📂 chats (Subcollection under user_chats)
   ├── 📄 {chatId} (Document)
       ├── user_id: string (ID of the user associated with one-to-one chat)
```

## Storage Structure:

This document outlines the Firebase Storage structure used for managing chat-related media files,
including images and audio messages.

```
📂 chats (Top Directory)
   ├── 📂 {chatID} (Sub Directory)
       ├── 📂 images: (Sub Directory)
           ├── 📄 {messageId}_{sendBy}_{timestamp}_{fileName}.{fileExtension}
       ├── 📂 voices: (Sub Directory)
           ├── 📄 {messageId}_{sendBy}_{timestamp}_{fileName}.{fileExtension}

```

### Breakdown of Path Components:

- **`chats/{chatId}/`** → Represents a unique chat session identified by `chatId`.
- **`images/` or `voices/`** → Specifies the type of media stored.
- **`{messageId}_{sendBy}_{timestamp}_{fileName}.{fileExtension}`** → A unique identifier for each
  media file, composed of:
    - `messageId` → Unique ID of the message containing the media.
    - `sendBy` → Unique ID of the user who sent media files.
    - `timestamp` → Unix timestamp in microseconds to maintain order.
    - `fileName` → The original or system-generated name of the file.
    - `fileExtension` → The format of the file (e.g., jpg, png, mp3, wav).

# Firebase Security Rules

## Firestore Database:

```text
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // TODO: Update the path as per configured in chatview_connect
  	function chatCollection() {
      return 'chats';
    }

    // TODO: Update the path as per configured in chatview_connect
    function usersCollection() {
      return 'users';
    }

    // TODO: Update the path as per configured in chatview_connect
    function messageCollection() {
      return 'messages';
    }

    // TODO: Update the path as per configured in chatview_connect
    function userChatsCollection() {
      return 'user_chats';
    }

    function isValidChatCollection(collection) {
      return collection == chatCollection();
    }

    function isValidUserCollection(collection) {
      return collection == usersCollection();
    }

    function isValidMessageCollection(collection) {
      return collection == messageCollection();
    }

    function isValidUserChatsCollection(collection) {
      return collection == userChatsCollection();
    }

    function isSignedIn() {
    	return request.auth != null;
    }

    function getChatRoomUserPath(userId, chatRoomID) {
      return /databases/$(database)/documents/$(chatCollection())/$(chatRoomID)/users/$(userId);
    }

    function getChatPath(chatRoomID) {
      return /databases/$(database)/documents/chats/$(chatRoomID);
    }

    function getUserPath(userId) {
      return /databases/$(database)/documents/$(usersCollection())/$(userId);
    }

    match /{collection}/{userId} {
      function isCurrentUser() {
        return request.auth.uid == userId;
      }

      allow create, read: if isValidUserCollection(collection) && isSignedIn();
      allow delete, update: if isValidUserCollection(collection) && isCurrentUser();
    }

    match /{collection}/{chatRoomID} {

      function checkIsUserMember(userId) {
      	let doc = get(getChatRoomUserPath(userId, chatRoomID));
        return doc != null && (doc != null && doc.data.membership_status != "left");
      }

      function isUserExists() {
        return isSignedIn() && exists(getUserPath(request.auth.uid));
      }

      function isUserInChatRoom() {
        return isSignedIn() && exists(getChatRoomUserPath(request.auth.uid, chatRoomID));
      }

      function isChatRoomExist() {
      	let doc = get(getChatPath(chatRoomID));
      	return doc != null && (doc.data.chat_room_type == "oneToOne" || (doc.data.chat_room_type == "group"));
      }

      function isRoomCorrect() {
      	let chatRoomType = request.resource.data.chat_room_type;
        return chatRoomType is string && ("oneToOne" == chatRoomType || "group" == chatRoomType);
      }

      function allowUpdateChatRoom() {
      	let doc = get(getChatPath(chatRoomID));
        return doc == null ? false : (doc.data.chat_room_type == "group" ? checkIsUserMember(request.auth.uid) : true);
      }

      allow delete: if isValidChatCollection(collection) && isSignedIn();
      allow create: if isValidChatCollection(collection) && isUserExists() && isRoomCorrect();
      allow read: if isValidChatCollection(collection) && isUserInChatRoom();
      allow update: if isValidChatCollection(collection) && isUserInChatRoom() && allowUpdateChatRoom();

      match /{collection}/{messageId} {
        function isValidMessage() {
          let data = request.resource.data;
          return ("sentBy" in data) && data.sentBy is string && ("createdAt" in data) && data.createdAt is timestamp;
        }

        function isValidUpdate() {
        	let data = request.resource.data;
        	return "update_at" in data || "status" in data || "update" in data;
        }

        allow create: if isValidMessageCollection(collection) && isSignedIn() && checkIsUserMember(request.auth.uid) && isValidMessage();
        allow read: if isValidMessageCollection(collection) && isUserInChatRoom();
        allow delete: if isValidMessageCollection(collection) && isUserInChatRoom() && checkIsUserMember(request.auth.uid);
        allow update: if isValidMessageCollection(collection) && isUserInChatRoom() && checkIsUserMember(request.auth.uid) && isValidUpdate();
      }

      match /users/{userId} {
      	function isInChatRoom() {
        	return isSignedIn() && exists(getChatRoomUserPath(userId, chatRoomID));
      	}

        function allowUserCreation() {
          let isUserExistsInChatRoom = exists(getChatRoomUserPath(userId, chatRoomID));
          let isCurrentUserExistsInChatRoom = exists(getChatRoomUserPath(request.auth.uid, chatRoomID));
          return isCurrentUserExistsInChatRoom ? checkIsUserMember(request.auth.uid) : request.auth.uid == userId;
        }

        allow delete: if (isUserInChatRoom() && checkIsUserMember(request.auth.uid)) || isInChatRoom();
      	allow create: if isUserExists() && isChatRoomExist() && allowUserCreation();
        allow update: if isUserInChatRoom() && checkIsUserMember(request.auth.uid);
        allow read: if isUserInChatRoom();
      }
    }

    match /{collection}/{userId} {

      allow update: if isValidUserChatsCollection(collection) && request.auth.uid == userId;
      allow read, write: if isValidUserChatsCollection(collection) && isSignedIn();

      match /chats/{chatId} {

        function isUserInChatRoom() {
          return isSignedIn() && exists(getChatRoomUserPath(request.auth.uid, chatId));
      	}

      	function isUserExists() {
      	  return exists(getChatRoomUserPath(userId, chatId));
      	}

      	allow read: if isSignedIn() && request.auth.uid == userId;
        allow create, update, delete: if isUserExists();
      }

    }
  }
}
```

## Firebase Storage:

```text
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {

    // TODO: Update the path as per configured in chatview_connect
  	function chatCollection() {
      return 'chats';
    }

   	function isSignedIn() {
      return request.auth != null;
    }

    function getChatRoomUserPath(userId, chatRoomID) {
      return /databases/(default)/documents/$(chatCollection())/$(chatRoomID)/users/$(userId);
    }

    match /chats/{chatRoomID} {
      function isUserMember() {
      	let doc = firestore.get(getChatRoomUserPath(request.auth.uid, chatRoomID));
      	return doc != null && doc.data.membership_status != "left"
      }

      match /{allPaths=**} {
        allow read, write: if isSignedIn() && isUserMember();
      }
    }

    match /{allPaths=**} {
      allow read: if isSignedIn();
    }
  }
}
```

# Demo App Setup

A Flutter app demonstrating the use of `chatview_connect` — a wrapper around the `chatview` package that supports multiple cloud backends. This example focuses on Firebase integration.

### Prerequisites

1. [Flutter SDK](https://docs.flutter.dev/release/archive#stable-channel) (version 3.22.0 or higher)
2. [Firebase project](https://console.firebase.google.com/)

### Firebase Setup

1. **Create a Firebase project**:
  - Go to [Firebase Console](https://console.firebase.google.com/)
  - Create a new project or use an existing one

2. **Add Firebase to your Flutter app**:
  - Register your app with Firebase (Android, iOS, Web and Others)
  - Download the configuration files:
    - `google-services.json` for Android
    - `GoogleService-Info.plist` for iOS, MacOS
    - Configure web, windows as needed

3. **Enable Firestore Database and Storage**:
  - In Firebase Console, enable [Cloud Firestore](https://console.firebase.google.com/project/_/firestore/?_gl=1*1df50if*_ga*MjA5MDI2ODM5My4xNzEyNTY1Njkx*_ga_CW55HF8NVT*czE3NDcxOTc5OTckbzExJGcxJHQxNzQ3MjAyNzkwJGozMCRsMCRoMA..)
  - Set up Firestore security rules (see [documentation](https://simform-flutter-packages.web.app/chatViewConnect/firebase-security-rules) for reference rules)
  - Enable [Firebase Storage](https://console.firebase.google.com/project/_/storage/?_gl=1*10n1fix*_ga*MjA5MDI2ODM5My4xNzEyNTY1Njkx*_ga_CW55HF8NVT*czE3NDcxOTc5OTckbzExJGcxJHQxNzQ3MjAzMTkyJGo1MiRsMCRoMA..) for handling media files
  - Configure storage security rules (see [documentation](https://simform-flutter-packages.web.app/chatViewConnect/firebase-security-rules) for reference rules)

### Running the Example App

1. Clone the [repository](https://github.com/SimformSolutionsPvtLtd/chatview_connect.git)
2. Navigate to the example directory (e.g. in terminal, `cd example`)
3. Configure Firebase:
   ```bash
   flutterfire configure
   ```
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Run the app:
   ```bash
   flutter run
   ```

## Code Structure

The example app follows a modular structure:

- `main.dart`: Entry point with Firebase initialization and ChatViewConnect setup
- `modules/`: Feature-based screens and components
  - `chat_list/`: Chat conversations list screen
  - `chat_detail/`: Individual chat screen
  - `create_chat/`: Screen for creating new chats


# Contributors

## Main Contributors

| ![img](https://avatars.githubusercontent.com/u/72062416?v=4&s=200) | ![img](https://avatars.githubusercontent.com/u/41247722?v=4&s=200) | ![img](https://avatars.githubusercontent.com/u/25323183?v=4&s=200) |
|:------------------------------------------------------------------:|:------------------------------------------------------------------:|:------------------------------------------------------------------:|
|    [Yash Dhrangdhariya](https://github.com/yash-dhrangdhariya)     |         [Aditya Chavda](https://github.com/aditya-chavda)          |           [Vatsal Tanna](https://github.com/vatsaltanna)           |

## How to Contribute

Contributions are welcome! If you'd like to contribute to this project, please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Implement your changes
4. Add tests if applicable
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Guidelines for Contributors

- Follow the coding style used throughout the project
- Write clear, concise commit messages
- Add comments to your code where necessary
- Update documentation for any changes you make
- Test your changes thoroughly before submitting a pull request

## Reporting Issues

If you find a bug or have a suggestion for improvement, please open an issue on the GitHub
repository. Be sure to include:

- A clear title and description
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots or code snippets if applicable
- Your environment (Flutter version, device, OS, etc.)

## Code of Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in
this project, you agree to abide by its terms.

# License

```
MIT License

Copyright (c) 2024 Simform Solutions

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

```
