import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';

class MunroSummaryTile extends StatelessWidget {
  final int? munroId;
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
            Navigator.of(context).pushNamed(MunroScreen.route);
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
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(fontWeight: FontWeight.w800, height: 1.1, fontSize: 16),
                        ),
                        munro.extra == null || munro.extra == ""
                            ? const SizedBox()
                            : Text(
                                "(${munro.extra})",
                                style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 12),
                              ),
                        const SizedBox(height: 4),
                        Text(
                          "${munro.area} · ${settingsState.metricHeight ? "${munro.meters}m" : "${munro.feet}ft"}",
                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 12),
                        ),
                        Row(
                          textBaseline: TextBaseline.alphabetic,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Text(
                              munro.averageRating?.toStringAsFixed(1) ?? "0",
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                  ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              CupertinoIcons.star_fill,
                              size: 12,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '/ ${munro.reviewCount == 1 ? "1 rating" : "${munro.reviewCount ?? 0} ratings"}',
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    fontSize: 10,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w300,
                                  ),
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
                          AnalyticsService.logEvent(
                            name: "Save Munro Button Clicked",
                            parameters: {
                              "source": "Munro Summary Tile",
                              "munro_id": (munroState.selectedMunro?.id ?? 0).toString(),
                              "munro_name": munroState.selectedMunro?.name ?? "",
                              "user_id": user?.uid ?? "",
                            },
                          );
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
                            createPostState.setPostPrivacy = settingsState.defaultPostVisibility;
                            navigationState.setNavigateToRoute = HomeScreen.route;
                            Navigator.of(context).pushNamed(CreatePostScreen.route);
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
