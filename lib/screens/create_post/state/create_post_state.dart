import 'dart:io';

import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class CreatePostState extends ChangeNotifier {
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
