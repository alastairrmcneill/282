import 'dart:io';

import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/services/services.dart';

class UserState extends ChangeNotifier {
  final UserRepository userRepository;
  final BlockedUserRepository blockedUserRepository;
  UserState(
    this.userRepository,
    this.blockedUserRepository,
  );

  UserStatus _status = UserStatus.initial;
  Error _error = Error();
  AppUser? _currentUser;
  List<String> _blockedUsers = [];

  UserStatus get status => _status;
  Error get error => _error;
  AppUser? get currentUser => _currentUser;
  List<String> get blockedUsers => _blockedUsers;

  Future<void> createUser({required AppUser appUser}) async {
    _status = UserStatus.loading;
    notifyListeners();
    try {
      await userRepository.create(appUser: appUser);
      _status = UserStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      _status = UserStatus.error;
      _error = Error(code: error.toString(), message: "There was an error creating the account.");
      notifyListeners();
    }
  }

  Future<void> updateUser({required AppUser appUser}) async {
    _status = UserStatus.loading;
    notifyListeners();
    try {
      await userRepository.update(appUser: appUser);
      _currentUser = appUser;
      _status = UserStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      _status = UserStatus.error;
      _error = Error(code: error.toString(), message: "There was an error updating the account.");
      notifyListeners();
    }
  }

  Future<void> readCurrentUser() async {
    _status = UserStatus.loading;
    notifyListeners();
    try {
      String? uid = AuthService.currentUserId;
      if (uid == null) {
        _status = UserStatus.loaded;
        notifyListeners();
        return;
      }

      AppUser? appUser = await userRepository.readUserFromUid(uid: uid);
      _currentUser = appUser;
      _status = UserStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      _status = UserStatus.error;
      _error = Error(code: error.toString(), message: "There was an error fetching the account.");
      notifyListeners();
    }
  }

  Future<void> deleteUser({required AppUser appUser}) async {
    _status = UserStatus.loading;
    notifyListeners();
    try {
      await userRepository.deleteUserWithUID(uid: appUser.uid!);
      _currentUser = null;
      _status = UserStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      _status = UserStatus.error;
      _error = Error(code: error.toString(), message: "There was an error deleting the account.");
      notifyListeners();
    }
  }

  Future<void> blockUser({required String userId}) async {
    try {
      if (_currentUser == null) return;

      BlockedUserRelationship blockedUserRelationship = BlockedUserRelationship(
        userId: _currentUser!.uid!,
        blockedUserId: userId,
        dateTimeBlocked: DateTime.now(),
      );

      await blockedUserRepository.blockUser(blockedUserRelationship: blockedUserRelationship);

      _blockedUsers = [..._blockedUsers, userId];
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
    }
  }

  Future<void> loadBlockedUsers() async {
    try {
      if (_currentUser == null) return;

      // Load the blocked users list
      List<String> blockedUsers = await blockedUserRepository.getBlockedUsersForUid(
        userId: _currentUser!.uid!,
      );

      // Update the state with the blocked users
      _blockedUsers = blockedUsers;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
    }
  }

  Future<void> updateProfileVisibility(String newValue) async {
    if (_currentUser == null) return;

    AppUser updatedUser = _currentUser!.copyWith(profileVisibility: newValue);
    updateUser(appUser: updatedUser);
  }

  Future updateProfile({required AppUser appUser, File? profilePicture}) async {
    try {
      if (_currentUser == null) return;
      _status = UserStatus.loading;
      notifyListeners();

      String? photoURL;
      if (profilePicture != null) {
        photoURL = await StorageService.uploadProfilePicture(profilePicture);
        appUser.profilePictureURL = photoURL;
      }

      // Update Auth
      // await AuthService.updateAuthUser(appUser: appUser); // TODO: come back to

      // Update user database
      await updateUser(appUser: appUser);
      _status = UserStatus.loaded;
      notifyListeners();
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      _status = UserStatus.error;
      _error = Error(code: error.toString(), message: "There was an issue updating the profile.");
      notifyListeners();
    }
  }

  set setCurrentUser(AppUser? appUser) {
    _currentUser = appUser;
    notifyListeners();
  }

  set setBlockedUsers(List<String> blockedUsers) {
    _blockedUsers = blockedUsers;
    notifyListeners();
  }

  void reset() {
    _status = UserStatus.initial;
    _error = Error();
    _currentUser = null;
    _blockedUsers = [];
    notifyListeners();
  }
}

enum UserStatus { initial, loading, loaded, error }
