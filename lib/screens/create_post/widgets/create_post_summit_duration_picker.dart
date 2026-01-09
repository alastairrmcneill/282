import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/create_post/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreatePostDurationPicker extends StatelessWidget {
  const CreatePostDurationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final createPostState = context.watch<CreatePostState>();
    Duration? pickedDuration = createPostState.duration ?? Duration.zero;

    TextEditingController durationController = TextEditingController(
      text: formatDuration(pickedDuration),
    );

    return TextFormFieldBase(
      controller: durationController,
      prefixIcon: const Icon(Icons.timer_outlined),
      readOnly: true,
      onTap: () async {
        final Duration? duration = await showDialog<Duration>(
          context: context,
          builder: (context) => DurationPickerDialog(initialDuration: pickedDuration),
        );

        if (duration != null) {
          createPostState.setDuration = duration;
          durationController.text = formatDuration(duration);
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required';
        }
        return null;
      },
    );
  }

  String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    return '${hours}h ${minutes}m';
  }
}
