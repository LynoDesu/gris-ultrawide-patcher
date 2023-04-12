import 'dart:io';
import 'dart:typed_data';

class FilePatcher {
  static final List<int> originalValues = [0x39, 0x8E, 0xE3, 0x3F];
  static final List<int> x1080Values = [0x26, 0xB4, 0x17, 0x40];
  static final List<int> x1440Values = [0x8E, 0xE3, 0x18, 0x40];

  static final Map patchValues = {
    DllStatus.unpatched: originalValues,
    DllStatus.patched1080: x1080Values,
    DllStatus.patched1440: x1440Values,
  };

  static Future<void> patchDll(String filePath, List<int> valuesToReplace,
      List<int> replacementValues) async {
    // The target hex string (byte sequence) to search for
    Uint8List targetBytes = Uint8List.fromList(valuesToReplace);

    // The replacement hex string (byte sequence)
    Uint8List replacementBytes = Uint8List.fromList(replacementValues);

    // Read the file into a Uint8List
    Uint8List fileBytes = await File(filePath).readAsBytes();

    // Check if the targetBytes exist in the file
    bool targetBytesExist = containsTargetBytes(fileBytes, targetBytes);

    if (targetBytesExist) {
      // Replace the target byte sequence with the replacement byte sequence
      Uint8List updatedFileBytes =
          replaceByteSequence(fileBytes, targetBytes, replacementBytes);

      // Write the updated Uint8List back to the file
      await File(filePath).writeAsBytes(updatedFileBytes);

      print('Replacement complete!');
    } else {
      print('Target bytes not found in the file.');
    }
  }

  static Uint8List replaceByteSequence(
      Uint8List input, Uint8List target, Uint8List replacement) {
    int targetLength = target.length;
    int inputLength = input.length;

    // Using BytesBuilder to create a new byte sequence efficiently
    BytesBuilder bytesBuilder = BytesBuilder();

    for (int i = 0; i < inputLength;) {
      if (i <= inputLength - targetLength &&
          _compareUint8List(input, target, i, targetLength)) {
        bytesBuilder.add(replacement);
        i += targetLength;
      } else {
        bytesBuilder.addByte(input[i]);
        i++;
      }
    }

    return bytesBuilder.takeBytes();
  }

  static bool containsTargetBytes(Uint8List input, Uint8List target) {
    int targetLength = target.length;
    int inputLength = input.length;

    for (int i = 0; i <= inputLength - targetLength; i++) {
      if (_compareUint8List(input, target, i, targetLength)) {
        return true;
      }
    }

    return false;
  }

  static bool _compareUint8List(
      Uint8List a, Uint8List b, int offset, int length) {
    for (int i = 0; i < length; i++) {
      if (a[offset + i] != b[i]) return false;
    }
    return true;
  }

  static Future<DllStatus> getFileStatus(File? file) async {
    DllStatus dllStatus = DllStatus.notLoaded;

    if (file != null) {
      Uint8List fileBytes = await file.readAsBytes();
      dllStatus = DllStatus.unknown;

      if (FilePatcher.containsTargetBytes(
          fileBytes, Uint8List.fromList(FilePatcher.originalValues))) {
        dllStatus = DllStatus.unpatched;
      } else if (FilePatcher.containsTargetBytes(
          fileBytes, Uint8List.fromList(FilePatcher.x1080Values))) {
        dllStatus = DllStatus.patched1080;
      } else if (FilePatcher.containsTargetBytes(
          fileBytes, Uint8List.fromList(FilePatcher.x1440Values))) {
        dllStatus = DllStatus.patched1440;
      }
    }

    return dllStatus;
  }

  static Future<DllStatus> patchGrisDll(
      File file, DllStatus statusToPatchTo) async {
    DllStatus currentStatus = await getFileStatus(file);

    if (currentStatus == statusToPatchTo) {
      // Already in the status we want to patch to!
      return currentStatus;
    }

    var patchFromValues = patchValues[currentStatus];
    var patchToValues = patchValues[statusToPatchTo];

    if (currentStatus == DllStatus.unpatched &&
        !await File("${file.path}.bak").exists()) {
      print("Creating backup file: ${file.path}.bak");

      try {
        await file.copy("${file.path}.bak");
      } on Exception catch (e) {
        print("Error creating backup: \n $e");
      }
    }

    await patchDll(file.path, patchFromValues, patchToValues);

    return await getFileStatus(file);
  }
}

enum DllStatus {
  notLoaded,
  unpatched,
  patched1080,
  patched1440,
  unknown,
}
