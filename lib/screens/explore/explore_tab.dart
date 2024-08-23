import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/explore/screens/screens.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'screens/munro_search_screen.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final PanelController panelController = PanelController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchVisible = false;
  bool _isMunroListViewVisible = false;
  BorderRadius borderRadius = const BorderRadius.vertical(top: Radius.circular(24));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MunroState>(
        builder: (context, munroState, child) {
          switch (munroState.status) {
            case MunroStatus.loading:
              return const LoadingWidget();
            case MunroStatus.error:
              print('munroState.error.message: ${munroState.error.code}');
              return CenterText(text: munroState.error.message);
            case MunroStatus.loaded:
              return _buildScreen(context);
            default:
              return const LoadingWidget();
          }
        },
      ),
    );
  }

  Widget _buildScreen(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    LayoutState layoutState = Provider.of<LayoutState>(context);

    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double bottomNavBarHeight = layoutState.bottomNavBarHeight;
    const double headerHeight = 60;

    return Scaffold(
      body: Stack(
        children: [
          SlidingUpPanel(
            controller: panelController,
            color: MyColors.backgroundColor,
            minHeight: munroState.selectedMunroId == null ? 60 : 0,
            maxHeight: screenHeight - bottomNavBarHeight - headerHeight - topPadding + 20,
            header: const SlidingPanelHeader(),
            borderRadius: borderRadius,
            collapsed: SlidingPanelCollapsed(
              panelController: panelController,
            ),
            onPanelSlide: (position) => setState(() {
              if (position > 0.9) {
                borderRadius = BorderRadius.zero;
                _isMunroListViewVisible = true;
              } else {
                borderRadius = const BorderRadius.vertical(top: Radius.circular(24));
                _isMunroListViewVisible = false;
              }
            }),
            panelBuilder: (sc) {
              return MunroListScreen(
                scrollController: sc,
                panelController: panelController,
              );
            },
            body: Container(
              margin: EdgeInsets.only(
                bottom: bottomNavBarHeight + bottomPadding,
              ),
              child: MapScreen(
                searchFocusNode: _searchFocusNode,
              ),
            ),
          ),
          _buildSearchOverlay(),
          ExploreTabHeader(
            headerHeight: headerHeight,
            searchFocusNode: _searchFocusNode,
            isSearchVisible: _isSearchVisible,
            isMunroListViewVisible: _isMunroListViewVisible,
            onBackTap: () {
              setState(() {
                _isSearchVisible = false;
                _searchFocusNode.unfocus();
              });
            },
            onSearchTap: () {
              setState(() {
                _isSearchVisible = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay() {
    return AnimatedOpacity(
      opacity: _isSearchVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: Visibility(
        visible: _isSearchVisible,
        child: const MunroSearchScreen(),
      ),
    );
  }
}
