import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/saved_list_header.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';

class SavedListTile extends StatelessWidget {
  final SavedList savedList;
  const SavedListTile({super.key, required this.savedList});

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    // A saved munroId may not (yet) exist in munroState.munroList, e.g. while
    // the munro list is still loading. Skip those rather than crashing.
    final munroIds = savedList.munroIds.where((id) => munroState.munroList.any((m) => m.id == id)).toList();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 12),
        child: Column(
          children: [
            SavedListHeader(savedList: savedList),
            const SizedBox(height: 10),
            munroIds.isEmpty
                ? SavedListEmptyMunroList()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: munroIds.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final munroId = munroIds[index];
                      final Munro munro = munroState.munroList.firstWhere((m) => m.id == munroId);
                      return SavedListMunroTile(
                        munro: munro,
                        onDelete: () async {
                          await context
                              .read<SavedListState>()
                              .removeMunroFromSavedList(savedList: savedList, munroId: munroId);
                        },
                      );
                    },
                  )
          ],
        ),
      ),
    );
  }
}
