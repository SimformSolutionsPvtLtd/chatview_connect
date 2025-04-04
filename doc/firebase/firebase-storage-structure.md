## 💾 Firebase Storage Structure

This document outlines the Firebase Storage structure used for managing chat-related media files,
including images and audio messages.

```plaintext
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
