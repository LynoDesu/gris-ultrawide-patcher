import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gris_ultrawide_patcher/main.dart';
import 'package:gris_ultrawide_patcher/file_patcher.dart';
import 'mock_file_manager.dart';

void main() {
  testWidgets('Displays all UI elements', (WidgetTester tester) async {
    // Use the MockFileManager with an unpatched file
    final mockFileManager = MockFileManager(
      fileToReturn: File('path/to/unpatched/UnityPlayer.dll'),
      dllStatusToReturn: DllStatus.unpatched,
    );

    await tester.pumpWidget(MyApp(fileManager: mockFileManager));

    // Verify that the main UI elements are displayed.
    expect(find.text('Select UnityPlayer.dll:'), findsOneWidget);
    expect(find.byType(TextButton), findsNWidgets(1));
    expect(find.text('Browse...'), findsOneWidget);
    expect(find.text('UnityPlayer.dll not loaded'), findsOneWidget);
    expect(find.byType(Row), findsNWidgets(1));
  });
}
