import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:provider/provider.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';
import 'package:two_eight_two/screens/notifiers.dart';
import 'package:two_eight_two/screens/screens.dart';

class PostMunroList extends StatelessWidget {
  final Post post;
  const PostMunroList({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final munroState = context.read<MunroState>();
    if (post.includedMunroIds.isEmpty) return const SizedBox();

    List<Munro> includedMunros = post.includedMunroIds
        .map((id) => munroState.munroList.firstWhere((m) => m.id == id, orElse: () => Munro.empty))
        .toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: includedMunros
            .map(
              (m) => InkWell(
                onTap: () {
                  munroState.setSelectedMunroId = m.id;
                  Navigator.of(context).pushNamed(MunroScreen.route, arguments: MunroScreenArgs(munro: m));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: context.colors.border,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          LucideIcons.map_pin,
                          size: 14,
                          color: context.colors.textPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          m.name,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ],
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
