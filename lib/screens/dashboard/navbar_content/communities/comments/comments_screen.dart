import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:iconly/iconly.dart';

// Data model for a single comment
class Comment {
  final String avatarUrl;
  final String name;
  final String time;
  final String text;
  final int likes;
  final List<Comment> replies;

  Comment({
    required this.avatarUrl,
    required this.name,
    required this.time,
    required this.text,
    this.likes = 0,
    this.replies = const [],
  });
}

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  // UPDATED: Added more mock comments
  final List<Comment> _comments = [
    Comment(
      avatarUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
      name: 'Rana Utban',
      time: '22h',
      text:
          'Lorem ipsum dolor sit amet consectetur. Mattis felis porttitor in tortor facilisis est platea quam euismod. Nulla aliquam dictumst sagittis quam.',
      likes: 12,
      replies: [
        Comment(
          avatarUrl: 'https://randomuser.me/api/portraits/men/65.jpg',
          name: 'John Doe',
          time: '21h',
          text: 'This is a reply.',
          likes: 2,
        ),
        Comment(
          avatarUrl: 'https://randomuser.me/api/portraits/women/66.jpg',
          name: 'Jane Smith',
          time: '20h',
          text: 'This is another reply.',
          likes: 5,
        ),
      ],
    ),
    Comment(
      avatarUrl: 'https://randomuser.me/api/portraits/women/67.jpg',
      name: 'Rana Utban',
      time: '22h',
      text:
          'Lorem ipsum dolor sit amet consectetur. Mattis felis porttitor in tortor facilisis est platea.',
      likes: 12,
    ),
    Comment(
      avatarUrl: 'https://randomuser.me/api/portraits/men/68.jpg',
      name: 'Alex Ray',
      time: '23h',
      text: 'Great point! I totally agree with what you are saying.',
      likes: 8,
      replies: [
        Comment(
          avatarUrl: 'https://randomuser.me/api/portraits/women/68.jpg',
          name: 'Sarah Lee',
          time: '22h',
          text: 'Thanks Alex!',
          likes: 1,
        ),
      ],
    ),
    Comment(
      avatarUrl: 'https://randomuser.me/api/portraits/women/69.jpg',
      name: 'Mia Wong',
      time: '1d',
      text: 'Has anyone else experienced this? Looking for some advice.',
      likes: 25,
    ),
    Comment(
      avatarUrl: 'https://randomuser.me/api/portraits/men/70.jpg',
      name: 'Leo Chen',
      time: '1d',
      text: 'This is a fantastic discussion.',
      likes: 3,
    ),
    Comment(
      avatarUrl: 'https://randomuser.me/api/portraits/women/71.jpg',
      name: 'Isabella Rossi',
      time: '2d',
      text: 'Can someone explain this in simpler terms?',
      likes: 15,
    ),
    Comment(
      avatarUrl: 'https://randomuser.me/api/portraits/men/72.jpg',
      name: 'Omar Ahmed',
      time: '2d',
      text:
          'I found a great article related to this topic, I will share it soon.',
      likes: 18,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // UPDATED: Wrapped Scaffold in KeyboardDismissOnTap
    return KeyboardDismissOnTap(
      dismissOnCapturedTaps: true,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.secondaryBackground,
        appBar: AppBar(
          backgroundColor: AppColors.secondaryBackground,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text('Reiki Healing Community', style: textTheme.titleLarge),
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryBackground,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildCommentsHeader()),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return CommentTile(comment: _comments[index]);
                      }, childCount: _comments.length),
                    ),
                  ],
                ),
              ),
            ),
            _buildCommentInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '579 Comments',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 14),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(color: AppColors.secondaryBackground),
      child: FormBuilder(
        key: _formKey,
        child: FormBuilderTextField(
          name: 'comment',
          decoration: InputDecoration(
            hintText: 'Write a comment',
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 14,
            ),
            filled: true,
            fillColor: AppColors.primaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryOrange),
            ),
            suffixIcon: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline, color: AppColors.textSecondary),
                SizedBox(width: 12),
                Icon(
                  Icons.emoji_emotions_outlined,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 12),
                Icon(IconlyLight.send, color: AppColors.textSecondary),
                SizedBox(width: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommentTile extends StatefulWidget {
  final Comment comment;
  final bool isReply;

  const CommentTile({super.key, required this.comment, this.isReply = false});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: widget.isReply ? 0 : 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: widget.isReply ? 32.0 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.comment.avatarUrl),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.comment.name,
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(widget.comment.time, style: textTheme.bodySmall),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.comment.text,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reply',
                            style: textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          if (widget.comment.replies.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showReplies = !_showReplies;
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'View all reply(${widget.comment.replies.length})',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    _showReplies
                                        ? Icons.arrow_drop_up
                                        : Icons.arrow_drop_down,
                                    color: AppColors.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    Text(
                      widget.comment.likes.toString(),
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      IconlyLight.heart,
                      color: AppColors.primaryRed,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_showReplies && widget.comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: widget.comment.replies
                    .map((reply) => CommentTile(comment: reply, isReply: true))
                    .toList(),
              ),
            ),
          if (!widget.isReply) const SizedBox(height: 16),
          if (!widget.isReply)
            const Divider(height: 1, color: AppColors.inputBorder),
        ],
      ),
    );
  }
}
