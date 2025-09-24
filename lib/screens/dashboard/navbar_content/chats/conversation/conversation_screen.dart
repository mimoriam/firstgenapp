import 'dart:io';
import 'package:firstgenapp/common/expanded_image_view.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:firstgenapp/models/chat_models.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/utils/time_ago.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ConversationScreen extends StatefulWidget {
  final Conversation? conversation;
  final ChatUser? otherUser;

  const ConversationScreen({super.key, this.conversation, this.otherUser})
    : assert(conversation != null || otherUser != null);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _scrollTriggered = false;

  bool _isUserAtBottom = true;
  int _messageCount = 0;
  late Future<Conversation> _conversationFuture;
  File? _imageFile;
  bool _isSending = false;
  bool _isVip = false;

  // Predefined sticker identifiers. Place sticker assets at images/stickers/<id>.png
  final List<String> _stickerIds = [
    'FG_logo',
    'Vector',
  ];

  @override
  void initState() {
    super.initState();
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );

    if (widget.conversation != null) {
      _conversationFuture = Future.value(widget.conversation);
      firebaseService.markAsRead(widget.conversation!.id);
    } else {
      _conversationFuture = firebaseService.getOrCreateConversationWithUser(
        widget.otherUser!,
      );
    }

    // Determine if current user has VIP subscription so we can show read receipts
    firebaseService.getUserProfile().then((profile) {
      try {
        final plan = profile?.data()?['subscriptionType'] as String? ??
            profile?.data()?['subscriptionPlan'] as String?;
        if (plan != null && plan == 'vip') {
          setState(() => _isVip = true);
        }
      } catch (e) {
        // ignore parsing errors
      }
    }).catchError((_) {
      // ignore errors fetching profile
    });

    _scrollController.addListener(_scrollListener);
    _focusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollToBottom(animated: false),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.removeListener(_scrollListener);
    _focusNode.removeListener(_onFocusChange);
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      if (_scrollController.position.atEdge) {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          _isUserAtBottom = true;
        }
      } else {
        _isUserAtBottom = false;
      }
    }
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      Future.delayed(
        const Duration(milliseconds: 500),
        () => _scrollToBottom(),
      );
    }
  }

  void _scrollToBottom({bool animated = true}) {
    // Wait until the end of the frame to ensure the new message is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.position.maxScrollExtent > 0) {
        final position = _scrollController.position.maxScrollExtent;
        if (animated) {
          _scrollController.animateTo(
            position,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(position);
        }
      }
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _showStickerPicker(String conversationId) async {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Send a Sticker',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                itemCount: _stickerIds.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final id = _stickerIds[index];
                  final assetPath = 'images/stickers/$id.png';
                  return GestureDetector(
                    onTap: () async {
                      Navigator.of(context).pop();
                      try {
                        await firebaseService.sendMessage(
                          conversationId,
                          stickerId: id,
                        );
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to send sticker.')),
                          );
                        }
                      }
                    },
                    child: Image.asset(
                      assetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Show a placeholder if asset missing
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.emoji_emotions)),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(String conversationId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _imageFile == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      await firebaseService.sendMessage(
        conversationId,
        text: text.isNotEmpty ? text : null,
        image: _imageFile,
      );
      _messageController.clear();
      setState(() {
        _imageFile = null;
      });
      // _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send message.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);
    final initialAppBarTitle =
        widget.conversation?.otherUser.name ?? widget.otherUser?.name ?? 'Chat';

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: _buildAppBar(initialAppBarTitle),
      body: FutureBuilder<Conversation>(
        future: _conversationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Could not load conversation.'));
          }

          final conversation = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: firebaseService.getMessages(conversation.id),
                  builder: (context, messageSnapshot) {
                    if (messageSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !messageSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (messageSnapshot.hasError) {
                      return Center(
                        child: Text('Error: ${messageSnapshot.error}'),
                      );
                    }
                    if (!messageSnapshot.hasData ||
                        messageSnapshot.data!.isEmpty) {
                      return const Center(child: Text('No messages yet.'));
                    }

                    final messages = messageSnapshot.data!;

                    // Mark incoming messages as delivered when the recipient's device receives them.
                    try {
                      for (final m in messages) {
                        if (m.senderId != firebaseService.currentUser?.uid &&
                            (m.status == 'sent')) {
                          // fire-and-forget; service handles idempotency
                          firebaseService.markMessageDelivered(conversation.id, m.id);
                        }
                      }
                    } catch (e) {
                      // non-fatal
                    }

                    if (messages.length > _messageCount) {
                      final lastMessage = messages.last;
                      // Only auto-scroll for new TEXT messages. Images will trigger their own scroll.
                      if (_isUserAtBottom && lastMessage.imageUrl == null) {
                        _scrollToBottom();
                      }
                    }
                    _messageCount = messages.length;

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 20.0,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final showDateSeparator =
                            index == 0 ||
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
                            // _buildMessageBubble(message),
                            MessageBubble(
                              message: message,
                              onImageLoaded: message.imageUrl != null
                                  ? () {
                                      // --- THIS IS THE FIX ---
                                      if (_isUserAtBottom) {
                                        _scrollToBottom(animated: true);
                                      }
                                    }
                                  : null,
                              showReadReceipts: _isVip,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              if (_imageFile != null) _buildImagePreview(),
              _buildMessageComposer(conversation.id, () => _sendMessage(conversation.id)),
            ],
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(String title) {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
      // actions: [
      //   IconButton(
      //     onPressed: () {},
      //     icon: const Icon(IconlyLight.video, color: AppColors.textSecondary),
      //   ),
      //   IconButton(
      //     onPressed: () {},
      //     icon: const Icon(IconlyLight.calling, color: AppColors.textSecondary),
      //   ),
      //   IconButton(
      //     onPressed: () {},
      //     icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
      //   ),
      // ],
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
    final isSender =
        message.senderId ==
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
        crossAxisAlignment: isSender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(4.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(color: color, borderRadius: borderRadius),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageUrl != null)
                    Image.network(
                      message.imageUrl!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    )
                  else if (message.stickerId != null)
                    // Render stickers the same way as images to avoid quirks.
                    Image.asset(
                      'images/stickers/${message.stickerId}.png',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey.shade200,
                          child: const Center(child: Icon(Icons.emoji_emotions)),
                        );
                      },
                    ),
                  if (message.text != null && message.text!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: Text(
                        message.text!,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
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

  Widget _buildImagePreview() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: Row(
        children: [
          Stack(
            children: [
              Image.file(_imageFile!, height: 60, width: 60, fit: BoxFit.cover),
              Positioned(
                top: -10,
                right: -10,
                child: IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _imageFile = null),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer(String conversationId, VoidCallback onSend) {
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
              onPressed: _pickImage,
            ),
            if (_isVip) ...[
              IconButton(
                icon: const Icon(
                  Icons.card_giftcard,
                  color: AppColors.textSecondary,
                  size: 26,
                ),
                onPressed: () => _showStickerPicker(conversationId),
              ),
            ],
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
              icon: _isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.send,
                      color: AppColors.primaryRed,
                      size: 28,
                    ),
              onPressed: _isSending ? null : onSend,
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final VoidCallback? onImageLoaded;
  final bool showReadReceipts;

  const MessageBubble({
    super.key,
    required this.message,
    this.onImageLoaded,
    this.showReadReceipts = false,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  bool _hasTriggeredScroll = false;

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final isSender =
        widget.message.senderId == firebaseService.currentUser?.uid;
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
        crossAxisAlignment: isSender
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(4.0),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            decoration: BoxDecoration(color: color, borderRadius: borderRadius),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.message.imageUrl != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ExpandedImageViewScreen(
                              imageUrl: widget.message.imageUrl!,
                              // Use a unique tag, the image URL is a good choice.
                              heroTag: widget.message.imageUrl!,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        // This tag MUST match the one in ExpandedImageViewScreen
                        tag: widget.message.imageUrl!,
                        child: Image.network(
                          widget.message.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              if (widget.onImageLoaded != null &&
                                  !_hasTriggeredScroll) {
                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  widget.onImageLoaded!();
                                });
                                _hasTriggeredScroll = true;
                              }
                              return child;
                            }
                            return Container(
                              height: 200,
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  else if (widget.message.stickerId != null)
                    // Render stickers like images to ensure consistent behavior.
                    Builder(builder: (context) {
                      final assetPath =
                          'images/stickers/${widget.message.stickerId}.png';
                      // Use a sized container to match image behavior
                      final image = Image.asset(
                        assetPath,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Center(child: Icon(Icons.emoji_emotions)),
                          );
                        },
                      );
                      // Trigger onImageLoaded after the frame so scrolling behaves same as images
                      if (widget.onImageLoaded != null && !_hasTriggeredScroll) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.onImageLoaded!();
                        });
                        _hasTriggeredScroll = true;
                      }
                      return image;
                    }),
                  if (widget.message.text != null &&
                      widget.message.text!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                      child: Text(
                        widget.message.text!,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildTimestampAndStatus(widget.message, isSender),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Moved this function inside the new widget's state
  Widget _buildTimestampAndStatus(ChatMessage message, bool isSender) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          TimeAgo.formatTimestamp(message.timestamp),
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        if (isSender) ...[
          const SizedBox(width: 8),
          // Status icon: sent -> single tick, delivered -> double tick, read -> double tick (blue) only if showReadReceipts enabled
          if (message.status == 'sent') ...[
            const Icon(Icons.check, size: 16, color: AppColors.textSecondary)
          ] else if (message.status == 'delivered') ...[
            const Icon(Icons.done_all, size: 16, color: AppColors.textSecondary)
          ] else if (message.status == 'read') ...[
            widget.showReadReceipts
                ? const Icon(Icons.done_all, size: 16, color: Colors.blue)
                : const Icon(Icons.done_all, size: 16, color: AppColors.textSecondary)
          ],
        ],
      ],
    );
  }
}
