import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class LikesState extends ChangeNotifier {
  final LikesRepository _repository;
  final UserState _userState;
  LikesState(this._repository, this._userState);

  LikesStatus _status = LikesStatus.initial;
  Error _error = Error();
  String? _postId;
  List<Like> _likes = [];

  LikesStatus get status => _status;
  Error get error => _error;
  String get postId => _postId!;
  List<Like> get likes => _likes;

  Future<void> getPostLikes({required String postId}) async {
    _postId = postId;
    try {
      _status = LikesStatus.loading;
      notifyListeners();
      List<String> excludedUserIds = _userState.blockedUsers;

      _likes = await _repository.readPostLikes(
        postId: _postId!,
        excludedUserIds: excludedUserIds,
      );

      _status = LikesStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an error loading likes.");
      notifyListeners();
    }
  }

  Future<void> paginatePostLikes() async {
    try {
      _status = LikesStatus.paginating;
      notifyListeners();
      List<String> excludedUserIds = _userState.blockedUsers;

      List<Like> newLikes = await _repository.readPostLikes(
        postId: _postId!,
        excludedUserIds: excludedUserIds,
        offset: _likes.length,
      );

      _likes.addAll(newLikes);
      _status = LikesStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an error loading more likes.");
      notifyListeners();
    }
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

  void reset() {
    _status = LikesStatus.initial;
    _error = Error();
    _postId = null;
    _likes = [];
    notifyListeners();
  }
}

enum LikesStatus { initial, loading, loaded, paginating, error }
