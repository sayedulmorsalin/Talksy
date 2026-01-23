import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:talksy/services/firebase_auth.dart';
import 'package:talksy/services/sms_service.dart';

class Message {
  final String text;
  final bool isReceived;
  final String time;

  Message({required this.text, required this.isReceived, required this.time});
}

class ViewChatPage extends StatefulWidget {
  final String contactName;
  final String contactAvatar;
  final String contactId;

  const ViewChatPage({
    Key? key,
    required this.contactName,
    required this.contactAvatar,
    required this.contactId,
  }) : super(key: key);

  @override
  State<ViewChatPage> createState() => _ViewChatPageState();
}

class _ViewChatPageState extends State<ViewChatPage> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;
  late String _chatRoomId;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    _generateChatRoomId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _generateChatRoomId() {
    final currentUserId = FirebaseAuthService.instance.currentUser?.uid ?? '';
    final userIds = [currentUserId, widget.contactId];
    userIds.sort();
    _chatRoomId = userIds.join('_');
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

  void _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    final messageText = _messageController.text;
    final senderName =
        FirebaseAuthService.instance.currentUser?.displayName ?? 'Unknown';
    _messageController.clear();

    try {
      await FirebaseFirestore.instance
          .collection('chatRooms')
          .doc(_chatRoomId)
          .collection('messages')
          .add({
            'text': messageText,
            'senderId': FirebaseAuthService.instance.currentUser?.uid,
            'senderName': senderName,
            'timestamp': FieldValue.serverTimestamp(),
          });

      await _sendNotification(senderName, messageText);
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  Future<void> _sendNotification(String senderName, String messageText) async {
    try {
      await SMSService.instance.sendSMS(
        widget.contactId,
        senderName,
        messageText,
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
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
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chatRooms')
                  .doc(_chatRoomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start a conversation!'),
                  );
                }

                final messages = snapshot.data!.docs;
                final currentUserId =
                    FirebaseAuthService.instance.currentUser?.uid;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final isReceived = messageData['senderId'] != currentUserId;

                    final timestamp = messageData['timestamp'] as Timestamp?;
                    final time = timestamp != null
                        ? _formatTime(timestamp.toDate())
                        : '';

                    final message = Message(
                      text: messageData['text'] ?? '',
                      isReceived: isReceived,
                      time: time,
                    );
                    return MessageBubble(message: message);
                  },
                );
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
