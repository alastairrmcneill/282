import 'dart:io';

import 'package:material_ui/material_ui.dart';

class CustomAppBarBackButton extends StatelessWidget {
  final Function() onPressed;
  const CustomAppBarBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    bool isIOS = Platform.isIOS;
    return IconButton(
      icon: Icon(isIOS ? Icons.arrow_back_ios_rounded : Icons.arrow_back),
      onPressed: onPressed,
    );
  }
}
