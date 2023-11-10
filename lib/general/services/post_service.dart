import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/services.dart';

class PostService {
  static Future createPost(BuildContext context, {required String? caption, required File? picture}) async {
    PostState postState = Provider.of<PostState>(context, listen: false);
    ProfileState feedState = Provider.of<ProfileState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);
    final user = Provider.of<AppUser?>(context, listen: false);

    try {
      postState.setStatus = PostStatus.submitting;

      // Upload picture and get url
      String? pictureURL;
      if (picture != null) {
        pictureURL = await StorageService.uploadPostImage(picture);
      }
      // Create post object
      Post post = Post(
        authorId: userState.currentUser?.uid ?? "",
        authorDisplayName: userState.currentUser?.displayName ?? "",
        authorProfilePictureURL: userState.currentUser?.profilePictureURL,
        dateTime: DateTime.now(),
        likes: 0,
        caption: caption,
        pictureURL: pictureURL,
      );

      // Send to database

      await PostsDatabaseService.create(context, post: post);

      // Update state
      print("Post completed");
      postState.setStatus = PostStatus.success;
    } catch (error) {
      postState.setError = Error(message: "There was an issue uploading your post. Please try again");
    }
  }

  static Future getProfilePosts(BuildContext context) async {
    ProfileState feedState = Provider.of<ProfileState>(context, listen: false);

    try {
      return await PostsDatabaseService.readPostsFromUserId(
        context,
        userId: feedState.user?.uid ?? "",
        lastPostId: null,
      );
    } catch (error) {
      feedState.setError = Error(message: "There was an retreiving your posts. Please try again.");
    }
  }

  static Future paginateProfilePosts(BuildContext context) async {
    ProfileState feedState = Provider.of<ProfileState>(context, listen: false);

    try {
      feedState.setStatus = ProfileStatus.paginating;

      // Find last user ID
      String lastPostId = "";
      if (feedState.posts.isNotEmpty) {
        lastPostId = feedState.posts.last.uid!;
      }

      // Add posts from database
      feedState.addPosts = await PostsDatabaseService.readPostsFromUserId(
        context,
        userId: feedState.user?.uid ?? "",
        lastPostId: lastPostId,
      );
      feedState.setStatus = ProfileStatus.loaded;
    } catch (error) {
      feedState.setError = Error(message: "There was an issue loading your posts. Please try again.");
    }
  }

  static Future getFeed(BuildContext context) async {
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);
    if (userState.currentUser == null) {
      // Not logged in
      feedState.setError = Error(message: "Log in and follow fellow munro baggers to see their posts.");
      return;
    }
    try {
      feedState.setStatus = FeedStatus.loading;

      feedState.setPosts = await PostsDatabaseService.getFeedFromUserId(
        context,
        userId: userState.currentUser?.uid ?? "",
        lastPostId: null,
      );
      feedState.setStatus = FeedStatus.loaded;
    } catch (error) {
      feedState.setError = Error(
        code: error.toString(),
        message: "There was an retreiving your posts. Please try again.",
      );
    }
  }

  static Future paginateFeed(BuildContext context) async {
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      feedState.setStatus = FeedStatus.paginating;

      // Find last user ID
      String lastPostId = "";
      if (feedState.posts.isNotEmpty) {
        lastPostId = feedState.posts.last.uid!;
      }

      // Add posts from database
      feedState.addPosts = await PostsDatabaseService.getFeedFromUserId(
        context,
        userId: userState.currentUser?.uid ?? "",
        lastPostId: lastPostId,
      );

      feedState.setStatus = FeedStatus.loaded;
    } catch (error) {
      feedState.setError = Error(message: "There was an issue loading your feed. Please try again.");
    }
  }
}
