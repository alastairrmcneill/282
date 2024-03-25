// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class CommentsService {
  static Future createComment(BuildContext context) async {
    CommentsState commentsState = Provider.of<CommentsState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      // Set status
      commentsState.setStatus = CommentsStatus.submitting;

      Comment comment = Comment(
        postId: commentsState.postId,
        authorId: userState.currentUser?.uid ?? "",
        authorDisplayName: userState.currentUser?.displayName ?? "",
        authorProfilePictureURL: userState.currentUser?.profilePictureURL,
        dateTime: DateTime.now().toUtc(),
        commentText: commentsState.commentText!,
      );

      // Upload comment
      await CommentsDatabase.create(context, comment: comment);

      // Add comment to comments list
      commentsState.addComments = [comment];

      // Set status
      commentsState.setCommentText = null;
      commentsState.setStatus = CommentsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      commentsState.setError = Error(message: "There was an issue posting your comment. Please try again");
    }
  }

  static Future getPostComments(BuildContext context) async {
    CommentsState commentsState = Provider.of<CommentsState>(context, listen: false);

    try {
      // Set Status
      commentsState.setStatus = CommentsStatus.loading;

      // Read comments for post
      commentsState.setComments = await CommentsDatabase.readPostComments(
        context,
        postId: commentsState.postId,
        lastCommentId: null,
      );

      // Read post details
      commentsState.setPost = await PostsDatabase.readPostFromUid(context, uid: commentsState.postId);

      // Update status
      commentsState.setStatus = CommentsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      commentsState.setError =
          Error(code: error.toString(), message: "There was an issue retreiving the comments. Please try again.");
    }
  }

  static Future paginatePostComments(BuildContext context) async {
    CommentsState commentsState = Provider.of<CommentsState>(context, listen: false);

    try {
      commentsState.setStatus = CommentsStatus.paginating;

      // Find last user ID
      String? lastCommentId;
      if (commentsState.comments.isNotEmpty) {
        lastCommentId = commentsState.comments.last.uid!;
      }

      // Add posts from database
      commentsState.addComments = await CommentsDatabase.readPostComments(
        context,
        postId: commentsState.postId,
        lastCommentId: lastCommentId,
      );

      commentsState.setStatus = CommentsStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      commentsState.setError = Error(message: "There was an issue retreiving the comments. Please try again.");
    }
  }

  static Future deleteComment(BuildContext context, {required Comment comment}) async {
    CommentsState commentsState = Provider.of<CommentsState>(context, listen: false);

    try {
      if (commentsState.comments.contains(comment)) {
        commentsState.removeComment(comment);
      }
      CommentsDatabase.deleteComment(context, comment: comment);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      commentsState.setError = Error(message: "There was an issue deleting the comment. Please try again.");
    }
  }
}
