import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class FeedState extends ChangeNotifier {
  final PostsRepository _postsRepository;
  final UserState _userState;
  final UserLikeState _userLikeState;
  final Analytics _analytics;
  final Logger _logger;

  FeedState(
    this._postsRepository,
    this._userState,
    this._userLikeState,
    this._analytics,
    this._logger,
  );

  FeedStatus _status = FeedStatus.initial;
  Error _error = Error();
  List<Post> _friendsPosts = [];
  List<Post> _globalPosts = [];

  FeedStatus get status => _status;
  Error get error => _error;
  List<Post> get friendsPosts => _friendsPosts;
  List<Post> get globalPosts => _globalPosts;

  Future getFriendsFeed() async {
    if (_userState.currentUser == null) {
      // Not logged in
      setError = Error(message: "Log in and follow fellow munro baggers to see their posts.");
      return;
    }

    List<String> blockedUsers = _userState.blockedUsers;

    try {
      setStatus = FeedStatus.loading;

      List<Post> posts = await _postsRepository.getFriendsFeedFromUserId(
        userId: _userState.currentUser?.uid ?? "",
        excludedAuthorIds: blockedUsers,
      );

      // Check likes
      _userLikeState.reset();
      _userLikeState.getLikedPostIds(posts: posts);

      _friendsPosts = posts;
      setStatus = FeedStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue retreiving your posts. Please try again.",
      );
    }
  }

  Future paginateFriendsFeed() async {
    if (_userState.currentUser == null) {
      // Not logged in
      setError = Error(message: "Log in and follow fellow munro baggers to see their posts.");
      return;
    }
    try {
      setStatus = FeedStatus.paginating;

      List<String> blockedUsers = _userState.blockedUsers;

      // Add posts from database
      List<Post> newPosts = await _postsRepository.getFriendsFeedFromUserId(
        userId: _userState.currentUser?.uid ?? "",
        excludedAuthorIds: blockedUsers,
        offset: friendsPosts.length,
      );

      // Check likes
      _userLikeState.getLikedPostIds(posts: newPosts);

      _friendsPosts.addAll(newPosts);
      setStatus = FeedStatus.loaded;
      _analytics.track(
        AnalyticsEvent.paginateFriendsFeed,
        props: {
          AnalyticsProp.postCount: _friendsPosts.length,
        },
      );
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading your feed. Please try again.");
    }
  }

  Future getGlobalFeed() async {
    if (_userState.currentUser == null) {
      // Not logged in
      setError = Error(message: "Log in and follow fellow munro baggers to see their posts.");
      return;
    }
    try {
      setStatus = FeedStatus.loading;
      List<String> blockedUsers = _userState.blockedUsers;

      List<Post> posts = await _postsRepository.getGlobalFeed(
        excludedAuthorIds: blockedUsers,
      );

      // Check likes
      _userLikeState.reset();
      _userLikeState.getLikedPostIds(posts: posts);

      _globalPosts = posts;
      setStatus = FeedStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue retreiving your posts. Please try again.",
      );
    }
  }

  Future paginateGlobalFeed() async {
    if (_userState.currentUser == null) {
      // Not logged in
      setError = Error(message: "Log in and follow fellow munro baggers to see their posts.");
      return;
    }
    try {
      setStatus = FeedStatus.paginating;

      List<String> blockedUsers = _userState.blockedUsers;

      // Add posts from database
      List<Post> newPosts = await _postsRepository.getGlobalFeed(
        excludedAuthorIds: blockedUsers,
        offset: globalPosts.length,
      );

      // Check likes
      _userLikeState.getLikedPostIds(posts: newPosts);

      _globalPosts.addAll(newPosts);
      setStatus = FeedStatus.loaded;
      _analytics.track(
        AnalyticsEvent.paginateGlobalFeed,
        props: {
          AnalyticsProp.postCount: _globalPosts.length,
        },
      );
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading your feed. Please try again.");
    }
  }

  set setStatus(FeedStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = FeedStatus.error;
    _error = error;
    notifyListeners();
  }

  set setFriendsPosts(List<Post> posts) {
    _friendsPosts = posts;
    notifyListeners();
  }

  set addFriendsPosts(List<Post> posts) {
    _friendsPosts.addAll(posts);
    notifyListeners();
  }

  set setGlobalPosts(List<Post> posts) {
    _globalPosts = posts;
    notifyListeners();
  }

  set addGlobalPosts(List<Post> posts) {
    _globalPosts.addAll(posts);
    notifyListeners();
  }

  void updatePost(Post post) {
    int index = _friendsPosts.indexWhere((element) => element.uid == post.uid);
    if (index != -1) {
      _friendsPosts[index] = post;
    }

    index = _globalPosts.indexWhere((element) => element.uid == post.uid);
    if (index != -1) {
      _globalPosts[index] = post;
    }
    notifyListeners();
  }

  removePost(Post post) {
    if (_friendsPosts.contains(post)) {
      _friendsPosts.remove(post);
    }

    if (_globalPosts.contains(post)) {
      _globalPosts.remove(post);
    }
    notifyListeners();
  }
}

enum FeedStatus { initial, loading, loaded, paginating, error }
