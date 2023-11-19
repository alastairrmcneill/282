import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class PostService {
  static Future createPost(BuildContext context) async {
    CreatePostState createPostState = Provider.of<CreatePostState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      createPostState.setStatus = CreatePostStatus.loading;

      // Upload picture and get url
      List<String> imageURLs = createPostState.imagesURLs;
      for (File image in createPostState.images) {
        String imageURL = await StorageService.uploadPostImage(image);
        imageURLs.add(imageURL);
      }

      // Get title
      String title = "";
      if (createPostState.title == null) {
        DateTime now = DateTime.now();
        if (now.month == 1 || now.month == 2 || now.month == 12) {
          title = "Winter Hike";
        } else if (now.month >= 3 && now.month <= 5) {
          title = "Spring Hike";
        } else if (now.month >= 6 && now.month <= 8) {
          title = "Summer Hike";
        } else if (now.month >= 9 && now.month <= 11) {
          title = "Autumn Hike";
        }
      } else {
        title = createPostState.title!;
      }

      // Create post object
      Post post = Post(
        authorId: userState.currentUser?.uid ?? "",
        authorDisplayName: userState.currentUser?.displayName ?? "",
        authorProfilePictureURL: userState.currentUser?.profilePictureURL,
        dateTime: DateTime.now(),
        likes: 0,
        title: title,
        description: createPostState.description,
        includedMunros: createPostState.selectedMunros,
        imageURLs: imageURLs,
      );

      // Send to database

      await PostsDatabase.create(context, post: post);

      // Update state
      print("Post completed");
      createPostState.setStatus = CreatePostStatus.loaded;
    } catch (error) {
      print(error);
      createPostState.setError = Error(message: "There was an issue uploading your post. Please try again");
    }
  }

  static Future editPost(BuildContext context) async {
    CreatePostState createPostState = Provider.of<CreatePostState>(context, listen: false);
    try {
      createPostState.setStatus = CreatePostStatus.loading;

      // Upload picture and get url
      List<String> imageURLs = createPostState.imagesURLs;
      for (File image in createPostState.images) {
        String imageURL = await StorageService.uploadPostImage(image);
        imageURLs.add(imageURL);
      }

      // Create post object
      Post post = createPostState.editingPost!;

      Post newPost = post.copyWith(
        title: createPostState.title,
        description: createPostState.description,
        imageURLs: imageURLs,
      );

      // Send to database

      await PostsDatabase.update(context, post: newPost);

      // Update state
      createPostState.setStatus = CreatePostStatus.loaded;
    } catch (error) {
      createPostState.setError = Error(message: "There was an issue uploading your post. Please try again");
    }
  }

  static Future getProfilePosts(BuildContext context) async {
    ProfileState feedState = Provider.of<ProfileState>(context, listen: false);

    try {
      return await PostsDatabase.readPostsFromUserId(
        context,
        userId: feedState.user?.uid ?? "",
        lastPostId: null,
      );
    } catch (error) {
      feedState.setError = Error(message: "There was an retreiving your posts. Please try again.");
    }
  }

  static Future paginateProfilePosts(BuildContext context) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);

    try {
      profileState.setStatus = ProfileStatus.paginating;

      // Find last user ID
      String? lastPostId;
      if (profileState.posts.isNotEmpty) {
        lastPostId = profileState.posts.last.uid!;
      }

      // Add posts from database
      List<Post> newPosts = await PostsDatabase.readPostsFromUserId(
        context,
        userId: profileState.user?.uid ?? "",
        lastPostId: lastPostId,
      );
      profileState.addPosts = newPosts;

      profileState.setStatus = ProfileStatus.loaded;
    } catch (error) {
      profileState.setError = Error(message: "There was an issue loading your posts. Please try again.");
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

      feedState.setPosts = await PostsDatabase.getFeedFromUserId(
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
      String? lastPostId;
      if (feedState.posts.isNotEmpty) {
        lastPostId = feedState.posts.last.uid!;
      }

      // Add posts from database
      feedState.addPosts = await PostsDatabase.getFeedFromUserId(
        context,
        userId: userState.currentUser?.uid ?? "",
        lastPostId: lastPostId,
      );

      feedState.setStatus = FeedStatus.loaded;
    } catch (error) {
      feedState.setError = Error(message: "There was an issue loading your feed. Please try again.");
    }
  }

  static Future deletePost(BuildContext context, {required Post post}) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);

    if (profileState.posts.contains(post)) {
      profileState.removePost(post);
    }

    PostsDatabase.deletePostWithUID(context, uid: post.uid ?? "");
  }
}
