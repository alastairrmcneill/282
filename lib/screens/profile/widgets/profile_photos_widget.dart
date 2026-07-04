import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class ProfilePhotosWidget extends StatelessWidget {
  const ProfilePhotosWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PhotoGalleryState<MunroPicture>>(
      builder: (context, state, _) {
        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (state.status == PhotoGalleryStatus.loaded &&
                notification.metrics.pixels >= notification.metrics.maxScrollExtent - 300) {
              state.paginate();
            }
            return false;
          },
          child: CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              ),
              ..._buildSlivers(context, state),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildSlivers(BuildContext context, PhotoGalleryState<MunroPicture> state) {
    switch (state.status) {
      case PhotoGalleryStatus.initial:
      case PhotoGalleryStatus.loading:
        return [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (_, __) => ShimmerBox(width: double.infinity, height: 100, borderRadius: 12),
                childCount: 12,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
            ),
          ),
        ];
      case PhotoGalleryStatus.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(state.error.message)),
          ),
        ];
      default:
        if (state.photos.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyPhotos(),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final munroPicture = state.photos[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ClickableImage(
                      image: munroPicture,
                      munroPictures: state.photos,
                      initialIndex: index,
                      fetchMorePhotos: () async => state.paginate(),
                    ),
                  );
                },
                childCount: state.photos.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
            ),
          ),
          if (state.status == PhotoGalleryStatus.paginating) const SliverToBoxAdapter(child: PaginationLoader()),
          const SliverFillRemaining(hasScrollBody: false, child: SizedBox()),
        ];
    }
  }
}

class _EmptyPhotos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(color: context.colors.border, shape: BoxShape.circle),
            width: 80,
            height: 80,
            child: Icon(PhosphorIconsRegular.camera, size: 35, color: context.colors.textMuted),
          ),
          const SizedBox(height: 10),
          Text('No Photos Yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          Text(
            'Photos from adventures will appear here.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
