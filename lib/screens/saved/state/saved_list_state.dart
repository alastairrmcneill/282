import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class SavedListState extends ChangeNotifier {
  final SavedListRepository _savedListRepository;
  final SavedListMunroRepository _savedListMunroRepository;
  final UserState _userState;
  final Logger _logger;

  SavedListState(
    this._savedListRepository,
    this._savedListMunroRepository,
    this._userState,
    this._logger,
  );

  SavedListStatus _status = SavedListStatus.initial;
  Error _error = Error();
  List<SavedList> _savedLists = [];

  SavedListStatus get status => _status;
  Error get error => _error;
  List<SavedList> get savedLists => _savedLists;

  Future createSavedList({required String name}) async {
    try {
      setStatus = SavedListStatus.loading;
      if (_userState.currentUser == null) {
        setError = Error(
          message: "You must be signed in to create a list",
          code: "user-not-signed-in",
        );
        return;
      }

      SavedList savedList = SavedList(
        name: name,
        userId: _userState.currentUser?.uid ?? "",
        munroIds: [],
        dateTimeCreated: DateTime.now(),
      );

      SavedList newSavedList = await _savedListRepository.create(savedList: savedList);

      addSavedList(newSavedList);
      setStatus = SavedListStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "There was an issue creating your list. Please try again",
        code: error.toString(),
      );
    }
  }

  Future readUserSavedLists() async {
    try {
      setStatus = SavedListStatus.loading;
      if (_userState.currentUser == null) {
        setError = Error(
          message: "You must be signed in to create a list",
          code: "user-not-signed-in",
        );
        return;
      }

      List<SavedList> savedLists = await _savedListRepository.readFromUserUid(
        userUid: _userState.currentUser?.uid ?? "",
      );

      setSavedLists = savedLists;
      setStatus = SavedListStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "There was an issue reading your saved lists. Please try again",
        code: error.toString(),
      );
    }
  }

  Future updateSavedListName({required SavedList savedList}) async {
    // Update a saved list

    try {
      if (_userState.currentUser == null) {
        setError = Error(
          message: "You must be signed in to create a list",
          code: "user-not-signed-in",
        );
        return;
      }

      await _savedListRepository.update(savedList: savedList);

      updateSavedList(savedList);
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "There was an issue updating your list. Please try again",
        code: error.toString(),
      );
    }
  }

  Future deleteSavedList({required SavedList savedList}) async {
    try {
      removeSavedList(savedList);

      await _savedListRepository.deleteFromUid(uid: savedList.uid ?? "");
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(message: "There was an issue deleting your post. Please try again.");
    }
  }

  Future addMunroToSavedList({
    required SavedList savedList,
    required int munroId,
  }) async {
    try {
      if (_userState.currentUser == null) {
        setError = Error(
          message: "You must be signed in to create a list",
          code: "user-not-signed-in",
        );
        return;
      }

      if (savedList.munroIds.contains(munroId)) return;

      savedList.munroIds.add(munroId);
      updateSavedList(savedList);

      SavedListMunro savedListMunro = SavedListMunro(
        savedListId: savedList.uid ?? "",
        munroId: munroId,
      );

      await _savedListMunroRepository.create(savedListMunro: savedListMunro);
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "There was an issue saving your Munro. Please try again",
        code: error.toString(),
      );
    }
  }

  Future removeMunroFromSavedList({
    required SavedList savedList,
    required int munroId,
  }) async {
    try {
      if (_userState.currentUser == null) {
        setError = Error(
          message: "You must be signed in to create a list",
          code: "user-not-signed-in",
        );
        return;
      }
      if (!savedList.munroIds.contains(munroId)) return;

      savedList.munroIds.remove(munroId);
      updateSavedList(savedList);

      await _savedListMunroRepository.delete(
        savedListId: savedList.uid ?? "",
        munroId: munroId,
      );
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        message: "There was an issue removing your Munro. Please try again",
        code: error.toString(),
      );
    }
  }

  set setStatus(SavedListStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = SavedListStatus.error;
    _error = error;
    notifyListeners();
  }

  set setSavedLists(List<SavedList> savedLists) {
    _savedLists = savedLists;
    notifyListeners();
  }

  void removeSavedList(SavedList savedList) {
    if (_savedLists.contains(savedList)) {
      _savedLists.remove(savedList);
      notifyListeners();
    }
  }

  void addSavedList(SavedList savedList) {
    _savedLists.add(savedList);
    notifyListeners();
  }

  void updateSavedList(SavedList savedList) {
    int index = _savedLists.indexWhere((element) => element.uid == savedList.uid);
    if (index != -1) {
      _savedLists[index] = savedList;
      notifyListeners();
    }
  }

  void reset() {
    _status = SavedListStatus.initial;
    _error = Error();
    _savedLists = [];
    notifyListeners();
  }
}

enum SavedListStatus { initial, loading, loaded, error }
