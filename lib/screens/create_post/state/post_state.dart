import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class PostState extends ChangeNotifier {
  PostStatus _status = PostStatus.initial;
  Error _error = Error();

  PostStatus get status => _status;
  Error get error => _error;

  set setStatus(PostStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = PostStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum PostStatus { initial, submitting, success, error }
