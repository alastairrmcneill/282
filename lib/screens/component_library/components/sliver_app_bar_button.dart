import 'package:flutter/material.dart';
import 'package:two_eight_two/screens/component_library/components/sliver_app_bar_multi_button.dart';

class SliverAppBarButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon icon;
  final EdgeInsets padding;
  final String? analyticsEvent;
  final Map<String, dynamic>? analyticsProperties;

  const SliverAppBarButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
    this.analyticsEvent,
    this.analyticsProperties,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBarMultiButton(
      padding: padding,
      buttons: [
        SliverAppBarButtonItem(
          icon: icon,
          onPressed: onPressed,
          analyticsEvent: analyticsEvent,
          analyticsProperties: analyticsProperties,
        ),
      ],
    );
  }
}
