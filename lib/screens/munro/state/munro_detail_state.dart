import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunroDetailState extends ChangeNotifier {
  final MunroPicturesRepository _munroPicturesRepository;
  final UserState _userState;
  final Logger _logger;
  MunroDetailState(
    this._munroPicturesRepository,
    this._userState,
    this._logger,
  );

  MunroDetailStatus _galleryStatus = MunroDetailStatus.initial;
  List<MunroPicture> _munroPictures = [];
  Error _error = Error();

  MunroDetailStatus get galleryStatus => _galleryStatus;
  List<MunroPicture> get munroPictures => _munroPictures;
  Error get error => _error;

  Future<void> loadMunroPictures({required int munroId, int count = 18}) async {
    try {
      setGalleryStatus = MunroDetailStatus.loading;
      final blockedUsers = _userState.blockedUsers;

      List<MunroPicture> munroPictures = await _munroPicturesRepository.readMunroPictures(
        munroId: munroId,
        excludedAuthorIds: blockedUsers,
        offset: 0,
        count: count,
      );
      _munroPictures = munroPictures;
      _galleryStatus = MunroDetailStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading pictures for this munro. Please try again.");
    }
  }

  Future<List<MunroPicture>> paginateMunroPictures({required int munroId, int count = 18}) async {
    try {
      setGalleryStatus = MunroDetailStatus.paginating;
      final blockedUsers = _userState.blockedUsers;

      List<MunroPicture> newMunroPictures = await _munroPicturesRepository.readMunroPictures(
        munroId: munroId,
        excludedAuthorIds: blockedUsers,
        offset: _munroPictures.length,
        count: count,
      );

      _munroPictures.addAll(newMunroPictures);
      _galleryStatus = MunroDetailStatus.loaded;
      notifyListeners();
      return _munroPictures;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading pictures for this munro. Please try again.");
      return [];
    }
  }

  set setGalleryStatus(MunroDetailStatus galleryStatus) {
    _galleryStatus = galleryStatus;
    notifyListeners();
  }

  set setMunroPictures(List<MunroPicture> munroPictures) {
    _munroPictures = munroPictures;
    notifyListeners();
  }

  set addMunroPictures(List<MunroPicture> munroPictures) {
    _munroPictures.addAll(munroPictures);
    notifyListeners();
  }

  set setError(Error error) {
    _galleryStatus = MunroDetailStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum MunroDetailStatus { initial, loading, loaded, paginating, error }
