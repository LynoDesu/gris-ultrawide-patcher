import 'dart:io';
import 'package:gris_ultrawide_patcher/file_patcher.dart';
import 'package:gris_ultrawide_patcher/file_manager.dart';

class MockFileManager extends FileManager {
  final File fileToReturn;
  final DllStatus dllStatusToReturn;

  MockFileManager(
      {required this.fileToReturn, required this.dllStatusToReturn});

  @override
  Future<File?> pickGrisDll() async {
    return fileToReturn;
  }

  @override
  Future<DllStatus> patchDll(File file, DllStatus statusToPatchTo) {
    // TODO: implement patchDll
    throw UnimplementedError();
  }
}
