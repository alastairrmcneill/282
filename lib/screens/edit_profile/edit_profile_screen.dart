import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/screens/auth/widgets/widgets.dart';
import 'package:two_eight_two/models/app_user.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/helpers/image_picker_helper.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  static const String route = '/profile/edit';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _bioController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _photoURL;
  File? _image;

  @override
  void initState() {
    super.initState();
    final userState = context.read<UserState>();

    if (userState.currentUser == null) return;

    _firstNameController.text = userState.currentUser!.firstName ?? "";
    _lastNameController.text = userState.currentUser!.lastName ?? "";
    _bioController.text = userState.currentUser!.bio ?? "";

    _photoURL = userState.currentUser?.profilePictureURL;
  }

  Future pickImage() async {
    try {
      final File? image = await ImagePickerHelper.pickSingleImage(context);
      if (image == null) return;

      setState(() {
        _image = image;
      });
    } catch (error, stackTrace) {
      context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.watch<UserState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: () async {
              if (!_formKey.currentState!.validate()) {
                return;
              }
              _formKey.currentState!.save();

              if (userState.currentUser == null) return;

              AppUser appUser = userState.currentUser!;

              AppUser newAppUser = appUser.copyWith(
                displayName: "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
                searchName: "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}".toLowerCase(),
                firstName: _firstNameController.text.trim(),
                lastName: _lastNameController.text.trim(),
                bio: _bioController.text.trim(),
              );
              startCircularProgressOverlay(context);
              await userState.updateProfile(
                appUser: newAppUser,
                profilePicture: _image,
              );
              stopCircularProgressOverlay(context);
              if (userState.status == UserStatus.loaded) {
                Navigator.of(context).pop(true);
              } else if (userState.status == UserStatus.error) {
                showErrorDialog(context, message: userState.error.message);
              }
            },
            child: const Text(
              "Save",
            ),
          )
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  await pickImage();
                },
                child: _photoURL == null && _image == null
                    ? Container(
                        width: 100.0,
                        height: 100.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[350],
                        ),
                        child: ClipOval(
                          child: Icon(
                            Icons.person_rounded,
                            color: Colors.grey[600],
                            size: 70,
                          ),
                        ),
                      )
                    : _image == null
                        ? Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: CachedNetworkImageProvider(
                                  _photoURL!,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            width: 100.0,
                            height: 100.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.file(
                                _image!, // Replace with the path to your local image file
                                fit: BoxFit.cover, // Adjust the fit as needed
                              ),
                            ),
                          ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    NameFormField(
                      textEditingController: _firstNameController,
                      hintText: "First Name",
                    ),
                    const SizedBox(height: 15),
                    NameFormField(
                      textEditingController: _lastNameController,
                      hintText: "Last Name",
                    ),
                    const SizedBox(height: 15),
                    BioFormField(
                      textEditingController: _bioController,
                      hintText: 'Bio',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
