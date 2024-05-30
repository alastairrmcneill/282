import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class ReportService {
  static Future<void> sendReport(BuildContext context) async {
    ReportState reportState = Provider.of<ReportState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    try {
      reportState.setStatus = ReportStatus.loading;

      Report report = Report(
        contentId: reportState.contentId,
        reporterId: userState.currentUser?.uid ?? "",
        dateTime: DateTime.now().toUtc(),
        comment: reportState.comment,
        type: reportState.type,
        completed: false,
      );

      // Upload report
      await ReportDatabase.create(context, report: report);

      // Update state
      reportState.setStatus = ReportStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      print("Error: $error");
      reportState.setError = Error(message: "There was an issue reporting the content. Please try again");
    }
  }
}
