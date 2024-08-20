import 'dart:io';

import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class CreatePostState extends ChangeNotifier {
  CreatePostStatus _status = CreatePostStatus.initial;
  Error _error = Error();
  String? _title;
  String? _description;
  Map<String, List<File>> _images = {};
  Map<String, List<String>> _imageURLs = {};
  List<Munro> _selectedMunros = [];
  String? _postPrivacy;
  Post? _editingPost;

  CreatePostStatus get status => _status;
  Error get error => _error;
  String? get title => _title;
  String? get description => _description;
  Map<String, List<File>> get images => _images;
  Map<String, List<String>> get imagesURLs => _imageURLs;
  List<Munro> get selectedMunros => _selectedMunros;
  String? get postPrivacy => _postPrivacy;
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

  set setPostPrivacy(String? postPrivacy) {
    _postPrivacy = postPrivacy;
    notifyListeners();
  }

  setImageURLs({required String munroId, required List<String> imageURLs}) {
    if (_imageURLs[munroId] == null) _imageURLs[munroId] = [];

    _imageURLs[munroId] = imageURLs;
    notifyListeners();
  }

  set loadPost(Post post) {
    _editingPost = post;
    _title = post.title;
    _description = post.description;
    _imageURLs = post.imageUrlsMap;
    _selectedMunros = post.includedMunros;
    _postPrivacy = post.privacy;
    notifyListeners();
  }

  addMunro(Munro munro) {
    if (!_selectedMunros.contains(munro)) {
      _selectedMunros.add(munro);
      notifyListeners();
    }
  }

  removeMunro(Munro munro) {
    if (_selectedMunros.contains(munro)) {
      _selectedMunros.remove(munro);
      notifyListeners();
    }
  }

  addImage({required String munroId, required File image}) {
    if (_images[munroId] == null) _images[munroId] = [];

    _images[munroId]!.add(image);

    notifyListeners();
  }

  removeImage({required String munroId, required int index}) {
    if (_images[munroId] == null) return;

    _images[munroId]!.removeAt(index);
    notifyListeners();
  }

  removeImageURL({required String munroId, required String url}) {
    if (_imageURLs[munroId] == null) return;
    if (_imageURLs[munroId]!.contains(url)) {
      _imageURLs[munroId]!.remove(url);
    }
    notifyListeners();
  }

  reset() {
    _title = null;
    _description = null;
    _editingPost = null;
    _imageURLs = {};
    _images = {};
    _selectedMunros = [];
    _postPrivacy = null;
    _error = Error();
    _status = CreatePostStatus.initial;
  }
}

enum CreatePostStatus { initial, loading, loaded, error }
