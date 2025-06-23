import 'package:flutter/material.dart';

class ColorPair {
  final Color light;
  final Color dark;

  const ColorPair({
    required this.light,
    required this.dark,
  });

  Color get({required BuildContext context, required ThemeMode themeMode}) {
    final isSystemDark = Theme.of(context).brightness == Brightness.dark;

    return themeMode == ThemeMode.dark
        ? dark
        : isSystemDark
        ? dark
        : light;
  }
}
