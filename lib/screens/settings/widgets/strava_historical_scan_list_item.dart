import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/munro_matches_repository.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class StravaHistoricalScanListItem extends StatefulWidget {
  const StravaHistoricalScanListItem({super.key});

  @override
  State<StravaHistoricalScanListItem> createState() => _StravaHistoricalScanListItemState();
}

class _StravaHistoricalScanListItemState extends State<StravaHistoricalScanListItem> {
  late final Stream<List<MunroMatch>> _userMunroMatchesStream;

  initState() {
    super.initState();
    final userId = context.read<UserState>().currentUser!.uid!;
    _userMunroMatchesStream = context.read<MunroMatchesRepository>().subscribeToUserMunroMatches(userId: userId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MunroMatch>>(
      stream: _userMunroMatchesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text("Loading historical scans..."),
            leading: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return ListTile(
            title: Text("Error loading historical scans"),
            subtitle: Text(snapshot.error.toString()),
            leading: Icon(Icons.error, color: context.colors.accent),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const ListTile(
            title: Text("No historical scans found"),
            leading: Icon(Icons.info_outline),
          );
        } else {
          final matches = snapshot.data!;
          return ListTile(
            title: Text("${matches.length} matches found"),
            leading: Icon(Icons.history, color: context.colors.accent),
          );
        }
      },
    );
  }
}
