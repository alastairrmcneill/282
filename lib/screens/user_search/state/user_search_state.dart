import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class UserSearchState extends ChangeNotifier {
  SearchStatus _status = SearchStatus.initial;
  List<AppUser> _users = [];
  Error _error = Error();

  List<AppUser> get users => _users;
  SearchStatus get status => _status;
  Error get error => _error;

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
