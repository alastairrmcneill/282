import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/support/app_route_observer.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class SavedTab extends StatefulWidget {
  const SavedTab({super.key});
  static const String route = '/saved_tab';

  @override
  State<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> {
  @override
  void initState() {
    context.read<AppRouteObserver>().updateCurrentScreen(SavedTab.route);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Munros'),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<SavedListState>().readUserSavedLists(),
        child: Consumer<SavedListState>(
          builder: (context, savedListState, child) {
            switch (savedListState.status) {
              case SavedListStatus.loading:
                return const LoadingWidget(text: "Loading saved lists...");
              case SavedListStatus.error:
                return CenterText(text: savedListState.error.message);
              default:
                return _buildScreen(context, savedListState: savedListState);
            }
          },
        ),
      ),
    );
  }

  Widget _buildScreen(BuildContext context, {required SavedListState savedListState}) {
    if (savedListState.savedLists.isEmpty) return const EmptySavedListScreen();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: ListView.separated(
        itemCount: savedListState.savedLists.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: OutlinedButton(
                onPressed: () {
                  showCreateSavedListDialog(context);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(PhosphorIconsBold.plus),
                    const SizedBox(width: 8),
                    Text('Create new list'),
                  ],
                ),
              ),
            );
          }

          final savedList = savedListState.savedLists[index - 1];
          return SavedListTile(savedList: savedList);
        },
      ),
    );
  }
}
