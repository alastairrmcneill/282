import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ReportDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _reportsRef = _db.from('reports');

  static Future<void> create(BuildContext context, {required Report report}) async {
    try {
      await _reportsRef.insert(report.toJSON());
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an issue sending your report.");
    }
  }
}
