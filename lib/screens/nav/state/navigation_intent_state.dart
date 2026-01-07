import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';

class NavigationIntentState extends ChangeNotifier {
  final Logger _logger;

  NavigationIntentState(this._logger);

  final Queue<NavigationIntent> _queue = Queue<NavigationIntent>();
  final Set<String> _recentDedupeKeys = <String>{};

  UnmodifiableListView<NavigationIntent> get pending =>
      UnmodifiableListView<NavigationIntent>(_queue.toList(growable: false));

  NavigationIntent? get next => _queue.isEmpty ? null : _queue.first;

  void enqueue(NavigationIntent intent) {
    if (_recentDedupeKeys.contains(intent.dedupeKey)) {
      // You can only get one instance of each intent per session
      _logger.info('Dropped duplicate intent: ${intent.dedupeKey}');
      return;
    }

    _queue.addLast(intent);
    _recentDedupeKeys.add(intent.dedupeKey);

    if (_recentDedupeKeys.length > 200) {
      _recentDedupeKeys.clear();
    }

    notifyListeners();
  }

  NavigationIntent? consumeNext() {
    if (_queue.isEmpty) return null;
    final intent = _queue.removeFirst();
    notifyListeners();
    return intent;
  }

  void clear() {
    _queue.clear();
    notifyListeners();
  }
}
