import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';

class MunroFilterList extends StatelessWidget {
  final Function(Munro munro) onSelected;
  const MunroFilterList({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context);
    return ListView(
      children: munroNotifier.filteredMunroList
          .map(
            (munro) => MunroFilterListTile(
              munro: munro,
              onSelected: (munro) {
                onSelected(munro);
              },
            ),
          )
          .toList(),
    );
  }
}
