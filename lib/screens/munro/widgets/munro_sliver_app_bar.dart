import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_eight_two/analytics/analytics.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/munro/widgets/widgets.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/saved/widgets/widgets.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroSliverAppBar extends StatefulWidget {
  final Munro munro;
  const MunroSliverAppBar({super.key, required this.munro});

  @override
  State<MunroSliverAppBar> createState() => _MunroSliverAppBarState();
}

class _MunroSliverAppBarState extends State<MunroSliverAppBar> {
  double _collapseRatio = 0.0;

  void _showActionsDialog(BuildContext context, {required Munro munro}) {
    final munroCompletionState = context.read<MunroCompletionState>();

    bool summited = munroCompletionState.munroCompletions.where((mc) => mc.munroId == munro.id).isNotEmpty;

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
            Navigator.of(context).pushNamed(
              MunroSummitsScreen.route,
              arguments: MunroSummitsScreenArgs(munro: munro),
            );
          },
        ),
    ];
    showActionSheet(context, items);
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthState>().currentUserId;

    return SliverAppBar(
      backgroundColor: context.colors.background,
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      leadingWidth: 16 + 40,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: SliverAppBarButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(PhosphorIconsRegular.caretLeft),
        ),
      ),
      actions: [
        SliverAppBarMultiButton(
          buttons: [
            SliverAppBarButtonItem(
              analyticsEvent: AnalyticsEvent.munroSaveButtonClicked,
              onPressed: () async {
                if (userId == null) {
                  Navigator.pushNamed(context, AuthHomeScreen.route);
                } else {
                  await SaveMunroBottomSheet.show(context, munroId: widget.munro.id);
                }
              },
              icon: Icon(PhosphorIconsRegular.bookmarkSimple),
            ),
            SliverAppBarButtonItem(
              analyticsEvent: AnalyticsEvent.munroSharePressed,
              onPressed: () async {
                final link = await context.read<ShareState>().createMunroLink(
                      munroId: widget.munro.id,
                      munroName: widget.munro.name,
                    );

                if (link == null) {
                  showSnackBar(context, 'Failed to share link.');
                  return;
                }

                await SharePlus.instance.share(ShareParams(text: 'Check out ${widget.munro.name} - $link'));
              },
              icon: Icon(PhosphorIconsRegular.shareNetwork),
            ),
            SliverAppBarButtonItem(
              analyticsEvent: AnalyticsEvent.munroMoreOptionsPressed,
              analyticsProperties: {AnalyticsProp.munroId: widget.munro.id.toString()},
              onPressed: () async {
                _showActionsDialog(context, munro: widget.munro);
              },
              icon: Icon(PhosphorIconsBold.dotsThreeVertical),
            ),
          ],
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
            collapseMode: CollapseMode.pin,
            background: Stack(
              fit: StackFit.expand,
              children: [
                MunroHeroImage(munro: widget.munro),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.6, 0.7, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: MunroTitle(munro: widget.munro),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
