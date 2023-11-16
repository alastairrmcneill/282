import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/error_model.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class SearchService {
  static Future search(BuildContext context, {required String query}) async {
    UserSearchState userSearchState = Provider.of<UserSearchState>(context, listen: false);
    try {
      // Set loading
      userSearchState.setStatus = SearchStatus.loading;

      // Search
      userSearchState.setUsers = await UserDatabase.searchUsers(context, query: query.toLowerCase(), lastUserId: null);

      userSearchState.setStatus = SearchStatus.loaded;
    } catch (error) {
      userSearchState.setError = Error(message: "There was an issue with the search. Please try again.");
    }
  }

  static Future paginateSearch(BuildContext context, {required String query}) async {
    UserSearchState userSearchState = Provider.of<UserSearchState>(context, listen: false);

    try {
      userSearchState.setStatus = SearchStatus.paginating;

      // Find last user ID
      String lastUserId = "";
      if (userSearchState.users.isNotEmpty) {
        lastUserId = userSearchState.users.last.uid!;
      }

      // Add posts from database
      userSearchState.addUsers = await UserDatabase.searchUsers(context, query: query, lastUserId: lastUserId);
      userSearchState.setStatus = SearchStatus.loaded;
    } catch (error) {
      userSearchState.setError = Error(message: "There was an issue loading more. Please try again.");
    }
  }

  static clearSearch(BuildContext context) {
    UserSearchState userSearchState = Provider.of<UserSearchState>(context, listen: false);
    userSearchState.setStatus = SearchStatus.initial;
    userSearchState.setUsers = [];
  }
}
