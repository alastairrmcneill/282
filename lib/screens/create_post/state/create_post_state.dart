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
  Map<int, List<File>> _images = {};
  Map<int, List<String>> _imageURLs = {};
  List<int> _selectedMunroIds = [];
  String? _postPrivacy;
  Post? _editingPost;

  CreatePostStatus get status => _status;
  Error get error => _error;
  String? get title => _title;
  String? get description => _description;
  DateTime? get summitedDate => _summitedDate;
  TimeOfDay? get startTime => _startTime;
  Duration? get duration => _duration;
  Map<int, List<File>> get images => _images;
  Map<int, List<String>> get imagesURLs => _imageURLs;
  List<int> get selectedMunroIds => _selectedMunroIds;
  String? get postPrivacy => _postPrivacy;
  bool get hasImage => images.values.any((element) => element.isNotEmpty);
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

  setImageURLs({required int munroId, required List<String> imageURLs}) {
    if (_imageURLs[munroId] == null) _imageURLs[munroId] = [];

    _imageURLs[munroId] = imageURLs;
    notifyListeners();
  }

  set loadPost(Post post) {
    _editingPost = post;
    _title = post.title;
    _summitedDate = post.summitedDateTime;
    _startTime = TimeOfDay.fromDateTime(post.summitedDateTime ?? DateTime(0, 0, 0, 12, 0));
    _duration = post.duration;
    _description = post.description;
    _imageURLs = post.imageUrlsMap;
    _selectedMunroIds = post.includedMunroIds;
    _postPrivacy = post.privacy;
    notifyListeners();
  }

  addMunro(int munroId) {
    if (!_selectedMunroIds.contains(munroId)) {
      _selectedMunroIds.add(munroId);
      notifyListeners();
    }
  }

  removeMunro(int munroId) {
    if (_selectedMunroIds.contains(munroId)) {
      _selectedMunroIds.remove(munroId);
      notifyListeners();
    }
  }

  addImage({required int munroId, required File image}) {
    if (_images[munroId] == null) _images[munroId] = [];

    _images[munroId]!.add(image);

    notifyListeners();
  }

  removeImage({required int munroId, required int index}) {
    if (_images[munroId] == null) return;

    _images[munroId]!.removeAt(index);
    notifyListeners();
  }

  removeImageURL({required int munroId, required String url}) {
    if (_imageURLs[munroId] == null) return;
    if (_imageURLs[munroId]!.contains(url)) {
      _imageURLs[munroId]!.remove(url);
    }
    notifyListeners();
  }

  reset() {
    _title = null;
    _description = null;
    _summitedDate = null;
    _startTime = null;
    _duration = null;
    _editingPost = null;
    _imageURLs = {};
    _images = {};
    _selectedMunroIds = [];
    _postPrivacy = null;
    _error = Error();
    _status = CreatePostStatus.initial;
  }
}

enum CreatePostStatus { initial, loading, loaded, error }
