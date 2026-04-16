import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreatePostSummitTimePicker extends StatelessWidget {
  const CreatePostSummitTimePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final createPostState = context.watch<CreatePostState>();
    TextEditingController timeController = TextEditingController(
      text: createPostState.completionStartTime?.format(context),
    );

    TimeOfDay? pickedStartTime;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Start Time', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: context.colors.textMuted)),
        const SizedBox(height: 2),
        AppTextFormField(
          controller: timeController,
          hintText: '--.--',
          prefixIcon: Icon(
            PhosphorIconsRegular.clock,
            size: 22,
            color: context.colors.textMuted,
          ),
          readOnly: true,
          onTap: () async {
            pickedStartTime = await showTimePicker(
              initialEntryMode: TimePickerEntryMode.input,
              context: context,
              helpText: "Start Time",
              hourLabelText: 'Hour',
              minuteLabelText: 'Minute',
              initialTime: TimeOfDay.now(),
            );

            if (pickedStartTime != null) {
              createPostState.setCompletionStartTime = pickedStartTime;
            }
          },
          validator: (value) {
            return null;
          },
        ),
      ],
    );
  }
}
