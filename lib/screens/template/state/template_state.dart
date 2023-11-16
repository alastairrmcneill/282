import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class TemplateState extends ChangeNotifier {
  TemplateStatus _status = TemplateStatus.initial;
  Error _error = Error();

  TemplateStatus get status => _status;
  Error get error => _error;

  set setStatus(TemplateStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = TemplateStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum TemplateStatus { initial, loading, loaded, error }
