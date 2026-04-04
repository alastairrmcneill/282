import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroDirectionsWidget extends StatelessWidget {
  const MunroDirectionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final munroDetailState = context.read<MunroDetailState>();
    return ListTile(
      visualDensity: VisualDensity.compact,
      onTap: () async {
        await launchUrl(
          Uri.parse(munroDetailState.selectedMunro?.startingPointURL ?? ""),
        );
      },
      leading: Icon(
        CupertinoIcons.map,
        color: context.colors.accent,
      ),
      title: Text(
        "Get Directions",
        style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w400, fontSize: 18),
      ),
      trailing: Icon(
        CupertinoIcons.forward,
        color: context.colors.textPrimary,
      ),
      dense: true,
    );
  }
}
