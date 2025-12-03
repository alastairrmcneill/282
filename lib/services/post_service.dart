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
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);
    MunroCompletionState munroCompletionState = Provider.of<MunroCompletionState>(context, listen: false);

    try {
      createPostState.setStatus = CreatePostStatus.loading;

      List<Munro> munros = munroState.munroList.where((m) => createPostState.selectedMunroIds.contains(m.id)).toList();

      // Upload picture and get url
      Map<int, List<String>> addedImageUrlsMap = {};

      for (int munroId in createPostState.addedImages.keys) {
        for (File image in createPostState.addedImages[munroId]!) {
          String imageURL = await StorageService.uploadPostImage(image);
          if (addedImageUrlsMap[munroId] == null) {
            addedImageUrlsMap[munroId] = [];
          }
          addedImageUrlsMap[munroId]!.add(imageURL);
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

      DateTime postDateTime = DateTime.now().toUtc();

      // Get summitDateTime by combining date and time
      DateTime? summitDateTime = DateTime(
        createPostState.summitedDate?.year ?? postDateTime.year,
        createPostState.summitedDate?.month ?? postDateTime.month,
        createPostState.summitedDate?.day ?? postDateTime.day,
        createPostState.startTime?.hour ?? 12,
        createPostState.startTime?.minute ?? 0,
      );

      // Create post object
      Post post = Post(
        authorId: userState.currentUser?.uid ?? "",
        title: title,
        description: createPostState.description,
        dateTimeCreated: postDateTime,
        privacy: createPostState.postPrivacy ?? Privacy.public,
      );

      // Send to database
      String postId = await PostsDatabase.create(context, post: post);

      // Log event
      bool showPrivacyOption = RemoteConfigService.getBool(RCFields.showPrivacyOption);

      await AnalyticsService.logPostCreation(
        privacy: post.privacy,
        showPrivacyOption: showPrivacyOption,
      );

      // Complete munros
      await munroCompletionState.markMunrosAsCompleted(
        munros: munros,
        summitDateTime: summitDateTime,
        postId: postId,
      );

      // Upload munro pictures
      await uploadMunroPictures(
        context,
        postId: postId,
        imageURLsMap: addedImageUrlsMap,
        privacy: post.privacy,
      );

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
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    MunroCompletionState munroCompletionState = Provider.of<MunroCompletionState>(context, listen: false);
    try {
      createPostState.setStatus = CreatePostStatus.loading;

      // Get the original post
      Map<int, List<String>> addedImageUrlsMap = {};

      for (int munroId in createPostState.addedImages.keys) {
        for (File image in createPostState.addedImages[munroId]!) {
          String imageURL = await StorageService.uploadPostImage(image);
          if (addedImageUrlsMap[munroId] == null) {
            addedImageUrlsMap[munroId] = [];
          }
          addedImageUrlsMap[munroId]!.add(imageURL);
        }
      }

      // Create post object
      Post post = createPostState.editingPost!;

      // Get summitDateTime by combining date and time
      DateTime? summitDateTime = DateTime(
        createPostState.summitedDate?.year ?? post.summitedDateTime!.year,
        createPostState.summitedDate?.month ?? post.summitedDateTime!.month,
        createPostState.summitedDate?.day ?? post.summitedDateTime!.day,
        createPostState.startTime?.hour ?? 12,
        createPostState.startTime?.minute ?? 0,
      );

      Post newPost = post.copyWith(
        title: createPostState.title,
        description: createPostState.description,
        summitedDateTime: summitDateTime,
        privacy: createPostState.postPrivacy ?? Privacy.public,
      );

      // Send to database
      await PostsDatabase.update(context, post: newPost);

      // Complete munros
      List<Munro> addedMunros =
          munroState.munroList.where((m) => createPostState.addedMunroIds.contains(m.id)).toList();

      munroCompletionState.markMunrosAsCompleted(
        munros: addedMunros,
        summitDateTime: newPost.summitedDateTime!,
        postId: post.uid,
      );

      munroCompletionState.removeCompletionsByMunroIdsAndPost(
        munroIds: createPostState.deletedMunroIds.toList(),
        postId: post.uid,
      );

      await uploadMunroPictures(
        context,
        postId: post.uid,
        imageURLsMap: addedImageUrlsMap,
        privacy: newPost.privacy,
      );

      // Delete images that aren't needed anymore
      await deleteMunroPictures(
        context,
        postId: post.uid,
        imageURLs: createPostState.deletedImages.toList(),
      );

      // Update post in state
      Map<int, List<String>> updatedImageURLsMap = {...createPostState.existingImages, ...addedImageUrlsMap};

      Post newPostState = newPost.copyWith(imageUrlsMap: updatedImageURLsMap);

      // Update state
      profileState.updatePost(newPostState);
      feedState.updatePost(newPostState);
      createPostState.setStatus = CreatePostStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      createPostState.setError = Error(message: "There was an issue uploading your post. Please try again");
    }
  }

  static Future<List<Post>> getProfilePosts(BuildContext context) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    UserLikeState userLikeState = context.read<UserLikeState>();

    List<Post> posts = [];
    try {
      // Get posts
      posts = await PostsDatabase.readPostsFromUserId(
        context,
        userId: profileState.profile?.id ?? "",
      );

      // Check likes
      userLikeState.reset();
      userLikeState.getLikedPostIds(posts: posts);

      return posts;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(message: "There was an retreiving your posts. Please try again.");
      return posts;
    }
  }

  static Future paginateProfilePosts(BuildContext context) async {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    UserLikeState userLikeState = context.read<UserLikeState>();

    try {
      profileState.setStatus = ProfileStatus.paginating;

      // Add posts from database
      List<Post> newPosts = await PostsDatabase.readPostsFromUserId(
        context,
        userId: profileState.profile?.id ?? "",
        offset: profileState.posts.length,
      );

      // Check likes
      userLikeState.getLikedPostIds(posts: newPosts);

      // Set state
      profileState.addPosts = newPosts;

      profileState.setStatus = ProfileStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(message: "There was an issue loading your posts. Please try again.");
    }
  }

  static Future getFriendsFeed(BuildContext context) async {
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);
    UserLikeState userLikeState = context.read<UserLikeState>();

    if (userState.currentUser == null) {
      // Not logged in
      feedState.setError = Error(message: "Log in and follow fellow munro baggers to see their posts.");
      return;
    }

    List<String> blockedUsers = userState.blockedUsers;

    try {
      feedState.setStatus = FeedStatus.loading;

      List<Post> posts = await PostsDatabase.getFriendsFeedFromUserId(
        context,
        userId: userState.currentUser?.uid ?? "",
        excludedAuthorIds: blockedUsers,
      );

      // Check likes
      userLikeState.reset();
      userLikeState.getLikedPostIds(posts: posts);

      posts = posts.where((post) => !blockedUsers.contains(post.authorId)).toList();

      feedState.setFriendsPosts = posts;
      feedState.setStatus = FeedStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      feedState.setError = Error(
        code: error.toString(),
        message: "There was an issue retreiving your posts. Please try again.",
      );
    }
  }

  static Future paginateFriendsFeed(BuildContext context) async {
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);
    UserLikeState userLikeState = context.read<UserLikeState>();

    if (userState.currentUser == null) {
      // Not logged in
      feedState.setError = Error(message: "Log in and follow fellow munro baggers to see their posts.");
      return;
    }
    try {
      feedState.setStatus = FeedStatus.paginating;

      List<String> blockedUsers = userState.blockedUsers;

      // Add posts from database
      List<Post> newPosts = await PostsDatabase.getFriendsFeedFromUserId(
        context,
        userId: userState.currentUser?.uid ?? "",
        excludedAuthorIds: blockedUsers,
        offset: feedState.friendsPosts.length,
      );

      // Check likes
      userLikeState.getLikedPostIds(posts: newPosts);

      feedState.addFriendsPosts = newPosts;
      feedState.setStatus = FeedStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      feedState.setError = Error(message: "There was an issue loading your feed. Please try again.");
    }
  }

  static Future getGlobalFeed(BuildContext context) async {
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);
    UserLikeState userLikeState = context.read<UserLikeState>();

    if (userState.currentUser == null) {
      // Not logged in
      feedState.setError = Error(message: "Log in and follow fellow munro baggers to see their posts.");
      return;
    }
    try {
      feedState.setStatus = FeedStatus.loading;
      List<String> blockedUsers = userState.blockedUsers;

      List<Post> posts = await PostsDatabase.getGlobalFeed(
        context,
        excludedAuthorIds: blockedUsers,
      );

      // Check likes
      userLikeState.reset();
      userLikeState.getLikedPostIds(posts: posts);

      feedState.setGlobalPosts = posts;
      feedState.setStatus = FeedStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      feedState.setError = Error(
        code: error.toString(),
        message: "There was an issue retreiving your posts. Please try again.",
      );
    }
  }

  static Future paginateGlobalFeed(BuildContext context) async {
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);
    UserLikeState userLikeState = context.read<UserLikeState>();

    if (userState.currentUser == null) {
      // Not logged in
      feedState.setError = Error(message: "Log in and follow fellow munro baggers to see their posts.");
      return;
    }
    try {
      feedState.setStatus = FeedStatus.paginating;

      List<String> blockedUsers = userState.blockedUsers;

      // Add posts from database
      List<Post> newPosts = await PostsDatabase.getGlobalFeed(
        context,
        excludedAuthorIds: blockedUsers,
        offset: feedState.globalPosts.length,
      );

      // Check likes
      userLikeState.getLikedPostIds(posts: newPosts);

      feedState.addGlobalPosts = newPosts;
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

      PostsDatabase.deletePostWithUID(context, uid: post.uid);
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(message: "There was an issue deleting your post. Please try again.");
    }
  }

  static Future uploadMunroPictures(
    BuildContext context, {
    required String postId,
    required Map<int, List<String>> imageURLsMap,
    required String privacy,
  }) async {
    // State management
    UserState userState = Provider.of<UserState>(context, listen: false);
    MunroPicturesRepository munroPicturesRepository = context.read<MunroPicturesRepository>();

    if (userState.currentUser == null) return;

    List<MunroPicture> munroPictures = [];

    imageURLsMap.forEach((munroId, imageURLs) async {
      for (String imageURL in imageURLs) {
        munroPictures.add(MunroPicture(
          uid: "",
          munroId: munroId,
          authorId: userState.currentUser!.uid!,
          imageUrl: imageURL,
          postId: postId,
          privacy: privacy,
        ));
      }
    });

    await munroPicturesRepository.createMunroPictures(munroPictures: munroPictures);
  }

  static Future deleteMunroPictures(
    BuildContext context, {
    required String postId,
    required List<String> imageURLs,
  }) async {
    MunroPicturesRepository munroPicturesRepository = context.read<MunroPicturesRepository>();

    await munroPicturesRepository.deleteMunroPicturesByUrls(imageURLs: imageURLs);

    for (String imageURL in imageURLs) {
      await StorageService.deleteImage(imageURL);
    }
  }
}
