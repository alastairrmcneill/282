import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/cached_munro_image.dart';
import 'package:two_eight_two/widgets/overlay_gradient.dart';

class MunroClimbedWithTile extends StatelessWidget {
  final Munro munro;
  final SettingsState settingsState;

  const MunroClimbedWithTile({
    super.key,
    required this.munro,
    required this.settingsState,
  });

  @override
  Widget build(BuildContext context) {
    final heightText = settingsState.metricHeight ? '${munro.meters}m' : '${munro.feet}ft';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(MunroScreen.route, arguments: MunroScreenArgs(munro: munro));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedMunroImage(imageUrl: munro.pictureURL),
            OverlayGradient(stops: const [0.2, 0.5, 1.0]),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      munro.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$heightText • ${munro.area}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
