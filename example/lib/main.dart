import 'dart:async';

import 'package:chatview_connect/chatview_connect.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ChatViewConnect.initialize(
    ChatViewCloudService.firebase,
    chatUserConfig: const ChatUserConfig(
      idKey: 'user_id',
      nameKey: 'first_name',
      profilePhotoKey: 'avatar',
    ),
    // Configuration for customizing Firebase Firestore paths and
    // collection names used by ChatViewConnect.
    //
    // Example:
    // cloudServiceConfig: FirebaseCloudConfig(
    //   databasePathConfig: FirestoreChatDatabasePathConfig(
    //     userCollectionPath: 'organizations/simform',
    //   ),
    //   collectionNameConfig: FirestoreChatCollectionNameConfig(
    //     users: 'app_users',
    //   ),
    // ),
  );

  // Sets the current user ID for the ChatViewConnect instance
  // based on the authenticated user.
  //
  // This ensures that all future chat-related operations are scoped
  // to the currently logged-in user (e.g., fetching user-specific
  // chat rooms or messages).
  //
  // It should be called after confirming a valid user is logged in
  // For example, on Firebase through `FirebaseAuth.instance.authStateChanges()`
  ChatViewConnect.instance.setCurrentUserId('1');
  runApp(const ChatViewConnectExampleApp());
}
