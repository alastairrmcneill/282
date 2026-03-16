import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroSliverAppBar extends StatefulWidget {
  const MunroSliverAppBar({super.key});

  @override
  State<MunroSliverAppBar> createState() => _MunroSliverAppBarState();
}

class _MunroSliverAppBarState extends State<MunroSliverAppBar> {
  double _collapseRatio = 0.0;

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void _showActionsDialog(BuildContext context) {
    final munroCompletionState = context.read<MunroCompletionState>();
    final munroState = context.read<MunroDetailState>();

    bool summited =
        munroCompletionState.munroCompletions.where((mc) => mc.munroId == munroState.selectedMunro!.id).isNotEmpty;

    final items = [
      ActionMenuItems(
        title: "Send Feedback",
        onPressed: () async {
          try {
            await launchUrl(
              Uri.parse('mailto:alastair.r.mcneill@gmail.com?subject=282%20Feedback'),
            );
          } on Exception catch (error, stackTrace) {
            context.read<Logger>().error(error.toString(), stackTrace: stackTrace);
            Clipboard.setData(ClipboardData(text: "alastair.r.mcneill@gmail.com"));
            showSnackBar(context, 'Copied email address. Go to email app to send.');
          }
        },
      ),
      if (summited)
        ActionMenuItems(
          title: "Unbag Munro",
          isDestructive: true,
          onPressed: () async {
            if (munroState.selectedMunro != null) {
              Navigator.of(context).pushNamed(
                MunroSummitsScreen.route,
                arguments: MunroSummitsScreenArgs(munro: munroState.selectedMunro!),
              );
            }
          },
        ),
    ];
    showActionSheet(context, items);
  }

  Widget _buildSliverBarButton(IconData icon, Future<void> Function() onTap) {
    final t = ((_collapseRatio - 0.8) / 0.2).clamp(0.0, 1.0);
    final bgColor = Color.lerp(
      Colors.black.withValues(alpha: 0.4),
      Colors.transparent,
      t,
    );
    final iconColor = Color.lerp(Colors.white, Colors.black, t);

    return InkWell(
      onTap: () => onTap(),
      child: Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 22,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthState>().currentUserId;
    final munroState = context.read<MunroDetailState>();
    Munro munro = munroState.selectedMunro!;

    return SliverAppBar(
      backgroundColor: MyColors.backgroundColor,
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: _buildSliverBarButton(
            Icons.arrow_back,
            () async {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      actions: [
        _buildSliverBarButton(
          PhosphorIconsRegular.bookmarkSimple,
          () async {
            context.read<Analytics>().track(AnalyticsEvent.saveMunroButtonClicked, props: {
              AnalyticsProp.source: "Munro Tile",
              AnalyticsProp.munroId: (munro.id).toString(),
              AnalyticsProp.munroName: munro.name,
            });

            if (userId == null) {
              Navigator.pushNamed(context, AuthHomeScreen.route);
            } else {
              await SaveMunroBottomSheet.show(context);
            }
          },
        ),
        const SizedBox(width: 6),
        _buildSliverBarButton(
          PhosphorIconsRegular.shareNetwork,
          () async {
            final link = await context.read<ShareState>().createMunroLink(
                  munroId: munro.id,
                  munroName: munro.name,
                );

            if (link == null) {
              showSnackBar(context, 'Failed to share link.');
              return;
            }

            await SharePlus.instance.share(ShareParams(text: 'Check out ${munro.name} - $link'));
          },
        ),
        const SizedBox(width: 6),
        _buildSliverBarButton(
          PhosphorIconsBold.dotsThreeVertical,
          () async {
            _showActionsDialog(context);
          },
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final topPadding = MediaQuery.of(context).padding.top;
          final collapsedHeight = kToolbarHeight + topPadding;
          final expandedHeight = 300.0 + topPadding;
          final ratio =
              ((expandedHeight - constraints.biggest.height) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);
          if (ratio != _collapseRatio) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _collapseRatio = ratio);
            });
          }
          return FlexibleSpaceBar(
            background: _isValidUrl(munro.pictureURL)
                ? CachedNetworkImage(
                    imageUrl: munro.pictureURL,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Image.asset(
                      'assets/images/post_image_placeholder.png',
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: 300,
                    ),
                    fadeInDuration: Duration.zero,
                    errorWidget: (context, url, error) {
                      return Image.asset(
                        'assets/images/post_image_placeholder.png',
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                        height: 300,
                      );
                    },
                  )
                : Image.asset(
                    'assets/images/post_image_placeholder.png',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                  ),
          );
        },
      ),
    );
  }
}
