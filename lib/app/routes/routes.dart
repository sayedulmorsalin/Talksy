import 'package:flutter/material.dart';
import 'package:talksy/views/home/home_page.dart';
import 'package:talksy/views/login.dart';
import 'package:talksy/views/register.dart';
import 'package:talksy/views/view_chat.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String chat = '/chat';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (context) => const LoginView(),
      register: (context) => const RegisterView(),
      home: (context) => const HomePage(),
    };
  }

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterView());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case chat:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => ViewChatPage(
            contactName: args?['contactName'] ?? 'Unknown',
            contactAvatar: args?['contactAvatar'] ?? 'U',
            contactId: args?['contactId'] ?? '',
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: Center(
              child: Text('No route defined for ${settings.name ?? 'unknown'}'),
            ),
          ),
        );
    }
  }
}
