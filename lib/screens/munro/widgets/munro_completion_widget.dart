import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/enums/enums.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/widgets/widgets.dart';

class MunroCompletionWidget extends StatelessWidget {
  final int index;
  final DateTime dateTime;
  const MunroCompletionWidget({super.key, required this.index, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    MunroState munroState = Provider.of<MunroState>(context, listen: false);
    Munro munro = munroState.selectedMunro!;
    List<MenuItem> menuItems = [
      MenuItem(
        text: 'Remove',
        onTap: () {
          MunroService.removeMunroCompletion(
            context,
            munro: munroState.selectedMunro!,
            dateTime: dateTime,
          );
        },
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: CachedNetworkImage(
                  imageUrl: munro.pictureURL,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Image.asset(
                    'assets/images/post_image_placeholder.png',
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    height: 300,
                  ),
                  fadeInDuration: Duration.zero,
                  errorWidget: (context, url, error) {
                    return const Icon(Icons.error);
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        munro.name,
                        maxLines: 2,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.w800, height: 1.1, fontSize: 16),
                      ),
                      munro.extra == null || munro.extra == ""
                          ? const SizedBox()
                          : Text(
                              "(${munro.extra})",
                              style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 12),
                            ),
                      const SizedBox(height: 10),
                      Text(
                        'Summit #${index + 1} - ${DateFormat("dd/MM/yyyy").format(dateTime)}',
                        style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuBase(items: menuItems),
            ],
          ),
        ),
      ),
    );
  }
}
