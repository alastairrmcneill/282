import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/explore/widgets/widgets.dart';
import 'package:two_eight_two/models/app_user.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class UserSearchScreen extends StatefulWidget {
  static const String route = "/user_search";
  const UserSearchScreen({super.key});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  late FocusNode _focusNode;
  @override
  void initState() {
    final userSearchState = context.read<UserSearchState>();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange &&
          userSearchState.status != SearchStatus.paginating) {
        userSearchState.paginateSearch(query: _searchController.text.trim());
      }
    });
    _focusNode = FocusNode();
    _focusNode.requestFocus();
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
    final userState = context.watch<UserState>();
    UserSearchState userSearchState = context.read<UserSearchState>();
    String currentUserId = userState.currentUser?.uid ?? "";

    return PopScope(
      onPopInvoked: (value) {
        userSearchState.clearSearch();
      },
      child: Scaffold(
        appBar: AppBar(
          title: AppSearchBar(
            focusNode: _focusNode,
            hintText: "Find friends",
            onClear: () {
              _searchController.clear();
              userSearchState.clearSearch();
            },
            onSearchTap: () {},
            onChanged: (value) {
              if (value.trim().length >= 2) {
                userSearchState.search(query: value.trim());
              }
            },
          ),
        ),
        body: Column(
          children: [
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
      itemCount: 20,
      controller: _scrollController,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const ShimmerListTile(),
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
        if (user.uid == currentUserId) return const SizedBox.shrink();

        return _UserSearchTile(user: user);
      },
    );
  }
}

class _UserSearchTile extends StatelessWidget {
  final AppUser user;

  const _UserSearchTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.dark ? AppColors.dark : AppColors.light;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(
        ProfileScreen.route,
        arguments: ProfileScreenArgs(userId: user.uid!),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircularProfilePicture(
              radius: 22,
              profilePictureURL: user.profilePictureURL,
              profileUid: user.uid,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user.displayName ?? "",
                    style: textTheme.titleSmall?.copyWith(color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${user.munrosCompleted ?? 0} Munros",
                    style: textTheme.bodySmall?.copyWith(color: colors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            UserTrailingButton(
              profileUserId: user.uid!,
              profileUserDisplayName: user.displayName ?? "",
              profileUserPictureURL: user.profilePictureURL ?? "",
            ),
          ],
        ),
      ),
    );
  }
}
