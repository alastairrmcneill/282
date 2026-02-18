import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class ReportState extends ChangeNotifier {
  final ReportRepository _repository;
  final UserState _userState;
  final Logger _logger;

  ReportState(
    this._repository,
    this._userState,
    this._logger,
  );

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

  Future<void> sendReport() async {
    try {
      setStatus = ReportStatus.loading;

      Report report = Report(
        contentId: _contentId,
        reporterId: _userState.currentUser?.uid ?? "",
        comment: _comment,
        type: _type,
      );

      // Upload report
      await _repository.create(report: report);

      // Update state
      setStatus = ReportStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue reporting the content. Please try again");
    }
  }

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
