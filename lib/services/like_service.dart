import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class LikeService {
  // Like Post
  static Future likePost(BuildContext context, {required Post post}) async {
    LikeState likeState = Provider.of<LikeState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    Like like = Like(
      postId: post.uid ?? "",
      userId: userState.currentUser?.uid ?? "",
      userDisplayName: userState.currentUser?.displayName ?? "User",
      userProfilePictureURL: userState.currentUser?.profilePictureURL,
    );
    LikeDatabase.create(context, like: like);
    likeState.addRecentlyLikedPost = post.uid!;
    likeState.addLikedPosts = {post.uid!};
  }

  // Unlike Post
  static Future unLikePost(BuildContext context, {required Post post}) async {
    LikeState likeState = Provider.of<LikeState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    LikeDatabase.delete(context, postId: post.uid ?? "", userId: userState.currentUser?.uid ?? "");
    likeState.removePost(post.uid!);
  }

  // Get liked posts
  static Future getLikedPostIds(BuildContext context, {required List<Post> posts}) async {
    LikeState likeState = Provider.of<LikeState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    likeState.addLikedPosts = await LikeDatabase.getLikedPostIds(
      userId: userState.currentUser?.uid ?? "",
      posts: posts,
    );
  }

  // Clear liked posts
  static clearLikedPosts(BuildContext context) {
    LikeState likeState = Provider.of<LikeState>(context, listen: false);
    likeState.reset();
  }
}
