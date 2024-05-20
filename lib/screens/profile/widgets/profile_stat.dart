import 'package:flutter/material.dart';

class ProfileStat extends StatelessWidget {
  final String text;
  final String stat;
  final Function()? onTap;
  const ProfileStat({
    super.key,
    required this.text,
    required this.stat,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              stat,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 18, height: 1.5),
            )
          ],
        ),
      ),
    );
  }
}
