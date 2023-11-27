import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/profile/screens/profile_screen.dart';
import 'package:two_eight_two/models/app_user.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  @override
  void initState() {
    UserSearchState userSearchState = Provider.of<UserSearchState>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          userSearchState.status != SearchStatus.paginating) {
        SearchService.paginateSearch(context, query: _searchController.text.trim());
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    String currentUserId = userState.currentUser?.uid ?? "";

    return WillPopScope(
      onWillPop: () async {
        SearchService.clearSearch(context);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: InputBorder.none,
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search, size: 30),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    SearchService.clearSearch(context);
                  },
                ),
                filled: true,
              ),
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                if (value.trim().length >= 3) {
                  SearchService.search(context, query: value.trim());
                }
              },
            ),
            Expanded(
              flex: 1,
              child: Consumer<UserSearchState>(
                builder: (context, userSearchState, child) {
                  switch (userSearchState.status) {
                    case SearchStatus.initial:
                      return const CenterText(text: "Search for fellow 282 users");
                    case SearchStatus.loading:
                      return _buildLoadingScreen();
                    case SearchStatus.error:
                      return CenterText(text: userSearchState.error.message);
                    default:
                      return _buildScreen(
                        context,
                        userSearchState: userSearchState,
                        scrollController: _scrollController,
                        currentUserId: currentUserId,
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return ListView.builder(
      itemCount: 30,
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => ShimmerListTile(),
    );
  }

  Widget _buildScreen(
    BuildContext context, {
    required UserSearchState userSearchState,
    required ScrollController scrollController,
    required String currentUserId,
  }) {
    if (userSearchState.users.isEmpty) {
      return const CenterText(text: "No users found");
    }

    return ListView.builder(
      controller: scrollController,
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
            onTap: () {
              ProfileService.loadUserFromUid(context, userId: user.uid!);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
