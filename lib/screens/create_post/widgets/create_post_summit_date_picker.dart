import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreatePostSummitDatePicker extends StatelessWidget {
  const CreatePostSummitDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    TextEditingController dateController = TextEditingController(
      text: DateFormat('dd/MM/yy').format(
        createPostState.summitedDate ?? DateTime.now(),
      ),
    );

    DateTime? pickedStartDate;

    return TextFormFieldBase(
      controller: dateController,
      prefixIcon: const Icon(Icons.calendar_today),
      readOnly: true,
      onTap: () async {
        pickedStartDate = await showDatePicker(
          context: context,
          helpText: "Summit Date",
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );

        if (pickedStartDate != null) {
          DateTime date = pickedStartDate!.add(const Duration(hours: 12));

          createPostState.setSummitedDate = date;
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
