import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart' show UserState;
import 'package:two_eight_two/services/services.dart';

class ProfileState extends ChangeNotifier {
  final MunroPicturesRepository _munroPicturesRepository;
  final UserState _userState;
  ProfileState(this._munroPicturesRepository, this._userState);

  ProfileStatus _status = ProfileStatus.initial;
  ProfilePhotoStatus _photoStatus = ProfilePhotoStatus.initial;
  Profile? _profile;
  List<Profile> _profileHistory = [];
  bool _isFollowing = false;
  List<bool> _isFollowingHistory = [];
  bool _isCurrentUser = false;
  List<bool> _isCurrentUserHistory = [];
  List<Post> _posts = [];
  List<List<Post>> _postsHistory = [];
  List<MunroPicture> _profilePhotos = [];
  List<List<MunroPicture>> _profilePhotosHistory = [];
  List<MunroCompletion> _munroCompletions = [];
  Error _error = Error();

  Profile? get profile => _profile;
  ProfileStatus get status => _status;
  ProfilePhotoStatus get photoStatus => _photoStatus;
  bool get isFollowing => _isFollowing;
  bool get isCurrentUser => _isCurrentUser;
  List<Post> get posts => _posts;
  List<MunroPicture> get profilePhotos => _profilePhotos;
  List<MunroCompletion> get munroCompletions => _munroCompletions;
  Error get error => _error;

  Future<void> getMunroPictures({required String profileId, int count = 18}) async {
    try {
      _photoStatus = ProfilePhotoStatus.loading;
      notifyListeners();
      final blockedUsers = _userState.blockedUsers;
      List<MunroPicture> pictures = await _munroPicturesRepository.readProfilePictures(
        profileId: profileId,
        excludedAuthorIds: blockedUsers,
        offset: 0,
        count: count,
      );

      _profilePhotosHistory.insert(0, pictures);
      _profilePhotos = pictures;

      _photoStatus = ProfilePhotoStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading pictures for this profile. Please try again.");
    }
  }

  Future<List<MunroPicture>> paginateMunroPictures({required String profileId}) async {
    try {
      _photoStatus = ProfilePhotoStatus.paginating;
      notifyListeners();
      final blockedUsers = _userState.blockedUsers;
      List<MunroPicture> pictures = await _munroPicturesRepository.readProfilePictures(
        profileId: profileId,
        excludedAuthorIds: blockedUsers,
        offset: _profilePhotos.length,
      );

      _profilePhotos.addAll(pictures);

      _photoStatus = ProfilePhotoStatus.loaded;
      notifyListeners();
      return pictures;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading pictures for this profile. Please try again.");
      return [];
    }
  }

  set setStatus(ProfileStatus profileStatus) {
    _status = profileStatus;
    notifyListeners();
  }

  set setPhotoStatus(ProfilePhotoStatus photoStatus) {
    _photoStatus = photoStatus;
    notifyListeners();
  }

  set setProfile(Profile? profile) {
    if (profile != null) {
      _profileHistory.insert(0, profile);
    }
    _profile = profile;
    notifyListeners();
  }

  void navigateBack() {
    if (_profileHistory.isNotEmpty &&
        _postsHistory.isNotEmpty &&
        _profilePhotosHistory.isNotEmpty &&
        _isFollowingHistory.isNotEmpty &&
        _isCurrentUserHistory.isNotEmpty) {
      _profileHistory.removeAt(0);
      _postsHistory.removeAt(0);
      _profilePhotosHistory.removeAt(0);
      _isFollowingHistory.removeAt(0);
      _isCurrentUserHistory.removeAt(0);
      if (_profileHistory.isNotEmpty && _postsHistory.isNotEmpty) {
        _profile = _profileHistory[0];
        _posts = _postsHistory[0];
        _profilePhotos = _profilePhotosHistory[0];
        _isFollowing = _isFollowingHistory[0];
        _isCurrentUser = _isCurrentUserHistory[0];
      } else {
        _profile = null;
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
    _profile = null;
    _posts = [];
    _postsHistory = [];
    _profilePhotos = [];
    _profilePhotosHistory = [];
    _isFollowing = false;
    _isFollowingHistory = [];
    _isCurrentUser = false;
    _isCurrentUserHistory = [];
    _munroCompletions = [];
  }

  set setIsFollowing(bool isFollowing) {
    _isFollowingHistory.insert(0, isFollowing);
    _isFollowing = isFollowing;
    notifyListeners();
  }

  set setMunroCompletions(List<MunroCompletion> munroCompletions) {
    _munroCompletions = munroCompletions;
    notifyListeners();
  }

  set setIsCurrentUser(bool isCurrentUser) {
    _isCurrentUserHistory.insert(0, isCurrentUser);
    _isCurrentUser = isCurrentUser;
    notifyListeners();
  }

  set setPosts(List<Post> posts) {
    _postsHistory.insert(0, posts);
    _posts = posts;
    notifyListeners();
  }

  set addPosts(List<Post> posts) {
    _postsHistory[0].addAll(posts);
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

    for (var i = 0; i < _postsHistory.length; i++) {
      int index = _postsHistory[i].indexWhere((element) => element.uid == post.uid);
      if (index != -1) {
        _postsHistory[i][index] = post;
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
    _profile = null;
    _profileHistory = [];
    _isFollowing = false;
    _isCurrentUser = false;
    _posts = [];
    _postsHistory = [];
    _munroCompletions = [];
    _error = Error();
  }
}

enum ProfileStatus { initial, loading, loaded, paginating, error }

enum ProfilePhotoStatus { initial, loading, loaded, paginating, error }
