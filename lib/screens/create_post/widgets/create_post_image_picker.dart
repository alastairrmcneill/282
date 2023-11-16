import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class CreatePostImagePicker extends StatelessWidget {
  const CreatePostImagePicker({super.key});

  Future pickImage(CreatePostState createPostState) async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      createPostState.addImage(File(image.path));
    } catch (e) {
      createPostState.setError = Error(code: e.toString(), message: "There was an issue selecting your image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    double height = 150;

    if (createPostState.images.isEmpty && createPostState.imagesURLs.isEmpty) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: InkWell(
          onTap: () async {
            await pickImage(createPostState);
          },
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(10),
            dashPattern: const [5, 5],
            color: Colors.green,
            strokeWidth: 1,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    color: Colors.green,
                  ),
                  Text(
                    'Add photos',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        height: height,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            ...createPostState.imagesURLs.map((imageURL) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(imageURL),
                ),
              );
            }).toList(),
            ...createPostState.images.map((image) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(image),
                ),
              );
            }).toList(),
            InkWell(
              onTap: () async {
                await pickImage(createPostState);
              },
              child: DottedBorder(
                borderType: BorderType.RRect,
                radius: const Radius.circular(10),
                dashPattern: const [5, 5],
                color: Colors.green,
                strokeWidth: 1,
                child: SizedBox(
                  width: height,
                  height: height,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_rounded,
                          color: Colors.green,
                        ),
                        Text(
                          'Add a photo',
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}
