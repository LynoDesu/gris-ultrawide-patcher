import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:gris_ultrawide_patcher/file_patcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Window.initialize();
  await Window.setEffect(
    effect: WindowEffect.aero,
    color: Colors.black.withOpacity(0.3),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late File _file;
  DllStatus _dllStatus = DllStatus.notLoaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Select UnityPlayer.dll:"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //TextField(),
                TextButton(
                  onPressed: () => _pickGrisDll(),
                  child: const Text("Browse..."),
                ),
              ],
            ),
            buildStatus(),
          ],
        ),
      ),
    );
  }

  Future<void> _pickGrisDll() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Choose UnityPlayer.dll",
      type: FileType.custom,
      allowedExtensions: ["dll"],
    );

    if (result != null) {
      _file = File(result.files.single.path!);

      _dllStatus = await FilePatcher.getFileStatus(_file);

      setState(() {
        _dllStatus;
      });
    } else {
      // User canceled the picker
    }
  }

  Widget buildStatus() {
    String statusText;

    switch (_dllStatus) {
      case DllStatus.notLoaded:
        statusText = "UnityPlayer.dll not loaded";
        break;
      case DllStatus.unpatched:
        statusText = "UnityPlayer.dll is ready for ultra-wide patching!";
        break;
      case DllStatus.patched1080:
        statusText =
            "UnityPlayer.dll appears to be patched with 2560x1080 resolution";
        break;
      case DllStatus.patched1440:
        statusText =
            "UnityPlayer.dll appears to be patched with 3440x1440 resolution";
        break;
      default:
        statusText =
            "Unable to determine status of UnityPlayer.dll. Is this the correct file?";
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(statusText),
    );
  }
}
