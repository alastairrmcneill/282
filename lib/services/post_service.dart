// ignore_for_file: use_build_context_synchronously

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
      Map<String, List<String>> imageURLsMap = createPostState.imagesURLs;

      for (String munroId in createPostState.images.keys) {
        for (File image in createPostState.images[munroId]!) {
          String imageURL = await StorageService.uploadPostImage(image);
          if (imageURLsMap[munroId] == null) {
            imageURLsMap[munroId] = [];
          }
          imageURLsMap[munroId]!.add(imageURL);
        }
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

      DateTime summitDatetime = DateTime.now().toUtc();
      // Create post object
      Post post = Post(
        authorId: userState.currentUser?.uid ?? "",
        authorDisplayName: userState.currentUser?.displayName ?? "",
        authorProfilePictureURL: userState.currentUser?.profilePictureURL,
        dateTime: summitDatetime,
        likes: 0,
        title: title,
        description: createPostState.description,
        includedMunros: createPostState.selectedMunros,
        includedMunroIds: createPostState.selectedMunros.map((Munro munro) => munro.id).toList(),
        imageUrlsMap: imageURLsMap,
        public: true,
      );

      // Send to database
      await PostsDatabase.create(context, post: post);

      // Complete munros
      await MunroService.markMunrosAsDone(
        context,
        munros: createPostState.selectedMunros,
        summitDateTime: summitDatetime,
      );

      // Check for achievements
      print("Checking achievements");
      AchievementService.checkAchievements(context);

      // Update state
      createPostState.setStatus = CreatePostStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      print("Error: $error");
      createPostState.setError = Error(message: "There was an issue uploading your post. Please try again");
    }
  }

  static Future editPost(BuildContext context) async {
    CreatePostState createPostState = Provider.of<CreatePostState>(context, listen: false);
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    try {
      createPostState.setStatus = CreatePostStatus.loading;

      // Upload picture and get url
      Map<String, List<String>> imageURLsMap = createPostState.imagesURLs;

      for (String munroId in createPostState.images.keys) {
        for (File image in createPostState.images[munroId]!) {
          String imageURL = await StorageService.uploadPostImage(image);
          if (imageURLsMap[munroId] == null) {
            imageURLsMap[munroId] = [];
          }
          imageURLsMap[munroId]!.add(imageURL);
        }
      }

      // Create post object
      Post post = createPostState.editingPost!;

      Post newPost = post.copyWith(
        title: createPostState.title,
        description: createPostState.description,
        imageUrlsMap: imageURLsMap,
      );

      // Send to database
      await PostsDatabase.update(context, post: newPost);

      // Complete munros
      MunroService.markMunrosAsDone(
        context,
        munros: createPostState.selectedMunros,
        summitDateTime: newPost.dateTime,
      );

      // Update state
      profileState.updatePost(newPost);
      feedState.updatePost(newPost);
      createPostState.setStatus = CreatePostStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      createPostState.setError = Error(message: "There was an issue uploading your post. Please try again");
    }
  }

  static Future<List<Post>> getProfilePosts(BuildContext context) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    List<Post> posts = [];
    try {
      // Get posts
      posts = await PostsDatabase.readPostsFromUserId(
        context,
        userId: profileState.user?.uid ?? "",
        lastPostId: null,
      );

      // Check likes
      LikeService.clearLikedPosts(context);
      LikeService.getLikedPostIds(context, posts: posts);

      return posts;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(message: "There was an retreiving your posts. Please try again.");
      return posts;
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

      // Check likes
      LikeService.getLikedPostIds(context, posts: newPosts);

      // Set state
      profileState.addPosts = newPosts;

      profileState.setStatus = ProfileStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
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

      List<Post> posts = await PostsDatabase.getFeedFromUserId(
        context,
        userId: userState.currentUser?.uid ?? "",
        lastPostId: null,
      );

      // Check likes
      LikeService.clearLikedPosts(context);
      LikeService.getLikedPostIds(context, posts: posts);

      // Filter posts
      List<String> blockedUsers = userState.currentUser!.blockedUsers ?? [];
      posts = posts.where((post) => !blockedUsers.contains(post.authorId)).toList();

      feedState.setPosts = posts;
      feedState.setStatus = FeedStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      feedState.setError = Error(
        code: error.toString(),
        message: "There was an issue retreiving your posts. Please try again.",
      );
    }
  }

  static Future paginateFeed(BuildContext context) async {
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);
    if (userState.currentUser == null) {
      // Not logged in
      feedState.setError = Error(message: "Log in and follow fellow munro baggers to see their posts.");
      return;
    }
    try {
      feedState.setStatus = FeedStatus.paginating;

      // Find last user ID
      String? lastPostId;
      if (feedState.posts.isNotEmpty) {
        lastPostId = feedState.posts.last.uid!;
      }

      // Add posts from database
      List<Post> newPosts = await PostsDatabase.getFeedFromUserId(
        context,
        userId: userState.currentUser?.uid ?? "",
        lastPostId: lastPostId,
      );

      // Check likes
      LikeService.getLikedPostIds(context, posts: newPosts);

      // Filter posts
      List<String> blockedUsers = userState.currentUser!.blockedUsers ?? [];
      newPosts = newPosts.where((post) => !blockedUsers.contains(post.authorId)).toList();

      feedState.addPosts = newPosts;
      feedState.setStatus = FeedStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      feedState.setError = Error(message: "There was an issue loading your feed. Please try again.");
    }
  }

  static Future deletePost(BuildContext context, {required Post post}) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    FeedState feedState = Provider.of<FeedState>(context, listen: false);

    try {
      profileState.removePost(post);
      feedState.removePost(post);

      PostsDatabase.deletePostWithUID(context, uid: post.uid ?? "");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(message: "There was an issue deleting your post. Please try again.");
    }
  }
}
