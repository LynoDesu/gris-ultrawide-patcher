import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:gris_ultrawide_patcher/file_patcher.dart';

abstract class FileManager {
  Future<File?> pickGrisDll();
  Future<DllStatus> patchDll(File file, DllStatus statusToPatchTo);
}

class FileManagerImpl implements FileManager {
  @override
  Future<File?> pickGrisDll() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Choose UnityPlayer.dll",
      type: FileType.custom,
      allowedExtensions: ["dll"],
    );

    if (result != null) {
      return File(result.files.single.path!);
    } else {
      return null;
    }
  }

  @override
  Future<DllStatus> patchDll(File file, DllStatus statusToPatchTo) async {
    return await FilePatcher.patchGrisDll(file, statusToPatchTo);
  }
}
