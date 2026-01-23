import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/screens/screens.dart';

class ProfilePhotosWidget extends StatelessWidget {
  const ProfilePhotosWidget({super.key});
  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileState>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(
                ProfilePhotoGallery.route,
                arguments: ProfilePhotoGalleryArgs(
                  userId: profileState.profile?.id ?? '',
                  displayName: profileState.profile?.displayName ?? 'User',
                ),
              );
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.ideographic,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      "Photos",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Icon(
                    CupertinoIcons.forward,
                    size: 16,
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: (MediaQuery.of(context).size.width - 60) / 4,
            child: profileState.profilePhotos.isEmpty
                ? const Center(
                    child: Text("No pictures available"),
                  )
                : SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      runAlignment: WrapAlignment.start,
                      spacing: 5,
                      children: profileState.profilePhotos.take(4).map((profilePhoto) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: (MediaQuery.of(context).size.width - 60) / 4,
                            height: (MediaQuery.of(context).size.width - 60) / 4,
                            child: InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  ProfilePhotoGallery.route,
                                  arguments: ProfilePhotoGalleryArgs(
                                    userId: profileState.profile?.id ?? '',
                                    displayName: profileState.profile?.displayName ?? 'User',
                                  ),
                                );
                              },
                              child: CachedNetworkImage(
                                progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 45),
                                  child: LinearProgressIndicator(
                                    value: downloadProgress.progress,
                                  ),
                                ),
                                imageUrl: profilePhoto.imageUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.error),
                                        Text(
                                          error.toString().contains(
                                                  'ClientException with SocketException: Connection reset by peer')
                                              ? "Error loading image. Please check your internet connection and try again."
                                              : error.toString(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
