import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/explore/screens/screens.dart';
import 'package:two_eight_two/screens/explore/widgets/explore_header_icon_button.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class ExploreHeaderFilterButton extends StatelessWidget {
  const ExploreHeaderFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();

    return ExploreHeaderIconButton(
      icon: PhosphorIconsRegular.funnel,
      onPressed: () => Navigator.of(context).pushNamed(FilterScreen.route),
      showBadge: munroState.isFilterOptionsSet,
    );
  }
}
