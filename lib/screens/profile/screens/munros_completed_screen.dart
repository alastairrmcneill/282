import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunrosCompletedScreen extends StatelessWidget {
  const MunrosCompletedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ProfileState profileState = Provider.of<ProfileState>(context, listen: false);
    List completedMunros =
        profileState.user?.personalMunroData?.where((munro) => munro[MunroFields.summited]).toList() ?? [];
    List remainingMunros =
        profileState.user?.personalMunroData?.where((munro) => !munro[MunroFields.summited]).toList() ?? [];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Munros"),
          centerTitle: false,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Completed"),
              Tab(text: "Remaining"),
            ],
          ),
        ),
        body: TabBarView(
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
