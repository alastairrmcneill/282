import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class UserLikeState extends ChangeNotifier {
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

  set setStatus(UserLikeStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = UserLikeStatus.error;
    _error = error;
    notifyListeners();
  }

  set addLikedPosts(Set<String> likedPosts) {
    _likedPosts.addAll(likedPosts);
    notifyListeners();
  }

  set addRecentlyLikedPost(String recentlyLikedPost) {
    if (_recentlyUnlikedPosts.contains(recentlyLikedPost)) {
      _recentlyUnlikedPosts.remove(recentlyLikedPost);
    } else {
      _recentlyLikedPosts.add(recentlyLikedPost);
    }
    notifyListeners();
  }

  removePost(String postId) {
    _likedPosts.remove(postId);
    if (_recentlyLikedPosts.contains(postId)) {
      _recentlyLikedPosts.remove(postId);
    } else {
      _recentlyUnlikedPosts.add(postId);
    }
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

  // set removeRecentlyLikedPosts(Set<String> recentlyLikedPosts){
  //   _recentlyLikedPosts.addAll(recentlyLikedPosts);
  //   notifyListeners();
  // }
}

enum UserLikeStatus { initial, loading, loaded, error }
