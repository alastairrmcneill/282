import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class CreatePostSummitDatePicker extends StatelessWidget {
  const CreatePostSummitDatePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final createPostState = context.watch<CreatePostState>();
    TextEditingController dateController = TextEditingController(
      text: createPostState.completionDate != null
          ? DateFormat('dd/MM/yyyy').format(
              createPostState.completionDate!,
            )
          : null,
    );

    DateTime? pickedStartDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Summit Date', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: context.colors.textMuted)),
        const SizedBox(height: 2),
        TextFormFieldBase(
          controller: dateController,
          prefixIcon: Icon(
            PhosphorIconsRegular.calendarBlank,
            size: 22,
            color: context.colors.textMuted,
          ),
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

              createPostState.setCompletionDate = date;
            }
          },
          hintText: DateFormat('dd/MM/yyyy').format(DateTime.now()),
          validator: (value) {
            return null;
          },
        ),
      ],
    );
  }
}
