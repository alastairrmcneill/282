import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class SaveMunroBottomSheetTile extends StatelessWidget {
  final SavedListState savedListState;
  final MunroState munroState;
  final SavedList savedList;
  const SaveMunroBottomSheetTile({
    super.key,
    required this.savedListState,
    required this.munroState,
    required this.savedList,
  });

  @override
  Widget build(BuildContext context) {
    final isSaved = savedList.munroIds.contains(munroState.selectedMunroId);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Card(
        color: isSaved ? Colors.green.withOpacity(0.1) : null,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: isSaved ? Colors.green : MyColors.mutedText.withOpacity(0.5),
            width: isSaved ? 1 : 0.5,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () async {
            if (isSaved) {
              await savedListState.removeMunroFromSavedList(
                savedList: savedList,
                munroId: munroState.selectedMunroId ?? 0,
              );
            } else {
              await savedListState.addMunroToSavedList(
                savedList: savedList,
                munroId: munroState.selectedMunroId ?? 0,
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
            child: Row(
              children: [
                Icon(
                  PhosphorIconsRegular.listDashes,
                  color: MyColors.mutedText,
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        savedList.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${savedList.munroIds.length} munro${savedList.munroIds.length == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (isSaved)
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Icon(
                      PhosphorIconsRegular.check,
                      color: Colors.green,
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
