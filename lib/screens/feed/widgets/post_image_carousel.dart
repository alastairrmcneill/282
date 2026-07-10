import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';

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
    final List<String> imageUrls = widget.post.imageUrlsMap.values.expand((urls) => urls).toList();
    if (imageUrls.isEmpty) return const SizedBox();

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
          items: imageUrls
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
                        context.read<Logger>().error(
                              'Failed to load photo',
                              error: error,
                              context: {'imageUrl': url},
                            );
                        return Center(
                          child: Icon(
                            PhosphorIconsRegular.warning,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        if (imageUrls.length > 1)
          SizedBox(
            height: 300,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: AnimatedSmoothIndicator(
                  activeIndex: _selectedIndex,
                  count: imageUrls.length,
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
      ],
    );
  }
}
