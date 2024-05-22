import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class ProfileState extends ChangeNotifier {
  ProfileStatus _status = ProfileStatus.initial;
  ProfilePhotoStatus _photoStatus = ProfilePhotoStatus.initial;
  AppUser? _user;
  List<AppUser> _profileHistory = [];
  bool _isFollowing = false;
  List<bool> _isFollowingHistory = [];
  bool _isCurrentUser = false;
  List<bool> _isCurrentUserHistory = [];
  List<Post> _posts = [];
  List<List<Post>> _postsHisotry = [];
  List<MunroPicture> _profilePhotos = [];
  List<List<MunroPicture>> _profilePhotosHistory = [];
  Error _error = Error();

  AppUser? get user => _user;
  ProfileStatus get status => _status;
  ProfilePhotoStatus get photoStatus => _photoStatus;
  bool get isFollowing => _isFollowing;
  bool get isCurrentUser => _isCurrentUser;
  List<Post> get posts => _posts;
  List<MunroPicture> get profilePhotos => _profilePhotos;
  Error get error => _error;

  set setStatus(ProfileStatus profileStatus) {
    _status = profileStatus;
    notifyListeners();
  }

  set setPhotoStatus(ProfilePhotoStatus photoStatus) {
    _photoStatus = photoStatus;
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
    if (_profileHistory.isNotEmpty &&
        _postsHisotry.isNotEmpty &&
        _profilePhotosHistory.isNotEmpty &&
        _isFollowingHistory.isNotEmpty &&
        _isCurrentUserHistory.isNotEmpty) {
      _profileHistory.removeAt(0);
      _postsHisotry.removeAt(0);
      _profilePhotosHistory.removeAt(0);
      _isFollowingHistory.removeAt(0);
      _isCurrentUserHistory.removeAt(0);
      if (_profileHistory.isNotEmpty && _postsHisotry.isNotEmpty) {
        _user = _profileHistory[0];
        _posts = _postsHisotry[0];
        _profilePhotos = _profilePhotosHistory[0];
        _isFollowing = _isFollowingHistory[0];
        _isCurrentUser = _isCurrentUserHistory[0];
      } else {
        _user = null;
        _posts = [];
        _profilePhotos = [];
        _isFollowing = false;
        _isCurrentUser = false;
      }

      notifyListeners();
    }
  }

  void clear() {
    _profileHistory = [];
    _user = null;
    _posts = [];
    _postsHisotry = [];
    _profilePhotos = [];
    _profilePhotosHistory = [];
    _isFollowing = false;
    _isFollowingHistory = [];
    _isCurrentUser = false;
    _isCurrentUserHistory = [];
  }

  set setIsFollowing(bool isFollowing) {
    _isFollowingHistory.insert(0, isFollowing);
    _isFollowing = isFollowing;
    notifyListeners();
  }

  set setIsCurrentUser(bool isCurrentUser) {
    _isCurrentUserHistory.insert(0, isCurrentUser);
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

  updatePost(Post post) {
    int index = _posts.indexWhere((element) => element.uid == post.uid);
    if (index != -1) {
      _posts[index] = post;
    }

    for (var i = 0; i < _postsHisotry.length; i++) {
      int index = _postsHisotry[i].indexWhere((element) => element.uid == post.uid);
      if (index != -1) {
        _postsHisotry[i][index] = post;
      }
    }
    notifyListeners();
  }

  set setProfilePhotos(List<MunroPicture> profilePhotos) {
    _profilePhotosHistory.insert(0, profilePhotos);
    _profilePhotos = profilePhotos;
    notifyListeners();
  }

  set addProfilePhotos(List<MunroPicture> profilePhotos) {
    _profilePhotos.addAll(profilePhotos);
    notifyListeners();
  }

  set setError(Error error) {
    _status = ProfileStatus.error;
    _error = error;
    notifyListeners();
  }

  reset() {
    _status = ProfileStatus.initial;
    _photoStatus = ProfilePhotoStatus.initial;
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

enum ProfilePhotoStatus { initial, loading, loaded, paginating, error }
