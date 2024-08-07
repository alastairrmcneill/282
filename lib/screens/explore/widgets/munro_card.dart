import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';

import '../../../models/models.dart';
import '../../../services/services.dart';
import '../../saved/widgets/widgets.dart';
import '../../screens.dart';

class MunroCard extends StatelessWidget {
  final Munro munro;
  const MunroCard({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);
    NavigationState navigationState = Provider.of(context);
    MunroState munroState = Provider.of<MunroState>(context);
    SettingsState settingsState = Provider.of<SettingsState>(context);
    SavedListState savedListState = Provider.of<SavedListState>(context);

    bool munroSaved = savedListState.savedLists.any((list) => list.munroIds.contains(munro.id));

    double width = MediaQuery.of(context).size.width - 60;
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15, top: 15),
      child: GestureDetector(
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
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(12),
              ),
              child: SizedBox(
                width: width,
                height: width,
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: munro.pictureURL,
                      width: width,
                      height: width,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Image.asset(
                        'assets/images/post_image_placeholder.png',
                        fit: BoxFit.cover,
                        width: width,
                        height: width,
                      ),
                      fadeInDuration: Duration.zero,
                      errorWidget: (context, url, error) {
                        return const Icon(Icons.error);
                      },
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white, // Background color
                              shape: const CircleBorder(), // Circular shape
                              elevation: 3, // Drop shadow
                              padding: const EdgeInsets.all(2), // Adjust padding to make it circular
                            ),
                            onPressed: () async {
                              if (user == null) {
                                navigationState.setNavigateToRoute = HomeScreen.route;
                                Navigator.pushNamed(context, AuthHomeScreen.route);
                              } else {
                                munroState.setSelectedMunro = munro;
                                showSaveMunroDialog(context);
                              }
                            },
                            child: Icon(
                              munroSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                              color: MyColors.accentColor,
                              size: 20,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
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
                    ],
                  ),
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
                    const SizedBox(width: 2),
                    const Icon(
                      CupertinoIcons.star_fill,
                      size: 12,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '(${munro.reviewCount ?? 0})',
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
          ],
        ),
      ),
    );
  }
}
