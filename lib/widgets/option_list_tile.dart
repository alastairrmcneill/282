import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class OptionListTile<T> extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final T value;
  final T groupValue;
  final Function(T) onChanged;
  const OptionListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = value == groupValue;

    return ListTile(
      title: Text(title),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.colors.textMuted),
            )
          : null,
      leading: Icon(
        Icons.circle,
        size: 12,
        color: isSelected ? context.colors.accent : Colors.transparent,
      ),
      trailing: trailing,
      onTap: () => onChanged(value),
    );
  }
}
