import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
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
                }) ??
                [],
            ...createPostState.images[munroId]?.map((image) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(image),
                    ),
                  );
                }) ??
                [],
            (createPostState.images[munroId]?.length ?? 0) + (createPostState.imagesURLs[munroId]?.length ?? 0) > 10
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
