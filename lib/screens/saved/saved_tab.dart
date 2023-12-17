import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/munro.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class SavedTab extends StatelessWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);
    return Scaffold(
      body: munroState.munroList.where((element) => element.saved).isEmpty
          ? const Padding(
              padding: EdgeInsets.all(15),
              child: CenterText(text: "You haven't saved any munros yet."),
            )
          : ListView(
              children: munroState.munroList
                  .where((element) => element.saved)
                  .map(
                    (Munro munro) => ListTile(
                      title: Text(munro.name),
                      subtitle: Text(
                          "${munro.extra == null || munro.extra!.isEmpty ? '' : '${munro.extra} - '}${munro.area}"),
                      onTap: () {
                        munroState.setSelectedMunro = munro;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MunroScreen(),
                          ),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
