import 'package:flutter/material.dart';

import 'modules/chat_list/chat_list_screen.dart';

class ChatViewDbConnectionExampleApp extends StatelessWidget {
  const ChatViewDbConnectionExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat View DB Connection Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          primary: const Color(0xffEE5366),
          seedColor: const Color(0xffEE5366),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      home: const ChatListScreen(),
    );
  }
}
