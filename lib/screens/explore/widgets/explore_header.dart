import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/explore/screens/screens.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
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
    MunroState munroState = Provider.of<MunroState>(context);
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: isMunroListViewVisible || isSearchVisible ? MyColors.backgroundColor : Colors.transparent,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Container(
          color: isMunroListViewVisible || isSearchVisible ? MyColors.backgroundColor : Colors.transparent,
          height: headerHeight, // Fixed height of the header
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
                    onTap: onSearchTap, // Trigger the callback on tap
                  ),
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Background color
                      shape: const CircleBorder(), // Circular shape
                      elevation: 0, // Drop shadow
                      padding: const EdgeInsets.all(13),
                      side: const BorderSide(
                        color: MyColors.accentColor, // Border color
                        width: 0.5, // Border width
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FilterScreen(),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        const Icon(
                          CupertinoIcons.slider_horizontal_3,
                          color: MyColors.accentColor,
                          size: 20,
                        ),
                        munroState.isFilterOptionsSet
                            ? Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
