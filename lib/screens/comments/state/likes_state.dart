import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class LikesState extends ChangeNotifier {
  LikesStatus _status = LikesStatus.initial;
  Error _error = Error();
  String? _postId;
  List<Like> _likes = [];

  LikesStatus get status => _status;
  Error get error => _error;
  String get postId => _postId!;
  List<Like> get likes => _likes;

  set setStatus(LikesStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = LikesStatus.error;
    _error = error;
    notifyListeners();
  }

  set setPostId(String postId) {
    _postId = postId;
    notifyListeners();
  }

  set setLikes(List<Like> likes) {
    _likes = likes;
    notifyListeners();
  }

  set addLikes(List<Like> likes) {
    _likes.addAll(likes);
    notifyListeners();
  }

  reset() {
    _status = LikesStatus.initial;
    _error = Error();
    _postId = null;
    _likes = [];
    notifyListeners();
  }
}

enum LikesStatus { initial, loading, loaded, paginating, error }
