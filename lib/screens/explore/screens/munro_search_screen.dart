import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/explore_tab.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/support/theme.dart';

class MunroSearchScreen extends StatelessWidget {
  const MunroSearchScreen({super.key});
  static const String route = '${ExploreTab.route}/munro_search';

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      color: MyColors.backgroundColor,
      child: ListView.builder(
        itemCount: munroState.filteredMunroList.length,
        itemBuilder: (context, index) {
          Munro munro = munroState.filteredMunroList[index];
          return MunroSearchListTile(munro: munro);
        },
      ),
    );
  }
}
