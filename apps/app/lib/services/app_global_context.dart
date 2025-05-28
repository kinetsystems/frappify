import 'package:flutter/material.dart';

class AppGlobalContext {
  static BuildContext? _context;

  static void setContext(BuildContext context) {
    _context = context;
  }

  static BuildContext? get context => _context;

  static bool get hasContext => _context != null;
}
