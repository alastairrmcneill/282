import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class MunroSummaryTile extends StatelessWidget {
  final String? munroId;
  const MunroSummaryTile({super.key, required this.munroId});

  @override
  Widget build(BuildContext context) {
    if (munroId == null) {
      return const SizedBox();
    }
    final user = Provider.of<AppUser?>(context);
    NavigationState navigationState = Provider.of(context);
    MunroState munroState = Provider.of<MunroState>(context);
    Munro munro = munroState.munroList.where((m) => m.id == munroId!).first;
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    SettingsState settingsState = Provider.of<SettingsState>(context);
    SavedListState savedListState = Provider.of<SavedListState>(context);

    bool munroSaved = savedListState.savedLists.any((list) => list.munroIds.contains(munro.id));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: InkWell(
          onTap: () {
            munroState.setSelectedMunro = munro;
            MunroPictureService.getMunroPictures(context, munroId: munro.id, count: 4);
            ReviewService.getMunroReviews(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MunroScreen(),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: munro.pictureURL,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/post_image_placeholder.png',
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                    ),
                    fadeInDuration: Duration.zero,
                    errorWidget: (context, url, error) {
                      return const Icon(Icons.error);
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          munro.name,
                          maxLines: 2,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        munro.extra == null || munro.extra == ""
                            ? const SizedBox()
                            : Text(
                                "(${munro.extra})",
                                style: TextStyle(fontWeight: FontWeight.w200, fontSize: 14),
                              ),
                        const SizedBox(height: 3),
                        Text(
                          settingsState.metricHeight
                              ? "${munro.meters}m - ${munro.area}"
                              : "${munro.feet}ft - ${munro.area}",
                          style: TextStyle(fontSize: 12),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            RatingBar(
                              itemSize: 15,
                              ratingWidget: RatingWidget(
                                full: const Icon(Icons.star, color: Colors.amber),
                                half: const Icon(Icons.star_half, color: Colors.amber),
                                empty: const Icon(Icons.star_border, color: Colors.amber),
                              ),
                              onRatingUpdate: (rating) {},
                              initialRating: munro.averageRating ?? 0.0,
                              allowHalfRating: true,
                              ignoreGestures: true,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "(${munro.reviewCount ?? 0})",
                              style: const TextStyle(fontSize: 8),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () async {
                          if (user == null) {
                            navigationState.setNavigateToRoute = HomeScreen.route;
                            Navigator.pushNamed(context, AuthHomeScreen.route);
                          } else {
                            munroState.setSelectedMunro = munro;
                            showSaveMunroDialog(context);
                          }
                        },
                        child: Icon(munroSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () {
                          if (user == null) {
                            navigationState.setNavigateToRoute = HomeScreen.route;
                            Navigator.pushNamed(context, AuthHomeScreen.route);
                          } else {
                            if (munro.summited) return;
                            munroState.setSelectedMunro = munro;
                            createPostState.reset();
                            createPostState.addMunro(munro);
                            navigationState.setNavigateToRoute = HomeScreen.route;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CreatePostScreen(),
                              ),
                            );
                          }
                        },
                        child: Icon(munro.summited ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
