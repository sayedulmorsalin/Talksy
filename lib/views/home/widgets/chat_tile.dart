import 'package:flutter/material.dart';
import 'package:talksy/app/routes/routes.dart';

class ChatTile extends StatelessWidget {
  final String name;
  final String email;
  final String userId;

  const ChatTile({
    super.key,
    required this.name,
    required this.email,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = name[0].toUpperCase();

    return ListTile(
      leading: CircleAvatar(child: Text(avatar)),
      title: Text(
        name,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(email),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.chat,
          arguments: {
            'contactName': name,
            'contactAvatar': avatar,
            'contactId': userId,
          },
        );
      },
    );
  }
}
