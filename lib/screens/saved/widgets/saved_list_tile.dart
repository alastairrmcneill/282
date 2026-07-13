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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 12),
        child: Column(
          children: [
            SavedListHeader(savedList: savedList),
            const SizedBox(height: 10),
            savedList.munroIds.isEmpty
                ? SavedListEmptyMunroList()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: savedList.munroIds.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final munroId = savedList.munroIds[index];
                      final Munro munro = munroState.munroList.where((m) => m.id == munroId).first;
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
