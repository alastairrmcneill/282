import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroDirectionsWidget extends StatelessWidget {
  const MunroDirectionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    return ListTile(
      visualDensity: VisualDensity.compact,
      onTap: () async {
        await launchUrl(
          Uri.parse(munroState.selectedMunro?.startingPointURL ?? ""),
        );
      },
      leading: const Icon(
        CupertinoIcons.map,
        color: MyColors.accentColor,
      ),
      title: Text(
        "To Starting point",
        style: Theme.of(context).textTheme.titleLarge,
      ),
      trailing: const Icon(
        CupertinoIcons.forward,
        color: MyColors.accentColor,
      ),
      dense: true,
    );
  }
}
