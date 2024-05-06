import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        FontAwesomeIcons.locationDot,
        size: 22,
      ),
      title: const Text("To Starting point"),
      trailing: const Icon(
        FontAwesomeIcons.chevronRight,
        size: 22,
      ),
      dense: false,
    );
  }
}
