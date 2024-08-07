import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/explore/screens/screens.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'screens/search_munro_screen.dart';

class ExploreTab extends StatefulWidget {
  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final PanelController panelController = PanelController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearchVisible = false;
  bool _isMunroListViewVisible = false;
  BorderRadius borderRadius = BorderRadius.vertical(top: Radius.circular(24));

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
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomNavBarHeight = layoutState.bottomNavBarHeight; // Default height of BottomNavigationBar
    final double headerHeight = 60;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          SlidingUpPanel(
            controller: panelController,
            color: MyColors.backgroundColor,
            minHeight: munroState.selectedMunroId == null ? 60 : 0,
            maxHeight: MediaQuery.of(context).size.height - bottomNavBarHeight - headerHeight - topPadding + 20,
            header: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 20,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.41,
                    vertical: 7.5,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
            borderRadius: borderRadius,
            collapsed: SlidingPanelCollapsed(
              panelController: panelController,
            ),
            panelBuilder: (sc) {
              return MunroListScreen(
                scrollController: sc,
                panelController: panelController,
              );
            },
            onPanelSlide: (position) => setState(() {
              if (position > 0.9) {
                borderRadius = BorderRadius.zero;
                _isMunroListViewVisible = true;
              } else {
                borderRadius = BorderRadius.vertical(top: Radius.circular(24));
                _isMunroListViewVisible = false;
              }
            }),
            body: Container(
              margin: EdgeInsets.only(
                bottom: bottomNavBarHeight + MediaQuery.of(context).padding.bottom + 30,
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
      duration: Duration(milliseconds: 500),
      child: Visibility(
        visible: _isSearchVisible,
        child: const SearchMunroScreen(),
      ),
    );
  }
}
