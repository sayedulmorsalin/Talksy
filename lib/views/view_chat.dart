import 'package:flutter/material.dart';

class Message {
  final String text;
  final bool isReceived;
  final String time;

  Message({required this.text, required this.isReceived, required this.time});
}

class ViewChatPage extends StatefulWidget {
  final String contactName;
  final String contactAvatar;

  const ViewChatPage({
    Key? key,
    required this.contactName,
    required this.contactAvatar,
  }) : super(key: key);

  @override
  State<ViewChatPage> createState() => _ViewChatPageState();
}

class _ViewChatPageState extends State<ViewChatPage> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  final List<Message> messages = [
    Message(text: 'Hi there!', isReceived: true, time: '10:30 AM'),
    Message(text: 'Hey! How are you?', isReceived: false, time: '10:31 AM'),
    Message(
      text: 'I\'m doing great, thanks for asking!',
      isReceived: true,
      time: '10:32 AM',
    ),
    Message(text: 'That\'s awesome!', isReceived: false, time: '10:33 AM'),
    Message(
      text: 'How about you? What have you been up to?',
      isReceived: true,
      time: '10:34 AM',
    ),
    Message(
      text: 'Just been working on some projects lately.',
      isReceived: false,
      time: '10:35 AM',
    ),
    Message(
      text: 'Oh nice! I\'d love to hear more about them.',
      isReceived: true,
      time: '10:36 AM',
    ),
    Message(
      text: 'Sure! Let\'s catch up soon over coffee ☕',
      isReceived: false,
      time: '10:37 AM',
    ),
    Message(
      text: 'Definitely! That sounds perfect.',
      isReceived: true,
      time: '10:38 AM',
    ),
    Message(
      text: 'Great! See you soon then 😊',
      isReceived: false,
      time: '10:39 AM',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        messages.add(
          Message(
            text: _messageController.text,
            isReceived: false,
            time: _getCurrentTime(),
          ),
        );
      });
      _messageController.clear();
      _scrollToBottom();
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.contactName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Active now',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return MessageBubble(message: message);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () {},
            color: const Color(0xFF075E54),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  hintStyle: TextStyle(color: Colors.grey[500]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            backgroundColor: const Color(0xFF075E54),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isReceived
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              margin: EdgeInsets.only(
                left: message.isReceived ? 8 : 50,
                right: message.isReceived ? 50 : 8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: message.isReceived
                    ? Colors.grey[300]
                    : const Color(0xFF075E54),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isReceived ? Colors.black : Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.time,
                    style: TextStyle(
                      color: message.isReceived
                          ? Colors.grey[600]
                          : Colors.grey[200],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
