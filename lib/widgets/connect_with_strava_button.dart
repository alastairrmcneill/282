import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/extensions/extensions.dart';

/// Strava's official "Connect with Strava" button, used unmodified as the
/// Brand Guidelines require. The image files live in assets/strava/.
class ConnectWithStravaButton extends StatelessWidget {
  static const String _asset = 'assets/strava/btn_strava_connect_with_orange.png';

  final VoidCallback? onPressed;
  const ConnectWithStravaButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Connect with Strava',
      child: GestureDetector(
        onTap: onPressed,
        child: Opacity(
          opacity: onPressed == null ? 0.5 : 1,
          child: Image.asset(
            _asset,
            height: 48,
            fit: BoxFit.contain,
            errorBuilder: (context, _, __) => Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              alignment: Alignment.center,
              color: context.colors.stravaOrange,
              child: Text(
                'Connect with Strava',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: context.colors.onStrava),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
