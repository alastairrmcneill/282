import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/profile/screens/screens.dart';
import 'package:two_eight_two/widgets/clickable_image.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ProfilePhotosWidget extends StatelessWidget {
  const ProfilePhotosWidget({super.key});
  @override
  Widget build(BuildContext context) {
    ProfileState profileState = Provider.of<ProfileState>(context);

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
                      children: profileState.profilePhotos.take(4).toList().asMap().entries.map((entry) {
                        int index = entry.key;
                        MunroPicture munroPicture = entry.value;
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: (MediaQuery.of(context).size.width - 60) / 4,
                            height: (MediaQuery.of(context).size.width - 60) / 4,
                            child: ClickableImage(
                                image: munroPicture,
                                munroPictures: profileState.profilePhotos,
                                initialIndex: index,
                                fetchMorePhotos: () async {
                                  List<MunroPicture> newPhotos = await profileState.paginateMunroPictures(
                                    profileId: profileState.profile?.id ?? '',
                                  );
                                  return newPhotos;
                                }),
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
