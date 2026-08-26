import 'package:two_eight_two/models/models.dart';

class PendingActivityReview {
  final StravaActivity activity;
  final List<MunroMatch> matches;

  PendingActivityReview({
    required this.activity,
    required this.matches,
  });
}
