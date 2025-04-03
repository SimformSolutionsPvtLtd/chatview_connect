import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatview_db_connection/flutter_chatview_db_connection.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  ChatViewDbConnection(
    ChatViewCloudService.firebase,
    chatUserConfig: const ChatUserConfig(
      idKey: 'user_id',
      nameKey: 'first_name',
      profilePhotoKey: 'avatar',
    ),
    // Configuration for customizing Firebase Firestore paths and
    // collection names used by ChatViewDbConnection.
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

  // Sets the current user ID for the ChatViewDbConnection instance
  // based on the authenticated user.
  //
  // This ensures that all future chat-related operations are scoped
  // to the currently logged-in user (e.g., fetching user-specific
  // chat rooms or messages).
  //
  // It should be called after confirming a valid user is logged in
  // For example, on Firebase through `FirebaseAuth.instance.authStateChanges()`
  ChatViewDbConnection.instance.setCurrentUserId('1');
  runApp(const ChatViewDbConnectionExampleApp());
}
