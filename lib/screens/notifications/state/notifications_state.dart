import 'package:flutter/material.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/repos/repos.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class NotificationsState extends ChangeNotifier {
  final NotificationsRepository _repository;
  final UserState _userState;
  final Logger _logger;
  NotificationsState(
    this._repository,
    this._userState,
    this._logger,
  );

  NotificationsStatus _status = NotificationsStatus.initial;
  Error _error = Error();
  List<Notif> _notifications = [];

  NotificationsStatus get status => _status;
  Error get error => _error;
  List<Notif> get notifications => _notifications;

  Future<void> getUserNotifications() async {
    try {
      // Set Status
      setStatus = NotificationsStatus.loading;

      List<String> blockedUsers = _userState.blockedUsers;

      // Read comments for post
      final notification = await _repository.readUserNotifs(
        userId: _userState.currentUser?.uid ?? "",
        excludedSourceIds: blockedUsers,
      );

      _notifications = notification
        ..sort((a, b) => b.dateTime.compareTo(a.dateTime))
        ..sort((a, b) {
          if (a.read && !b.read) {
            return 1;
          } else if (!a.read && b.read) {
            return -1;
          } else {
            return 0;
          }
        });

      // Update status
      setStatus = NotificationsStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue retreiving your notifications. Please try again.",
      );
    }
  }

  Future<void> paginateUserNotifications() async {
    try {
      setStatus = NotificationsStatus.paginating;

      List<String> blockedUsers = _userState.blockedUsers;

      // Add posts from database
      addNotifications = await _repository.readUserNotifs(
        userId: _userState.currentUser?.uid ?? "",
        excludedSourceIds: blockedUsers,
        offset: _notifications.length,
      );

      setStatus = NotificationsStatus.loaded;
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue retreiving your notifications. Please try again.",
      );
    }
  }

  Future<void> markNotificationAsRead(Notif notification) async {
    try {
      Notif newNotification = notification.copyWith(read: true);

      await _repository.updateNotif(notification: newNotification);

      int index = _notifications.indexWhere((element) => notification.uid == element.uid);
      if (index == -1) return;
      _notifications[index] = newNotification;

      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue marking your notification as done. Please try again.",
      );
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    try {
      for (Notif notification in _notifications.where((notif) => !notif.read)) {
        Notif newNotification = notification.copyWith(read: true);
        await _repository.updateNotif(notification: newNotification);
      }

      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(read: true);
      }

      notifyListeners();
    } catch (error, stackTrace) {
      _logger.error(error.toString(), stackTrace: stackTrace);
      setError = Error(
        code: error.toString(),
        message: "There was an issue marking your notifications as done. Please try again.",
      );
    }
  }

  set setStatus(NotificationsStatus searchStatus) {
    _status = searchStatus;
    notifyListeners();
  }

  set setError(Error error) {
    _status = NotificationsStatus.error;
    _error = error;
    notifyListeners();
  }

  set setNotifications(List<Notif> notifications) {
    _notifications = notifications;
    notifyListeners();
  }

  set addNotifications(List<Notif> notifications) {
    _notifications.addAll(notifications);
    notifyListeners();
  }

  void reset() {
    _status = NotificationsStatus.initial;
    _error = Error();
    _notifications = [];
    notifyListeners();
  }
}

enum NotificationsStatus { initial, loading, loaded, paginating, error }
