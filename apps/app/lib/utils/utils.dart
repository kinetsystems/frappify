import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

String getInitials(String input) {
  var words = input.split(RegExp(r'[\s-]+')).map((word) {
    return word.replaceAll(RegExp(r'[^\w]'), '');
  }).toList();

  words = words.take(2).toList();

  return words
      .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
      .join();
}

String mapThemeModeToString(ThemeMode? themeMode) {
  switch (themeMode) {
    case ThemeMode.light:
      return 'Light';
    case ThemeMode.dark:
      return 'Dark';
    case ThemeMode.system:
      return 'System';
    case null:
      return 'System';
  }
}

IconData mapThemeModeToIcon(ThemeMode? themeMode) {
  switch (themeMode) {
    case ThemeMode.light:
      return Icons.light_mode;
    case ThemeMode.dark:
      return Icons.dark_mode;
    case ThemeMode.system:
      return Icons.settings;
    case null:
      return Icons.settings;
  }
}

ThemeMode mapStringToThemeMode(String? theme) {
  final themeMap = {
    'Light': ThemeMode.light,
    'Dark': ThemeMode.dark,
    'System': ThemeMode.system,
  };

  return themeMap[theme] ?? ThemeMode.system;
}

String mapLocaleToLanguage(Locale? locale) {
  const languageMap = {
    'ar': 'العربية',
    'en': 'English',
  };

  return locale != null
      ? languageMap[locale.languageCode] ?? 'English'
      : 'English';
}

Locale mapLanguageToLocale(String? language) {
  const localeMap = {
    'العربية': Locale('ar'),
    'English': Locale('en'),
  };

  return localeMap[language] ?? const Locale('en');
}

Locale mapCodeToLocale(String? language) {
  const localeMap = {
    'ar': Locale('ar'),
    'en': Locale('en'),
  };

  return localeMap[language] ?? const Locale('en');
}

String formatDuration(int seconds) {
  if (seconds < 60) {
    return '$seconds sec';
  } else if (seconds < 3600) {
    final minutes = seconds ~/ 60;
    return '$minutes min';
  } else if (seconds < 86400) {
    final hours = seconds ~/ 3600;
    return "$hours hour${hours > 1 ? 's' : ''}";
  } else {
    final days = seconds ~/ 86400;
    return "$days day${days > 1 ? 's' : ''}";
  }
}

class MouseScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.unknown,
    PointerDeviceKind.stylus,
  };
}
