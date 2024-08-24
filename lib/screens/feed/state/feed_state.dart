import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class FeedState extends ChangeNotifier {
  FeedStatus _status = FeedStatus.initial;
  Error _error = Error();
  List<Post> _friendsPosts = [];
  List<Post> _globalPosts = [];

  FeedStatus get status => _status;
  Error get error => _error;
  List<Post> get friendsPosts => _friendsPosts;
  List<Post> get globalPosts => _globalPosts;

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

  updatePost(Post post) {
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
