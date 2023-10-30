import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/home/explore/screens/screens.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:two_eight_two/general/services/munro_service.dart';

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
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context);
    Munro munro = munroNotifier.munroList.where((m) => m.id == munroId!).first;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: InkWell(
          onTap: () {
            munroNotifier.setSelectedMunro = munro;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const MunroDetailScreen(),
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
                  // child: Container(
                  //   width: 100,
                  //   height: 100,
                  //   color: Colors.grey,
                  // ),
                  // child: Image.network(
                  //   munro.pictureURL,
                  //   width: 100,
                  //   height: 100,
                  //   fit: BoxFit.cover,
                  //   errorBuilder:
                  //       (BuildContext context, Object exception, StackTrace? stackTrace) {
                  //     // Appropriate error handling code here
                  //     print("Error: ${exception.toString()}");
                  //     return Text('Error');
                  //   },
                  // ),
                  child: CachedNetworkImage(
                    imageUrl: munro.pictureURL,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 45),
                      child: LinearProgressIndicator(
                        value: downloadProgress.progress,
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      print('-------------------------------');
                      print(error.toString());
                      print('-------------------------------');
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
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        munro.extra == null || munro.extra == ""
                            ? const SizedBox()
                            : Text(
                                "(${munro.extra})",
                                style:
                                    TextStyle(fontWeight: FontWeight.w200, fontSize: 14),
                              ),
                        const SizedBox(height: 3),
                        Text(
                          "${munro.meters}m - ${munro.area}",
                          style: TextStyle(fontSize: 12),
                        )
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
                            navigationState.setNavigateToRoute = "/home_screen";
                            Navigator.pushNamed(context, "/auth_home_screen");
                          } else {
                            await MunroService.toggleMunroSaved(context, munro: munro);
                          }
                        },
                        child: Icon(munro.saved
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: InkWell(
                        onTap: () {
                          if (user == null) {
                            navigationState.setNavigateToRoute = "/home_screen";
                            Navigator.pushNamed(context, "/auth_home_screen");
                          } else {
                            if (munro.summited) return;
                            munroNotifier.setSelectedMunro = munro;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MunroSummitedPostScreen(munro: munro),
                              ),
                            );
                          }
                        },
                        child: Icon(munro.summited
                            ? Icons.check_circle_rounded
                            : Icons.check_circle_outline_rounded),
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
