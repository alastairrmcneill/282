import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroCompletionsDatabase {
  static final _db = Supabase.instance.client;
  static final SupabaseQueryBuilder _munroCompletionsRef = _db.from('munro_completions');

  static Future create(BuildContext context, {required List<MunroCompletion> munroCompletions}) async {
    try {
      await _munroCompletionsRef.insert(munroCompletions.map((e) => e.toJSON()).toList());
    } catch (error, stackTrace) {
      // Log the error and show a dialog
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error creating the munro completion.");
    }
  }

  static Future<List<MunroCompletion>> getUserMunroCompletions(BuildContext context, {required String userId}) async {
    List<MunroCompletion> munroCompletions = [];
    List<Map<String, dynamic>> response = [];
    try {
      response = await _munroCompletionsRef
          .select()
          .eq(MunroCompletionFields.userId, userId)
          .order(MunroCompletionFields.dateTimeCompleted, ascending: false);
      for (var doc in response) {
        munroCompletions.add(MunroCompletion.fromJSON(doc));
      }
      return munroCompletions;
    } catch (error, stackTrace) {
      // Log the error and show a dialog
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error loading your munro completions.");
      return munroCompletions;
    }
  }

  static Future<List<MunroCompletion>> getMunroCompletionsFromUserList(
    BuildContext context, {
    required List<String> userIds,
  }) async {
    List<MunroCompletion> munroCompletions = [];
    List<Map<String, dynamic>> response = [];
    try {
      response = await _munroCompletionsRef.select().inFilter(MunroCompletionFields.userId, userIds);

      for (var doc in response) {
        munroCompletions.add(MunroCompletion.fromJSON(doc));
      }
      return munroCompletions;
    } catch (error, stackTrace) {
      // Log the error and show a dialog
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error loading munro completions.");
      return munroCompletions;
    }
  }

  static Future delete(BuildContext context, {required String munroCompletionId}) async {
    try {
      await _munroCompletionsRef.delete().eq(MunroCompletionFields.id, munroCompletionId);
    } catch (error, stackTrace) {
      // Log the error and show a dialog
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error deleting the munro completion.");
    }
  }

  static Future<void> deleteByMunroIdsAndPostId(
    BuildContext context, {
    required List<int> munroIds,
    required String postId,
  }) async {
    try {
      await _munroCompletionsRef
          .delete()
          .eq(MunroCompletionFields.postId, postId)
          .inFilter(MunroCompletionFields.munroId, munroIds);
    } catch (error, stackTrace) {
      // Log the error and show a dialog
      Log.error(error.toString(), stackTrace: stackTrace);
      showErrorDialog(context, message: "There was an error deleting the munro completion.");
    }
  }
}
