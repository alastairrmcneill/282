import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/remote_config_service.dart';
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
    SettingsState settingsState = Provider.of<SettingsState>(context);
    CreatePostState createPostState = Provider.of<CreatePostState>(context);

    bool showPrivacyOption = RemoteConfigService.getBool(RCFields.showPrivacyOption);

    controller.text = createPostState.postPrivacy?.capitalize() ?? settingsState.defaultPostVisibility.capitalize();

    IconData icon = CupertinoIcons.globe;

    switch (createPostState.postPrivacy) {
      case "public":
        icon = CupertinoIcons.globe;
        break;
      case "friends":
        icon = CupertinoIcons.person_2;
        break;
      case "private":
        icon = CupertinoIcons.lock;
        break;
    }

    if (!showPrivacyOption) {
      return const SizedBox.shrink();
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
