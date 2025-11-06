import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class FeedbackDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _feedbackRef = _db.from('app_feedbacks');

  static Future<void> create(BuildContext context, {required AppFeedback feedback}) async {
    try {
      await _feedbackRef.insert(feedback.toJSON());
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error sending your feedback.");
    }
  }
}
