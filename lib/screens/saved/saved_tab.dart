import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/services/services.dart';
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
    appRouteObserver.updateCurrentScreen(SavedTab.route);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Saved Lists'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showCreateSavedListDialog(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => SavedListService.readUserSavedLists(context),
        child: Consumer<SavedListState>(
          builder: (context, savedListState, child) {
            switch (savedListState.status) {
              case SavedListStatus.loading:
                return const Center(child: CircularProgressIndicator());
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
    if (savedListState.savedLists.isEmpty) return const CenterText(text: "You don't have any saved lists yet");

    return ListView(
      children: savedListState.savedLists.map((savedList) {
        return SavedListTile(savedList: savedList);
      }).toList(),
    );
  }
}
