import 'package:flutter/material.dart';

import 'modules/chat_list/chat_list_screen.dart';
import 'values/app_colors.dart';

class ChatViewConnectExampleApp extends StatelessWidget {
  const ChatViewConnectExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat View Connect Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.uiTwoGreen,
        colorScheme: ColorScheme.fromSwatch(accentColor: AppColors.uiTwoGreen),
      ),
      home: const ChatListScreen(),
    );
  }
}
