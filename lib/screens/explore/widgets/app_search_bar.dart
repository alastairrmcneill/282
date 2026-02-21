import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:two_eight_two/support/theme.dart';

enum SearchBarVariant { hero, standard, compact }

@immutable
class SearchBarSpec {
  final double height;
  final BoxDecoration boxDecoration;
  final EdgeInsets contentPadding;
  final double iconSize;
  final TextStyle textStyle;
  final TextStyle hintStyle;

  const SearchBarSpec({
    required this.height,
    required this.contentPadding,
    required this.iconSize,
    required this.boxDecoration,
    required this.textStyle,
    required this.hintStyle,
  });
}

class AppSearchBarSpecs {
  static SearchBarSpec of(BuildContext context, SearchBarVariant variant) {
    final theme = Theme.of(context);
    switch (variant) {
      case SearchBarVariant.hero:
        return SearchBarSpec(
          height: 44,
          boxDecoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: MyColors.accentColor,
              width: 0.5,
            ),
          ),
          contentPadding: const EdgeInsets.only(left: 20, right: 0, top: 10, bottom: 10),
          iconSize: 18,
          textStyle: theme.textTheme.bodyLarge!,
          hintStyle: theme.textTheme.bodyLarge!.copyWith(color: Colors.grey),
        );
      case SearchBarVariant.standard:
        return SearchBarSpec(
          height: 44,
          boxDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Colors.transparent,
              width: 0,
            ),
            color: Colors.grey[200],
          ),
          contentPadding: const EdgeInsets.only(left: 20, right: 0, top: 10, bottom: 10),
          iconSize: 16,
          textStyle: theme.textTheme.bodyLarge!,
          hintStyle: theme.textTheme.bodyLarge!.copyWith(color: Colors.grey),
        );
      case SearchBarVariant.compact:
        return SearchBarSpec(
          height: 32,
          boxDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.transparent,
              width: 0,
            ),
            color: Colors.grey[200],
          ),
          contentPadding: const EdgeInsets.only(left: 20, right: 0, top: 6, bottom: 6),
          iconSize: 14,
          textStyle: theme.textTheme.bodySmall!,
          hintStyle: theme.textTheme.bodySmall!.copyWith(color: Colors.grey),
        );
    }
  }
}

class AppSearchBar extends StatefulWidget {
  final FocusNode focusNode;
  final VoidCallback? onSearchTap;
  final Function(String)? onChanged;
  final VoidCallback onClear;
  final String hintText;
  final IconData? icon;
  final SearchBarVariant variant;
  const AppSearchBar({
    super.key,
    required this.focusNode,
    this.onSearchTap,
    required this.onClear,
    this.onChanged,
    required this.hintText,
    this.icon,
    this.variant = SearchBarVariant.standard,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = AppSearchBarSpecs.of(context, widget.variant);

    return SizedBox(
      height: spec.height,
      child: DecoratedBox(
        decoration: spec.boxDecoration,
        child: Row(
          children: [
            if (widget.icon != null)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  widget.icon,
                  color: textEditingController.text.isNotEmpty ? MyColors.accentColor : spec.hintStyle.color,
                  size: spec.iconSize,
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsGeometry.only(
                  left: widget.icon != null ? 12 : spec.contentPadding.left,
                  right: spec.contentPadding.right,
                  top: spec.contentPadding.top,
                  bottom: spec.contentPadding.bottom,
                ),
                child: TextField(
                  controller: textEditingController,
                  focusNode: widget.focusNode,
                  autocorrect: false,
                  minLines: 1,
                  maxLines: 1,
                  textAlignVertical: TextAlignVertical.center,
                  style: spec.textStyle,
                  onTap: widget.onSearchTap,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    hintText: widget.hintText,
                    hintStyle: spec.hintStyle,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    setState(() {});
                    widget.onChanged?.call(value);
                  },
                ),
              ),
            ),
            if (textEditingController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    CupertinoIcons.xmark,
                    color: MyColors.accentColor,
                    size: spec.iconSize,
                  ),
                  onPressed: () {
                    setState(() {
                      textEditingController.clear();
                    });
                    widget.onClear();
                    widget.onChanged?.call('');
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
