import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/screens/munro_photo_gallery_screen.dart';
import 'package:two_eight_two/screens/munro/state/munro_detail_state.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/clickable_image.dart';

class MunroPictureGallery extends StatelessWidget {
  const MunroPictureGallery({super.key});
  @override
  Widget build(BuildContext context) {
    MunroDetailState munroDetailState = Provider.of<MunroDetailState>(context);
    MunroState munroState = Provider.of<MunroState>(context);

    return Column(
      children: [
        InkWell(
          onTap: () {
            MunroPictureService.getMunroPictures(context, munroId: munroState.selectedMunro!.id);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MunroPhotoGallery()),
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
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 16,
                )
              ],
            ),
          ),
        ),
        SizedBox(
          height: (MediaQuery.of(context).size.width - 60) / 4,
          child: munroDetailState.munroPictures.isEmpty
              ? const Center(
                  child: Text("No picutres available"),
                )
              : SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    runAlignment: WrapAlignment.start,
                    spacing: 5,
                    children: munroDetailState.munroPictures.take(4).map((MunroPicture munroPicture) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: (MediaQuery.of(context).size.width - 60) / 4,
                          height: (MediaQuery.of(context).size.width - 60) / 4,
                          child: ClickableImage(imageURL: munroPicture.imageUrl),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}
