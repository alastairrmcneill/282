import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/create_post/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreatePostDurationPicker extends StatelessWidget {
  const CreatePostDurationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final createPostState = context.watch<CreatePostState>();
    Duration? pickedDuration = createPostState.completionDuration ?? Duration.zero;

    TextEditingController durationController = TextEditingController(
      text: createPostState.completionDuration != null ? formatDuration(pickedDuration) : null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Duration', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: MyColors.mutedText)),
        const SizedBox(height: 2),
        TextFormFieldBase(
          controller: durationController,
          prefixIcon: const Icon(
            PhosphorIconsRegular.timer,
            size: 22,
            color: MyColors.mutedText,
          ),
          readOnly: true,
          onTap: () async {
            final Duration? duration = await showDialog<Duration>(
              context: context,
              builder: (context) => DurationPickerDialog(initialDuration: pickedDuration),
            );

            if (duration != null) {
              createPostState.setCompletionDuration = duration;
              durationController.text = formatDuration(duration);
            }
          },
          hintText: '00h 00m',
          validator: (value) {
            return null;
          },
        ),
      ],
    );
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m';
  }
}
