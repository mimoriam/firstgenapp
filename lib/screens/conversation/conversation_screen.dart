import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';

// A model to represent a chat message
class ChatMessage {
  final String text;
  final String time;
  final bool isSender;
  final String? status;
  final String? imageUrl;
  final String? replyTo;
  final String? replyText;
  final bool isAudio;

  ChatMessage({
    required this.text,
    required this.time,
    required this.isSender,
    this.status,
    this.imageUrl,
    this.replyTo,
    this.replyText,
    this.isAudio = false,
  });
}

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // ADDED: FocusNode to detect when the text field is focused.
  final FocusNode _focusNode = FocusNode();

  // Mock data to build the chat UI as per the screenshot
  final List<dynamic> _chatItems = [
    ChatMessage(
      text: 'Look at how chocho sleep in my arms!',
      time: '16.46',
      isSender: false,
      imageUrl: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=500&q=80',
    ),
    ChatMessage(
      text: 'Of course, let me know if you’re on your way',
      time: '16.46',
      isSender: false,
      replyTo: 'You',
      replyText: 'Can I come over?',
    ),
    ChatMessage(
      text: 'K, I’m on my way',
      time: '16.50',
      isSender: true,
      status: 'Read',
    ),
    'Sat, 17/10', // Date separator
    ChatMessage(
      text: '0:20',
      time: '09.13',
      isSender: true,
      status: 'Read',
      isAudio: true,
    ),
    ChatMessage(
      text: 'Good morning, did you sleep well?',
      time: '09.45',
      isSender: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // ADDED: Listener to scroll down when keyboard appears.
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // ADDED: Clean up the FocusNode and its listener.
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  // ADDED: Method to handle focus changes and scroll to the bottom.
  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // A short delay ensures the keyboard is up before scrolling.
      Future.delayed(const Duration(milliseconds: 300), () => _scrollToBottom());
    }
  }

  // ADDED: A helper method to scroll the list to the end.
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF6F6),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              itemCount: _chatItems.length,
              itemBuilder: (context, index) {
                final item = _chatItems[index];
                if (item is String) {
                  return _buildDateSeparator(item);
                } else if (item is ChatMessage) {
                  return _buildMessageBubble(item);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFEF6F6),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Elsa Kuhn',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.videocam_outlined, color: AppColors.textPrimary),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.call_outlined, color: AppColors.textPrimary),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildDateSeparator(String date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          date,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isSender = message.isSender;
    final alignment = isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isSender ? AppColors.primaryRed : Colors.white;
    final textColor = isSender ? Colors.white : AppColors.textPrimary;
    final borderRadius = isSender
        ? const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
    )
        : const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomRight: Radius.circular(20),
    );

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.all(12.0),
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: borderRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message.replyTo != null) _buildReplyContent(message, isSender),
              if (message.imageUrl != null) _buildImageContent(message),
              if (message.isAudio) _buildAudioContent(message, textColor),
              if (!message.isAudio)
                Text(
                  message.text,
                  style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        _buildTimestampAndStatus(message, isSender),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildReplyContent(ChatMessage message, bool isSender) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: const EdgeInsets.only(left: 8.0),
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.primaryRed, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.replyTo!,
            style: const TextStyle(
              color: AppColors.primaryRed,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message.replyText!,
            style: TextStyle(
              color: isSender ? Colors.white70 : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent(ChatMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.network(message.imageUrl!),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }

  Widget _buildAudioContent(ChatMessage message, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.play_arrow, color: textColor),
        const SizedBox(width: 8),
        Text(message.text, style: TextStyle(color: textColor)),
        const SizedBox(width: 8),
        // Placeholder for the audio waveform
        Icon(Icons.bar_chart_rounded, color: textColor, size: 40),
      ],
    );
  }

  Widget _buildTimestampAndStatus(ChatMessage message, bool isSender) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.time,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        if (isSender && message.status != null) ...[
          const SizedBox(width: 4),
          Text(
            '· ${message.status}',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add, color: AppColors.textSecondary, size: 28),
              onPressed: () {},
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F7),
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: TextField(
                  controller: _messageController,
                  // ADDED: Attached the FocusNode to the TextField.
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Type a message... ',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send, color: AppColors.primaryRed, size: 28),
              onPressed: () {
                // Send message logic
              },
            ),
          ],
        ),
      ),
    );
  }
}
