import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/screens/strava/strava_connected_colors.dart';

class StravaConnectedTimelineStep extends StatelessWidget {
  final int number;
  final String eyebrow;
  final String title;
  final String description;
  final bool isActive;
  final bool showConnector;

  const StravaConnectedTimelineStep({
    super.key,
    required this.number,
    required this.eyebrow,
    required this.title,
    required this.description,
    this.isActive = false,
    this.showConnector = true,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? StravaConnectedColors.accentText : Colors.transparent,
                  border: isActive ? null : Border.all(color: StravaConnectedColors.accentText, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isActive ? StravaConnectedColors.background : StravaConnectedColors.accentText,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
              if (showConnector)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: StravaConnectedColors.accentText.withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showConnector ? 24 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eyebrow.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: StravaConnectedColors.accentText,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: StravaConnectedColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: StravaConnectedColors.textSubtitle),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
