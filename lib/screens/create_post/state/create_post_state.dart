import 'dart:io';

import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics_base.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class CreatePostState extends ChangeNotifier {
  final PostsRepository _postsRepository;
  final MunroPicturesRepository _munroPicturesRepository;
  final StorageRepository _storageRepository;
  final UserState _userState;
  final MunroCompletionState _munroCompletionState;
  final RemoteConfigState _remoteConfigState;
  final Analytics _analytics;
  final Logger _logger;

  CreatePostState(
    this._postsRepository,
    this._munroPicturesRepository,
    this._storageRepository,
    this._userState,
    this._munroCompletionState,
    this._remoteConfigState,
    this._analytics,
    this._logger,
  );

  CreatePostStatus _status = CreatePostStatus.initial;
  Error _error = Error();
  String? _title;
  String? _description;
  DateTime? _summitedDate;
  TimeOfDay? _startTime;
  Duration? _duration;
  Map<int, List<String>> _existingImages = {};
  Map<int, List<File>> _addedImages = {};
  Set<String> _deletedImages = {};
  Set<int> _existingMunroIds = {};
  Set<int> _addedMunroIds = {};
  Set<int> _deletedMunroIds = {};
  String? _postPrivacy;
  Post? _editingPost;

  CreatePostStatus get status => _status;
  Error get error => _error;
  String? get title => _title;
  String? get description => _description;
  DateTime? get summitedDate => _summitedDate;
  TimeOfDay? get startTime => _startTime;
  Duration? get duration => _duration;
  Map<int, List<String>> get existingImages => _existingImages;
  Map<int, List<File>> get addedImages => _addedImages;
  Set<String> get deletedImages => _deletedImages;
  Set<int> get existingMunroIds => _existingMunroIds;
  Set<int> get addedMunroIds => _addedMunroIds;
  Set<int> get deletedMunroIds => _deletedMunroIds;
  Set<int> get selectedMunroIds => _existingMunroIds.union(_addedMunroIds);
  String? get postPrivacy => _postPrivacy;
  bool get hasImage =>
      _addedImages.values.any((element) => element.isNotEmpty) ||
      _existingImages.values.any((element) => element.isNotEmpty);
  Post? get editingPost => _editingPost;

  Future<Post?> createPost() async {
    try {
      setStatus = CreatePostStatus.loading;

      // Upload picture and get url
      Map<int, List<String>> addedImageUrlsMap = {};

      for (int munroId in _addedImages.keys) {
        for (File image in _addedImages[munroId]!) {
          String imageURL = await _storageRepository.uploadImage(imageFile: image, type: ImageUploadType.post);
          if (addedImageUrlsMap[munroId] == null) {
            addedImageUrlsMap[munroId] = [];
          }
          addedImageUrlsMap[munroId]!.add(imageURL);
        }
      }

      // Get title
      String title = "";
      if (_title == null) {
        DateTime now = DateTime.now();
        if (now.month == 1 || now.month == 2 || now.month == 12) {
          title = "Winter Hike";
        } else if (now.month >= 3 && now.month <= 5) {
          title = "Spring Hike";
        } else if (now.month >= 6 && now.month <= 8) {
          title = "Summer Hike";
        } else if (now.month >= 9 && now.month <= 11) {
          title = "Autumn Hike";
        }
      } else {
        title = _title!;
      }

      DateTime postDateTime = DateTime.now().toUtc();

      // Get summitDateTime by combining date and time
      DateTime? summitDateTime = DateTime(
        _summitedDate?.year ?? postDateTime.year,
        _summitedDate?.month ?? postDateTime.month,
        _summitedDate?.day ?? postDateTime.day,
        _startTime?.hour ?? 12,
        _startTime?.minute ?? 0,
      );

      // Create post object
      Post post = Post(
        authorId: _userState.currentUser?.uid ?? "",
        title: title,
        description: _description,
        dateTimeCreated: postDateTime,
        privacy: _postPrivacy ?? Privacy.public,
      );

      // Send to database
      String postId = await _postsRepository.create(post: post);

      // Log event
      bool showPrivacyOption = _remoteConfigState.config.showPrivacyOption;

      _analytics.track(
        AnalyticsEvent.createPost,
        props: {
          AnalyticsProp.privacy: post.privacy,
          AnalyticsProp.showPrivacyOption: showPrivacyOption,
          AnalyticsProp.munroCompletionsAdded: selectedMunroIds.length,
          AnalyticsProp.imagesAdded:
              addedImageUrlsMap.values.fold<int>(0, (previousValue, element) => previousValue + element.length),
        },
      );

      // Complete munros
      await _munroCompletionState.markMunrosAsCompleted(
        munroIds: selectedMunroIds.toList(),
        summitDateTime: summitDateTime,
        postId: postId,
      );

      // Upload munro pictures
      await uploadMunroPictures(
        postId: postId,
        imageURLsMap: addedImageUrlsMap,
        privacy: post.privacy,
      );

      // Update state
      setStatus = CreatePostStatus.loaded;
      return post.copyWith(
        uid: postId,
        summitedDateTime: summitDateTime,
        imageUrlsMap: addedImageUrlsMap,
      );
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue uploading your post. Please try again");
      return null;
    }
  }

  Future<Post?> editPost() async {
    try {
      setStatus = CreatePostStatus.loading;

      // Get the original post
      Map<int, List<String>> addedImageUrlsMap = {};

      for (int munroId in _addedImages.keys) {
        for (File image in _addedImages[munroId]!) {
          String imageURL = await _storageRepository.uploadImage(imageFile: image, type: ImageUploadType.post);
          if (addedImageUrlsMap[munroId] == null) {
            addedImageUrlsMap[munroId] = [];
          }
          addedImageUrlsMap[munroId]!.add(imageURL);
        }
      }

      // Create post object
      Post post = _editingPost!;

      // Get summitDateTime by combining date and time
      DateTime? summitDateTime = DateTime(
        _summitedDate?.year ?? post.summitedDateTime!.year,
        _summitedDate?.month ?? post.summitedDateTime!.month,
        _summitedDate?.day ?? post.summitedDateTime!.day,
        _startTime?.hour ?? 12,
        _startTime?.minute ?? 0,
      );

      Post newPost = post.copyWith(
        title: _title,
        description: _description,
        summitedDateTime: summitDateTime,
        privacy: _postPrivacy ?? Privacy.public,
      );

      // Send to database
      await _postsRepository.update(post: newPost);

      _munroCompletionState.markMunrosAsCompleted(
        munroIds: _addedMunroIds.toList(),
        summitDateTime: newPost.summitedDateTime!,
        postId: post.uid,
      );

      _munroCompletionState.removeCompletionsByMunroIdsAndPost(
        munroIds: _deletedMunroIds.toList(),
        postId: post.uid,
      );

      await uploadMunroPictures(
        postId: post.uid,
        imageURLsMap: addedImageUrlsMap,
        privacy: newPost.privacy,
      );

      // Delete images that aren't needed anymore
      await deleteMunroPictures(
        postId: post.uid,
        imageURLs: deletedImages.toList(),
      );

      // Update post in state
      Map<int, List<String>> updatedImageURLsMap = {...existingImages, ...addedImageUrlsMap};

      Post newPostState = newPost.copyWith(imageUrlsMap: updatedImageURLsMap);

      setStatus = CreatePostStatus.loaded;

      _analytics.track(
        AnalyticsEvent.editPost,
        props: {
          AnalyticsProp.postId: post.uid,
          AnalyticsProp.privacy: post.privacy,
          AnalyticsProp.munroCompletionsAdded: selectedMunroIds.length,
          AnalyticsProp.imagesAdded:
              addedImageUrlsMap.values.fold<int>(0, (previousValue, element) => previousValue + element.length),
        },
      );
      return newPostState;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue uploading your post. Please try again");
      return null;
    }
  }

  Future<void> uploadMunroPictures({
    required String postId,
    required Map<int, List<String>> imageURLsMap,
    required String privacy,
  }) async {
    if (_userState.currentUser == null) return;

    List<MunroPicture> munroPictures = [];

    imageURLsMap.forEach((munroId, imageURLs) async {
      for (String imageURL in imageURLs) {
        munroPictures.add(MunroPicture(
          uid: "",
          munroId: munroId,
          authorId: _userState.currentUser!.uid!,
          imageUrl: imageURL,
          postId: postId,
          privacy: privacy,
        ));
      }
    });

    await _munroPicturesRepository.createMunroPictures(munroPictures: munroPictures);
  }

  Future deleteMunroPictures({
    required String postId,
    required List<String> imageURLs,
  }) async {
    await _munroPicturesRepository.deleteMunroPicturesByUrls(imageURLs: imageURLs);

    for (String imageURL in imageURLs) {
      await _storageRepository.deleteByUrl(imageURL);
    }
  }

  Future deletePost({required Post post}) async {
    try {
      _postsRepository.deletePostWithUID(uid: post.uid);
      _analytics.track(
        AnalyticsEvent.deletePost,
        props: {
          AnalyticsProp.postId: post.uid,
        },
      );
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      _status = CreatePostStatus.error;
      notifyListeners();
    }
  }

  set setStatus(CreatePostStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = CreatePostStatus.error;
    _error = error;
    notifyListeners();
  }

  set setTitle(String? title) {
    _title = title;
    notifyListeners();
  }

  set setDescription(String? description) {
    _description = description;
    notifyListeners();
  }

  set setSummitedDate(DateTime? summitedDate) {
    _summitedDate = summitedDate;
    notifyListeners();
  }

  set setStartTime(TimeOfDay? startTime) {
    _startTime = startTime;
    notifyListeners();
  }

  set setDuration(Duration? duration) {
    _duration = duration;
    notifyListeners();
  }

  set setPostPrivacy(String? postPrivacy) {
    _postPrivacy = postPrivacy;
    notifyListeners();
  }

  set loadPost(Post post) {
    _editingPost = post;
    _title = post.title;
    _summitedDate = post.summitedDateTime;
    _startTime = TimeOfDay.fromDateTime(post.summitedDateTime ?? DateTime(0, 0, 0, 12, 0));
    _duration = post.duration;
    _description = post.description;
    _existingImages = post.imageUrlsMap;
    _addedImages = {};
    _deletedImages = {};
    _existingMunroIds = post.includedMunroIds.toSet();
    _addedMunroIds = {};
    _deletedMunroIds = {};
    _postPrivacy = post.privacy;
    notifyListeners();
  }

  addMunro(int munroId) {
    _addedMunroIds.add(munroId);
    notifyListeners();
  }

  removeMunro(int munroId) {
    if (_existingMunroIds.contains(munroId)) {
      _existingMunroIds.remove(munroId);
      _deletedMunroIds.add(munroId);
    }
    if (_addedMunroIds.contains(munroId)) {
      _addedMunroIds.remove(munroId);
      _deletedMunroIds.add(munroId);
    }

    if (_existingImages.keys.contains(munroId)) {
      _deletedImages.addAll(_existingImages[munroId]!);
      _existingImages.remove(munroId);
    }

    if (_addedImages.keys.contains(munroId)) {
      _addedImages.remove(munroId);
    }

    notifyListeners();
  }

  addImage({required int munroId, required File image}) {
    if (_addedImages[munroId] == null) _addedImages[munroId] = [];

    _addedImages[munroId]!.add(image);

    notifyListeners();
  }

  removeImage({required int munroId, required int index}) {
    if (_addedImages[munroId] == null) return;

    _addedImages[munroId]!.removeAt(index);
    notifyListeners();
  }

  removeExistingImage({required int munroId, required String url}) {
    if (_existingImages[munroId] == null) return;
    if (_existingImages[munroId]!.contains(url)) {
      _existingImages[munroId]!.remove(url);
    }
    _deletedImages.add(url);
    notifyListeners();
  }

  reset() {
    _title = null;
    _description = null;
    _summitedDate = null;
    _startTime = null;
    _duration = null;
    _editingPost = null;
    _existingImages = {};
    _addedImages = {};
    _deletedImages = {};
    _existingMunroIds = {};
    _addedMunroIds = {};
    _deletedMunroIds = {};
    _postPrivacy = null;
    _error = Error();
    _status = CreatePostStatus.initial;
  }
}

enum CreatePostStatus { initial, loading, loaded, error }
