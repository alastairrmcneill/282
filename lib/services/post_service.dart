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

    try {
      createPostState.setStatus = CreatePostStatus.loading;

      List<Munro> munros = munroState.munroList.where((m) => createPostState.selectedMunroIds.contains(m.id)).toList();

      // Upload picture and get url
      Map<int, List<String>> imageURLsMap = createPostState.imagesURLs;

      for (int munroId in createPostState.images.keys) {
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
        authorDisplayName: userState.currentUser?.displayName ?? "",
        authorProfilePictureURL: userState.currentUser?.profilePictureURL,
        dateTimeCreated: postDateTime,
        summitedDateTime: summitDateTime,
        duration: createPostState.duration,
        likes: 0,
        title: title,
        description: createPostState.description,
        includedMunroIds: createPostState.selectedMunroIds,
        imageUrlsMap: imageURLsMap,
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
      await MunroCompletionService.markMunrosAsCompleted(
        context,
        munros: munros,
        summitDateTime: summitDateTime,
        postId: postId,
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
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    try {
      createPostState.setStatus = CreatePostStatus.loading;

      // Get the original post
      Post originalPost = createPostState.editingPost!;
      Map<int, List<String>> originalImageURLsMap = originalPost.imageUrlsMap;
      
      // Start with existing URLs
      Map<int, List<String>> finalImageURLsMap = Map.from(createPostState.imagesURLs);
      
      // Process each munro's images
      for (int munroId in createPostState.images.keys) {
        List<File> newImages = createPostState.images[munroId]!;
        
        if (newImages.isNotEmpty) {
          // Upload new images for this munro
          List<String> newImageURLs = [];
          for (File image in newImages) {
            String imageURL = await StorageService.uploadPostImage(image);
            newImageURLs.add(imageURL);
          }
          
          // Replace the images for this munro with new ones
          finalImageURLsMap[munroId] = [
            ...(finalImageURLsMap[munroId] ?? []), // Keep existing URLs that weren't changed
            ...newImageURLs // Add new URLs
          ];
          
          // Delete old images for this munro from storage
          if (originalImageURLsMap.containsKey(munroId)) {
            for (String oldImageURL in originalImageURLsMap[munroId]!) {
              // Only delete if it's not in the final map (i.e., it was removed)
              if (!finalImageURLsMap[munroId]!.contains(oldImageURL)) {
                await StorageService.deleteImage(oldImageURL);
              }
            }
          }
        }
      }
      
      // Handle munros that were completely removed
      for (int originalMunroId in originalImageURLsMap.keys) {
        if (!createPostState.selectedMunroIds.contains(originalMunroId)) {
          // This munro was removed from the post, delete all its images
          for (String imageURL in originalImageURLsMap[originalMunroId]!) {
            await StorageService.deleteImage(imageURL);
          }
          finalImageURLsMap.remove(originalMunroId);
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
        imageUrlsMap: finalImageURLsMap,
        privacy: createPostState.postPrivacy ?? Privacy.public,
      );

      // Send to database
      await PostsDatabase.update(context, post: newPost);

      // Complete munros
      // TODO: fix logic here for making sure we don't duplicate munro completions

      List<int> previousMunroIds = post.includedMunroIds;
      List<int> currentMunroIds = createPostState.selectedMunroIds;
      List<int> newMunroIds = currentMunroIds.where((id) => !previousMunroIds.contains(id)).toList();

      List<Munro> newMunros = munroState.munroList.where((m) => newMunroIds.contains(m.id)).toList();

      MunroCompletionService.markMunrosAsCompleted(
        context,
        munros: newMunros,
        summitDateTime: newPost.summitedDateTime!,
        postId: post.uid ?? "",
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

      // Add posts from database
      List<Post> newPosts = await PostsDatabase.readPostsFromUserId(
        context,
        userId: profileState.user?.uid ?? "",
        offset: profileState.posts.length,
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

  static Future getFriendsFeed(BuildContext context) async {
    FeedState feedState = Provider.of<FeedState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);
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
      // TODO: how to do we do the likes?
      LikeService.clearLikedPosts(context);
      LikeService.getLikedPostIds(context, posts: posts);

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
      // TODO how do we do the likes?
      LikeService.getLikedPostIds(context, posts: newPosts);

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
      LikeService.clearLikedPosts(context);
      LikeService.getLikedPostIds(context, posts: posts);

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
      LikeService.getLikedPostIds(context, posts: newPosts);

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

      PostsDatabase.deletePostWithUID(context, uid: post.uid ?? "");
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      profileState.setError = Error(message: "There was an issue deleting your post. Please try again.");
    }
  }
}
