import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class FeedState extends ChangeNotifier {
  FeedStatus _status = FeedStatus.initial;
  Error _error = Error();
  List<Post> _posts = [];

  FeedStatus get status => _status;
  Error get error => _error;
  List<Post> get posts => _posts;

  set setStatus(FeedStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = FeedStatus.error;
    _error = error;
    notifyListeners();
  }

  set setPosts(List<Post> posts) {
    _posts = posts;
    notifyListeners();
  }

  set addPosts(List<Post> posts) {
    _posts.addAll(posts);
    notifyListeners();
  }

  updatePost(Post post) {
    int index = _posts.indexWhere((element) => element.uid == post.uid);
    if (index != -1) {
      _posts[index] = post;
    }
    notifyListeners();
  }

  removePost(Post post) {
    if (_posts.contains(post)) {
      _posts.remove(post);
    }
    notifyListeners();
  }
}

enum FeedStatus { initial, loading, loaded, paginating, error }
