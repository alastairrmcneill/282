import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectionsWidget extends StatelessWidget {
  const DirectionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    return ListTile(
      onTap: () async {
        await launchUrl(
          Uri.parse(munroState.selectedMunro?.startingPointURL ?? ""),
        );
      },
      leading: const Icon(
        CupertinoIcons.location_solid,
        size: 22,
      ),
      title: const Text("To Starting point"),
      trailing: const Icon(
        CupertinoIcons.forward,
        size: 22,
      ),
      dense: false,
    );
  }
}
