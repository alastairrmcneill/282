import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroDirectionsWidget extends StatelessWidget {
  const MunroDirectionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
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
        "Get Directions",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w400, fontSize: 18),
      ),
      trailing: const Icon(
        CupertinoIcons.forward,
        color: MyColors.textColor,
      ),
      dense: true,
    );
  }
}
