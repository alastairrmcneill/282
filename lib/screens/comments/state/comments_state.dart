import 'package:flutter/material.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class CommentsState extends ChangeNotifier {
  final CommentsRepository _commentsRepository;
  final UserState userState;
  final PostsRepository _postsRepository;
  final Analytics _analytics;
  final Logger _logger;

  CommentsState(
    this._commentsRepository,
    this.userState,
    this._postsRepository,
    this._analytics,
    this._logger,
  );

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

  Future<void> createComment() async {
    _status = CommentsStatus.submitting;
    notifyListeners();
    try {
      Comment comment = Comment(
        postId: _postId!,
        authorId: userState.currentUser?.uid ?? "",
        authorDisplayName: userState.currentUser?.displayName ?? "",
        authorProfilePictureURL: userState.currentUser?.profilePictureURL,
        dateTime: DateTime.now().toUtc(),
        commentText: _commentText!,
      );
      await _commentsRepository.create(comment: comment);
      _comments.add(comment);
      _commentText = null;
      _status = CommentsStatus.loaded;
      notifyListeners();

      _analytics.track(
        AnalyticsEvent.createComment,
        props: {
          AnalyticsProp.postId: _postId!,
        },
      );
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue posting your comment. Please try again");
    }
  }

  Future<void> getPostComments() async {
    if (userState.currentUser == null) return;
    List<String> blockedUsers = userState.blockedUsers;

    try {
      _status = CommentsStatus.loading;
      notifyListeners();
      _comments = await _commentsRepository.readPostComments(
        postId: _postId!,
        excludedAuthorIds: blockedUsers,
        offset: 0,
      );

      // Read post details //TODO: remove this at some point
      _post = await _postsRepository.readPostFromUid(uid: _postId!);

      _status = CommentsStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue retreiving the comments. Please try again.",
      );
    }
  }

  Future<void> paginatePostComments() async {
    if (userState.currentUser == null) return;

    try {
      _status = CommentsStatus.paginating;
      notifyListeners();
      List<String> blockedUsers = userState.blockedUsers;
      List<Comment> comments = await _commentsRepository.readPostComments(
        postId: _postId!,
        excludedAuthorIds: blockedUsers,
        offset: _comments.length,
      );
      _comments.addAll(comments);
      _status = CommentsStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue retreiving the comments. Please try again.",
      );
    }
  }

  Future<void> deleteComment({required Comment comment}) async {
    try {
      if (_comments.contains(comment)) {
        _comments.remove(comment);
        notifyListeners();
      }
      await _commentsRepository.deleteComment(comment: comment);

      _analytics.track(
        AnalyticsEvent.deleteComment,
        props: {
          AnalyticsProp.postId: _postId!,
        },
      );
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue deleting the comment. Please try again.");
    }
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

  void removeComment(Comment comment) {
    if (_comments.contains(comment)) {
      _comments.remove(comment);
    }
    notifyListeners();
  }

  void reset() {
    _status = CommentsStatus.initial;
    _error = Error();
    _postId = null;
    _post = null;
    _commentText = null;
    _comments = [];
    notifyListeners();
  }
}

enum CommentsStatus { initial, loading, loaded, paginating, submitting, error }
