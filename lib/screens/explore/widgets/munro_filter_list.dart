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
    MunroState munroState = Provider.of<MunroState>(context);
    return ListView(
      children: munroState.filteredMunroList
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
