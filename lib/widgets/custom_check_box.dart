import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:two_eight_two/support/theme.dart';

class CustomCheckbox extends StatelessWidget {
  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 18,
    this.targetSize = 48,
    this.activeFillColor = MyColors.accentColor,
    this.inactiveFillColor = const Color.fromRGBO(245, 245, 245, 1.0),
    this.activeBorderColor = MyColors.accentColor,
    this.inactiveBorderColor = const Color.fromRGBO(224, 224, 224, 1.0),
    this.checkColor = Colors.white,
    this.borderRadius = 4,
    this.borderWidth = 0.8,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;
  final double targetSize;
  final Color activeFillColor;
  final Color inactiveFillColor;
  final Color activeBorderColor;
  final Color inactiveBorderColor;
  final Color checkColor;
  final double borderRadius;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => onChanged(!value),
      highlightShape: BoxShape.circle,
      highlightColor: Colors.transparent,
      containedInkWell: false, // allow splash outside child
      radius: targetSize / 2, // controls splash extent
      child: SizedBox(
        width: targetSize, // hit target size
        height: targetSize, // hit target size
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: value ? activeBorderColor : inactiveBorderColor,
                width: borderWidth,
              ),
              color: value ? activeFillColor : inactiveFillColor,
            ),
            child: value
                ? Icon(
                    PhosphorIconsBold.check,
                    size: size - 4,
                    color: checkColor,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
