import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';

class SavedListTile extends StatelessWidget {
  final SavedList savedList;
  const SavedListTile({super.key, required this.savedList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 15),
            Expanded(
              flex: 1,
              child: Text(
                '${savedList.name} (${savedList.munroIds.length})',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            SavedListPopupMenu(savedList: savedList),
          ],
        ),
        ...savedList.munroIds.map((munroId) {
          return MunroSummaryTile(munroId: munroId);
        }),
      ],
    );
  }
}
