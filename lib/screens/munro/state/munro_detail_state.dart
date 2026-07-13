import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class MunroDetailState extends ChangeNotifier {
  final MunroPicturesRepository _munroPicturesRepository;
  final ReviewsRepository _reviewsRepository;
  final UserState _userState;
  final Logger _logger;

  MunroDetailState(
    this._munroPicturesRepository,
    this._reviewsRepository,
    this._userState,
    this._logger,
  );

  MunroDetailStatus _status = MunroDetailStatus.initial;
  Munro? _selectedMunro;
  List<MunroPicture> _munroPictures = [];
  List<Review> _reviews = [];
  Error _error = Error();

  MunroDetailStatus get status => _status;
  Munro? get selectedMunro => _selectedMunro;
  List<MunroPicture> get munroPictures => _munroPictures;
  List<Review> get reviews => _reviews;
  Error get error => _error;

  Future<void> init(Munro munro) async {
    _selectedMunro = munro;

    try {
      _status = MunroDetailStatus.loading;
      notifyListeners();

      final blockedUsers = _userState.blockedUsers;

      Future.wait([
        _munroPicturesRepository.readMunroPictures(
          munroId: munro.id,
          excludedAuthorIds: blockedUsers,
          offset: 0,
          count: 4,
        ),
        _reviewsRepository.readReviewsFromMunro(
          munroId: munro.id,
          excludedAuthorIds: blockedUsers,
          offset: 0,
        ),
      ]).then((results) {
        _munroPictures = results[0] as List<MunroPicture>;
        _reviews = results[1] as List<Review>;
        _status = MunroDetailStatus.loaded;
        notifyListeners();
      }).catchError((error, stackTrace) {
        _logger.error(error.toString(), stackTrace: stackTrace);
        _error = Error(message: "There was an issue loading data for this munro. Please try again.");
        _status = MunroDetailStatus.error;
        notifyListeners();
      });
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      _error = Error(message: "There was an issue loading data for this munro. Please try again.");
      notifyListeners();
    }
  }
}

enum MunroDetailStatus { initial, loading, loaded, paginating, error }
