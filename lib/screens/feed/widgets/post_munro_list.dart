import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/int_extension.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';
import 'package:two_eight_two/support/theme.dart';

class PostMunroList extends StatelessWidget {
  final Post post;
  const PostMunroList({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    final settingsState = context.read<SettingsState>();
    if (post.includedMunroIds.isEmpty) return const SizedBox();

    List<Munro> includedMunros = post.includedMunroIds
        .map((id) => munroState.munroList.firstWhere((m) => m.id == id, orElse: () => Munro.empty))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: includedMunros
            .map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: InkWell(
                  onTap: () {
                    munroState.setSelectedMunroId = m.id;
                    Navigator.of(context).pushNamed(MunroScreen.route, arguments: MunroScreenArgs(munro: m));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: MyColors.lightGrey,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.map_pin,
                            size: 14,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            m.name,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "(${settingsState.metricHeight ? "${m.meters.thousandsSeparator()}m" : "${m.feet.thousandsSeparator()}ft"})",
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(fontWeight: FontWeight.w400, color: MyColors.mutedText),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
