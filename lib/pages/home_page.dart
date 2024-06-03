import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  String? recordingPath;
  bool isRecording = false, isPlaying = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _recordingButton(),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          recordingPath != null
              ? MaterialButton(
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () async {
                    if (audioPlayer.playing) {
                      audioPlayer.stop();
                      setState(() {
                        isPlaying = false;
                      });
                    } else {
                      await audioPlayer.setFilePath(recordingPath!);
                      audioPlayer.play();
                      setState(() {
                        isPlaying = true;
                      });
                    }
                  },
                  child: Text(isPlaying ? "Stop PLaying Recording" : "Start Playing Recording", style: const TextStyle(color: Colors.white)))
              : const Text('No Recording  found'),
        ],
      ),
    );
  }

  Widget _recordingButton() {
    return FloatingActionButton(
      onPressed: () async {
        if (isRecording) {
          String? filepath = await audioRecorder.stop();
          if (filepath != null) {
            setState(() {
              isRecording = false;
              recordingPath = filepath;
            });
          }
        } else {
          if (await audioRecorder.hasPermission()) {
            final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
            final String filepath = p.join(appDocumentsDir.path, 'recording.wav');
            await audioRecorder.start(const RecordConfig(), path: filepath);
            setState(() {
              isRecording = true;
              recordingPath = null;
            });
          }
        }
      },
      child: Icon(isRecording ? Icons.stop : Icons.mic),
    );
  }
}
