import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

Future<void> navigateToLogClimb({
  required BuildContext context,
  required Munro munro,
}) async {
  final appFlags = context.read<AppFlagsRepository>();

  if (!appFlags.showBulkMunroDialog) {
    await appFlags.setShowBulkMunroDialog(false);

    if (!context.mounted) return;

    final wantsBulk = await showDialog<bool>(
      context: context,
      builder: (ctx) => const BulkMunroUpdateDialog(),
    );

    if (!context.mounted) return;

    if (wantsBulk == true) {
      Navigator.of(context).pushNamed(BulkMunroUpdateScreen.route);
      return;
    }
  }

  final createPostState = context.read<CreatePostState>();
  final settingsState = context.read<SettingsState>();
  createPostState.reset();
  createPostState.addMunro(munro.id);
  createPostState.setPostPrivacy = settingsState.defaultPostVisibility;
  Navigator.of(context).pushNamed(
    SelectMunrosScreen.route,
    arguments: SelectMunrosScreenArgs(mainMunro: munro),
  );
}
