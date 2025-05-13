## 🗄️ Firestore Database Schema

This document outlines the Firestore database schema for a chat application. Firestore uses a NoSQL,
document-based structure in which data is stored in collections and documents.

### Collections & Documents:

#### Users Collection:

The `users` collection stores user information, with each document representing a single user. This
collection is read-only for us.

```plaintext
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

```plaintext
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
```

#### User Chats Collection:

The `user_chats` collection maintains a mapping between individual users and their associated chat
rooms.

```plaintext
📂 user_chats (Collection)
   ├── 📄 {userId} (Document)
       ├── user_active_status: string (online/offline)

📂 chats (Subcollection under user_chats)
   ├── 📄 {chatId} (Document)
       ├── user_id: string (ID of the user associated with one-to-one chat)
```
