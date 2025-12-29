import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class GroupFilterState extends ChangeNotifier {
  final FollowersRepository _followersRepository;
  final MunroCompletionsRepository _munroCompletionRepository;
  final UserState _userState;
  final MunroState _munroState;
  final Logger _logger;
  GroupFilterState(
    this._userState,
    this._followersRepository,
    this._munroState,
    this._munroCompletionRepository,
    this._logger,
  );

  GroupFilterStatus _status = GroupFilterStatus.initial;
  Error _error = Error();
  List<FollowingRelationship> _friends = [];
  List<String> _selectedFriendsUids = [];

  GroupFilterStatus get status => _status;
  Error get error => _error;
  List<FollowingRelationship> get friends => _friends;
  List<String> get selectedFriendsUids => _selectedFriendsUids;

  Future getInitialFriends({required String userId}) async {
    if (_userState.currentUser == null) return;
    List<String> blockedUsers = _userState.blockedUsers;

    try {
      setStatus = GroupFilterStatus.loading;

      setFriends = await _followersRepository.getFollowingFromUid(
        sourceId: userId,
        excludedUserIds: blockedUsers,
      );

      setStatus = GroupFilterStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue. Please try again.");
    }
  }

  Future search({required String query}) async {
    if (_userState.currentUser == null) return;

    try {
      // Set loading
      setStatus = GroupFilterStatus.loading;

      // Search
      List<FollowingRelationship> friends = await _followersRepository.searchFollowing(
        sourceId: _userState.currentUser?.uid ?? "",
        searchTerm: query.toLowerCase(),
      );

      setFriends = friends;

      setStatus = GroupFilterStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue with the search. Please try again.");
    }
  }

  Future paginateSearch({required String query}) async {
    if (_userState.currentUser == null) return;

    try {
      setStatus = GroupFilterStatus.paginating;

      // Add posts from database
      List<FollowingRelationship> friends = await _followersRepository.searchFollowing(
        sourceId: _userState.currentUser?.uid ?? "",
        searchTerm: query.toLowerCase(),
        offset: _friends.length,
      );

      addFriends = friends;

      setStatus = GroupFilterStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue loading more. Please try again.");
    }
  }

  void clearSearch() {
    setStatus = GroupFilterStatus.initial;
    setFriends = [];
  }

  void addSelectedFriend({required String uid}) {
    _selectedFriendsUids.add(uid);
    notifyListeners();
  }

  void removeSelectedFriend({required String uid}) {
    if (_selectedFriendsUids.contains(uid)) _selectedFriendsUids.remove(uid);
    notifyListeners();
  }

  void clearSelection() {
    _selectedFriendsUids = [];
    _munroState.setGroupFilterMunroIds = [];
    notifyListeners();
  }

  void reset() {
    _status = GroupFilterStatus.initial;
    _error = Error();
    _friends = [];
    _selectedFriendsUids = [];
    notifyListeners();
  }

  Future filterMunrosBySelection() async {
    if (_userState.currentUser == null) return;

    List<MunroCompletion> munroCompletions = await _munroCompletionRepository.getMunroCompletionsFromUserList(
      userIds: [..._selectedFriendsUids, _userState.currentUser?.uid ?? ''],
    );

    // Send completed munros to munro state and filter out those munros
    _munroState.setGroupFilterMunroIds = munroCompletions.map((mc) => mc.munroId).toSet().toList();
  }

  set setFriends(List<FollowingRelationship> friends) {
    _friends = friends;
    notifyListeners();
  }

  set addFriends(List<FollowingRelationship> friends) {
    _friends.addAll(friends);
    notifyListeners();
  }

  set setStatus(GroupFilterStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = GroupFilterStatus.error;
    _error = error;
    notifyListeners();
  }
}

enum GroupFilterStatus { initial, loading, paginating, loaded, error }
