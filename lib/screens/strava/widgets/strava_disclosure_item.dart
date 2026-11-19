import 'package:material_ui/material_ui.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class StravaDisclosureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const StravaDisclosureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: context.colors.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textSubtitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
