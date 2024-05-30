import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class ReportState extends ChangeNotifier {
  ReportStatus _status = ReportStatus.initial;
  Error _error = Error();
  String _contentId = "";
  String _type = "";
  String _comment = "";

  ReportStatus get status => _status;
  Error get error => _error;
  String get contentId => _contentId;
  String get type => _type;
  String get comment => _comment;

  set setContentId(String contentId) {
    _contentId = contentId;
    notifyListeners();
  }

  set setComment(String comment) {
    _comment = comment;
    notifyListeners();
  }

  set setType(String type) {
    _type = type;
    notifyListeners();
  }

  set setStatus(ReportStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = ReportStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum ReportStatus { initial, loading, loaded, error }
