import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

typedef PageLoader<T> = Future<List<T>> Function({
  required int offset,
  required int count,
  required List<String> excludedAuthorIds,
});

class PhotoGalleryState<T> extends ChangeNotifier {
  final UserState _userState;
  final Logger _logger;
  final PageLoader<T> _pageLoader;

  PhotoGalleryState(
    this._userState,
    this._logger,
    this._pageLoader,
  );

  PhotoGalleryStatus _status = PhotoGalleryStatus.initial;
  Error _error = Error();
  List<T> _photos = [];

  PhotoGalleryStatus get status => _status;
  Error get error => _error;
  List<T> get photos => _photos;

  Future<void> loadInitital() async {
    try {
      _status = PhotoGalleryStatus.loading;
      notifyListeners();
      final blockedUsers = _userState.blockedUsers;

      List<T> pictures = await _pageLoader(
        offset: 0,
        count: 20,
        excludedAuthorIds: blockedUsers,
      );

      _photos = pictures;

      _status = PhotoGalleryStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading pictures. Please try again.");
    }
  }

  Future<List<T>> paginate() async {
    try {
      _status = PhotoGalleryStatus.paginating;
      notifyListeners();
      final blockedUsers = _userState.blockedUsers;

      List<T> pictures = await _pageLoader(
        offset: _photos.length,
        count: 20,
        excludedAuthorIds: blockedUsers,
      );

      _photos.addAll(pictures);

      _status = PhotoGalleryStatus.loaded;
      notifyListeners();
      return pictures;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading pictures Please try again.");
      return [];
    }
  }

  set setStatus(PhotoGalleryStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = PhotoGalleryStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum PhotoGalleryStatus { initial, loading, paginating, loaded, error }
