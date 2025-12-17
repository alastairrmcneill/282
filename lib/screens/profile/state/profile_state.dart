import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class ProfileState extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  final MunroPicturesRepository _munroPicturesRepository;
  final PostsRepository _postsRepository;
  final UserState _userState;
  final UserLikeState _userLikeState;
  final MunroCompletionsRepository _munroCompletionsRepository;
  ProfileState(
    this._profileRepository,
    this._munroPicturesRepository,
    this._postsRepository,
    this._userState,
    this._userLikeState,
    this._munroCompletionsRepository,
  );

  ProfileStatus _status = ProfileStatus.initial;
  ProfilePhotoStatus _photoStatus = ProfilePhotoStatus.initial;
  Profile? _profile;
  bool _isCurrentUser = false;
  List<Post> _posts = [];
  List<MunroPicture> _profilePhotos = [];
  List<MunroCompletion> _munroCompletions = [];
  Error _error = Error();

  Profile? get profile => _profile;
  ProfileStatus get status => _status;
  ProfilePhotoStatus get photoStatus => _photoStatus;
  bool get isCurrentUser => _isCurrentUser;
  List<Post> get posts => _posts;
  List<MunroPicture> get profilePhotos => _profilePhotos;
  List<MunroCompletion> get munroCompletions => _munroCompletions;
  Error get error => _error;

  Future<void> loadProfileFromUserId({required String userId}) async {
    _status = ProfileStatus.loading;
    notifyListeners();

    try {
      _profile = await _profileRepository.getProfileFromUserId(userId: userId);

      _isCurrentUser = _userState.currentUser?.uid == userId;

      await getProfilePosts();

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

  Future<void> getProfileMunroCompletions() async {
    try {
      final munroCompletions = await _munroCompletionsRepository.getUserMunroCompletions(
        userId: _profile?.id ?? "",
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
    _profile = profile;
    notifyListeners();
  }

  set setMunroCompletions(List<MunroCompletion> munroCompletions) {
    _munroCompletions = munroCompletions;
    notifyListeners();
  }

  set setIsCurrentUser(bool isCurrentUser) {
    _isCurrentUser = isCurrentUser;
    notifyListeners();
  }

  set setPosts(List<Post> posts) {
    _posts = posts;
    notifyListeners();
  }

  set addPosts(List<Post> posts) {
    notifyListeners();
  }

  void removePost(Post post) {
    if (_posts.contains(post)) {
      _posts.remove(post);
    }
    notifyListeners();
  }

  void updatePost(Post post) {
    int index = _posts.indexWhere((element) => element.uid == post.uid);
    if (index != -1) {
      _posts[index] = post;
    }
    notifyListeners();
  }

  set setProfilePhotos(List<MunroPicture> profilePhotos) {
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

  void reset() {
    _status = ProfileStatus.initial;
    _photoStatus = ProfilePhotoStatus.initial;
    _profile = null;
    _isCurrentUser = false;
    _posts = [];
    _munroCompletions = [];
    _error = Error();
  }
}

enum ProfileStatus { initial, loading, loaded, paginating, error }

enum ProfilePhotoStatus { initial, loading, loaded, paginating, error }
