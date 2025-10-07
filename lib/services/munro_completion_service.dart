import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroCompletionService {
  static Future getUserMunroCompletions(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    MunroCompletionState munroCompletionState = Provider.of<MunroCompletionState>(context, listen: false);

    try {
      if (userState.currentUser == null) return;

      List<MunroCompletion> munroCompletions =
          await MunroCompletionsDatabase.getUserMunroCompletions(context, userId: userState.currentUser!.uid ?? "");

      munroCompletionState.setMunroCompletions = munroCompletions;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      munroCompletionState.setError = Error(
        code: error.toString(),
        message: "There was an issue loading your munro completions",
      );
      showErrorDialog(context, message: "There was an issue loading your munro completions");
    }
  }

  static Future<void> bulkUpdateMunros(
    BuildContext context,
  ) async {
    // State management
    UserState userState = Provider.of<UserState>(context, listen: false);
    BulkMunroUpdateState bulkMunroUpdateState = Provider.of<BulkMunroUpdateState>(context, listen: false);
    MunroCompletionState munroCompletionState = Provider.of<MunroCompletionState>(context, listen: false);

    if (userState.currentUser == null) return;
    // Update user data with new personal munro data
    MunroCompletionsDatabase.create(
      context,
      munroCompletions: bulkMunroUpdateState.bulkMunroUpdateList,
    );

    // Update state
    munroCompletionState.setMunroCompletions = [
      ...munroCompletionState.munroCompletions,
      ...bulkMunroUpdateState.bulkMunroUpdateList,
    ];
  }

  static Future markMunrosAsCompleted(
    BuildContext context, {
    required List<Munro> munros,
    required DateTime summitDateTime,
    String? postId,
  }) async {
    // State management
    UserState userState = Provider.of<UserState>(context, listen: false);
    MunroCompletionState munroCompletionState = Provider.of<MunroCompletionState>(context, listen: false);

    if (userState.currentUser == null) return;

    List<MunroCompletion> munroCompletions = munros
        .map((m) => MunroCompletion(
              userId: userState.currentUser!.uid!,
              munroId: m.id,
              postId: postId,
              dateTimeCompleted: summitDateTime,
            ))
        .toList();

    MunroCompletionsDatabase.create(
      context,
      munroCompletions: munroCompletions,
    );
    munroCompletionState.setMunroCompletions = [
      ...munroCompletionState.munroCompletions,
      ...munroCompletions,
    ];
  }

  static Future removeMunroCompletion(
    BuildContext context, {
    required MunroCompletion munroCompletion,
  }) async {
    // State management
    UserState userState = Provider.of<UserState>(context, listen: false);
    MunroCompletionState munroCompletionState = Provider.of<MunroCompletionState>(context, listen: false);

    if (userState.currentUser == null) return;

    try {
      await MunroCompletionsDatabase.delete(
        context,
        munroCompletionId: munroCompletion.id ?? "",
      );

      munroCompletionState.setMunroCompletions =
          munroCompletionState.munroCompletions.where((mc) => mc.id != munroCompletion.id).toList();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      munroCompletionState.setError = Error(
        code: error.toString(),
        message: "There was an issue removing your munro completion",
      );
      showErrorDialog(context, message: "There was an issue removing your munro completion");
    }
  }
}
