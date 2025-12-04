import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class UserLikeState extends ChangeNotifier {
  final LikesRepository _repository;
  final UserState _userState;

  UserLikeState(
    this._repository,
    this._userState,
  );

  UserLikeStatus _status = UserLikeStatus.initial;
  Error _error = Error();
  Set<String> _likedPosts = {};
  Set<String> _recentlyLikedPosts = {};
  Set<String> _recentlyUnlikedPosts = {};

  UserLikeStatus get status => _status;
  Error get error => _error;
  Set<String> get likedPosts => _likedPosts;
  Set<String> get recentlyLikedPosts => _recentlyLikedPosts;
  Set<String> get recentlyUnlikedPosts => _recentlyUnlikedPosts;

  Future<void> likePost({
    required Post post,
    required void Function(Post newPost) onPostUpdated,
  }) async {
    Like like = Like(
      postId: post.uid,
      userId: _userState.currentUser?.uid ?? "",
      userDisplayName: _userState.currentUser?.displayName ?? "User",
      userProfilePictureURL: _userState.currentUser?.profilePictureURL,
      dateTimeCreated: DateTime.now(),
    );

    await _repository.create(like: like);

    if (_recentlyUnlikedPosts.contains(post.uid)) {
      _recentlyUnlikedPosts.remove(post.uid);
    } else {
      _recentlyLikedPosts.add(post.uid);
    }
    _likedPosts.add(post.uid);

    notifyListeners();

    Post newPost = post.copyWith(likes: post.likes + 1);
    onPostUpdated(newPost);
  }

  Future<void> unLikePost({
    required Post post,
    required void Function(Post newPost) onPostUpdated,
  }) async {
    await _repository.delete(
      postId: post.uid,
      userId: _userState.currentUser?.uid ?? "",
    );

    _likedPosts.remove(post.uid);
    if (_recentlyLikedPosts.contains(post.uid)) {
      _recentlyLikedPosts.remove(post.uid);
    } else {
      _recentlyUnlikedPosts.add(post.uid);
    }
    notifyListeners();

    Post newPost = post.copyWith(likes: post.likes - 1);
    onPostUpdated(newPost);
  }

  Future<void> getLikedPostIds({required List<Post> posts}) async {
    _status = UserLikeStatus.loading;
    notifyListeners();
    try {
      final likedPosts = await _repository.getLikedPostIds(
        userId: _userState.currentUser?.uid ?? "",
        posts: posts,
      );

      _likedPosts.addAll(likedPosts);
      _status = UserLikeStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an error loading liked posts.");
    }
  }

  set setError(Error error) {
    _status = UserLikeStatus.error;
    _error = error;
    notifyListeners();
  }

  void reset() {
    _recentlyLikedPosts = {};
    _likedPosts = {};
    _recentlyUnlikedPosts = {};
    _status = UserLikeStatus.initial;
    _error = Error();
    notifyListeners();
  }
}

enum UserLikeStatus { initial, loading, loaded, error }
