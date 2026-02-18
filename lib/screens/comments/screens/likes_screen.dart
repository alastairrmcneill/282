import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/comments/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class LikesScreenArgs {
  final String postId;
  LikesScreenArgs({required this.postId});
}

class LikesScreen extends StatefulWidget {
  final String postId;
  const LikesScreen({super.key, required this.postId});
  static const String route = '/posts/likes';

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  late ScrollController _scrollController;
  @override
  void initState() {
    LikesState likesState = context.read<LikesState>();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          likesState.status != LikesStatus.paginating) {
        likesState.paginatePostLikes();
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
    return Consumer<LikesState>(
      builder: (context, likesstate, child) {
        switch (likesstate.status) {
          case LikesStatus.loading:
            return _buildLoadingScreen();
          case LikesStatus.error:
            return Scaffold(
              appBar: AppBar(),
              body: CenterText(text: likesstate.error.message),
            );
          default:
            return _buildScreen(context, likesstate);
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 30,
        itemBuilder: (context, index) => const ShimmerListTile(),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, LikesState likesState) {
    LikesState likesState = context.watch<LikesState>();
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            likesState.getPostLikes(postId: widget.postId);
          },
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ...likesState.likes.map(
                (Like like) => LikeTile(
                  like: like,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
