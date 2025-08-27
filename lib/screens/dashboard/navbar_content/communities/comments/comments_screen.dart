import 'package:firstgenapp/models/community_models.dart';
import 'package:firstgenapp/services/firebase_service.dart';
import 'package:firstgenapp/utils/time_ago.dart';
import 'package:flutter/material.dart';
import 'package:firstgenapp/constants/appColors.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _commentController = TextEditingController();
  final _focusNode = FocusNode();
  String? _replyingToCommentId;
  String? _replyingToUsername;

  void _postComment() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );
      final userId = firebaseService.currentUser?.uid;
      if (userId == null) return;

      final text = _commentController.text;

      firebaseService.addCommentOrReply(
        postId: widget.postId,
        parentId: _replyingToCommentId,
        authorId: userId,
        text: text,
      );

      _commentController.clear();
      _focusNode.unfocus();
      setState(() {
        _replyingToCommentId = null;
        _replyingToUsername = null;
      });
    }
  }

  void _startReplying(String commentId, String username) {
    setState(() {
      _replyingToCommentId = commentId;
      _replyingToUsername = username;
    });
    _focusNode.requestFocus();
  }

  Future<void> _handleRefresh() async {
    setState(() {});
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );

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
          title: Text('Comments', style: textTheme.titleLarge),
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
                child: RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: StreamBuilder<List<Comment>>(
                    stream: firebaseService.getCommentsForPost(widget.postId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No comments yet.'));
                      }
                      final comments = snapshot.data!;
                      return CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: _buildCommentsHeader(comments.length),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return CommentTile(
                                comment: comments[index],
                                onReply: _startReplying,
                              );
                            }, childCount: comments.length),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            _buildCommentInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$count Comments',
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: AppColors.secondaryBackground),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyingToCommentId != null)
              Row(
                children: [
                  Text(
                    'Replying to $_replyingToUsername',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _replyingToCommentId = null;
                        _replyingToUsername = null;
                      });
                    },
                  ),
                ],
              ),
            FormBuilder(
              key: _formKey,
              child: FormBuilderTextField(
                name: 'comment',
                controller: _commentController,
                focusNode: _focusNode,
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
                    borderSide: const BorderSide(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      IconlyLight.send,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: _postComment,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommentTile extends StatefulWidget {
  final Comment comment;
  final bool isReply;
  final Function(String, String) onReply;

  const CommentTile({
    super.key,
    required this.comment,
    this.isReply = false,
    required this.onReply,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );

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
                FutureBuilder<Map<String, dynamic>?>(
                  future: firebaseService.getUserData(widget.comment.authorId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircleAvatar(radius: 20);
                    }
                    final authorData = snapshot.data!;
                    return CircleAvatar(
                      backgroundImage: NetworkImage(
                        authorData['profileImageUrl'],
                      ),
                      radius: 20,
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, dynamic>?>(
                        future: firebaseService.getUserData(
                          widget.comment.authorId,
                        ),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text("...");
                          }
                          final authorData = snapshot.data!;
                          return Row(
                            children: [
                              Text(
                                authorData['fullName'],
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                TimeAgo.format(
                                  widget.comment.timestamp
                                      .toDate()
                                      .toIso8601String(),
                                ),
                                style: textTheme.bodySmall,
                              ),
                            ],
                          );
                        },
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
                          GestureDetector(
                            onTap: () async {
                              final authorData = await firebaseService
                                  .getUserData(widget.comment.authorId);
                              widget.onReply(
                                widget.comment.id,
                                authorData?['fullName'] ?? "user",
                              );
                            },
                            child: Text(
                              'Reply',
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          if (widget.comment.replyCount > 0)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showReplies = !_showReplies;
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    'View all reply(${widget.comment.replyCount})',
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
                GestureDetector(
                  onTap: () {
                    firebaseService.toggleCommentLike(
                      widget.comment.id,
                      firebaseService.currentUser!.uid,
                    );
                  },
                  child: Row(
                    children: [
                      Text(
                        widget.comment.likes.length.toString(),
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        widget.comment.likes[firebaseService
                                    .currentUser!
                                    .uid] ==
                                true
                            ? IconlyBold.heart
                            : IconlyLight.heart,
                        color: AppColors.primaryRed,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showReplies && widget.comment.replyCount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: StreamBuilder<List<Comment>>(
                stream: firebaseService.getRepliesForComment(widget.comment.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }
                  final replies = snapshot.data!;
                  return Column(
                    children: replies
                        .map(
                          (reply) => CommentTile(
                            comment: reply,
                            isReply: true,
                            onReply: widget.onReply,
                          ),
                        )
                        .toList(),
                  );
                },
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
