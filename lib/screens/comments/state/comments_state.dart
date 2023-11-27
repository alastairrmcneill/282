import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class CommentsState extends ChangeNotifier {
  CommentsStatus _status = CommentsStatus.initial;
  Error _error = Error();
  String? _postId;
  Post? _post;
  String? _commentText;
  List<Comment> _comments = [];

  CommentsStatus get status => _status;
  Error get error => _error;
  String get postId => _postId!;
  Post get post => _post!;
  String? get commentText => _commentText;
  List<Comment> get comments => _comments;

  set setStatus(CommentsStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = CommentsStatus.error;
    _error = error;
    notifyListeners();
  }

  set setPostId(String postId) {
    _postId = postId;
    notifyListeners();
  }

  set setPost(Post? post) {
    _post = post;
    notifyListeners();
  }

  set setCommentText(String? commentText) {
    _commentText = commentText;
    notifyListeners();
  }

  set setComments(List<Comment> comments) {
    _comments = comments;
    notifyListeners();
  }

  set addComments(List<Comment> comments) {
    _comments.addAll(comments);
    notifyListeners();
  }

  removeComment(Comment comment) {
    if (_comments.contains(comment)) {
      _comments.remove(comment);
    }
    notifyListeners();
  }

  reset() {
    _postId = null;
    _commentText = null;
    _comments = [];
    notifyListeners();
  }
}

enum CommentsStatus { initial, loading, loaded, paginating, submitting, error }
