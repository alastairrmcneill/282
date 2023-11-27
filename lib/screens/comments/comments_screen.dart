import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/comments/screens/likes_screen.dart';
import 'package:two_eight_two/screens/comments/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
    CommentsState commentsState = Provider.of<CommentsState>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          commentsState.status != CommentsStatus.paginating) {
        CommentsService.paginatePostComments(context);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentsState>(
      builder: (context, commentsState, child) {
        switch (commentsState.status) {
          case CommentsStatus.loading:
            return _buildLoadingScreen();
          case CommentsStatus.error:
            print(commentsState.error.code);
            return Scaffold(
              appBar: AppBar(),
              body: CenterText(text: commentsState.error.message),
            );
          default:
            return _buildScreen(context, commentsState);
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: 30,
                controller: _scrollController,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => ShimmerListTile(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, CommentsState commentsState) {
    LikesState likesState = Provider.of<LikesState>(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: RefreshIndicator(
                onRefresh: () async {
                  CommentsService.getPostComments(context);
                },
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    InkWell(
                      onTap: () {
                        likesState.reset();
                        likesState.setPostId = commentsState.postId;
                        LikeService.getPostLikes(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LikesScreen(),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Icon(Icons.favorite_rounded),
                          Text(commentsState.post.likes == 1
                              ? "${commentsState.post.likes} like"
                              : "${commentsState.post.likes} likes"),
                        ],
                      ),
                    ),
                    ...commentsState.comments
                        .map((Comment comment) => CommentTile(
                              comment: comment,
                            ))
                        .toList(),
                  ],
                ),
              ),
            ),
            const CommentInputField(),
          ],
        ),
      ),
    );
  }
}
