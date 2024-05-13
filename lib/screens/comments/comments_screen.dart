import 'package:cached_network_image/cached_network_image.dart';
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
                    commentsState.post.imageUrlsMap.values.expand((element) => element).toList().isEmpty
                        ? const SizedBox()
                        : SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              imageUrl: commentsState.post.imageUrlsMap.values.expand((element) => element).toList()[0],
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Image.asset(
                                'assets/images/post_image_placeholder.png',
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: 300,
                              ),
                              fadeInDuration: Duration.zero,
                              errorWidget: (context, url, error) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.error),
                                      Text(
                                        error.toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          commentsState.post.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
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
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_rounded),
                            const SizedBox(width: 10),
                            Text(commentsState.post.likes == 1
                                ? "${commentsState.post.likes} like"
                                : "${commentsState.post.likes} likes"),
                          ],
                        ),
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
