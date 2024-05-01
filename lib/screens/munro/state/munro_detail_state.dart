import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class MunroDetailState extends ChangeNotifier {
  MunroDetailStatus _galleryStatus = MunroDetailStatus.initial;
  List<MunroPicture> _munroPictures = [];
  Error _error = Error();

  MunroDetailStatus get galleryStatus => _galleryStatus;
  List<MunroPicture> get munroPictures => _munroPictures;
  Error get error => _error;

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
