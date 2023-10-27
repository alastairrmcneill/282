import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';

class MunrosSummitedPage extends StatelessWidget {
  const MunrosSummitedPage({super.key});

  @override
  Widget build(BuildContext context) {
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Munros"),
          centerTitle: false,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Summited"),
              Tab(text: "Remaining"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView(
              children: munroNotifier.munroList
                  .where((munro) => munro.summited)
                  .map((munro) => ListTile(
                        title: Text(munro.name),
                      ))
                  .toList(),
            ),
            ListView(
              children: munroNotifier.munroList
                  .where((munro) => !munro.summited)
                  .map((munro) => ListTile(
                        title: Text(munro.name),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
