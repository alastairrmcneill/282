import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class LikeService {
  // Like Post
  static Future likePost(BuildContext context, {required Post post}) async {
    UserLikeState userLikeState = Provider.of<UserLikeState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    Like like = Like(
      postId: post.uid ?? "",
      userId: userState.currentUser?.uid ?? "",
      userDisplayName: userState.currentUser?.displayName ?? "User",
      userProfilePictureURL: userState.currentUser?.profilePictureURL,
    );
    LikeDatabase.create(context, like: like);
    userLikeState.addRecentlyLikedPost = post.uid!;
    userLikeState.addLikedPosts = {post.uid!};
  }

  // Unlike Post
  static Future unLikePost(BuildContext context, {required Post post}) async {
    UserLikeState userLikeState = Provider.of<UserLikeState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    LikeDatabase.delete(context, postId: post.uid ?? "", userId: userState.currentUser?.uid ?? "");
    userLikeState.removePost(post.uid!);
  }

  // Get liked posts
  static Future getLikedPostIds(BuildContext context, {required List<Post> posts}) async {
    UserLikeState userLikeState = Provider.of<UserLikeState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    userLikeState.addLikedPosts = await LikeDatabase.getLikedPostIds(
      userId: userState.currentUser?.uid ?? "",
      posts: posts,
    );
  }

  // Clear liked posts
  static clearLikedPosts(BuildContext context) {
    UserLikeState userLikeState = Provider.of<UserLikeState>(context, listen: false);
    userLikeState.reset();
  }

  // Get likes for a given post
  static Future getPostLikes(BuildContext context) async {
    LikesState likesState = Provider.of<LikesState>(context, listen: false);

    likesState.setStatus = LikesStatus.loading;

    likesState.setLikes = await LikeDatabase.readPostLikes(
      postId: likesState.postId,
      lastLikeId: null,
    );

    likesState.setStatus = LikesStatus.loaded;
  }

  // Get likes for a given post
  static Future paginatePostLikes(BuildContext context) async {
    LikesState likesState = Provider.of<LikesState>(context, listen: false);

    likesState.setStatus = LikesStatus.paginating;

    // Find last document
    String? lastLikeId;
    if (likesState.likes.isNotEmpty) {
      lastLikeId = likesState.likes.last.uid!;
    }
    likesState.addLikes = await LikeDatabase.readPostLikes(
      postId: likesState.postId,
      lastLikeId: lastLikeId,
    );

    likesState.setStatus = LikesStatus.loaded;
  }
}
