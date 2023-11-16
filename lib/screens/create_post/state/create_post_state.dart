import 'dart:io';

import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class CreatePostState extends ChangeNotifier {
  CreatePostStatus _status = CreatePostStatus.initial;
  Error _error = Error();
  String? _title;
  String? _description;
  List<File> _images = [];
  List<String> _imageURLs = [];
  List<Munro> _selectedMunros = [];
  Post? _editingPost;

  CreatePostStatus get status => _status;
  Error get error => _error;
  String? get title => _title;
  String? get description => _description;
  List<File> get images => _images;
  List<String> get imagesURLs => _imageURLs;
  List<Munro> get selectedMunros => _selectedMunros;
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

  set setImageURLs(List<String> imageURLs) {
    _imageURLs = imageURLs;
    notifyListeners();
  }

  set loadPost(Post post) {
    _editingPost = post;
    _title = post.title;
    _description = post.description;
    _imageURLs = post.imageURLs;
    _selectedMunros = post.includedMunros;
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

  addImage(File image) {
    _images.add(image);
    notifyListeners();
  }

  removeImage(int index) {
    _images.removeAt(index);
    notifyListeners();
  }

  removeImageURL(String url) {
    if (_imageURLs.contains(url)) {
      _imageURLs.remove(url);
    }
    notifyListeners();
  }

  reset() {
    _title = null;
    _description = null;
    _editingPost = null;
    _imageURLs = [];
    _images = [];
    _selectedMunros = [];
  }
}

enum CreatePostStatus { initial, loading, loaded, error }
