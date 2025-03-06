import 'package:flutter/material.dart';

class UserStackedProfile extends StatelessWidget {
  const UserStackedProfile({required this.usersProfileURLs, super.key});

  final List<String> usersProfileURLs;

  @override
  Widget build(BuildContext context) {
    final usersProfileURLsLength = usersProfileURLs.length;
    final urlsLength = usersProfileURLsLength > 2 ? 2 : usersProfileURLsLength;
    return Stack(
      children: List.generate(
        urlsLength,
        (index) {
          final position = index * 10.0;
          final profilePhoto = usersProfileURLs[index];
          return Positioned(
            left: position,
            top: position,
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.transparent,
              backgroundImage: NetworkImage(profilePhoto),
            ),
          );
        },
      ),
    );
  }
}
