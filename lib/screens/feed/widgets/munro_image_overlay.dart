import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroImageOverlay extends StatelessWidget {
  final Munro munro;
  const MunroImageOverlay({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(MunroScreen.route, arguments: MunroScreenArgs(munro: munro)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.black.withAlpha(170),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.mountain, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  munro.name,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
