import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/extensions/extensions.dart';

/// Strava's official "Powered by Strava" logo, shown wherever Strava Data is displayed.
class PoweredByStravaLogo extends StatelessWidget {
  static const String _lightAsset = 'assets/strava/api_logo_pwrdBy_strava_horiz_orange.png';
  static const String _darkAsset = 'assets/strava/api_logo_pwrdBy_strava_horiz_white.png';

  final double height;
  const PoweredByStravaLogo({super.key, this.height = 20});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      label: 'Powered by Strava',
      child: Image.asset(
        isDark ? _darkAsset : _lightAsset,
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, _, __) => Text(
          'Powered by Strava',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textMuted),
        ),
      ),
    );
  }
}
