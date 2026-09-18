import 'package:material_ui/material_ui.dart';

import 'package:two_eight_two/widgets/widgets.dart';

/// Standard bottom sheet frame: drag handle, height cap, side padding,
/// min-size column. Use instead of repeating the
/// ConstrainedBox/Padding/Column/SheetDragHandle boilerplate per sheet.
class AppBottomSheet extends StatelessWidget {
  final List<Widget> children;
  final double maxHeightFactor;
  final EdgeInsetsGeometry padding;
  final bool scrollable;
  final bool isDismissible;

  const AppBottomSheet({
    super.key,
    required this.children,
    this.maxHeightFactor = 0.9,
    this.padding = const EdgeInsets.symmetric(horizontal: 15),
    this.scrollable = false,
    this.isDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final column = Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetDragHandle(),
          ...children,
        ],
      ),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
      ),
      child: scrollable ? SingleChildScrollView(child: column) : column,
    );
  }
}

/// Shows [builder] as a modal bottom sheet with the app's standard
/// scroll-controlled config (shape/background come from [BottomSheetThemeData]).
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    builder: builder,
  );
}
