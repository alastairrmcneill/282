import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class PostPrivacySelector extends StatelessWidget {
  final List<String> _postVisibilityOptions = [
    Privacy.public,
    Privacy.friends,
    Privacy.private,
  ];
  PostPrivacySelector({super.key});

  @override
  Widget build(BuildContext context) {
    SettingsState settingsState = Provider.of<SettingsState>(context);
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    return ListTile(
      title: const Text('Post Visibility'),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: createPostState.postPrivacy ?? settingsState.defaultPostVisibility,
          onChanged: (String? newValue) {
            if (newValue != null) {
              createPostState.setPostPrivacy = newValue;
            }
          },
          items: _postVisibilityOptions.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value.capitalize(),
                style: const TextStyle(fontWeight: FontWeight.w400),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
