import 'dart:io';
import 'dart:typed_data';

import 'package:gris_ultrawide_patcher/file_patcher.dart';
import 'package:test/test.dart';
import 'package:test_process/test_process.dart';

void main() {
  group('FilePatcher', () {
    File? testFile;
    String testFilePath = "";

    setUp(() async {
      // Create a temporary file for testing
      testFilePath =
          '${Directory.systemTemp.path}/test_file_${DateTime.now().millisecondsSinceEpoch}.bin';
      testFile = File(testFilePath);
      await testFile!.writeAsBytes(Uint8List.fromList(
          [0x39, 0x8E, 0xE3, 0x3F, 0x01, 0x02, 0x03, 0x39, 0x8E, 0xE3, 0x3F]));
    });

    tearDown(() async {
      // Delete the temporary file after each test
      if (await testFile!.exists()) {
        await testFile!.delete();
      }
    });

    test('containsTargetBytes', () {
      Uint8List fileBytes = testFile!.readAsBytesSync();
      expect(
          FilePatcher.containsTargetBytes(
              fileBytes, Uint8List.fromList(FilePatcher.originalValues)),
          isTrue);
    });

    test('replaceByteSequence', () async {
      await FilePatcher.patchDll(
          testFilePath, FilePatcher.originalValues, FilePatcher.x1440Values);
      Uint8List updatedFileBytes = await testFile!.readAsBytes();
      expect(
          FilePatcher.containsTargetBytes(
              updatedFileBytes, Uint8List.fromList(FilePatcher.x1440Values)),
          isTrue);
    });

    test('getFileStatus', () async {
      expect(await FilePatcher.getFileStatus(testFile),
          equals(DllStatus.unpatched));
    });

    test('patchGrisDll', () async {
      await FilePatcher.patchGrisDll(testFile!, DllStatus.patched1440);
      expect(await FilePatcher.getFileStatus(testFile),
          equals(DllStatus.patched1440));
    });
  });
}
