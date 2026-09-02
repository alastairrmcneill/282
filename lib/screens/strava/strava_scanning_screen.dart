import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/screens/strava/helpers/match_strava_activity.dart';
import 'package:two_eight_two/screens/strava/widgets/widgets.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class StravaScanningScreen extends StatelessWidget {
  static const String route = '/strava_scanning';

  const StravaScanningScreen({super.key});

  Widget _scanningProgressState(BuildContext context, StravaState stravaState) {
    final munroCompletionState = context.read<MunroCompletionState>();
    final userState = context.read<UserState>();
    final activitiesCount = stravaState.activities.length;
    final activitiesScannedCount = stravaState.activitiesScannedCount;
    final munroMatches = stravaState.matches;

    final userId = userState.currentUser?.uid;

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/strava_solid.svg',
                width: 18,
                height: 18,
              ),
              const SizedBox(width: 8),
              Text('Reading your Strava History'),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${munroMatches.length}',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: context.colors.accent,
                      fontSize: 72,
                    ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Munro${munroMatches.length == 1 ? '' : 's'}', style: Theme.of(context).textTheme.titleLarge),
                    Text('found so far', style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: activitiesCount > 0 ? activitiesScannedCount / activitiesCount : 0,
            backgroundColor: context.colors.middleGrey,
            color: context.colors.accent,
            borderRadius: BorderRadius.circular(100),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${activitiesScannedCount.thousandsSeparator()} of ${activitiesCount.thousandsSeparator()} activities',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
              ),
              Text(
                '${(activitiesScannedCount / activitiesCount * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Expanded(
            child: ListView(
              children: stravaState.matches
                  .map(
                    (match) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: StravaMatchMunroTile(
                        munroMatch: match,
                        isSelected: stravaState.selectedMatches.contains(match),
                        isRepeat: munroCompletionState.completedMunroIds.contains(match.munro.id),
                        onSelected: (isSelected) {
                          stravaState.toggleMatchSelection(match);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
          CtaButton(
            disabled:
                stravaState.scanningStatus != StravaScanningStatus.completed || stravaState.selectedMatches.isEmpty,
            height: 56,
            onPressed: () async {
              List<MunroCompletion> completions = [];

              for (StravaMunroMatch match in stravaState.selectedMatches) {
                final completion = MunroCompletion(
                  munroId: match.munro.id,
                  completionDate: match.stravaActivity.startDate,
                  dateTimeCompleted: match.stravaActivity.startDate,
                  userId: userId ?? '',
                  completionDuration: match.stravaActivity.durationS == null
                      ? null
                      : Duration(seconds: match.stravaActivity.durationS!.toInt()),
                  completionStartTime: TimeOfDay.fromDateTime(match.stravaActivity.startDate),
                );
                completions.add(completion);
              }

              await munroCompletionState.addBulkCompletions(munroCompletions: completions);

              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.route, (route) => false);
              }
            },
            child: Text("Add ${stravaState.selectedMatches.length} to my map"),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Consumer<StravaState>(
          builder: (context, stravaState, child) {
            switch (stravaState.scanningStatus) {
              case StravaScanningStatus.initial:
                return Center(
                  child: const StravaScanningProgressState(
                    title: 'Getting ready',
                    subtitle: "We're about to check your Strava history against all 282 Munros.",
                  ),
                );
              case StravaScanningStatus.loading:
                return Center(
                  child: const StravaScanningProgressState(
                    title: 'Fetching your activities',
                    subtitle: "Pulling your history from Strava…",
                  ),
                );
              case StravaScanningStatus.scanning:
                return _scanningProgressState(context, stravaState);
              case StravaScanningStatus.completed:
                return _scanningProgressState(context, stravaState);

              case StravaScanningStatus.error:
                return const StravaScanningResultState(
                  isError: true,
                  title: 'Something went wrong',
                  subtitle: "We couldn't finish scanning your Strava activities. Please try again.",
                );
            }
          },
        ),
      ),
    );
  }
}
