import 'package:flutter/material.dart';
import 'package:two_eight_two/models/models.dart';

class MunroDescription extends StatelessWidget {
  final Munro munro;
  const MunroDescription({super.key, required this.munro});

  @override
  Widget build(BuildContext context) {
    return Text(
      munro.description,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
    );
  }
}
