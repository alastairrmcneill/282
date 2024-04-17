import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class ExpandedSavedListTile extends StatelessWidget {
  final SavedList savedList;
  final Function() onTap;
  const ExpandedSavedListTile({super.key, required this.savedList, required this.onTap});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    return Column(
      children: [
        ListTile(
          title: Text(
            "${savedList.name} (${savedList.munroIds.length})",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: const Icon(Icons.keyboard_arrow_down_rounded),
          trailing: SavedListPopupMenu(savedList: savedList),
          onTap: onTap,
        ),
        ...savedList.munroIds.map((munroId) {
          print("Munro ID: $munroId");
          Munro munro = munroState.munroList.where((munro) => munro.id == munroId).first;
          return ListTile(
            title: Text(munro.name),
            subtitle: munro.extra != null ? Text(munro.extra!) : null,
            onTap: () {
              munroState.setSelectedMunro = munro;
              ReviewService.getMunroReviews(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MunroScreen(),
                ),
              );
            },
          );
        }),
        const Divider(),
      ],
    );
  }
}
