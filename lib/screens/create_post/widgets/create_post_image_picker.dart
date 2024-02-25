import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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
      print("Starting image picker");
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      print("Finished image picker");
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
            print("Tapped");
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
                  child: CachedNetworkImage(
                    imageUrl: imageURL,
                    progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 45),
                      child: LinearProgressIndicator(
                        value: downloadProgress.progress,
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return const Icon(Icons.photo_rounded);
                    },
                  ),
                ),
              );
            }),
            ...createPostState.images.map((image) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(image),
                ),
              );
            }),
            createPostState.images.length + createPostState.imagesURLs.length > 10
                ? const SizedBox()
                : InkWell(
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
