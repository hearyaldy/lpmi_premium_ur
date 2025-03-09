import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/audio_player_service.dart';

class AudioControlsWidget extends StatefulWidget {
  final String url;
  final String title;
  final AudioPlayerService audioPlayerService;
  final ValueNotifier<bool> isPlayingNotifier;

  const AudioControlsWidget({
    super.key,
    required this.url,
    required this.title,
    required this.audioPlayerService,
    required this.isPlayingNotifier,
  });

  @override
  _AudioControlsWidgetState createState() => _AudioControlsWidgetState();
}

class _AudioControlsWidgetState extends State<AudioControlsWidget> {
  @override
  void initState() {
    super.initState();
    widget.isPlayingNotifier.addListener(() {
      setState(() {});
    });
  }

  Future<void> _checkPermissionsAndPlay() async {
    if (await widget.audioPlayerService.requestStoragePermission()) {
      _togglePlayPause();
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Storage Permission Required"),
        content: const Text(
          "Storage permission is required to download and play audio files. "
          "Please enable it in app settings.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayPause() async {
    try {
      await widget.audioPlayerService.playOrPause(widget.url, widget.title);
      widget.isPlayingNotifier.value = widget.audioPlayerService.isPlaying;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _downloadAudio() async {
    try {
      await widget.audioPlayerService.download(widget.url, widget.title);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Download complete!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading file: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            widget.isPlayingNotifier.value ? Icons.pause : Icons.play_arrow,
          ),
          tooltip: widget.isPlayingNotifier.value ? 'Pause' : 'Play',
          onPressed: _checkPermissionsAndPlay,
        ),
        IconButton(
          icon: const Icon(Icons.download),
          tooltip: 'Download',
          onPressed: _downloadAudio,
        ),
      ],
    );
  }

  @override
  void dispose() {
    widget.isPlayingNotifier.removeListener(() {});
    super.dispose();
  }
}
