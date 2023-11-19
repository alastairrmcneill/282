import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/comments/services/comments_service.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CommentsScreen extends StatelessWidget {
  const CommentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommentsState>(
      builder: (context, commentsState, child) {
        switch (commentsState.status) {
          case CommentsStatus.loading:
            return Scaffold(
              appBar: AppBar(),
              body: const LoadingWidget(),
            );
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

  Widget _buildScreen(BuildContext context, CommentsState commentsState) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          children: [
            ...commentsState.comments.map((e) => Text(e.commentText)).toList(),
            ElevatedButton(
              onPressed: () {
                CommentsService.createComment(context, content: "This is my second comment");
              },
              child: Text("comment"),
            ),
          ],
        ),
      ),
    );
  }
}
