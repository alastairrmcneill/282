import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/log_service.dart';

class CreatePostImagePicker extends StatelessWidget {
  final String munroId;
  const CreatePostImagePicker({super.key, required this.munroId});

  Future pickImage(CreatePostState createPostState) async {
    try {
      final images = await ImagePicker().pickMultiImage();
      for (var image in images) {
        createPostState.addImage(munroId: munroId, image: File(image.path));
      }
    } catch (error, stackTrace) {
      Log.error(error.toString(), stackTrace: stackTrace);
      createPostState.setError = Error(code: error.toString(), message: "There was an issue selecting your image.");
    }
  }

  @override
  Widget build(BuildContext context) {
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    double height = 150;

    if ((createPostState.images[munroId]?.isEmpty ?? true) && (createPostState.imagesURLs[munroId]?.isEmpty ?? true)) {
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
            ...createPostState.imagesURLs[munroId]?.map((imageURL) {
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl: imageURL,
                            height: height, // Set a fixed height
                            width: height, // Set a fixed width
                            fit: BoxFit.cover, // Determine how the image should be displayed
                            placeholder: (context, url) => Image.asset(
                              'assets/images/post_image_placeholder.png',
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: 300,
                            ),
                            fadeInDuration: Duration.zero,
                            errorWidget: (context, url, error) {
                              return const Icon(Icons.photo_rounded);
                            },
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          createPostState.removeImageURL(munroId: munroId, url: imageURL);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.minus_circle,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  );
                }) ??
                [],
            ...createPostState.images[munroId]?.map((image) {
                  int index = createPostState.images[munroId]?.indexOf(image) ?? 0;
                  return Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(image),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          createPostState.removeImage(munroId: munroId, index: index);
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.minus_circle,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  );
                }) ??
                [],
            (createPostState.images[munroId]?.length ?? 0) + (createPostState.imagesURLs[munroId]?.length ?? 0) > 10
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.all(8),
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
                  ),
          ],
        ),
      );
    }
  }
}
