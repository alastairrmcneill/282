import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

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
            child: isMunroListViewVisible
                ? Row(
                    children: [
                      Expanded(
                        child: AppSearchBar(
                          variant: SearchBarVariant.hero,
                          focusNode: searchFocusNode,
                          hintText: "Search Munros",
                          initialValue: munroState.filterString,
                          onSearchTap: onSearchTap,
                          onChanged: (value) {
                            munroState.setFilterString = value;
                          },
                          onClear: () {
                            context.read<Analytics>().track(AnalyticsEvent.exploreSearchClearTapped);
                            munroState.setFilterString = '';
                          },
                          trailing: const ExploreHeaderFilterButton(),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const GlobalCompletionCountWidget(),
                      const SizedBox(height: 8),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SliverAppBarButton(
                            icon: Icon(PhosphorIconsRegular.magnifyingGlass),
                            analyticsEvent: AnalyticsEvent.exploreSearchButtonTapped,
                            onPressed: onSearchTap,
                          ),
                          if (munroState.isFilterOptionsSet || munroState.isSearchActive)
                            Positioned(
                              right: 2,
                              top: -2,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: context.colors.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.light.surface, width: 1.5),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
