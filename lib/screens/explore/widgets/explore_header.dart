import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/support/theme.dart';

class ExploreTabHeader extends StatelessWidget {
  final double headerHeight;
  final FocusNode searchFocusNode;
  final VoidCallback onSearchTap;
  final bool isSearchVisible;
  final bool isMunroListViewVisible;
  final void Function() onBackTap;

  const ExploreTabHeader({
    super.key,
    required this.headerHeight,
    required this.searchFocusNode,
    required this.onSearchTap,
    required this.isSearchVisible,
    required this.isMunroListViewVisible,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: isMunroListViewVisible || isSearchVisible ? MyColors.backgroundColor : Colors.transparent,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Container(
          color: isMunroListViewVisible || isSearchVisible ? MyColors.backgroundColor : Colors.transparent,
          height: headerHeight,
          child: Padding(
            padding: EdgeInsets.only(
              left: isSearchVisible ? 0 : 30,
              right: 30,
            ),
            child: Row(
              children: [
                isSearchVisible
                    ? IconButton(
                        icon: const Icon(
                          CupertinoIcons.arrow_left,
                          color: MyColors.accentColor,
                        ),
                        onPressed: onBackTap,
                      )
                    : const SizedBox(),
                Expanded(
                  flex: 1,
                  child: MunroSearchBar(
                    focusNode: searchFocusNode,
                    onSelected: (item) {},
                    onTap: onSearchTap,
                  ),
                ),
                const ExploreHeaderFilterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
