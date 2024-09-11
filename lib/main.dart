import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'package:truth_frontend/dio.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sound Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder!.openRecorder();
    await _player!.openPlayer();
    await _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }
  }

  Future<void> _startRecording() async {
    Directory tempDir = await getTemporaryDirectory();
    _filePath = '${tempDir.path}/flutter_sound_example.wav';
    await _recorder!.startRecorder(
      toFile: _filePath,
      codec: Codec.pcm16WAV,
    );
  }

  String? transcription;

  Future<void> _stopRecording() async {
    await _recorder!.stopRecorder();
    transcription =
        await uploadFile("http://192.168.16.75:8000/upload", _filePath ?? "");
    setState(() {});
  }

  Future<void> _playRecording() async {
    if (_filePath != null) {
      await _player!.startPlayer(
        fromURI: _filePath,
        codec: Codec.aacADTS,
      );
    }
  }

  Future<void> _stopPlayback() async {
    await _player!.stopPlayer();
  }

  @override
  void dispose() {
    _recorder!.closeRecorder();
    _player!.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Sound Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (transcription != null) Text(transcription ?? ""),
            ElevatedButton(
              onPressed: _startRecording,
              child: Text('Start Recording'),
            ),
            ElevatedButton(
              onPressed: _stopRecording,
              child: Text('Stop Recording'),
            ),
            ElevatedButton(
              onPressed: _playRecording,
              child: Text('Play Recording'),
            ),
            ElevatedButton(
              onPressed: _stopPlayback,
              child: Text('Stop Playback'),
            ),
          ],
        ),
      ),
    );
  }
}
