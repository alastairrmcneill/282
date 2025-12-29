import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class ProfileGalleryState extends ChangeNotifier {
  final MunroPicturesRepository _munroPicturesRepository;
  final UserState _userState;
  final Logger _logger;

  ProfileGalleryState(
    this._munroPicturesRepository,
    this._userState,
    this._logger,
  );

  ProfileGalleryStatus _status = ProfileGalleryStatus.initial;
  Error _error = Error();
  List<MunroPicture> _photos = [];

  ProfileGalleryStatus get status => _status;
  Error get error => _error;
  List<MunroPicture> get photos => _photos;

  Future<void> getMunroPictures({required String profileId, int count = 18}) async {
    try {
      _status = ProfileGalleryStatus.loading;
      notifyListeners();
      final blockedUsers = _userState.blockedUsers;
      List<MunroPicture> pictures = await _munroPicturesRepository.readProfilePictures(
        profileId: profileId,
        excludedAuthorIds: blockedUsers,
        offset: 0,
        count: count,
      );

      _photos = pictures;

      _status = ProfileGalleryStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading pictures for this profile. Please try again.");
    }
  }

  Future<List<MunroPicture>> paginateMunroPictures({required String profileId}) async {
    try {
      _status = ProfileGalleryStatus.paginating;
      notifyListeners();
      final blockedUsers = _userState.blockedUsers;
      List<MunroPicture> pictures = await _munroPicturesRepository.readProfilePictures(
        profileId: profileId,
        excludedAuthorIds: blockedUsers,
        offset: _photos.length,
      );

      _photos.addAll(pictures);

      _status = ProfileGalleryStatus.loaded;
      notifyListeners();
      return pictures;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading pictures for this profile. Please try again.");
      return [];
    }
  }

  set setStatus(ProfileGalleryStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = ProfileGalleryStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum ProfileGalleryStatus { initial, loading, paginating, loaded, error }
