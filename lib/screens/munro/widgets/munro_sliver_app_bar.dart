import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/logging/logging.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroSliverAppBar extends StatelessWidget {
  const MunroSliverAppBar({super.key});

  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Widget _buildPopupMenu(
    BuildContext context,
    UserState userState,
    MunroState munroState,
    MunroCompletionState munroCompletionState,
  ) {
    List<MenuItem> menuItems = [];
    bool summited =
        munroCompletionState.munroCompletions.where((mc) => mc.munroId == munroState.selectedMunro!.id).isNotEmpty;

    if (userState.currentUser != null) {
      if (summited) {
        menuItems.add(
          MenuItem(
            text: 'Unbag Munro',
            onTap: () {
              if (munroState.selectedMunro != null) {
                Navigator.of(context).pushNamed(MunroSummitsScreen.route);
              }
            },
          ),
        );
      }
    }

    menuItems.add(
      MenuItem(
        text: "Share",
        onTap: () async {
          final link = await context.read<ShareMunroState>().createShareLink(
                munroId: munroState.selectedMunro?.id ?? 0,
                munroName: munroState.selectedMunro?.name ?? "",
              );

          if (link == null) {
            showSnackBar(context, 'Failed to share link.');
            return;
          }

          await SharePlus.instance
              .share(ShareParams(text: 'Check out ${munroState.selectedMunro?.name ?? "this munro"} - $link'));
        },
      ),
    );

    menuItems.add(
      MenuItem(
        text: "Send Feedback",
        onTap: () async {
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
    );

    return PopupMenuBase(items: menuItems);
  }

  @override
  Widget build(BuildContext context) {
    final munroCompletionState = context.watch<MunroCompletionState>();
    final munroState = context.read<MunroState>();
    final userState = context.watch<UserState>();
    Munro munro = munroState.selectedMunro!;

    return SliverAppBar(
      backgroundColor: MyColors.backgroundColor,
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      actions: [
        _buildPopupMenu(context, userState, munroState, munroCompletionState),
      ],
      flexibleSpace: FlexibleSpaceBar(
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
      ),
    );
  }
}
