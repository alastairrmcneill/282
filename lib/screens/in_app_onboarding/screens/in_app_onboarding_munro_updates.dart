import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/bulk_munro_updates/widgets/widgets.dart';
import 'package:two_eight_two/screens/explore/widgets/app_search_bar.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

class InAppOnboardingMunroUpdates extends StatelessWidget {
  final FocusNode searchFocusNode = FocusNode();
  static const String route = '/in_app_onboarding/munro_updates';
  InAppOnboardingMunroUpdates({super.key});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Already summited a few munros?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'Log your progress before you get started! 👇',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 30),
          AppSearchBar(
            focusNode: searchFocusNode,
            hintText: "Search Munros",
            onSearchTap: () {},
            onChanged: (value) {
              munroState.setFilterString = value;
            },
            onClear: () {
              munroState.setFilterString = ''; // Chanhge to friends
            },
          ),
          const SizedBox(height: 30),
          Expanded(
            flex: 1,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(25),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: MyColors.accentColor, width: 0.5),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(25),
                  ),
                ),
                child: ListView.separated(
                  itemCount: munroState.filteredMunroList.length,
                  itemBuilder: (context, index) {
                    Munro munro = munroState.filteredMunroList[index];
                    return BulkMunroUpdateListTile(munro: munro);
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(
                      color: Colors.grey,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
