import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class NotificationsState extends ChangeNotifier {
  NotificationsStatus _status = NotificationsStatus.initial;
  Error _error = Error();
  List<Notif> _notifications = [];

  NotificationsStatus get status => _status;
  Error get error => _error;
  List<Notif> get notifications => _notifications;

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

  markNotificationAsRead(Notif notification) {
    int index = _notifications.indexWhere((element) => notification.uid == element.uid);
    if (index == -1) return;
    _notifications[index] = notification.copyWith(read: true);
    notifyListeners();
  }

  reset() {
    _status = NotificationsStatus.initial;
    _error = Error();
    _notifications = [];
    notifyListeners();
  }
}

enum NotificationsStatus { initial, loading, loaded, paginating, error }
