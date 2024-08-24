import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreatePostSummitTimePicker extends StatelessWidget {
  const CreatePostSummitTimePicker({super.key});

  @override
  Widget build(BuildContext context) {
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    TextEditingController timeController = TextEditingController(
      text: createPostState.summitedDate != null
          ? DateFormat('hh:mm a').format(createPostState.summitedDate!)
          : DateFormat('hh:mm a').format(DateTime.now()),
    );

    TimeOfDay? pickedStartTime;

    return TextFormFieldBase(
      controller: timeController,
      prefixIcon: const Icon(Icons.access_time_rounded),
      readOnly: true,
      onTap: () async {
        pickedStartTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (pickedStartTime != null) {
          createPostState.setStartTime = pickedStartTime;
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
}
