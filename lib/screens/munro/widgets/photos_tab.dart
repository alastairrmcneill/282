import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class PhotosTab extends StatefulWidget {
  final ScrollController scrollController;
  const PhotosTab({super.key, required this.scrollController});

  @override
  State<PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends State<PhotosTab> {
  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<PhotoGalleryState<MunroPicture>>();
    if (widget.scrollController.position.pixels >= widget.scrollController.position.maxScrollExtent - 300 &&
        state.status == PhotoGalleryStatus.loaded) {
      state.paginate();
    }
  }

  Widget _buildLoadingScreen() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: 12,
          itemBuilder: (context, index) => ShimmerBox(width: double.infinity, height: 100, borderRadius: 12),
        ),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _buildErrorScreen(String message) {
    return SizedBox(height: 200, child: Center(child: Text(message)));
  }

  Widget _buildEmptyScreen() {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: MyColors.lightGrey,
              shape: BoxShape.circle,
            ),
            width: 80,
            height: 80,
            child: Icon(
              PhosphorIconsRegular.camera,
              size: 35,
              color: MyColors.mutedText,
            ),
          ),
          const SizedBox(height: 10),
          Text('No Photos Yet', style: textTheme.titleLarge),
          const SizedBox(height: 20),
          Text(
            'Photos from your adventures and the community will appear here. Be the first to share a snap!',
            style: textTheme.bodyMedium?.copyWith(color: MyColors.mutedText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(BuildContext context, PhotoGalleryState<MunroPicture> state) {
    if (state.photos.isEmpty) {
      return _buildEmptyScreen();
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: state.photos.length,
          itemBuilder: (context, index) {
            MunroPicture munroPicture = state.photos[index];
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ClickableImage(
                image: munroPicture,
                munroPictures: state.photos,
                initialIndex: index,
                fetchMorePhotos: () async {
                  return await state.paginate();
                },
              ),
            );
          },
        ),
        if (state.status == PhotoGalleryStatus.paginating)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: CircularProgressIndicator(),
          ),
        const SizedBox(height: 110),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoGalleryState<MunroPicture>>(
      builder: (context, state, child) {
        switch (state.status) {
          case PhotoGalleryStatus.error:
            return _buildErrorScreen(state.error.message);
          case PhotoGalleryStatus.loading:
            return _buildLoadingScreen();
          default:
            return _buildScreen(context, state);
        }
      },
    );
  }
}
