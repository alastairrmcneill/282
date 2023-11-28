import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
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
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
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
              items: widget.post.imageURLs
                  .map(
                    (url) => Container(
                      margin: EdgeInsets.zero,
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: url,
                          fit: BoxFit.cover,
                          height: 300,
                          width: MediaQuery.of(context).size.width,
                          progressIndicatorBuilder: (context, url, downloadProgress) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 45),
                            child: LinearProgressIndicator(
                              value: downloadProgress.progress,
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error),
                                  Text(
                                    error.toString(),
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
            widget.post.imageURLs.length < 2
                ? const SizedBox()
                : SizedBox(
                    height: 300,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: AnimatedSmoothIndicator(
                          activeIndex: _selectedIndex,
                          count: widget.post.imageURLs.length,
                          effect: const WormEffect(
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
        ),
      ),
    );
  }
}
