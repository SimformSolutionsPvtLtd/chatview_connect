import 'dart:math';

import 'package:chatview/chatview.dart';

class MessagesData {
  const MessagesData._();

  static List<Message> getMessages(List<String> userIds) {
    final userIdsLength = userIds.length;
    return [
      Message(
        id: '1',
        message: 'Hey, how’s it going?',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 7, hours: 2, minutes: 30)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.delivered,
      ),
      Message(
        id: '2',
        message: 'All good! What about you?',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 7, hours: 2, minutes: 25)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.read,
      ),
      Message(
        id: '3',
        message: 'Just chilling. Got any plans for the weekend?',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 6, hours: 4, minutes: 10)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.pending,
      ),
      Message(
        id: '4',
        message: 'Thinking of going on a road trip!',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 6, hours: 4, minutes: 5)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.delivered,
      ),
      Message(
        id: '5',
        message: 'That sounds awesome!',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 5, hours: 6, minutes: 15)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.read,
      ),
      Message(
        id: '6',
        message: 'Yeah! Want to join?',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 5, hours: 6, minutes: 10)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.delivered,
      ),
      Message(
        id: '7',
        message: 'Let me check my schedule and get back to you.',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 4, hours: 3, minutes: 50)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.read,
      ),
      Message(
        id: '8',
        message: 'Sure! Let me know.',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 4, hours: 3, minutes: 45)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.delivered,
      ),
      Message(
        id: '9',
        message: 'Okay, I’m in!',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 3, hours: 5, minutes: 20)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.read,
      ),
      Message(
        id: '10',
        message: 'Awesome! Let’s plan the route.',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 3, hours: 5, minutes: 15)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.delivered,
      ),
      Message(
        id: '11',
        message: 'Where are we heading first?',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 2, hours: 7, minutes: 10)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.read,
      ),
      Message(
        id: '12',
        message: 'I was thinking of starting with the mountains.',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 2, hours: 7, minutes: 5)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.delivered,
      ),
      Message(
        id: '13',
        message: 'That’s perfect!',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 1, hours: 8, minutes: 30)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.read,
      ),
      Message(
        id: '14',
        message: 'I’ll book a place to stay.',
        createdAt: DateTime.now()
            .subtract(const Duration(days: 1, hours: 8, minutes: 25)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.delivered,
      ),
      Message(
        id: '15',
        message: 'Cool! Can’t wait!',
        createdAt:
            DateTime.now().subtract(const Duration(hours: 10, minutes: 40)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.read,
      ),
      Message(
        id: '16',
        message: 'Me neither!',
        createdAt:
            DateTime.now().subtract(const Duration(hours: 10, minutes: 35)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.delivered,
      ),
      Message(
        id: '17',
        message: 'All packed up and ready to go?',
        createdAt:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.read,
      ),
      Message(
        id: '18',
        message: 'Yup! Let’s do this!',
        createdAt:
            DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.delivered,
      ),
      Message(
        id: '19',
        message: 'See you at the meeting point in 30 mins.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 50)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.read,
      ),
      Message(
        id: '20',
        message: 'On my way!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        sentBy: userIds[Random().nextInt(userIdsLength)],
        status: MessageStatus.delivered,
      ),
    ];
  }
}
