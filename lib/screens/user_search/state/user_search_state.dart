import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';

class UserSearchState extends ChangeNotifier {
  final UserRepository _userRepository;
  final UserState _userState;
  UserSearchState(this._userRepository, this._userState);

  SearchStatus _status = SearchStatus.initial;
  List<AppUser> _users = [];
  Error _error = Error();

  List<AppUser> get users => _users;
  SearchStatus get status => _status;
  Error get error => _error;

  Future<void> search({required String query}) async {
    if (_userState.currentUser == null) return;

    try {
      setStatus = SearchStatus.loading;

      List<String> blockedUsers = _userState.blockedUsers;

      // Search
      _users = await _userRepository.readUsersByName(
        searchTerm: query.toLowerCase(),
        excludedAuthorIds: blockedUsers,
        offset: 0,
      );

      _status = SearchStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue with the search. Please try again.");
    }
  }

  Future<void> paginateSearch({required String query}) async {
    if (_userState.currentUser == null) return;

    try {
      setStatus = SearchStatus.paginating;

      List<String> blockedUsers = _userState.blockedUsers;

      // Search
      final users = await _userRepository.readUsersByName(
        searchTerm: query.toLowerCase(),
        excludedAuthorIds: blockedUsers,
        offset: _users.length,
      );
      _users.addAll(users);
      _status = SearchStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue with the search. Please try again.");
    }
  }

  void clearSearch() {
    _status = SearchStatus.initial;
    _users = [];
    notifyListeners();
  }

  set setStatus(SearchStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setUsers(List<AppUser> users) {
    _users = users;
    notifyListeners();
  }

  set addUsers(List<AppUser> users) {
    _users.addAll(users);

    notifyListeners();
  }

  set setError(Error error) {
    _status = SearchStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum SearchStatus { initial, loading, loaded, paginating, error }
