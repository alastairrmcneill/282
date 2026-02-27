import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroSummaryTile extends StatelessWidget {
  final int? munroId;
  const MunroSummaryTile({super.key, required this.munroId});

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (munroId == null) {
      return const SizedBox();
    }
    final userId = context.read<AuthState>().currentUserId;
    final munroState = context.watch<MunroState>();
    Munro munro = munroState.munroList.where((m) => m.id == munroId!).first;
    final createPostState = context.watch<CreatePostState>();
    final settingsState = context.watch<SettingsState>();
    final savedListState = context.watch<SavedListState>();
    final munroCompletionState = context.watch<MunroCompletionState>();

    bool munroSaved = savedListState.savedLists.any((list) => list.munroIds.contains(munro.id));
    bool munroSummited = munroCompletionState.munroCompletions.any((mc) => mc.munroId == munro.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(MunroScreen.route, arguments: MunroScreenArgs(munro: munro));
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
                  child: _isValidUrl(munro.pictureURL)
                      ? CachedNetworkImage(
                          imageUrl: munro.pictureURL,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Image.asset(
                            'assets/images/post_image_placeholder.png',
                            fit: BoxFit.cover,
                            width: 100,
                            height: 100,
                          ),
                          fadeInDuration: Duration.zero,
                          errorWidget: (context, url, error) {
                            return Image.asset(
                              'assets/images/post_image_placeholder.png',
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                            );
                          },
                        )
                      : Image.asset(
                          'assets/images/post_image_placeholder.png',
                          fit: BoxFit.cover,
                          width: 100,
                          height: 100,
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
                          context.read<Analytics>().track(AnalyticsEvent.saveMunroButtonClicked, props: {
                            AnalyticsProp.source: "Munro Summary Tile",
                            AnalyticsProp.munroId: (munro.id).toString(),
                          });
                          if (userId == null) {
                            Navigator.pushNamed(context, AuthHomeScreen.route);
                          } else {
                            munroState.setSelectedMunroId = munro.id;
                            await SaveMunroBottomSheet.show(context);
                          }
                        },
                        child: Icon(munroSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () {
                          if (userId == null) {
                            Navigator.pushNamed(context, AuthHomeScreen.route);
                          } else {
                            if (munroSummited) return;
                            munroState.setSelectedMunroId = munro.id; // TODO is this needed
                            createPostState.reset();
                            createPostState.addMunro(munro.id);
                            createPostState.setPostPrivacy = settingsState.defaultPostVisibility;
                            Navigator.of(context).pushNamed(CreatePostScreen.route);
                          }
                        },
                        child: Icon(munroSummited ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded),
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
