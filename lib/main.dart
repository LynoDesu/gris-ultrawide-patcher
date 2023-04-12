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
  File? _file;
  DllStatus _dllStatus = DllStatus.notLoaded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            buildSelectText(),
            TextButton(
              onPressed: () => _pickGrisDll(),
              child: const Text("Browse..."),
            ),
            buildStatus(),
            buildOptions(),
          ],
        ),
      ),
    );
  }

  Text buildSelectText() {
    String selectText = "Select UnityPlayer.dll:";

    if (_file != null && _file!.existsSync()) {
      selectText = "${_file!.path} selected.";
    }

    return Text(selectText);
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
      // User cancelled the picker
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
        statusText = "UnityPlayer.dll is patched with 2560x1080 resolution";
        break;
      case DllStatus.patched1440:
        statusText = "UnityPlayer.dll is patched with 3440x1440 resolution";
        break;
      default:
        statusText =
            "Unable to determine status of UnityPlayer.dll. Is this the correct file?";
        break;
    }

    List<Widget> widgets = [
      Flexible(child: Wrap(children: [Text(statusText)]))
    ];

    if ([DllStatus.unpatched, DllStatus.patched1080, DllStatus.patched1440]
        .contains(_dllStatus)) {
      widgets.add(
        const Icon(
          Icons.done_rounded,
          color: Colors.green,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widgets,
      ),
    );
  }

  Widget buildOptions() {
    Widget options = const Spacer();

    if ([DllStatus.patched1080, DllStatus.patched1440, DllStatus.unpatched]
        .contains(_dllStatus)) {
      options = Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton(
            onPressed: _dllStatus == DllStatus.unpatched
                ? null
                : () async => patchDll(DllStatus.unpatched),
            child: const Text("Revert to widescreen"),
          ),
          TextButton(
            onPressed: _dllStatus == DllStatus.patched1080
                ? null
                : () async => patchDll(DllStatus.patched1080),
            child: const Text("Enable 2560x1080"),
          ),
          TextButton(
            onPressed: _dllStatus == DllStatus.patched1440
                ? null
                : () async => patchDll(DllStatus.patched1440),
            child: const Text("Enable 3440x1440"),
          ),
        ],
      );
    }

    return options;
  }

  Future<void> patchDll(DllStatus statusToPatchTo) async {
    _dllStatus = await FilePatcher.patchGrisDll(_file!, statusToPatchTo);

    setState(() {
      _dllStatus;
    });
  }
}
