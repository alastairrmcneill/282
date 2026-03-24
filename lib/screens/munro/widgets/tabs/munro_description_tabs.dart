import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class MunroDescriptionTabs extends StatelessWidget {
  final Munro munro;
  const MunroDescriptionTabs({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    return Text(
      munro.description,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300, height: 1.6),
    );
  }
}
