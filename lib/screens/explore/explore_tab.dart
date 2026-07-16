import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/explore/screens/screens.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/app_route_observer.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ExploreTab extends StatefulWidget {
  const ExploreTab({super.key});
  static const String route = '/explore';

  @override
  _ExploreTabState createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  final PanelController panelController = PanelController();
  final FocusNode _searchFocusNode = FocusNode();

  bool _isMunroListViewVisible = false;
  bool _hasLoggedPanelOpen = false;

  BorderRadius borderRadius = const BorderRadius.vertical(top: Radius.circular(24));

  @override
  void initState() {
    context.read<AppRouteObserver>().updateCurrentScreen(ExploreTab.route);
    super.initState();
  }

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
    final munroState = context.watch<MunroState>();
    final layoutState = context.watch<LayoutState>();

    final double screenHeight = MediaQuery.of(context).size.height;
    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double bottomNavBarHeight = layoutState.bottomNavBarHeight;
    final double headerHeight = _isMunroListViewVisible ? 64 : 100;

    return Scaffold(
      body: Stack(
        children: [
          SlidingUpPanel(
            controller: panelController,
            color: context.colors.background,
            minHeight: munroState.selectedMunroId == null ? 60 : 0,
            maxHeight: screenHeight - bottomNavBarHeight - headerHeight - topPadding,
            header: const SlidingPanelHeader(),
            borderRadius: borderRadius,
            collapsed: SlidingPanelCollapsed(panelController: panelController),
            onPanelSlide: (position) => setState(() {
              if (position > 0.95 && !_hasLoggedPanelOpen) {
                _hasLoggedPanelOpen = true;
                _isMunroListViewVisible = true;
                borderRadius = BorderRadius.zero;

                context.read<AppRouteObserver>().updateCurrentScreen(MunroListScreen.route);
              } else if (position < 0.8) {
                _hasLoggedPanelOpen = false;
                _isMunroListViewVisible = false;
                borderRadius = const BorderRadius.vertical(top: Radius.circular(24));
                _searchFocusNode.unfocus();
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
              child: MapboxMapScreen(searchFocusNode: _searchFocusNode),
            ),
          ),
          Positioned(
            top: topPadding + headerHeight,
            left: 0,
            right: 0,
            child: const Center(child: GroupFilterActiveChip()),
          ),
          ExploreTabHeader(
            headerHeight: headerHeight,
            searchFocusNode: _searchFocusNode,
            isMunroListViewVisible: _isMunroListViewVisible,
            onSearchTap: () {
              panelController.open();
              _searchFocusNode.requestFocus();
            },
          ),
        ],
      ),
    );
  }
}
