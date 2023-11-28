import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class ProfileState extends ChangeNotifier {
  ProfileStatus _status = ProfileStatus.initial;
  AppUser? _user;
  List<AppUser> _profileHistory = [];
  bool _isFollowing = false;
  bool _isCurrentUser = false;
  List<Post> _posts = [];
  List<List<Post>> _postsHisotry = [];
  Error _error = Error();

  AppUser? get user => _user;
  ProfileStatus get status => _status;
  bool get isFollowing => _isFollowing;
  bool get isCurrentUser => _isCurrentUser;
  List<Post> get posts => _posts;
  Error get error => _error;

  set setStatus(ProfileStatus profileStatus) {
    _status = profileStatus;
    notifyListeners();
  }

  set setUser(AppUser? user) {
    if (user != null) {
      _profileHistory.insert(0, user);
    }
    _user = user;
    notifyListeners();
  }

  void navigateBack() {
    if (_profileHistory.isNotEmpty) {
      _profileHistory.removeAt(0);
      _postsHisotry.removeAt(0);
      if (_profileHistory.isNotEmpty) {
        _user = _profileHistory[0];
        _posts = _postsHisotry[0];
      } else {
        _user = null;
        _posts = [];
      }

      notifyListeners();
    }
  }

  void clear() {
    _profileHistory = [];
    _user = null;
  }

  set setIsFollowing(bool isFollowing) {
    _isFollowing = isFollowing;
    notifyListeners();
  }

  set setIsCurrentUser(bool isCurrentUser) {
    _isCurrentUser = isCurrentUser;
    notifyListeners();
  }

  set setPosts(List<Post> posts) {
    _postsHisotry.insert(0, posts);
    _posts = posts;
    notifyListeners();
  }

  set addPosts(List<Post> posts) {
    _postsHisotry[0].addAll(posts);
    notifyListeners();
  }

  removePost(Post post) {
    if (_posts.contains(post)) {
      _posts.remove(post);
    }
    notifyListeners();
  }

  set setError(Error error) {
    _status = ProfileStatus.error;
    _error = error;
    notifyListeners();
  }

  reset() {
    _status = ProfileStatus.initial;
    _user = null;
    _profileHistory = [];
    _isFollowing = false;
    _isCurrentUser = false;
    _posts = [];
    _postsHisotry = [];
    _error = Error();
  }
}

enum ProfileStatus { initial, loading, loaded, paginating, error }
