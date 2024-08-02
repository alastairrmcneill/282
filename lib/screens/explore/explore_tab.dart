import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/screens/screens.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ExploreTab extends StatelessWidget {
  ExploreTab({super.key});

  final PanelController panelController = PanelController();

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
            // return MapScreen();
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
    final double bottomNavBarHeight = layoutState.bottomNavBarHeight; // Default height of BottomNavigationBar
    final double headerHeight = 60; // Fixed height of the header

    final double availableHeight = screenHeight - topPadding - bottomNavBarHeight - headerHeight - bottomPadding;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          SlidingUpPanel(
            controller: panelController,
            minHeight: munroState.selectedMunroId == null ? 60 : 0,
            maxHeight: availableHeight + 30,
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            collapsed: SlidingPanelCollapsed(
              panelController: panelController,
            ),
            panelBuilder: (sc) {
              return MunroListScreen(
                scrollController: sc,
                panelController: panelController,
              );
            },
            body: Container(
              margin: EdgeInsets.only(
                bottom: bottomNavBarHeight + MediaQuery.of(context).padding.bottom + 30,
                top: topPadding + headerHeight,
              ),
              child: const MapScreen(),
            ),
          ),
          ExploreTabHeader(
            headerHeight: headerHeight,
          ),
        ],
      ),
    );
  }
}
