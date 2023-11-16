import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/error_model.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class SearchService {
  static Future search(BuildContext context, {required String query}) async {
    SearchState searchState = Provider.of<SearchState>(context, listen: false);
    try {
      // Set loading
      searchState.setStatus = SearchStatus.loading;

      // Search
      searchState.setUsers = await UserDatabase.searchUsers(context, query: query.toLowerCase(), lastUserId: null);

      searchState.setStatus = SearchStatus.loaded;
    } catch (error) {
      searchState.setError = Error(message: "There was an issue with the search. Please try again.");
    }
  }

  static Future paginateSearch(BuildContext context, {required String query}) async {
    SearchState searchState = Provider.of<SearchState>(context, listen: false);

    try {
      searchState.setStatus = SearchStatus.paginating;

      // Find last user ID
      String lastUserId = "";
      if (searchState.users.isNotEmpty) {
        lastUserId = searchState.users.last.uid!;
      }

      // Add posts from database
      searchState.addUsers = await UserDatabase.searchUsers(context, query: query, lastUserId: lastUserId);
      searchState.setStatus = SearchStatus.loaded;
    } catch (error) {
      searchState.setError = Error(message: "There was an issue loading more. Please try again.");
    }
  }

  static clearSearch(BuildContext context) {
    SearchState searchState = Provider.of<SearchState>(context, listen: false);
    searchState.setStatus = SearchStatus.initial;
    searchState.setUsers = [];
  }
}
