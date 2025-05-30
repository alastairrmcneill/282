import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/explore/widgets/app_search_bar.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class InAppOnboardingFindFriends extends StatelessWidget {
  final FocusNode searchFocusNode = FocusNode();
  static const String route = '/in_app_onboarding/find_friends';
  InAppOnboardingFindFriends({super.key});

  @override
  Widget build(BuildContext context) {
    UserSearchState userSearchState = Provider.of<UserSearchState>(context);
    UserState userState = Provider.of<UserState>(context);
    String currentUserId = userState.currentUser?.uid ?? "";

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Never miss your friends\' progress!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            'Find your friends and friends and give them a follow and some encouragement! 👏',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 30),
          AppSearchBar(
            focusNode: searchFocusNode,
            hintText: "Search Friends",
            onSearchTap: () {},
            onChanged: (value) {
              if (value.trim().length >= 3) {
                SearchService.search(context, query: value.trim());
              }
            },
            onClear: () {
              SearchService.clearSearch(context);
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
                  itemCount: userSearchState.users.length,
                  itemBuilder: (context, index) {
                    final AppUser user = userSearchState.users[index];

                    if (user.uid != currentUserId) {
                      return ListTile(
                        leading: CircularProfilePicture(
                          radius: 20,
                          profilePictureURL: user.profilePictureURL,
                        ),
                        title: Text(user.displayName ?? ""),
                        trailing: UserTrailingButton(
                          profileUserId: user.uid!,
                          profileUserDisplayName: user.displayName ?? "",
                          profileUserPictureURL: user.profilePictureURL ?? "",
                        ),
                        onTap: () {
                          ProfileService.loadUserFromUid(context, userId: user.uid!);
                          Navigator.of(context).pushNamed(ProfileScreen.route);
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
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
