import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class GroupFilterService {
  static Future getInitialFriends(BuildContext context, {required String userId}) async {
    GroupFilterState groupFilterState = Provider.of<GroupFilterState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    List<String> blockedUsers = userState.blockedUsers;

    if (userState.currentUser == null) return;

    try {
      groupFilterState.setStatus = GroupFilterStatus.loading;

      groupFilterState.setFriends = await FollowingRelationshipsDatabase.getFollowingFromUid(
        context,
        sourceId: userId,
        excludedUserIds: blockedUsers,
      );

      groupFilterState.setStatus = GroupFilterStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      groupFilterState.setError = Error(message: "There was an issue. Please try again.");
    }
  }

  static Future search(BuildContext context, {required String query}) async {
    GroupFilterState groupFilterState = Provider.of<GroupFilterState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    if (userState.currentUser == null) return;

    try {
      // Set loading
      groupFilterState.setStatus = GroupFilterStatus.loading;

      // Search
      List<FollowingRelationship> friends = await FollowingRelationshipsDatabase.searchFollowingByUid(
        context,
        sourceId: userState.currentUser?.uid ?? "",
        searchTerm: query,
      );

      groupFilterState.setFriends = friends;

      groupFilterState.setStatus = GroupFilterStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      groupFilterState.setError = Error(message: "There was an issue with the search. Please try again.");
    }
  }

  static Future paginateSearch(BuildContext context, {required String query}) async {
    GroupFilterState groupFilterState = Provider.of<GroupFilterState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context, listen: false);

    if (userState.currentUser == null) return;

    try {
      groupFilterState.setStatus = GroupFilterStatus.paginating;

      // Add posts from database
      List<FollowingRelationship> friends = await FollowingRelationshipsDatabase.searchFollowingByUid(
        context,
        sourceId: userState.currentUser?.uid ?? "",
        searchTerm: query.toLowerCase(),
        offset: groupFilterState.friends.length,
      );

      groupFilterState.addFriends = friends;

      groupFilterState.setStatus = GroupFilterStatus.loaded;
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      groupFilterState.setError = Error(message: "There was an issue loading more. Please try again.");
    }
  }

  static clearSearch(BuildContext context) {
    GroupFilterState groupFilterState = Provider.of<GroupFilterState>(context, listen: false);
    groupFilterState.setStatus = GroupFilterStatus.initial;
    groupFilterState.setFriends = [];
  }

  static addSelectedFreindUid(BuildContext context, {required String uid}) {
    GroupFilterState groupFilterState = Provider.of<GroupFilterState>(context, listen: false);
    groupFilterState.addSelectedFriend(uid);
  }

  static removeSelectedFreindUid(BuildContext context, {required String uid}) {
    GroupFilterState groupFilterState = Provider.of<GroupFilterState>(context, listen: false);
    groupFilterState.removeSelectedFriend(uid);
  }

  static clearSelection(BuildContext context) {
    GroupFilterState groupFilterState = Provider.of<GroupFilterState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    groupFilterState.clearSelection();
    munroState.setGroupFilterMunroIds = [];
  }

  static reset(BuildContext context) {
    GroupFilterState groupFilterState = Provider.of<GroupFilterState>(context, listen: false);
    groupFilterState.reset();
  }

  static Future filterMunrosBySelection(BuildContext context) async {
    UserState userState = Provider.of<UserState>(context, listen: false);
    GroupFilterState groupFilterState = Provider.of<GroupFilterState>(context, listen: false);
    MunroState munroState = Provider.of<MunroState>(context, listen: false);

    // Set to store all climbed Munro IDs
    Set<String> completedMunroIds = {};

    AppUser? currentUser = userState.currentUser;

    if (currentUser == null) return;

    List<AppUser> selectedFriends = await UserDatabase.readUsersFromUids(
      context,
      uids: groupFilterState.selectedFriendsUids,
    );

    selectedFriends.add(currentUser);

    for (var user in selectedFriends) {
      for (var munro in user.personalMunroData ?? []) {
        // TODO fix

        // if (munro[MunroFields.summited] as bool == true) {
        //   completedMunroIds.add(munro[MunroFields.id]);
        // }
      }
    }

    // Send completed munros to munro state and filter out those munros
    munroState.setGroupFilterMunroIds = completedMunroIds.toList();
  }
}
