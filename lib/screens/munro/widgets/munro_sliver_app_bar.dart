import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class MunroSliverAppBar extends StatelessWidget {
  const MunroSliverAppBar({super.key});

  Widget _buildPopupMenu(BuildContext context, UserState userState, MunroState munroState) {
    List<MenuItem> menuItems = [];

    if (userState.currentUser != null) {
      if (munroState.selectedMunro?.summitedDates?.isNotEmpty ?? false) {
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
          await DeepLinkService.shareMunro(
            context,
            munroState.selectedMunro?.name ?? "",
            munroState.selectedMunro?.id ?? "",
          );
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
            Log.error(error.toString(), stackTrace: stackTrace);
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
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    UserState userState = Provider.of<UserState>(context);
    Munro munro = munroState.selectedMunro!;

    return SliverAppBar(
      backgroundColor: MyColors.backgroundColor,
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      actions: [
        _buildPopupMenu(context, userState, munroState),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: CachedNetworkImage(
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
            return const Icon(Icons.photo_rounded);
          },
        ),
      ),
    );
  }
}
