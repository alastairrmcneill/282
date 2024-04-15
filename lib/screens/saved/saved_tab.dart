import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/saved_list_tile.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class SavedTab extends StatelessWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Saved Lists'),
        actions: [IconButton(icon: Icon(Icons.add), onPressed: () {})],
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
