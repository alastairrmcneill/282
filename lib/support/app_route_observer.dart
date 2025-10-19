import 'package:flutter/material.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/analytics_service.dart';

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  String? _previousScreen;
  DateTime? _previousScreenStartTime;

  @override
  void didPush(Route route, Route? previousRoute) {
    _trackScreenTransition(route, previousRoute);
    super.didPush(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _trackScreenTransition(newRoute, oldRoute);
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _trackScreenTransition(previousRoute, route);
    super.didPop(route, previousRoute);
  }

  void _trackScreenTransition(Route? newRoute, Route? oldRoute) {
    final String? newScreen = _getScreenName(newRoute);
    if (newScreen == _previousScreen) return;

    if (newScreen != null) {
      final now = DateTime.now();

      if (_previousScreen != null && _previousScreenStartTime != null) {
        final duration = now.difference(_previousScreenStartTime!);
        AnalyticsService.logEvent(
          name: 'Screen Viewed',
          parameters: {
            'screen': newScreen,
            'previous_screen': _previousScreen ?? "",
            'duration_seconds': duration.inSeconds.toString(),
          },
        );
      } else {
        AnalyticsService.logEvent(
          name: 'Screen Viewed',
          parameters: {
            'screen': newScreen,
          },
        );
      }

      _previousScreen = newScreen;
      _previousScreenStartTime = now;
    }
  }

  String? _getScreenName(Route? route) {
    if (route is PageRoute) {
      final name = route.settings.name;
      if (name != null && name.isNotEmpty) {
        if (name == '/' || name == HomeScreen.route) {
          return _getActiveTabRouteFromHome();
        }
        return name;
      }
    }
    return null;
  }

  String? _getActiveTabRouteFromHome() {
    if (homeScreenKey.currentState != null) {
      return homeScreenKey.currentState!.currentTabRoute;
    }
    return null;
  }

  void updateCurrentScreen(String newScreen) {
    final now = DateTime.now();
    if (newScreen == _previousScreen) return;

    if (_previousScreen != null && _previousScreenStartTime != null) {
      final duration = now.difference(_previousScreenStartTime!);
      AnalyticsService.logEvent(
        name: 'Screen Viewed',
        parameters: {
          'screen': newScreen,
          'previous_screen': _previousScreen!,
          'duration_seconds': duration.inSeconds.toString(),
        },
      );
    } else {
      AnalyticsService.logEvent(
        name: 'Screen Viewed',
        parameters: {'screen': newScreen},
      );
    }

    _previousScreen = newScreen;
    _previousScreenStartTime = now;
  }
}

final AppRouteObserver appRouteObserver = AppRouteObserver(); // 👈 global instance
