import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PostPrivacySelector extends StatelessWidget {
  final List<String> _postVisibilityOptions = [
    Privacy.public,
    Privacy.friends,
    Privacy.private,
  ];

  final TextEditingController controller = TextEditingController();
  PostPrivacySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsState = context.watch<SettingsState>();
    final createPostState = context.watch<CreatePostState>();

    controller.text = createPostState.postPrivacy?.capitalize() ?? settingsState.defaultPostVisibility.capitalize();

    IconData icon = PhosphorIconsRegular.globe;

    switch (createPostState.postPrivacy) {
      case "public":
        icon = PhosphorIconsRegular.globe;
        break;
      case "friends":
        icon = PhosphorIconsRegular.users;
        break;
      case "private":
        icon = PhosphorIconsRegular.lock;
        break;
    }

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Visibility',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        TextFormFieldBase(
          controller: controller,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          readOnly: true,
          labelText: "Post Visibility",
          hintText: "Post Visibility Selector",
          onTap: () async {
            // Show bottom sheet with 3 options
            await showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 40, top: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _postVisibilityOptions.map((String option) {
                      return ListTile(
                        title: Text(option.capitalize()),
                        subtitle: Text(
                          option == "public"
                              ? PrivacyDescriptions.public
                              : option == "friends"
                                  ? PrivacyDescriptions.friends
                                  : PrivacyDescriptions.private,
                        ),
                        trailing: createPostState.postPrivacy == option ? const Icon(Icons.check) : null,
                        onTap: () {
                          createPostState.setPostPrivacy = option;
                          Navigator.of(context).pop();
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
