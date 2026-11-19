import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/strava/widgets/widgets.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class StravaDisconnectButton extends StatelessWidget {
  const StravaDisconnectButton({super.key});

  static Future<void> confirmAndDisconnect(BuildContext context) async {
    final stravaState = context.read<StravaState>();
    if (!await StravaDisconnectConfirmDialog.show(context)) return;

    final deletion = await stravaState.disconnectAndDeleteData();
    if (!context.mounted) return;
    if (deletion == null) {
      showSnackBar(context, stravaState.error.message);
      return;
    }
    await StravaDataDeletedDialog.show(context, deletion: deletion);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => confirmAndDisconnect(context),
      child: Text(
        'Disconnect and delete my Strava data',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: context.colors.warning,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
