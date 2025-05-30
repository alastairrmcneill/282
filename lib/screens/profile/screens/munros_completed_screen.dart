import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/app_route_observer.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunrosCompletedScreen extends StatefulWidget {
  static const String route = '/profile/munros_completed';
  const MunrosCompletedScreen({super.key});

  @override
  State<MunrosCompletedScreen> createState() => _MunrosCompletedScreenState();
}

class _MunrosCompletedScreenState extends State<MunrosCompletedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logTabAnalytics(_tabController.index);
    });

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      _logTabAnalytics(_tabController.index);
    });
  }

  void _logTabAnalytics(int index) {
    final screenName =
        index == 0 ? '${MunrosCompletedScreen.route}/completed' : '${MunrosCompletedScreen.route}/remaining';
    appRouteObserver.updateCurrentScreen(screenName);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);

    final completedMunros =
        profileState.user?.personalMunroData?.where((munro) => munro[MunroFields.summited]).toList() ?? [];

    final remainingMunros =
        profileState.user?.personalMunroData?.where((munro) => !munro[MunroFields.summited]).toList() ?? [];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Munros"),
          centerTitle: false,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Completed"),
              Tab(text: "Remaining"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            completedMunros.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(15),
                    child: CenterText(text: "No Munros completed."),
                  )
                : ListView(
                    children: completedMunros.map((munro) => MunroSummaryTile(munroId: munro[MunroFields.id])).toList(),
                  ),
            remainingMunros.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(15),
                    child: CenterText(text: "You have completed all Munros!"),
                  )
                : ListView(
                    children: remainingMunros.map((munro) => MunroSummaryTile(munroId: munro[MunroFields.id])).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
