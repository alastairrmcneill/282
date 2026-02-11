import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/feed/widgets/munro_image_overlay.dart';
import 'package:two_eight_two/screens/notifiers.dart';

class PostImagesCarousel extends StatefulWidget {
  final Post post;
  const PostImagesCarousel({super.key, required this.post});

  @override
  State<PostImagesCarousel> createState() => _PostImagesCarouselState();
}

class _PostImagesCarouselState extends State<PostImagesCarousel> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();

    Map<String, int> imageUrlToMunroId = {
      for (var entry in widget.post.imageUrlsMap.entries)
        for (var url in entry.value) url: entry.key
    };
    if (imageUrlToMunroId.isEmpty) return const SizedBox();

    Munro shownMunro = munroState.munroList
        .firstWhere((m) => m.id == imageUrlToMunroId[imageUrlToMunroId.keys.elementAt(_selectedIndex)]!);

    return Stack(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            scrollPhysics: const ClampingScrollPhysics(),
            autoPlay: false,
            enlargeCenterPage: false,
            animateToClosest: true,
            enableInfiniteScroll: false,
            viewportFraction: 1,
            height: 300,
            onPageChanged: (index, reason) => setState(() => _selectedIndex = index),
          ),
          items: imageUrlToMunroId.keys
              .map(
                (url) => Container(
                  margin: EdgeInsets.zero,
                  child: Center(
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      placeholder: (context, url) => Image.asset(
                        'assets/images/post_image_placeholder.png',
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                      ),
                      fadeInDuration: Duration.zero,
                      errorWidget: (context, url, error) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error),
                              Text(
                                error
                                        .toString()
                                        .contains('ClientException with SocketException: Connection reset by peer')
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
              )
              .toList(),
        ),
        imageUrlToMunroId.length < 2
            ? const SizedBox()
            : SizedBox(
                height: 300,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: AnimatedSmoothIndicator(
                      activeIndex: _selectedIndex,
                      count: imageUrlToMunroId.length,
                      effect: const ExpandingDotsEffect(
                        dotWidth: 8,
                        dotHeight: 8,
                        activeDotColor: Colors.white,
                        dotColor: Color.fromARGB(255, 154, 171, 147),
                      ),
                    ),
                  ),
                ),
              ),
        Positioned(
          bottom: 10,
          left: 10,
          child: MunroImageOverlay(munro: shownMunro),
        ),
      ],
    );
  }
}
