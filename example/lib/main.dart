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
    cloudServiceConfig: FirebaseCloudConfig(
      databasePathConfig: FirestoreChatDatabasePathConfig(
        userCollectionPath: 'organizations/simform',
      ),
      collectionNameConfig: FirestoreChatCollectionNameConfig(
        users: 'app_users',
      ),
    ),
  ).setCurrentUserId('2');
  runApp(const ChatViewDbConnectionExampleApp());
}
