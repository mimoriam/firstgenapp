import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/utils/time_ago.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class ConversationScreen extends StatefulWidget {
  final Conversation conversation;
  const ConversationScreen({super.key, required this.conversation});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  // --- OPTIMIZATION START ---
  // These variables help manage the smart auto-scrolling behavior.
  bool _isUserAtBottom = true; // Tracks if the user is scrolled to the bottom.
  int _messageCount = 0; // Tracks the number of messages to detect new ones.
  // --- OPTIMIZATION END ---

  @override
  void initState() {
    super.initState();
    Provider.of<FirebaseService>(
      context,
      listen: false,
    ).markAsRead(widget.conversation.id);

    // --- OPTIMIZATION START ---
    // Add a listener to the scroll controller to track the user's position.
    _scrollController.addListener(_scrollListener);
    // --- OPTIMIZATION END ---

    // Scroll to the bottom when the screen first loads.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom(animated: false));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener); // Remove the listener
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // --- OPTIMIZATION START ---
  // This listener updates whether the user is at the bottom of the list.
  void _scrollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.position.atEdge) {
        // Check if the user is at the bottom edge.
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _isUserAtBottom = true;
        }
      } else {
        // If they are not at an edge, they are not at the bottom.
        _isUserAtBottom = false;
      }
    }
  }
  // --- OPTIMIZATION END ---

  void _scrollToBottom({bool animated = true}) {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(position);
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      firebaseService.sendMessage(widget.conversation.id, text);
      _messageController.clear();
      // After sending a message, always scroll to the bottom.
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: firebaseService.getMessages(widget.conversation.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No messages yet.'));
                }

                final messages = snapshot.data!;

                // --- OPTIMIZATION START ---
                // This is the smart auto-scroll logic.
                // It checks if new messages have arrived since the last rebuild.
                if (messages.length > _messageCount) {
                  // If the user was already at the bottom, scroll down to show the new message.
                  if (_isUserAtBottom) {
                    WidgetsBinding.instance
                        .addPostFrameCallback((_) => _scrollToBottom());
                  }
                }
                // Update the message count for the next check.
                _messageCount = messages.length;
                // --- OPTIMIZATION END ---

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final showDateSeparator = index == 0 ||
                        TimeAgo.formatDateSeparator(message.timestamp) !=
                            TimeAgo.formatDateSeparator(
                              messages[index - 1].timestamp,
                            );

                    return Column(
                      children: [
                        if (showDateSeparator)
                          _buildDateSeparator(
                            TimeAgo.formatDateSeparator(message.timestamp),
                          ),
                        _buildMessageBubble(message),
                      ],
                    );
                  },
                );
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
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        widget.conversation.otherUser.name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(IconlyLight.video, color: AppColors.textSecondary),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(IconlyLight.calling, color: AppColors.textSecondary),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
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
    final isSender = message.senderId ==
        Provider.of<FirebaseService>(context, listen: false).currentUser?.uid;
    final alignment = isSender ? Alignment.centerRight : Alignment.centerLeft;
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

    return Align(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
        isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(color: color, borderRadius: borderRadius),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
            ),
          ),
          const SizedBox(height: 4),
          _buildTimestampAndStatus(message, isSender),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTimestampAndStatus(ChatMessage message, bool isSender) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          TimeAgo.formatTimestamp(message.timestamp),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        if (isSender) ...[
          const SizedBox(width: 4),
          Text(
            '· Read',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.add,
                color: AppColors.textSecondary,
                size: 28,
              ),
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
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Type a message... ',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 14.0,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.send,
                color: AppColors.primaryRed,
                size: 28,
              ),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
