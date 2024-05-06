import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';

class MunroSliverAppBar extends StatefulWidget {
  const MunroSliverAppBar({super.key});

  @override
  State<MunroSliverAppBar> createState() => _MunroScreenSliverAppBarState();
}

class _MunroScreenSliverAppBarState extends State<MunroSliverAppBar> {
  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    final user = Provider.of<AppUser?>(context, listen: false);
    NavigationState navigationState = Provider.of(context, listen: false);
    SavedListState savedListState = Provider.of<SavedListState>(context, listen: false);
    Munro munro = munroState.selectedMunro!;
    bool munroSaved = savedListState.savedLists.any((list) => list.munroIds.contains(munro.id));

    return SliverAppBar(
      expandedHeight: 255.0,
      floating: false,
      pinned: true,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Calculate the percentage of the AppBar's size as it collapses
          double percentage = (constraints.biggest.height - kToolbarHeight) / (255.0 - kToolbarHeight);
          // Ensure the percentage is between 0 and 1
          percentage = 1 - percentage.clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            title: Opacity(
              opacity: percentage,
              child: Text(
                munroState.selectedMunro?.name ?? "Munro",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            centerTitle: false,
            background: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 249,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: munroState.selectedMunro?.pictureURL ?? "",
                        fit: BoxFit.fitWidth,
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
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 35,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              munroState.selectedMunro?.name ?? "Munro",
                              style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 27),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (user == null) {
                                navigationState.setNavigateToRoute = HomeScreen.route;
                                Navigator.pushNamed(context, AuthHomeScreen.route);
                              } else {
                                showSaveMunroDialog(context);
                              }
                            },
                            child: Icon(munroSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
