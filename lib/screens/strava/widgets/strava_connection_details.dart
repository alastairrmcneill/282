import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class StravaConnectionDetails extends StatelessWidget {
  final StravaConnection connection;
  const StravaConnectionDetails({super.key, required this.connection});

  @override
  Widget build(BuildContext context) {
    final format = DateFormat('d MMM yyyy');
    final lastScan = connection.lastHistoricalScanAt;
    final mutedStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textSubtitle);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Connected on ${format.format(connection.connectedAt.toLocal())}', style: mutedStyle),
        Text('Permission: ${connection.scope}', style: mutedStyle),
        Text(
          lastScan == null ? 'History never scanned' : 'History last scanned ${format.format(lastScan.toLocal())}',
          style: mutedStyle,
        ),
        ViewOnStravaLink(url: connection.stravaProfileUrl),
      ],
    );
  }
}
