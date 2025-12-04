import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart' show UserLikeState, UserState;
import 'package:two_eight_two/services/services.dart';

class ProfileState extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final MunroPicturesRepository _munroPicturesRepository;
  final PostsRepository _postsRepository;
  final UserState _userState;
  final UserLikeState _userLikeState;
  final FollowersRepository _followersRepository;
  final MunroCompletionsRepository _munroCompletionsRepository;
  ProfileState(
    this._profileRepository,
    this._munroPicturesRepository,
    this._postsRepository,
    this._userState,
    this._userLikeState,
    this._followersRepository,
    this._munroCompletionsRepository,
  );

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

  Future<void> loadProfileFromUserId({required String userId}) async {
    try {
      setStatus = ProfileStatus.loading;
      // Load user from database
      setProfile = await _profileRepository.getProfileFromUserId(userId: userId);

      // Check if this is current user
      setIsCurrentUser = _userState.currentUser?.uid == userId;

      // Check if current user is following this user
      setIsFollowing = await isFollowingUser(
        currentUserId: _userState.currentUser?.uid ?? "",
        profileUserId: userId,
      );

      await getProfilePosts();

      // Load profile pictures
      getMunroPictures(profileId: userId);

      // Set loading status?
      setStatus = ProfileStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue loading the profile. Please try again.",
      );
    }
  }

  Future<bool> isFollowingUser({
    required String currentUserId,
    required String profileUserId,
  }) async {
    try {
      final relationshipExists = await _followersRepository.relationshipExists(
        sourceId: currentUserId,
        targetId: profileUserId,
      );

      return relationshipExists;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> getProfileMunroCompletions({required String userId}) async {
    try {
      final munroCompletions = await _munroCompletionsRepository.getUserMunroCompletions(
        userId: userId,
      );
      setMunroCompletions = munroCompletions;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue loading the munros. Please try again.",
      );
    }
  }

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

  Future<void> getProfilePosts() async {
    try {
      setStatus = ProfileStatus.loading;
      // Get posts
      final posts = await _postsRepository.readPostsFromUserId(
        userId: _profile?.id ?? "",
      );

      // Check likes
      _userLikeState.reset();
      _userLikeState.getLikedPostIds(posts: posts);

      setPosts = posts;
      setStatus = ProfileStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an retreiving your posts. Please try again.");
    }
  }

  Future<void> paginateProfilePosts() async {
    try {
      setStatus = ProfileStatus.paginating;

      // Add posts from database
      List<Post> newPosts = await _postsRepository.readPostsFromUserId(
        userId: _profile?.id ?? "",
        offset: _posts.length,
      );

      // Check likes
      _userLikeState.getLikedPostIds(posts: newPosts);

      // Set state
      addPosts = newPosts;
      setStatus = ProfileStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading your posts. Please try again.");
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
