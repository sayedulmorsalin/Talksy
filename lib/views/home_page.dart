import 'package:flutter/material.dart';
import 'package:talksy/app/routes/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  final List<ChatItem> chatItems = [
    ChatItem(
      name: 'John Doe',
      lastMessage: 'Hey, how are you?',
      time: '2:30 PM',
      avatar: 'JD',
      unreadCount: 2,
    ),
    ChatItem(
      name: 'Sarah Smith',
      lastMessage: 'See you tomorrow!',
      time: '1:45 PM',
      avatar: 'SS',
      unreadCount: 0,
    ),
    ChatItem(
      name: 'Mike Johnson',
      lastMessage: 'Thanks for the update',
      time: 'Yesterday',
      avatar: 'MJ',
      unreadCount: 1,
    ),
    ChatItem(
      name: 'Emma Wilson',
      lastMessage: 'Sounds good!',
      time: 'Tuesday',
      avatar: 'EW',
      unreadCount: 0,
    ),
    ChatItem(
      name: 'David Brown',
      lastMessage: 'Let me check and get back',
      time: 'Monday',
      avatar: 'DB',
      unreadCount: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Talksy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 7, 125, 112),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(child: Text('New group')),
              const PopupMenuItem(child: Text('New broadcast')),
              const PopupMenuItem(child: Text('Linked devices')),
              const PopupMenuItem(child: Text('Settings')),
            ],
          ),
        ],
        bottom: TabBar(
          labelColor: Colors.white,
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'CHATS'),
            Tab(text: 'STATUS'),
            Tab(text: 'CALLS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: chatItems.length,
            itemBuilder: (context, index) {
              final chat = chatItems[index];
              return ChatTile(chat: chat);
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No status available',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.call_missed, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No calls available',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF075E54),
        onPressed: () {},
        child: const Icon(Icons.message),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'People'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class ChatItem {
  final String name;
  final String lastMessage;
  final String time;
  final String avatar;
  final int unreadCount;

  ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.avatar,
    required this.unreadCount,
  });
}

class ChatTile extends StatelessWidget {
  final ChatItem chat;

  const ChatTile({Key? key, required this.chat}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF075E54),
        child: Text(
          chat.avatar,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        chat.name,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        chat.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.time,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 4),
          if (chat.unreadCount > 0)
            CircleAvatar(
              radius: 10,
              backgroundColor: const Color(0xFF075E54),
              child: Text(
                chat.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.chat,
          arguments: {'contactName': chat.name, 'contactAvatar': chat.avatar},
        );
      },
    );
  }
}
