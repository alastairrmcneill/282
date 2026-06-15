import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class ExploreTabHeader extends StatelessWidget {
  final double headerHeight;
  final FocusNode searchFocusNode;
  final VoidCallback onSearchTap;
  final bool isMunroListViewVisible;

  const ExploreTabHeader({
    super.key,
    required this.headerHeight,
    required this.searchFocusNode,
    required this.onSearchTap,
    required this.isMunroListViewVisible,
  });

  @override
  Widget build(BuildContext context) {
    final munroState = context.watch<MunroState>();
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: isMunroListViewVisible ? context.colors.background : Colors.transparent,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Container(
          color: isMunroListViewVisible ? context.colors.background : Colors.transparent,
          height: headerHeight,
          child: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: AppSearchBar(
                        variant: SearchBarVariant.hero,
                        focusNode: searchFocusNode,
                        hintText: "Search Munros",
                        onSearchTap: onSearchTap,
                        onChanged: (value) {
                          munroState.setFilterString = value;
                        },
                        onClear: () {
                          munroState.setFilterString = '';
                        },
                      ),
                    ),
                    const ExploreHeaderGroupButton(),
                    const ExploreHeaderFilterButton(),
                  ],
                ),
                const GlobalCompletionCountWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
