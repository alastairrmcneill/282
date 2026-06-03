import 'package:flutter/cupertino.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/explore/widgets/explore_header_icon_button.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class ExploreHeaderGroupButton extends StatelessWidget {
  const ExploreHeaderGroupButton({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthState>().currentUserId;
    final groupFilterState = context.watch<GroupFilterState>();

    return ExploreHeaderIconButton(
      icon: PhosphorIconsRegular.usersThree,
      onPressed: () {
        if (userId == null) {
          Navigator.of(context).pushNamed(AuthHomeScreen.route);
        } else {
          Navigator.of(context).pushNamed(GroupFilterIntroScreen.route);
        }
      },
      showBadge: groupFilterState.selectedFriendsUids.isNotEmpty,
    );
  }
}
