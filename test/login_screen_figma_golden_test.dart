import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sample_ui_test_app/login_screen.dart';

/// Golden test comparing LoginScreen implementation against Figma design.
///
/// The Figma design image is stored at: test/goldens/figma/login_screen.png
/// (copied from scripts/figma/images/selection.png)
///
/// To update goldens after UI changes:
/// ```bash
/// flutter test --update-goldens test/login_screen_figma_golden_test.dart
/// ```
void main() {
  setUpAll(() async {
    // Load Material Icons font for proper icon rendering
    final materialIcons = File(
      '${_flutterRoot()}/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (materialIcons.existsSync()) {
      final bytes = materialIcons.readAsBytesSync();
      final fontLoader = FontLoader('MaterialIcons');
      fontLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
      await fontLoader.load();
    }

    // Load Roboto font for proper text rendering
    final robotoRegular = File(
      '${_flutterRoot()}/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
    );
    final robotoBold = File(
      '${_flutterRoot()}/bin/cache/artifacts/material_fonts/Roboto-Bold.ttf',
    );

    if (robotoRegular.existsSync()) {
      final fontLoader = FontLoader('Roboto');
      fontLoader.addFont(
        Future.value(ByteData.view(robotoRegular.readAsBytesSync().buffer)),
      );
      if (robotoBold.existsSync()) {
        fontLoader.addFont(
          Future.value(ByteData.view(robotoBold.readAsBytesSync().buffer)),
        );
      }
      await fontLoader.load();
    }
  });

  group('LoginScreen Figma Golden Tests', () {
    testWidgets('LoginScreen matches Figma design', (tester) async {
      // Set screen size to match Figma design image (786 x 1704 pixels)
      // Using devicePixelRatio 2.0 for retina-like rendering
      tester.view.physicalSize = const Size(786, 1704);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Compare against Figma design
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/figma/login_screen.png'),
      );
    });

    testWidgets('LoginScreen generates new golden for comparison',
        (tester) async {
      // Set screen size to match Figma design image (786 x 1704 pixels)
      tester.view.physicalSize = const Size(786, 1704);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
          ),
          home: const LoginScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Generate actual UI golden for side-by-side comparison
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/figma/login_screen_actual.png'),
      );
    });
  });
}

/// Get the Flutter SDK root directory
String _flutterRoot() {
  // Try to get from environment
  final envRoot = Platform.environment['FLUTTER_ROOT'];
  if (envRoot != null && envRoot.isNotEmpty) {
    return envRoot;
  }

  // Try to find from dart executable path
  final dartExe = Platform.resolvedExecutable;
  // Dart is typically at: <flutter>/bin/cache/dart-sdk/bin/dart
  final parts = dartExe.split('/');
  final cacheIndex = parts.indexOf('cache');
  if (cacheIndex > 0) {
    return parts.sublist(0, cacheIndex - 1).join('/');
  }

  // Fallback - try common locations
  final home = Platform.environment['HOME'] ?? '';
  final possiblePaths = [
    '$home/fvm/versions/3.32.8',
    '$home/.fvm/flutter_sdk',
    '/usr/local/flutter',
    '$home/flutter',
  ];

  for (final path in possiblePaths) {
    if (Directory(path).existsSync()) {
      return path;
    }
  }

  return '/usr/local/flutter';
}
