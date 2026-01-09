import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';

class OverlayIntentState extends ChangeNotifier {
  final Logger _logger;

  OverlayIntentState(this._logger);

  final Queue<OverlayIntent> _queue = Queue<OverlayIntent>();
  final Set<String> _recentDedupeKeys = <String>{};

  UnmodifiableListView<OverlayIntent> get pending =>
      UnmodifiableListView<OverlayIntent>(_queue.toList(growable: false));

  OverlayIntent? get next => _queue.isEmpty ? null : _queue.first;

  void enqueue(OverlayIntent intent) {
    if (_recentDedupeKeys.contains(intent.dedupeKey)) {
      // You only get one instance of the dialog per session.
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

  OverlayIntent? consumeNext() {
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
