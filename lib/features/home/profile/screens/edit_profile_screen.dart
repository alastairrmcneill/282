import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/auth/widgets/widgets.dart';
import 'package:two_eight_two/general/models/app_user.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _photoURL;
  File? _image;

  @override
  void initState() {
    super.initState();
    UserState userState = Provider.of<UserState>(context, listen: false);

    if (userState.currentUser == null) return;

    _firstNameController.text = userState.currentUser!.firstName ?? "";
    _lastNameController.text = userState.currentUser!.lastName ?? "";

    _photoURL = userState.currentUser!.profilePictureURL;
  }

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() {
        _image = File(image.path);
      });
    } on PlatformException catch (e) {
      print("Image picker error: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);

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
              AppUser appUser = userState.currentUser!;

              AppUser newAppUser = appUser.copyWith(
                displayName:
                    "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}",
                firstName: _firstNameController.text.trim(),
                lastName: _lastNameController.text.trim(),
              );

              await AuthService.updateAuthUser(
                context,
                appUser: newAppUser,
                profilePicture: _image,
              ).whenComplete(
                () => Navigator.pop(context),
              );
            },
            child: const Text(
              "Save",
              style: TextStyle(color: Colors.white, decoration: TextDecoration.none),
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
                                fit: BoxFit.fill,
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
