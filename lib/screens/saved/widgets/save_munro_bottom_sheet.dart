import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';

class SaveMunroBottomSheet extends StatelessWidget {
  const SaveMunroBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const SaveMunroBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    final savedListState = context.watch<SavedListState>();
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const SavedMunroBottomSheetHeader(),
              const Divider(thickness: 0.7),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: SizedBox(width: double.infinity, child: const CreateNewSavedListWidget(basic: true)),
              ),
              const SizedBox(height: 10),

              ...savedListState.savedLists.map(
                (e) => SaveMunroBottomSheetTile(
                  savedListState: savedListState,
                  munroState: munroState,
                  savedList: e,
                ),
              ),

              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }
}
