import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'main.dart' as original_main;

// This file is the default main entry-point for go-flutter application.
void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  original_main.main();
}
