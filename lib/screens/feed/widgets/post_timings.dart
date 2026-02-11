import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/support/theme.dart';

class PostTimings extends StatelessWidget {
  final Post post;
  const PostTimings({super.key, required this.post});

  Widget _buildItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: MyColors.mutedText),
        const SizedBox(width: 4),
        Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: MyColors.mutedText)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (post.completionDate == null && post.completionStartTime == null && post.completionDuration == null) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          if (post.completionDate != null)
            _buildItem(
              context,
              Icons.calendar_today_outlined,
              DateFormat('dd MMM yyyy').format(post.completionDate!),
            ),
          if (post.completionDate != null) const SizedBox(width: 15),
          if (post.completionStartTime != null)
            _buildItem(
              context,
              Icons.access_time_outlined,
              post.completionStartTime!.format12Hour(),
            ),
          if (post.completionStartTime != null) const SizedBox(width: 15),
          if (post.completionDuration != null)
            _buildItem(
              context,
              Icons.timer_outlined,
              "${post.completionDuration!.inHours.toString()}h ${post.completionDuration!.inMinutes.remainder(60).toString().padLeft(2, '0')}m",
            ),
        ],
      ),
    );
  }
}
