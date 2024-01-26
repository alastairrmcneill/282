import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class MunroDetailState extends ChangeNotifier {
  MunroDetailStatus _galleryStatus = MunroDetailStatus.initial;
  List<Post> _galleryPost = [];
  Error _error = Error();

  MunroDetailStatus get galleryStatus => _galleryStatus;
  List<Post> get galleryPosts => _galleryPost;
  Error get error => _error;

  set setGalleryStatus(MunroDetailStatus galleryStatus) {
    _galleryStatus = galleryStatus;
    notifyListeners();
  }

  set setGalleryPosts(List<Post> posts) {
    _galleryPost = posts;
    notifyListeners();
  }

  set addGalleryPosts(List<Post> posts) {
    _galleryPost.addAll(posts);
    notifyListeners();
  }

  set setError(Error error) {
    _galleryStatus = MunroDetailStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum MunroDetailStatus { initial, loading, loaded, paginating, error }
