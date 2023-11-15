import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/features/auth/screens/screens.dart';
import 'package:two_eight_two/features/home/explore/screens/screens.dart';
import 'package:two_eight_two/general/models/models.dart';
import 'package:two_eight_two/general/models/munro.dart';
import 'package:two_eight_two/general/notifiers/notifiers.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroDetailScreen extends StatelessWidget {
  const MunroDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    MunroNotifier munroNotifier = Provider.of<MunroNotifier>(context);
    NavigationState navigationState = Provider.of<NavigationState>(context);
    CreatePostState createPostState = Provider.of<CreatePostState>(context);
    final user = Provider.of<AppUser?>(context);

    Munro munro = munroNotifier.selectedMunro!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
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
                    child: Text(munro.name),
                  ),
                  centerTitle: false,
                  background: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: Image.network(
                            munro.pictureURL,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 35,
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              munro.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  munro.extra == null || munro.extra == ""
                      ? const SizedBox()
                      : SizedBox(width: double.infinity, child: Text("(${munro.extra})")),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Height',
                            style: TextStyle(
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          Text(
                            "${munro.meters}m",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Area',
                            style: TextStyle(
                              fontWeight: FontWeight.w200,
                            ),
                          ),
                          Text(
                            munro.area,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: TextSpan(
                      text: "${munro.description} ",
                      style: const TextStyle(color: Colors.black, fontFamily: "NotoSans"),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Read more.',
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launchUrl(
                                Uri.parse(munro.link),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  munro.summited
                      ? Text("Summited: ${DateFormat('dd/MM/yyyy').format(munro.summitedDate ?? DateTime.now())}")
                      : SizedBox(
                          height: 44,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (user == null) {
                                navigationState.setNavigateToRoute = "/home_screen";
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthHomeScreen()));
                              } else {
                                createPostState.reset();
                                createPostState.addMunro(munro);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => MunroSummitedPostScreen(),
                                  ),
                                );
                              }
                            },
                            child: const Text("Mark as summited"),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
