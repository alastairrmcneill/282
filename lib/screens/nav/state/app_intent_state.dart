import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';

class AppIntentState extends ChangeNotifier {
  final Logger _logger;

  AppIntentState(this._logger);

  final Queue<AppIntent> _queue = Queue<AppIntent>();
  final Set<String> _recentDedupeKeys = <String>{};

  UnmodifiableListView<AppIntent> get pending => UnmodifiableListView<AppIntent>(_queue.toList(growable: false));

  AppIntent? get next => _queue.isEmpty ? null : _queue.first;

  void enqueue(AppIntent intent) {
    if (_recentDedupeKeys.contains(intent.dedupeKey)) {
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

  AppIntent? consumeNext() {
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
